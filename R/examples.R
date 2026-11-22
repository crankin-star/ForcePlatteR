#' List example files or return the filepath for a example file.
#'
#' @param path the file to be returned. If null, lists possible files.
#'
#' @returns a filepath or a character vector of example file names.
#' @export
au2_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "ForcePlatteR"))
  } else {
    system.file("extdata", path, package = "ForcePlatteR", mustWork = TRUE)
  }
}
