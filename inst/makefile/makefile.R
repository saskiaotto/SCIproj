#
# ################ MASTER SCRIPT TEMPLATE TO IMPROVE WORKFLOW ###############
#
# # For a more sophisticated approach consider using the pipeline toolkit
# # 'targets' (https://docs.ropensci.org/targets/) for a reproducible workflow!
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
# # render R Markdown or Quarto files
# rmarkdown::render("analyses/time_series_analysis.Rmd")
# # quarto::quarto_render("analyses/time_series_analysis.qmd")
#
#
# # Render publication-ready documents -----------------
# rmarkdown::render("docs/paper/paper.Rmd")
# rmarkdown::render("docs/presentations/presentation.Rmd")
# # quarto::quarto_render("docs/paper/paper.qmd")
#
