# Burrow-Created Bare Soil Mounds on Insect Density in Vernal Pools

**Authors:** Nick Shpaner, Xochtil Camacho, Alan Love

R Version: 4.6.1 | IDE: RStudio

## Overview

This repository contains the data visualization, statistical analysis, and exploratory community ecology code investigating the effect of burrow-created bare soil mounds on insect density and community composition in vernal pools.

## Repository Structure

```text
├── data/
│   ├── study_spreadsheet.csv              # Raw dataset
│   └── study_spreadsheet_codebook.xlsx    # Dataset codebook
├── code+nb/
│   ├── results_insects/                   # Generated summary CSVs and visualizations (ignored by git)
│   ├── insect_terrain_nb.qmd              # Quarto notebook containing the full narrative and analysis
│   ├── insect_analysis.R                  # Standalone R script for running the analysis and exporting results
│   └── install_deps.R                     # Dependency installation and renv snapshot script
├── renv.lock                              # Package version lockfile for reproducibility
├── LICENSE.txt                            # MIT License
└── README.md                              # Project overview and usage instructions
```

## Quick Start

1. **Clone the repository** and open the `.Rproj` file in RStudio so your working directory is anchored to the project root.
2. **Set up dependencies:** Follow the instructions in `install_deps_README.md` to restore the `renv` environment or run `install_deps.R`.
3. **Verify dataset:** The data, `study_spreadsheet.csv`, is already provided inside the `data` folder at the project root. Make sure it's formatted correctly and all entries are present (679 rows, 14 columns).
4. **Run the analysis:**
   * Execute `source("insect_analysis.R")` in the R console to generate all summary tables and figures in `results_insects`, **or**
   * Open and render `insect_terrain_nb.qmd` in RStudio/Quarto to view the inline analysis.

## Statistical Methods Included

* **Distribution and EDA:** Overall `Insect Group` frequency distribution
* **Chi-Squared and Residual Analysis:** Testing site-type differences (`Control` vs. `Experimental`) and identifying the most explanatory taxa using Pearson residuals
* **Permutation Testing:** Non-parametric significance testing (10,000 shuffles) for the overall Chi-squared statistic and targeted taxon comparisons
* **Bootstrapping:** 2,000-resample estimation of mean counts and 95% confidence intervals across all Insect Groups
* **Community Ecology (Exploratory):** Indicator species analysis (`indicspecies::multipatt`) and Non-metric Multidimensional Scaling (`vegan::metaMDS` with Bray-Curtis dissimilarity)

## License

This project is licensed under the MIT License — see `LICENSE.txt` for details.