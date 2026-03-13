#' Sanitize a directory name into a valid R package name
#'
#' Converts underscores and hyphens to dots and removes other invalid
#' characters. R package names may only contain letters, numbers, and dots,
#' must start with a letter, and must not end with a dot.
#'
#' @param name Character. The directory name to sanitize.
#' @return A valid R package name.
#' @keywords internal
sanitize_pkg_name <- function(name) {
  # Replace underscores and hyphens with dots
  pkg <- gsub("[_-]", ".", name)
  # Remove any remaining invalid characters (keep letters, numbers, dots)
  pkg <- gsub("[^a-zA-Z0-9.]", "", pkg)
  # Must start with a letter
  pkg <- sub("^[^a-zA-Z]+", "", pkg)
  # Must not end with a dot
  pkg <- sub("[.]+$", "", pkg)
  # If empty after sanitization, use a fallback

  if (nchar(pkg) == 0) {
    stop("Cannot derive a valid R package name from '", name,
      "'. Please use at least one letter in the project name.", call. = FALSE)
  }

  pkg
}
