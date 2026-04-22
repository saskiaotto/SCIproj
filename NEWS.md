# SCIproj 1.0.1

## Bug fixes

* Fixed working directory handling in non-RStudio IDEs such as Positron
  and VSCode. Previously, `create_proj()` used `rstudioapi::isAvailable()`
  to detect RStudio — but Positron also implements this API, which
  caused `check_is_project()` to fail when `create_proj()` was called
  from a working directory that was not inside an existing project. The
  function now switches the working directory consistently across all
  IDEs. Thanks to @eribul for the detailed bug report (#1).

## New features

* New `setwd_to_proj` parameter (default `TRUE`) to set the working
  directory to the new project after creation, so you can continue
  working inside it immediately. Set to `FALSE` for script-driven
  workflows where you want to stay in your current working directory
  — for example, when creating multiple projects in sequence.

* New `use_rproj` parameter (default `TRUE`) to optionally skip
  `.Rproj` file creation for users working exclusively in Positron,
  VSCode, or other non-RStudio IDEs.

## User-facing changes

* `create_proj()` now displays a confirmation message at the end
  indicating whether the working directory was changed or a new IDE
  session was opened, so the current state is always transparent.

* When `open_proj = TRUE`, the new IDE session gets the project and
  the current session keeps its original working directory. Previously,
  both sessions could end up in the new project.


# SCIproj 1.0.0

Initial CRAN release.

## Breaking changes

* `use_pipe` now defaults to `FALSE`. The native pipe operator `|>` (available
  since R 4.1.0) is recommended instead of the magrittr pipe `%>%`.
* CI options `"travis"`, `"circle"`, and `"appveyor"` have been removed. Only
  `"gh-actions"` (GitHub Actions) is supported.
* Minimum R version raised to >= 4.1.0 (from 3.5.0).
* License functions now use `copyright_holder` parameter (matching usethis >= 2.0).
* `use_renv` and `use_targets` now default to `TRUE` — projects are
  workflow-oriented by default.
* `open_proj` now defaults to `FALSE` — open the `.Rproj` file manually after
  creation to avoid RStudio session conflicts.

## New features (FAIR / Open Science)

* **CITATION.cff** is now generated automatically with project name, author,
  and optional ORCID — making projects machine-readable and citable.
* New `orcid` parameter for including the author's ORCID iD in CITATION.cff.
* **DATA_SOURCES.md** template added to `data-raw/` for documenting data
  provenance (source, license, download date, DOI).
* **CONTRIBUTING.md** template added to every project.
* **GitHub Actions workflow** template (R CMD check + optional targets pipeline)
  included when `ci = "gh-actions"`.

## New features (workflow)

* New `use_git` parameter to initialize a local git repository without creating
  a GitHub repo.
* `use_renv = TRUE` (default) initializes renv with lockfile and .Rprofile
  bootstrap for dependency management (using `snapshot.type = "explicit"`).
* `use_targets = TRUE` (default) adds a `_targets.R` pipeline template for
  reproducible workflow management.
* New `use_docker` parameter to add a `Dockerfile` template for reproducible
  computational environments.
* Input validation with `match.arg()` for `add_license` and `ci` parameters.
* The function now returns the project path invisibly.
* Project names with underscores or hyphens (e.g. `"my_project"`) are now
  accepted — the R package name is auto-sanitized (e.g. `my.project` in
  DESCRIPTION). New helper `sanitize_pkg_name()`.
* Updated `_targets.R` template with `tar_source()`, numbered steps matching
  the official targets manual, and `format = "file"` example.

## RStudio integration fixes

* Suppressed `create_package()` from triggering RStudio's "switch project?"
  dialog by deferring `.Rproj` file creation.
* Suppressed `use_git()` interactive prompts (commit confirmation, session
  restart) via `rlang_interactive = FALSE`.
* Added `restart = FALSE` to `renv::init()` to prevent RStudio session
  restart during project creation.
* Conditional `setwd` handling: `setwd = FALSE` in RStudio (avoids project
  switch dialog), `setwd = TRUE` outside RStudio (required for usethis
  functions under R CMD check).
* Non-interactive fallback: `create_package()` failures in terminal/Rscript
  sessions are caught with `tryCatch` and fall back to manual package
  structure creation.
* Library paths are saved and restored around `renv::init()` to prevent
  `rstudioapi` and other packages from becoming unavailable.

## Bug fixes

* Fixed copy-paste error in `@param add_license` documentation.
* Fixed `@param ci` incorrectly documented as "Logical" (is Character).
* Fixed examples using old parameter names (`github`, `private.repo`).
* Fixed `@details` referencing old parameter name `github`.
* Removed placeholder text in DESCRIPTION.
* Removed redundant `Maintainer` field (already specified via `Authors@R`).
* Removed `LazyData: true` (package contains no data).
* Fixed GitHub URL from `/blob/master/` to `/blob/main/`.

## Other improvements

* Updated usethis API calls: `use_apl2_license()` replaced with
  `use_apache_license()`, `name` parameter replaced with `copyright_holder`.
* License selection now uses `switch()` instead of repeated `if` statements.
* Options are now properly restored on exit via `on.exit()`.
* Package license changed from CC BY 4.0 to MIT.
* Updated makefile template to reference Quarto and targets.
* Updated README with FAIR principles, rOpenSci, TIER Protocol, and NASA TOPS
  references. Reorganized resources section.
* Added comprehensive test suite (testthat): directory structure, data_raw,
  targets, docker, input validation, CITATION.cff, name cleaning.

# SCIproj 0.1.0

* Initial release with `create_proj()` function.
