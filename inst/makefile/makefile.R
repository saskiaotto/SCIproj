#
# ################ MASTER SCRIPT TEMPLATE TO IMPROVE WORKFLOW ###############
#
# # Consider also using the pipeline toolkit 'targets' for a reproducible workflow!
#
# # Package loading ---------------------
# # (needed if you have written your own functions in R/)
# library("your_project_name")
#
# # Data pre-processing -----------------
# # Source the cleaning script template or your own
# source("data-raw/clean_data.R")
#
# # Data post-processing/analyses -----------------
#
# # source R scripts
# source("analyses/data_exploration.R")
# # render R Markdown files
# rmarkdown::render("analyses/time_series_analysis.Rmd")
#
#
# # Render publication-ready documents -----------------
# rmarkdown::render("docs/paper/PNAS_paper.Rmd")
# rmarkdown::render("docs/presentations/user_conf21.Rmd")
#
#
