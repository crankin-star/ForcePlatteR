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

#' Nice printing for au2 objects
#' @exportS3Method base::print
print.au2 <- function(x, ...) {
  print(glue::glue(
    "Force plate data with {x$`Number of Channels`} channels\n"
  ))

  df <- x$data
  names(df) <- c("Time", paste0(x$Label, "(", x$Units, ")"))
  print(head(df))

  print(
    glue::glue(
      "Scan rate: {x$`Scan Rate`}\tScans per Frame:{x$`Scans Per Frame`}\tTotal scans: {x$`Total Scans`}"
    )
  )
}


#' Read calibration file
#'
#' @param fp file path to the calibration file
#'
#' @returns a calibration object with the calibration matrix and associated
#' metadata
#' @export

read_config <- function(fp) {
  cfg <- readChar(fp, file.info(fp)$size)
  lines <- stringr::str_split_fixed(cfg, "\r\n", 9)

  .convert_value <- function(x) {
    num <- suppressWarnings(as.numeric(x))

    if (is.na(num)) x else num
  }

  meta <- lines[1:8] |>
    lapply(\(x) stringr::str_split(x, ":")) |>
    unlist(recursive = FALSE) |>
    lapply(trimws)

  output <- setNames(
    lapply(meta, function(x) .convert_value(x[2])),
    sapply(meta, `[`, 1)
  )

  output$S <- lines[9] |>
    gsub("COEFFROW[0-9]:", "", x = _) |>
    read.table(text = _, sep = ",")
  names(output$S) <- paste0("S", 1:8)

  return(output)
}
