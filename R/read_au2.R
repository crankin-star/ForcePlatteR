#' Read in an au2 file and store pertinent data in an R object.
#'
#'
#' @param fp Filepath for the file to be read.
#' @param n_channel Number of channels in the file, defaults to 8.
#' @param write_data write the data to a csv file.
#'
#' @return An `au2` object with all fields contained in the original file.
#'
#' @importFrom stats as.formula
#' @export

read_au2 <- function(fp, n_channel = 8, write_data = FALSE) {
  parse_line <- function(x) {
    df <- read.table(text = x[2], sep = "\t")
    if (ncol(df) > 1) {
      colnames(df) <- paste0("channel", 1:(ncol(df)))
    } else {
      df <- unlist(df)
      df <- unname(df)
    }
    return(df)
  }

  txt <- readLines(fp, 11)
  lines <- stringr::str_split_fixed(txt, "\r\n", 12)
  meta <- lines[1:11] |>
    lapply(\(x) stringr::str_split(x, ":")) |>
    unlist(recursive = FALSE) |>
    sapply(trimws)

  zp_tp <- stringr::str_split(meta[[4]], pattern = "\t") |> unlist()
  meta[[4]] <- zp_tp[1:2]
  meta[[12]] <- zp_tp[3:4]

  output <- setNames(
    lapply(meta, function(x) parse_line(x)),
    sapply(meta, `[`, 1)
  )

  # data <- sub("^Index", "", data) |> trimws()
  # output$data <- read.table(text = data, header = TRUE, sep = '\t')
  output$data <- read.table(fp, header = TRUE, sep = "\t", skip = 11)
  names(output$data)[1] <- "Time"

  if (write_data) {
    write.csv(output$data, file = glue::glue("{getwd()}/{basename(fp)}.csv"))
  }

  class(output) <- "au2"
  return(output)
}
