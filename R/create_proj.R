#' Create new data analysis project as R package
#'
#' Create all the scaffolding for a new project in a new directory. The scaffolding includes a README file, different folders to hold raw data, analyses, etc, and optionally also \code{testthat} infrastructure. Also, optionally, set a private or public GitHub repo with continuous integration (Travis-CI, GitHub Actions...).
#'
#' @param name Character. Name of the new project. Could be a path, e.g. \code{"~/myRcode/newproj"}. A new folder will be created with that name.
#' @param data_raw Logical. If TRUE, adds a 'data-raw' folder for all the raw data files, including a 'clean_data.R' script file for generating
#'        clean datasets from the raw files that are then saved in the 'data' folder.
#' @param makefile Logical. If TRUE, adds a template \code{makefile.R} file to the project.
#' @param testthat Logical. Add testthat infrastructure?
#' @param use_pipe Logical. Use magrittr's pipe in your package?
#' @param add_license Character. Use magrittr's pipe in your package?
#' @param license_holder Character. If you want to use a license than replace 'Your name' with your own name.
#' @param create_github_repo Logical. Create GitHub repository? Note this requires some working infrastructure like \code{git} and a \code{GITHUB_PAT}. See instructions here \url{https://usethis.r-lib.org/articles/articles/usethis-setup.html}.
#' @param private_repo Logical. Default is TRUE.
#' @param ci Logical. Use continuous integration in your GitHub repository? Current options are "none" (default), "travis" (uses Travis-CI), "circle" (uses Circle-CI), "appveyor" (uses AppVeyor), or "gh-actions" (uses GitHub Actions).
#' @param open_proj Logical. If TRUE (the default) will open the newly created Rstudio project in a new session.
#' @param verbose Logical. Print verbose output in the console while creating the new project? Default is FALSE.
#'
#' @return A new directory with a slightly modified R package structure.
#' @export
#' @details If using github = TRUE, you will be asked if you want to commit some files. Reply positively to continue.
#'
#' @examples
#' \dontrun{
#' library("SCIproj")
#' create_proj("myproject")
#' create_proj("myproject", github = TRUE, private.repo = TRUE)
#' }
create_proj <- function(name,
  data_raw = TRUE, makefile = FALSE, testthat = FALSE,
  use_pipe = TRUE, add_license = NULL, license_holder = "Your name",
  create_github_repo = FALSE, private_repo = TRUE, ci = "none",
  open_proj = TRUE, verbose = FALSE){

  if (!isTRUE(verbose)) {
    options(usethis.quiet = TRUE)
  }

  usethis::create_package(name, open = FALSE)
  usethis::proj_set(name, force = TRUE)

  # usethis::use_package_doc()
  usethis::use_readme_rmd(open = FALSE)

  # Create folders and template files
  dir.create(file.path(name, "data"))
  dir.create(file.path(name, "analyses"))
  dir.create(file.path(name, "analyses/figures"))
  file.copy(from = system.file("analyses", "README.md", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "analyses") )
  dir.create(file.path(name, "docs"))
  file.copy(from = system.file("docs", "README.md", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "docs"))
  file.copy(from = system.file("for-r", "function_ex.R", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "R"))
  file.copy(from = system.file("for-r", "data.R", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "R"))
  dir.create(file.path(name, "trash"))

  # Exclude created folders from build file
  usethis::use_build_ignore(c("analyses", "docs", "trash"))

  # Add the raw data folder
  if (isTRUE(data_raw)) {
    usethis::use_data_raw(open = FALSE)
    # Remove default DATASET.R file and replace after with my clean_data.R file
    file.remove(file.path(usethis::proj_get(), "data-raw/DATASET.R"))
    file.copy(from = system.file("data-raw", "clean_data.R", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "data-raw") )
    file.copy(from = system.file("data-raw", "README.md", package = "SCIproj"),
              to = file.path(usethis::proj_get(), "data-raw") )
    usethis::use_build_ignore("data-raw")
  }

  # Add makefile.R
  if (isTRUE(makefile)) {
    file.copy(from = system.file("makefile", "makefile.R", package = "SCIproj"),
              to = usethis::proj_get())
    usethis::use_build_ignore("makefile.R")
  }

  # Set up testing infrastructure
  if (isTRUE(testthat)) {
    usethis::use_testthat()
  }

  # Use magrittr's pipe in package
  if (isTRUE(use_pipe)) {
    usethis::use_pipe()
  }

  # Add license
  if (!is.null(add_license)) {

    if (add_license == "MIT") {
      usethis::use_mit_license(name = license_holder)
    }
    if (add_license == "CCBY") {
      usethis::use_ccby_license(name = license_holder)
    }
    if (add_license == "CC0") {
      usethis::use_cc0_license(name = license_holder)
    }
    if (add_license == "GPL") {
      usethis::use_gpl3_license(name = license_holder)
    }
    if (add_license == "AGPL") {
      usethis::use_agpl3_license(name = license_holder)
    }
    if (add_license == "LGPL") {
      usethis::use_lgpl_license(name = license_holder)
    }
    if (add_license == "Apache") {
      usethis::use_apl2_license(name = license_holder)
    }

  }

  # Link to GitHub repo
  if (isTRUE(create_github_repo)) {

    # Initialise a git repository
    usethis::use_git()
    usethis::use_github(private = private_repo)

    ## Add continuous integration services
    stopifnot(ci %in% c("none", "travis", "gh-actions", "circle", "appveyor"))
    if (ci == "travis") {
      usethis::use_travis()
      #usethis::use_travis_badge()
    }
    if (ci == "gh-actions") {
      usethis::use_github_actions()
      # usethis::use_github_action_check_release()
      #usethis::use_github_actions_badge()
    }
    if (ci == "circle") {
      usethis::use_circleci()
    }
    if (ci == "appveyor") {
      usethis::use_appveyor()
    }

  }

  # Open Rstudio project in new session at the end?
  if (isTRUE(open_proj)) {
    if (rstudioapi::isAvailable()) {
      rstudioapi::openProject(name, newSession = TRUE)
    }
  }


}
