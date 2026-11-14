# Required packages for insect_analysis.R
required_packages <- c(
  "here",
  "readr",
  "rmarkdown",
  "knitr",
  "ggplot2",
  "forcats",
  "dplyr",
  "tidyr",
  "indicspecies", # For additional, in-depth visuals
  "vegan"         # For additional, in-depth visuals
)

# Enforce Posit Package Manager (RSPM) for fast, pre-compiled binaries
# This prevents source-compilation errors on Linux/Ubuntu and speeds up installs
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

# Identify any missing packages
installed_pkgs <- installed.packages()[, "Package"]
missing_packages <- required_packages[!(required_packages %in% installed_pkgs)]

if (length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  
  # Primary installation attempt using renv (if active) or standard install
  install_success <- tryCatch({
    if (requireNamespace("renv", quietly = TRUE) && !is.null(renv::project())) {
      renv::install(missing_packages, prompt = FALSE)
    } else {
      install.packages(missing_packages)
    }
    TRUE
  }, error = function(e) {
    message("Primary bulk installation hit an error: ", e$message)
    FALSE
  })
  
  # Fallback safeguard: If bulk install failed, try installing one-by-one
  if (!install_success) {
    message("Running fallback safeguard: Installing packages individually...")
    for (pkg in missing_packages) {
      tryCatch({
        message("-> Attempting to install: ", pkg)
        if (requireNamespace("renv", quietly = TRUE) && !is.null(renv::project())) {
          renv::install(pkg, prompt = FALSE)
        } else {
          install.packages(pkg)
        }
      }, error = function(inner_e) {
        warning("Warning: Could not automatically install '", pkg, "'. Error: ", inner_e$message)
      })
    }
  }
  
} else {
  message("All required packages are already installed.")
}

# Snapshot environment safely if renv is active
if (requireNamespace("renv", quietly = TRUE) && !is.null(renv::project())) {
  tryCatch({
    renv::snapshot(prompt = FALSE)
  }, error = function(e) {
    message("renv snapshot note: ", e$message)
  })
}