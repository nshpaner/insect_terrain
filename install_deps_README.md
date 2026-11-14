# Environment \& Dependency Setup

This project uses [`renv`](https://rstudio.github.io/renv/) to ensure reproducible package versions across machines, along with built-in safeguards to handle binary installation and source-compilation errors smoothly.

## Required R Packages

* `readr` — Data import
* `ggplot2` — Data visualization (configured with binary fallbacks)
* `knitr` — Knitting output format
* `rmarkdown` — RMarkdown features
* `forcats` — Categorical factor ordering
* `dplyr` — Data manipulation
* `tidyr` — Data reshaping
* `indicspecies` — Indicator species analysis
* `vegan` — Community ecology and NMDS ordination

\---

## Option 1: Restore from `renv.lock`

If you are cloning this repository and `renv.lock` is already present:

1. Open the project `.Rproj` file in RStudio.
2. Run the following in the R console:

```r
   if (!requireNamespace("renv", quietly = TRUE)) {
     install.packages("renv")
   }
   renv::restore()
   ```

3. Confirm the prompt to install the exact package versions recorded in `renv.lock`.

\---

## Option 2: Fresh Environment Setup

If you are setting up the environment from scratch or updating dependencies, `install\_deps.R` includes automated safeguards:

1. Open the project `.Rproj` file in RStudio.
2. Initialize a bare `renv` project (if not already initialized):

```r
   if (!requireNamespace("renv", quietly = TRUE)) {
     install.packages("renv")
   }
   renv::init(bare = TRUE)
   ```

3. Run the dependency installer script:

```r
   source("install\_deps.R")
   ```

### Built-in Safeguards in `install\_deps.R`:

* **Posit Package Manager (RSPM) Binaries:** The script automatically points your R session to pre-compiled CRAN binaries (`packagemanager.posit.co/cran/latest`). This eliminates the need for complex system-level `-dev` libraries (like `libfontconfig1-dev`) when compiling packages like `ggplot2` on Linux/Ubuntu.
* **Graceful Fallback Loop:** If a bulk installation attempt encounters an error, the script automatically catches it via `tryCatch` and cycles through missing packages individually, warning you if any specific package needs manual attention instead of crashing the entire script.

