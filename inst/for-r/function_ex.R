#' How to document functions.
#'
#' This is an example showing how to document functions to be included in the package.
#' See \url{https://r-pkgs.org/man.html#man-functions} for further explanations.
#' To format your text use LaTeX style.
#'
#' @param text Input string to print.
#'
#' @return
#' The function returns the input string in capital letters.
#'
#' @author Your name
#' @seealso \url{https://r-pkgs.org/man.html#man-functions}
#' @export
#'
#' @examples
#' function_ex('hello world!')

function_ex <- function(text){
  TEXT <- toupper(text)
  return(TEXT)
}
