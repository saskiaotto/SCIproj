# This is an example showing how to document datasets included in the package
# (in the 'data/' folder): You must specify the name of the dataset and
# list all items (e.g. columns) in the '@format' section. You can also use other
# roxygen sections, e.g. '@details', '@source' or '@examples'. See
# https://r-pkgs.org/man.html#man-data for further explanations. To format your text
# use LaTeX style.


####################### Dataset 1: dataset_ex #####################

#' Title for the dataset
#'
#' Brief summary on what this dataset is about and/or for.
#'
#' @format A data frame with 10 rows and 2 columns:
#' \describe{
#' \item{x}{A sequence from 1 to 10.}
#' \item{y}{A numeric vector containing 10 random values drawn from a normal distribution with zero mean
#'          and a standard deviation of one.}
#' }
"dataset_ex"



####################### Dataset 2: .. #####################

#...
