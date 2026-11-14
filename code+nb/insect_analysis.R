# ==============================================================================
# Burrow-Created Bare Soil Mounds on Insect Density in Vernal Pools:
# Data Visualization and Analysis

# Authors: Nick Shpaner, Xochtil Camacho, Alan Love
# ==============================================================================

# Load in relevant packages
library(readr)
library(ggplot2)
library(forcats)
library(dplyr)
library(tidyr)
library(indicspecies)
library(vegan)

# Create output folder for results if it doesn't already exist
dir.create("results_insects", showWarnings = FALSE)

# Load in our dataset and assign it to a variable name
bugs_full <- read_csv(here::here("data", "study_spreadsheet.csv"), show_col_types = FALSE)

# Use only relevant columns
bugs <- bugs_full[bugs_full$`Should data be used for count` == "Yes", ]
bugs

# Visualize Data
bugs_bar <- ggplot(bugs, aes(x = fct_infreq(`Insect Group`))) +
  geom_bar(fill = "darkorchid4") + 
  geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5) +
  theme_minimal() +
  labs(title = "Total Insect Distribution", 
       x = "Insect Group", 
       y = "Number of Insects Found") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  expand_limits(y = 10)

print(bugs_bar)
ggsave("results_insects/total_insect_distribution.png", bugs_bar, width = 8, height = 6, dpi = 300)

# Condense Data and Run Statistical Test (Chi Squared)
site_type_counts_table <- table(bugs$`Insect Group`, bugs$`Site Type`)
print(site_type_counts_table)

# Save summary table
write_csv(as.data.frame(site_type_counts_table), "results_insects/site_type_counts_table.csv")

bugs_chisq_test_results = chisq.test(site_type_counts_table)
print(bugs_chisq_test_results)

# Visualize the Test Results (Chi Squared)
df_site_type_counts <- as.data.frame(site_type_counts_table)
colnames(df_site_type_counts) <- c("InsectGroup", "SiteType", "Count")

df_site_type_counts$PlotCount <- ifelse(df_site_type_counts$SiteType == "Control", 
                                        -df_site_type_counts$Count, 
                                        df_site_type_counts$Count)

chisq_results_bar = ggplot(df_site_type_counts, aes(x = reorder(InsectGroup, Count), y = PlotCount, fill = SiteType)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = abs(PlotCount)), 
            hjust = ifelse(df_site_type_counts$SiteType == "Control", 1.2, -0.2), 
            size = 3) +
  coord_flip() +
  scale_y_continuous(labels = abs, limits = c(-max(df_site_type_counts$Count) - 2, max(df_site_type_counts$Count) + 2)) +
  scale_fill_manual(values = c("Control" = "gray70", "Experimental" = "darkorchid4")) +
  theme_minimal() +
  labs(title = "Insect Distribution: Control vs. Experimental",
       subtitle = "Chi Squared Test: X^2 = 58.939, p-value = 1.799 × 10-7",
       x = "Insect Group",
       y = "Count (Control ← | → Experimental)",
       fill = "Site Type") +
  geom_hline(yintercept = 0, color = "black")

print(chisq_results_bar)
ggsave("results_insects/chisq_results_bar.png", chisq_results_bar, width = 8, height = 6, dpi = 300)

# Condense Data and Run Statistical Test (Permutation Test)
perm_test <- chisq.test(site_type_counts_table, simulate.p.value = TRUE, B = 10000)
print(perm_test)

# Example: Testing if "Beetles" are significantly different between sites
obs_diff <- sum(bugs$`Insect Group` == "Beetle" & bugs$`Site Type` == "Experimental") - 
  sum(bugs$`Insect Group` == "Beetle" & bugs$`Site Type` == "Control")

set.seed(123)
null_diffs <- replicate(5000, {
  shuffled_sites <- sample(bugs$`Site Type`)
  sum(bugs$`Insect Group` == "Beetle" & shuffled_sites == "Experimental") - 
    sum(bugs$`Insect Group` == "Beetle" & shuffled_sites == "Control")
})

print(mean(abs(null_diffs) >= abs(obs_diff)))

# Visualize the Test Results (Permutation Test)
obs_stat <- suppressWarnings(chisq.test(table(bugs$`Insect Group`, bugs$`Site Type`))$statistic)

set.seed(123)
sim_stats <- replicate(10000, {
  shuffled_sites <- sample(bugs$`Site Type`)
  suppressWarnings(chisq.test(table(bugs$`Insect Group`, shuffled_sites))$statistic)
})

null_dist_df <- data.frame(stat = as.numeric(sim_stats))

perm_dist_plot <- ggplot(null_dist_df, aes(x = stat)) +
  geom_histogram(bins = 50, fill = "gray80", color = "white") +
  geom_vline(xintercept = obs_stat, color = "darkorchid4", 
             linewidth = 1.2, linetype = "dashed") +
  annotate("text", x = obs_stat, y = 500, 
           label = paste("Actual Result:", round(obs_stat, 2)), 
           color = "darkorchid4", angle = 90, vjust = -0.5) +
  theme_minimal() +
  labs(title = "Permutation Test: Null Distribution (10k Shuffles)",
       subtitle = "Simulating trials to test if our X^2 test result was a product of randomness.",
       x = "Chi-squared Statistic",
       y = "Frequency")

print(perm_dist_plot)
ggsave("results_insects/permutation_null_distribution.png", perm_dist_plot, width = 8, height = 6, dpi = 300)

# Visualize the Residuals
res <- perm_test$residuals

res_bugs <- as.data.frame(res)
colnames(res_bugs) <- c("InsectGroup", "SiteType", "Residual")
write_csv(res_bugs, "results_insects/pearson_residuals_table.csv")

res_plot <- ggplot(res_bugs, aes(x = reorder(InsectGroup, Residual), y = Residual, fill = SiteType)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  scale_fill_manual(values = c("Control" = "gray70", "Experimental" = "darkorchid4")) +
  theme_minimal() +
  labs(title = "Which insects drive the difference?",
       subtitle = "Values > 2 or < -2 are the main reasons WHY the p-value is so small",
       x = "Insect Group",
       y = "Pearson Residual (Deviation from Expected)") +
  geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "red", alpha = 0.5)

print(res_plot)
ggsave("results_insects/pearson_residuals_plot.png", res_plot, width = 8, height = 6, dpi = 300)

# Bootstrapping (Insect Group vs Site Type)
set.seed(42)
all_boot_results <- replicate(2000, {
  boot_sample <- bugs[sample(nrow(bugs), replace = TRUE), ]
  as.data.frame(table(boot_sample$`Insect Group`, boot_sample$`Site Type`))
}, simplify = FALSE) %>% bind_rows()

all_boot_summary <- all_boot_results %>%
  group_by(Var1, Var2) %>%
  summarize(
    MeanCount = mean(Freq),
    Lower = quantile(Freq, 0.025),
    Upper = quantile(Freq, 0.975),
    .groups = "drop"
  )
colnames(all_boot_summary) <- c("InsectGroup", "SiteType", "MeanCount", "Lower", "Upper")
write_csv(all_boot_summary, "results_insects/bootstrapped_summary_table.csv")

boot_plot <- ggplot(all_boot_summary, aes(x = SiteType, y = MeanCount, fill = SiteType)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.3) +
  facet_wrap(~ InsectGroup, scales = "free_y") + 
  scale_fill_manual(values = c("Control" = "gray70", "Experimental" = "darkorchid4")) +
  theme_light() +
  labs(title = "Bootstrapped Insect Counts across All Groups",
       subtitle = "Error bars represent 95% Confidence Intervals from 2,000 resamples",
       x = "Site Type",
       y = "Mean Count") +
  theme(legend.position = "none")

print(boot_plot)
ggsave("results_insects/bootstrapped_counts_plot.png", boot_plot, width = 10, height = 6, dpi = 300)

# Misc EXPERIMENTAL (Insect Group vs Site Type)
wide_bugs <- bugs %>%
  group_by(`Site #`, `Site Type`, `Insect Group`) %>%
  tally() %>%
  pivot_wider(names_from = `Insect Group`, values_from = n, values_fill = 0)

inv = multipatt(wide_bugs[, -c(1,2)], wide_bugs$`Site Type`, 
                func = "r.g", control = how(nperm=999))

print(summary(inv))

dist_matrix <- vegdist(wide_bugs[, -c(1,2)], method = "bray")
nmds_results <- metaMDS(dist_matrix, k = 2)

# Save NMDS plot using a graphics device and render inline
png("results_insects/nmds_plot.png", width = 800, height = 600, res = 100)
plot(nmds_results, display = "sites", type = "n")
points(nmds_results, display = "sites", 
       col = ifelse(wide_bugs$`Site Type` == "Experimental", "darkorchid4", "gray"), 
       pch = 16)
ordiellipse(nmds_results, wide_bugs$`Site Type`, label = TRUE)
dev.off()

# Re-run plot so it renders in the notebook interface
plot(nmds_results, display = "sites", type = "n")
points(nmds_results, display = "sites", 
       col = ifelse(wide_bugs$`Site Type` == "Experimental", "darkorchid4", "gray"), 
       pch = 16)
ordiellipse(nmds_results, wide_bugs$`Site Type`, label = TRUE)