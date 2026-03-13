#' Create new data analysis project as R package
#'
#' Create all the scaffolding for a new project in a new directory. The
#' scaffolding includes a README file, different folders to hold raw data,
#' analyses, etc, a \code{_targets.R} pipeline template,
#' \href{https://rstudio.github.io/renv/}{renv} dependency management,
#' and a \code{CITATION.cff} file. Optionally, initialize a git repository
#' and/or set up a private or public GitHub repo with GitHub Actions CI.
#'
#' @param name Character. Name of the new project. Could be a path, e.g.
#'   \code{"~/myRcode/newproj"}. A new folder will be created with that name.
#'   The directory name can contain underscores or hyphens (e.g.
#'   \code{"my_project"}) — these will be automatically converted to dots
#'   for the internal R package name (e.g. \code{my.project} in DESCRIPTION).
#' @param data_raw Logical. If TRUE (default), adds a \code{data-raw/} folder
#'   for all the raw data files, including a \code{clean_data.R} script file for
#'   generating clean datasets, a \code{DATA_SOURCES.md} for documenting data
#'   provenance (source, license, download date, DOI), and a README.
#' @param makefile Logical. If TRUE, adds a template \code{makefile.R} file to
#'   the project.
#' @param testthat Logical. If TRUE, adds testthat infrastructure.
#' @param use_pipe Logical. If TRUE, adds magrittr's pipe operator to the
#'   package. Default is FALSE since R >= 4.1.0 provides the native pipe
#'   operator \code{|>} which is recommended instead.
#' @param add_license Character. Type of license to add. Options are
#'   \code{"MIT"}, \code{"GPL"}, \code{"AGPL"}, \code{"LGPL"},
#'   \code{"Apache"}, \code{"CCBY"}, or \code{"CC0"}. Default is NULL (no
#'   license added).
#' @param license_holder Character. Name of the license holder / project
#'   author. Also used in CITATION.cff. Default is \code{"Your name"}.
#' @param orcid Character. ORCID iD of the project author (e.g.
#'   \code{"0000-0001-7986-0308"}). Used in CITATION.cff. Default is NULL.
#' @param use_git Logical. If TRUE (default), initializes a local git
#'   repository.
#' @param create_github_repo Logical. If TRUE, creates a GitHub repository.
#'   Note this requires some working infrastructure like \code{git} and a
#'   \code{GITHUB_PAT}. See
#'   \url{https://usethis.r-lib.org/articles/articles/usethis-setup.html}.
#' @param private_repo Logical. If TRUE (default), the GitHub repo will be
#'   private.
#' @param ci Character. Type of continuous integration for your GitHub
#'   repository. Options are \code{"none"} (default) or \code{"gh-actions"}
#'   (uses GitHub Actions with R CMD check). Only used when
#'   \code{create_github_repo = TRUE}.
#' @param use_renv Logical. If TRUE (default), initializes
#'   \href{https://rstudio.github.io/renv/}{renv} for dependency management.
#'   Creates a lockfile and \code{.Rprofile} bootstrap.
#' @param use_targets Logical. If TRUE (default), adds a
#'   \href{https://docs.ropensci.org/targets/}{\code{_targets.R}} template file
#'   for pipeline-based workflow management.
#' @param use_docker Logical. If TRUE, adds a template \code{Dockerfile} for
#'   building a reproducible computational environment.
#' @param open_proj Logical. If TRUE, opens the newly created RStudio
#'   project in a new session. Default is FALSE — open the \code{.Rproj}
#'   file manually after creation.
#' @param verbose Logical. If TRUE, prints verbose output in the console while
#'   creating the new project. Default is FALSE.
#'
#' @return Invisibly returns the path to the new project directory.
#' @export
#'
#' @details SCIproj creates a research compendium that combines
#'   \strong{structure} (where files live) with \strong{workflow} (how analyses
#'   are reproduced). By default, it sets up:
#'   \itemize{
#'     \item \code{renv} for dependency management (reproducible package versions)
#'     \item \code{targets} for pipeline-based workflow (automatic dependency
#'       tracking and caching)
#'     \item \code{CITATION.cff} for machine-readable citation metadata (FAIR)
#'     \item \code{DATA_SOURCES.md} for data provenance documentation
#'   }
#'
#'   Since R >= 4.1.0, the native pipe operator \code{|>} is available and
#'   recommended over the magrittr pipe \code{\%>\%}. The \code{use_pipe}
#'   parameter is therefore set to FALSE by default.
#'
#' @examples
#' \dontrun{
#' library("SCIproj")
#'
#' # Minimal project (includes renv + targets by default)
#' create_proj("myproject")
#'
#' # Names with underscores/hyphens are fine — the R package name is
#' # auto-cleaned (e.g. "baltic_cod" -> "baltic.cod" in DESCRIPTION)
#' create_proj("baltic_cod_analysis")
#'
#' # Full-featured project
#' create_proj("my_research_project",
#'   add_license = "MIT",
#'   license_holder = "Jane Doe",
#'   orcid = "0000-0001-2345-6789",
#'   create_github_repo = TRUE,
#'   ci = "gh-actions"
#' )
#'
#' # Minimal without workflow tools
#' create_proj("myproject", use_renv = FALSE, use_targets = FALSE)
#' }
create_proj <- function(name,
  data_raw = TRUE,
  makefile = FALSE,
  testthat = FALSE,
  use_pipe = FALSE,
  add_license = NULL,
  license_holder = "Your name",
  orcid = NULL,
  use_git = TRUE,
  create_github_repo = FALSE,
  private_repo = TRUE,
  ci = "none",
  use_renv = TRUE,
  use_targets = TRUE,
  use_docker = FALSE,
  open_proj = FALSE,
  verbose = FALSE) {

  # --- Input validation ---
  if (!is.character(name) || length(name) != 1 || nchar(name) == 0) {
    stop("`name` must be a non-empty character string.", call. = FALSE)
  }

  if (!is.null(add_license)) {
    add_license <- match.arg(add_license,
      choices = c("MIT", "GPL", "AGPL", "LGPL", "Apache", "CCBY", "CC0"))
  }

  ci <- match.arg(ci, choices = c("none", "gh-actions"))

  if (!is.null(orcid) && (!is.character(orcid) || length(orcid) != 1)) {
    stop("`orcid` must be a single character string.", call. = FALSE)
  }

  if (!isTRUE(verbose)) {
    old_opt <- options(usethis.quiet = TRUE)
    on.exit(options(old_opt), add = TRUE)
  }

  # --- Create package skeleton ---
  # The directory name can be anything (underscores, hyphens, etc.) but the
  # R package name in DESCRIPTION must follow R naming rules (letters, numbers,
  # dots only). The basename will be cleaned and and the DESCRIPTION fixed after creation.
  dir_name <- basename(name)
  pkg_name <- clean_pkg_name(dir_name)

  # create_package() internally calls local_project() which does setwd()
  # to the new directory. RStudio detects this and shows a "switch project?"
  # dialog if an .Rproj file exists there. To prevent this:
  #   1. Pass rstudio = FALSE so no .Rproj is created during create_package()
  #   2. Suppress interactive prompts with rlang_interactive = FALSE
  #   3. Create the .Rproj file later, when setwd = FALSE is active
  # In non-interactive sessions (e.g. Rscript), fall back to manual
  # structure creation if create_package() fails.
  tryCatch(
    local({
      op <- options(rlang_interactive = FALSE)
      on.exit(options(op))
      usethis::create_package(name, open = FALSE, check_name = FALSE,
        rstudio = FALSE)
    }),
    error = function(e) {
      if (grepl("User input required|not interactive", conditionMessage(e))) {
        dir.create(name, recursive = TRUE, showWarnings = FALSE)
        dir.create(file.path(name, "R"), showWarnings = FALSE)
        writeLines(
          c(
            paste0("Package: ", pkg_name),
            "Title: What the Package Does (One Line, Title Case)",
            "Version: 0.0.0.9000",
            "Authors@R: ",
            '    person("First", "Last", role = c("aut", "cre"))',
            "Description: What the package does (one paragraph).",
            'License: `use_mit_license()`, `use_gpl3_license()` or friends to',
            "    pick a license",
            "Encoding: UTF-8",
            "Roxygen: list(markdown = TRUE)"
          ),
          file.path(name, "DESCRIPTION")
        )
        writeLines(
          "# Generated by roxygen2: do not edit by hand",
          file.path(name, "NAMESPACE")
        )
      } else {
        stop(e)
      }
    }
  )

  # Normalize path after directory creation to resolve symlinks
  # (e.g. macOS /var -> /private/var). Activate the new project with
  # local_project() and auto-restore when create_proj() exits.
  # In RStudio, setwd = FALSE prevents triggering the "switch project?"
  # dialog. Outside RStudio (terminal, R CMD check), setwd = TRUE is
  # needed for usethis functions to find the active project.
  proj_path <- normalizePath(name)
  use_setwd <- !rstudioapi::isAvailable()
  usethis::local_project(proj_path, force = TRUE, setwd = use_setwd, quiet = TRUE)

  # Create .Rproj file now — at this point setwd has NOT been changed to
  # the new project (in RStudio), so RStudio will not trigger a dialog.
  tryCatch(usethis::use_rstudio(), error = function(e) NULL)

  # Fix the Package name in DESCRIPTION if it differs from the directory name
  if (pkg_name != dir_name) {
    desc_path <- file.path(proj_path, "DESCRIPTION")
    desc_lines <- readLines(desc_path)
    desc_lines <- sub(
      paste0("^Package: ", dir_name, "$"),
      paste0("Package: ", pkg_name),
      desc_lines
    )
    writeLines(desc_lines, desc_path)
    message(
      "Note: Directory name '", dir_name, "' contains characters not allowed ",
      "in R package names.\n",
      "  The package name in DESCRIPTION has been set to '", pkg_name, "'.\n",
      "  Use library(", pkg_name, ") or devtools::load_all() to load the project."
    )
  }

  usethis::use_readme_rmd(open = FALSE)

  # --- Create folders and template files ---
  dir.create(file.path(proj_path, "data"), showWarnings = FALSE)
  dir.create(file.path(proj_path, "analyses"), showWarnings = FALSE)
  dir.create(file.path(proj_path, "analyses", "figures"), showWarnings = FALSE)
  file.copy(
    from = system.file("analyses", "README.md", package = "SCIproj"),
    to = file.path(proj_path, "analyses")
  )
  dir.create(file.path(proj_path, "docs"), showWarnings = FALSE)
  file.copy(
    from = system.file("docs", "README.md", package = "SCIproj"),
    to = file.path(proj_path, "docs")
  )
  file.copy(
    from = system.file("for-r", "function_ex.R", package = "SCIproj"),
    to = file.path(proj_path, "R")
  )
  file.copy(
    from = system.file("for-r", "data.R", package = "SCIproj"),
    to = file.path(proj_path, "R")
  )
  dir.create(file.path(proj_path, "trash"), showWarnings = FALSE)

  # Exclude created folders from build
  usethis::use_build_ignore(c("analyses", "docs", "trash"))

  # --- Raw data folder ---
  if (isTRUE(data_raw)) {
    usethis::use_data_raw(open = FALSE)
    file.remove(file.path(proj_path, "data-raw", "DATASET.R"))
    file.copy(
      from = system.file("data-raw", "clean_data.R", package = "SCIproj"),
      to = file.path(proj_path, "data-raw")
    )
    file.copy(
      from = system.file("data-raw", "README.md", package = "SCIproj"),
      to = file.path(proj_path, "data-raw")
    )
    file.copy(
      from = system.file("data-raw", "DATA_SOURCES.md", package = "SCIproj"),
      to = file.path(proj_path, "data-raw")
    )
    usethis::use_build_ignore("data-raw")
  }

  # --- Makefile ---
  if (isTRUE(makefile)) {
    file.copy(
      from = system.file("makefile", "makefile.R", package = "SCIproj"),
      to = proj_path
    )
    usethis::use_build_ignore("makefile.R")
  }

  # --- Testing infrastructure ---
  if (isTRUE(testthat)) {
    usethis::use_testthat()
  }

  # --- Magrittr pipe (opt-in, native pipe |> is recommended) ---
  if (isTRUE(use_pipe)) {
    usethis::use_pipe()
  }

  # --- License ---
  if (!is.null(add_license)) {
    switch(add_license,
      MIT    = usethis::use_mit_license(copyright_holder = license_holder),
      CCBY   = usethis::use_ccby_license(),
      CC0    = usethis::use_cc0_license(),
      GPL    = usethis::use_gpl3_license(),
      AGPL   = usethis::use_agpl3_license(),
      LGPL   = usethis::use_lgpl_license(),
      Apache = usethis::use_apache_license()
    )
  }

  # --- CITATION.cff ---
  proj_name <- basename(proj_path)
  cff_lines <- c(
    "cff-version: 1.2.0",
    paste0('title: "', proj_name, '"'),
    'message: "If you use this project, please cite it as below."',
    "type: software",
    "authors:",
    paste0("  - name: ", license_holder)
  )
  if (!is.null(orcid)) {
    cff_lines <- c(cff_lines,
      paste0("    orcid: https://orcid.org/", orcid))
  }
  cff_lines <- c(cff_lines,
    paste0("version: 0.1.0"),
    paste0("date-released: ", Sys.Date()),
    if (!is.null(add_license)) paste0("license: ", add_license)
  )
  writeLines(cff_lines, file.path(proj_path, "CITATION.cff"))
  usethis::use_build_ignore("CITATION.cff")

  # --- CONTRIBUTING.md ---
  file.copy(
    from = system.file("contributing", "CONTRIBUTING.md", package = "SCIproj"),
    to = proj_path
  )
  usethis::use_build_ignore("CONTRIBUTING.md")

  # --- renv ---
  if (isTRUE(use_renv)) {
    if (!requireNamespace("renv", quietly = TRUE)) {
      warning("Package 'renv' is not installed. Skipping renv initialization.",
        call. = FALSE)
    } else {
      # Use of "explicit" snapshot type (dependency discovery via DESCRIPTION),
      # which is recommended for package-based research compendia.
      # Pre-setting snapshot.type avoids the interactive prompt and ensures
      # renv uses DESCRIPTION (not all R files) for dependency discovery.
      # Library paths are saved and restored because renv::init() switches them
      # to the new project's (empty) library, which would break subsequent
      # calls to usethis, rstudioapi, etc. in the current session.
      old_libs <- .libPaths()
      renv::init(
        project = proj_path,
        restart = FALSE,
        settings = list(snapshot.type = "explicit")
      )
      # renv does not record itself in the lockfile by default (it considers
      # itself infrastructure). This causes a "was loaded but configured to
      # use" warning on startup. Explicitly recording it fixes this.
      renv::record(
        paste0("renv@", as.character(utils::packageVersion("renv"))),
        project = proj_path
      )
      .libPaths(old_libs)
      usethis::use_build_ignore(c("renv", "renv.lock", ".Rprofile"))
    }
  }

  # --- targets ---
  if (isTRUE(use_targets)) {
    file.copy(
      from = system.file("targets", "_targets.R", package = "SCIproj"),
      to = proj_path
    )
    usethis::use_build_ignore(c("_targets.R", "_targets"))
  }

  # --- Docker ---
  if (isTRUE(use_docker)) {
    file.copy(
      from = system.file("docker", "Dockerfile", package = "SCIproj"),
      to = proj_path
    )
    # Template stored as 'dockerignore' (no dot) to avoid R CMD check NOTE
    file.copy(
      from = system.file("docker", "dockerignore", package = "SCIproj"),
      to = file.path(proj_path, ".dockerignore")
    )
    usethis::use_build_ignore(c("Dockerfile", ".dockerignore"))
  }

  # --- Git (local only) ---
  # Suppression of interactive prompts from use_git() (commit confirmation,
  # RStudio restart request) to avoid conflicts with openProject().
  # For a freshly created project, the default answers are always correct.
  if (isTRUE(use_git) && !isTRUE(create_github_repo)) {
    local({
      op <- options(rlang_interactive = FALSE)
      on.exit(options(op))
      usethis::use_git()
    })
  }

  # --- GitHub repo ---
  if (isTRUE(create_github_repo)) {
    local({
      op <- options(rlang_interactive = FALSE)
      on.exit(options(op))
      usethis::use_git()
    })
    usethis::use_github(private = private_repo)

    if (ci == "gh-actions") {
      # Copy the comprehensive workflow template from SCIproj
      gh_dir <- file.path(proj_path, ".github", "workflows")
      dir.create(gh_dir, recursive = TRUE, showWarnings = FALSE)
      file.copy(
        from = system.file("github", "R-CMD-check.yaml", package = "SCIproj"),
        to = gh_dir
      )
      usethis::use_build_ignore("^\\.github$")
    }
  }

  # --- Open project ---
  if (isTRUE(open_proj)) {
    if (rstudioapi::isAvailable()) {
      rstudioapi::openProject(proj_path, newSession = TRUE)
    }
  }

  invisible(proj_path)
}
