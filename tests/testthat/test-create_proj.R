test_that("create_proj creates correct directory structure", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    data_raw = TRUE,
    makefile = TRUE,
    testthat = FALSE,
    use_pipe = FALSE,
    use_git = FALSE,
    create_github_repo = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    use_docker = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE,
    verbose = FALSE
  )

  # Normalize to resolve macOS symlinks in temp paths
  proj_path <- normalizePath(proj_path)

  expect_true(dir.exists(proj_path))
  expect_true(dir.exists(file.path(proj_path, "R")))
  expect_true(dir.exists(file.path(proj_path, "data")))
  expect_true(dir.exists(file.path(proj_path, "data-raw")))
  expect_true(dir.exists(file.path(proj_path, "analyses")))
  expect_true(dir.exists(file.path(proj_path, "analyses", "figures")))
  expect_true(dir.exists(file.path(proj_path, "docs")))
  expect_true(dir.exists(file.path(proj_path, "trash")))

  expect_true(file.exists(file.path(proj_path, "DESCRIPTION")))
  expect_true(file.exists(file.path(proj_path, "R", "function_ex.R")))
  expect_true(file.exists(file.path(proj_path, "R", "data.R")))
  expect_true(file.exists(file.path(proj_path, "data-raw", "clean_data.R")))
  expect_true(file.exists(file.path(proj_path, "data-raw", "DATA_SOURCES.md")))
  expect_true(file.exists(file.path(proj_path, "makefile.R")))
  expect_true(file.exists(file.path(proj_path, "analyses", "README.md")))
  expect_true(file.exists(file.path(proj_path, "docs", "README.md")))
  expect_true(file.exists(file.path(proj_path, "CITATION.cff")))
  expect_true(file.exists(file.path(proj_path, "CONTRIBUTING.md")))
})

test_that("create_proj respects data_raw = FALSE", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj2")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    data_raw = FALSE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  expect_false(dir.exists(file.path(proj_path, "data-raw")))
})

test_that("create_proj adds targets template by default", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj3")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_git = FALSE,
    use_renv = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  expect_true(file.exists(file.path(proj_path, "_targets.R")))
})

test_that("create_proj adds docker files", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj4")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_docker = TRUE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  expect_true(file.exists(file.path(proj_path, "Dockerfile")))
  expect_true(file.exists(file.path(proj_path, ".dockerignore")))
})

test_that("create_proj validates inputs", {
  expect_error(create_proj(""), "`name` must be a non-empty character string")
  expect_error(create_proj(123), "`name` must be a non-empty character string")
  expect_error(
    create_proj("test", add_license = "INVALID"),
    "'arg' should be one of"
  )
  expect_error(
    create_proj("test", ci = "travis"),
    "'arg' should be one of"
  )
})

test_that("create_proj generates CITATION.cff with orcid", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj6")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    license_holder = "Jane Doe",
    orcid = "0000-0001-7986-0308",
    add_license = "MIT",
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  cff <- readLines(file.path(proj_path, "CITATION.cff"))
  expect_true(any(grepl("Jane Doe", cff)))
  expect_true(any(grepl("0000-0001-7986-0308", cff)))
  expect_true(any(grepl("license: MIT", cff)))
})

test_that("create_proj returns path invisibly", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj5")

  withr::local_options(usethis.quiet = TRUE)

  result <- create_proj(proj_path,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  expect_true(is.character(result))
})

test_that("clean_pkg_name converts underscores and hyphens to dots", {
  expect_equal(clean_pkg_name("my_project"), "my.project")
  expect_equal(clean_pkg_name("baltic-cod-analysis"), "baltic.cod.analysis")
  expect_equal(clean_pkg_name("test_my-project"), "test.my.project")
  expect_equal(clean_pkg_name("myproject"), "myproject")
  expect_equal(clean_pkg_name("my.project"), "my.project")
  expect_equal(clean_pkg_name("123project"), "project")
  expect_equal(clean_pkg_name("project_"), "project")
  expect_error(clean_pkg_name("___"), "Cannot derive a valid R package name")
})

test_that("create_proj works with underscores in name", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "test_compendium")

  withr::local_options(usethis.quiet = TRUE)

  expect_message(
    create_proj(proj_path,
      use_git = FALSE,
      use_renv = FALSE,
      use_targets = FALSE,
      setwd_to_proj = FALSE,
      open_proj = FALSE
    ),
    "package name in DESCRIPTION has been set to"
  )

  proj_path <- normalizePath(proj_path)
  desc <- readLines(file.path(proj_path, "DESCRIPTION"))
  pkg_line <- desc[grepl("^Package:", desc)]
  expect_equal(pkg_line, "Package: test.compendium")
})

test_that("create_proj with setwd_to_proj = FALSE keeps working directory unchanged", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_wd_false")

  withr::local_options(usethis.quiet = TRUE)

  wd_before <- getwd()
  create_proj(proj_path,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )
  expect_equal(getwd(), wd_before)
})

test_that("create_proj with setwd_to_proj = TRUE changes working directory to new project", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_wd_true")

  withr::local_options(usethis.quiet = TRUE)

  # Ensure WD is restored after this test so other tests are not affected
  wd_before <- getwd()
  withr::defer(setwd(wd_before))

  create_proj(proj_path,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = TRUE,
    open_proj = FALSE
  )

  # Normalize both paths so symlink differences (macOS /var vs /private/var)
  # don't cause the comparison to fail
  expect_equal(normalizePath(getwd()), normalizePath(proj_path))
})

test_that("create_proj initialises renv", {
  skip_on_cran()
  skip_if_not_installed("renv")

  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_renv")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_git = FALSE,
    use_renv = TRUE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  expect_true(file.exists(file.path(proj_path, "renv.lock")))
  expect_true(file.exists(file.path(proj_path, ".Rprofile")))
})

test_that("create_proj supports all license types", {
  license_types <- c("MIT", "GPL", "AGPL", "LGPL", "Apache", "CCBY", "CC0")

  for (lic in license_types) {
    tmp <- withr::local_tempdir()
    proj_path <- file.path(tmp, paste0("testproj_", tolower(lic)))

    withr::local_options(usethis.quiet = TRUE)

    create_proj(proj_path,
      add_license = lic,
      license_holder = "Test Author",
      use_git = FALSE,
      use_renv = FALSE,
      use_targets = FALSE,
      setwd_to_proj = FALSE,
      open_proj = FALSE
    )

    proj_path <- normalizePath(proj_path)
    has_license <- file.exists(file.path(proj_path, "LICENSE")) ||
      file.exists(file.path(proj_path, "LICENSE.md"))
    expect_true(has_license, info = paste("License file missing for", lic))
  }
})

test_that("CITATION.cff omits orcid and license when not provided", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_norcid")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    license_holder = "Test Author",
    orcid = NULL,
    add_license = NULL,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  cff <- readLines(file.path(proj_path, "CITATION.cff"))
  expect_false(any(grepl("orcid:", cff)))
  expect_false(any(grepl("^license:", cff)))
})

test_that("create_proj validates orcid input", {
  expect_error(
    create_proj("test", orcid = 123),
    "`orcid` must be a single character string"
  )
  expect_error(
    create_proj("test", orcid = c("a", "b")),
    "`orcid` must be a single character string"
  )
})

test_that("create_proj adds testthat infrastructure", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_tt")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    testthat = TRUE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  expect_true(file.exists(file.path(proj_path, "tests", "testthat.R")))
  expect_true(dir.exists(file.path(proj_path, "tests", "testthat")))
})

test_that("create_proj adds pipe with use_pipe = TRUE", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_pipe")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_pipe = TRUE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  desc <- readLines(file.path(proj_path, "DESCRIPTION"))
  desc_text <- paste(desc, collapse = "\n")
  expect_true(grepl("magrittr", desc_text))
})

test_that("clean_pkg_name handles edge cases", {
  expect_equal(clean_pkg_name("a"), "a")
  expect_error(clean_pkg_name("..."), "Cannot derive a valid R package name")
  expect_equal(clean_pkg_name(".project"), "project")
})

test_that("create_proj writes correct .Rbuildignore entries", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_rbi")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    data_raw = TRUE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  rbi <- readLines(file.path(proj_path, ".Rbuildignore"))
  rbi_text <- paste(rbi, collapse = "\n")
  expect_true(grepl("analyses", rbi_text))
  expect_true(grepl("docs", rbi_text))
  expect_true(grepl("trash", rbi_text))
  expect_true(grepl("CITATION\\.cff", rbi_text) || grepl("CITATION", rbi_text))
  expect_true(grepl("CONTRIBUTING", rbi_text))
  expect_true(grepl("data-raw", rbi_text))
})

test_that("create_proj produces output with verbose = TRUE", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_verbose")

  expect_message(
    create_proj(proj_path,
      use_git = FALSE,
      use_renv = FALSE,
      use_targets = FALSE,
      setwd_to_proj = FALSE,
      open_proj = FALSE,
      verbose = TRUE
    )
  )
})

test_that("create_proj with use_rproj = TRUE creates an .Rproj file", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_rproj")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_rproj = TRUE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  rproj_files <- list.files(proj_path, pattern = "\\.Rproj$")
  expect_length(rproj_files, 1)
})

test_that("create_proj with use_rproj = FALSE does not create an .Rproj file", {
  tmp <- withr::local_tempdir()
  proj_path <- file.path(tmp, "testproj_no_rproj")

  withr::local_options(usethis.quiet = TRUE)

  create_proj(proj_path,
    use_rproj = FALSE,
    use_git = FALSE,
    use_renv = FALSE,
    use_targets = FALSE,
    setwd_to_proj = FALSE,
    open_proj = FALSE
  )

  proj_path <- normalizePath(proj_path)
  rproj_files <- list.files(proj_path, pattern = "\\.Rproj$")
  expect_length(rproj_files, 0)
})

test_that("create_proj runs successfully from a project-free working directory", {
  # Regression test for #1: create_proj() must not fail with
  # check_is_project() errors when called from a directory that is
  # not itself inside an RStudio project. This was previously broken
  # in non-RStudio IDEs (e.g., Positron) where rstudioapi::isAvailable()
  # returned TRUE but the working directory was never switched.
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)  # scoped setwd to a project-free tempdir

  proj_path <- file.path(tmp, "testproj_regression")

  withr::local_options(usethis.quiet = TRUE)

  expect_no_error(
    create_proj(proj_path,
      use_git = FALSE,
      use_renv = FALSE,
      use_targets = FALSE,
      setwd_to_proj = FALSE,
      open_proj = FALSE
    )
  )

  expect_true(file.exists(file.path(normalizePath(proj_path), "DESCRIPTION")))
  expect_true(file.exists(file.path(normalizePath(proj_path), "README.Rmd")))
})
