# _targets.R
# Pipeline definition for the 'targets' workflow toolkit.
# See https://books.ropensci.org/targets/ for the user manual.
#
# Run the pipeline:   targets::tar_make()
# Visualise targets:  targets::tar_visnetwork()

# 1. Load packages needed to define the pipeline
library(targets)
# library(tarchetypes) # Uncomment for tar_render(), tar_quarto(), etc.

# 2. Source all functions in R/
#    tar_source() recursively sources all .R files in R/.
#    Keep only function definitions there (no scripts or side effects).
tar_source()

# 3. Set target-specific options (packages needed at runtime)
tar_option_set(packages = c("your_project_name"))

# 4. Define the pipeline
list(
  # --- Data pre-processing ---
  # Track input files with format = "file" so the pipeline detects changes.
  # tar_target(raw_data_file, "data-raw/your_data.csv", format = "file"),
  # tar_target(raw_data, read.csv(raw_data_file)),
  # tar_target(clean_data, clean_raw_data(raw_data)),

  # --- Analyses ---
  # tar_target(model, fit_model(clean_data)),
  # tar_target(summary_table, summarise_results(model)),

  # --- Reports ---
  # tarchetypes::tar_render(report, "docs/report.Rmd")
  # tarchetypes::tar_quarto(report, "docs/report.qmd")
)

# Note: The _targets/ data store can become very large.
# It is already listed in .Rbuildignore. Make sure it is
# also in your .gitignore (usethis::use_git_ignore("_targets")).
