#' Function for reading an au2 file into an R object
read_au2_text <- function(fp, n_channel=8, write_data=FALSE){
  parse_line <- function(x) {
    df <- read.table(text = x, sep = '\t')
    if (ncol(df) > 1) {
      colnames(df) <- paste0("channel", 1:(ncol(df)))
    } else {
      df <- unlist(df)
      df <- unname(df)
    }
    return(df)
  }

  txt <- readChar(fp, file.info(fp)$size)
  lines <- stringr::str_split_fixed(txt, "\r\n", 12)
  attributes <- lines[1:11] |>
    lapply(\(x) stringr::str_split(x, ":")) |>
    unlist(recursive = FALSE) |>
    sapply(trimws)
  data <- lines[12]

  # simpler version of the below code, but misses out on sublties like zp/tp being on the same line

  # attributes <- setNames(lapply(x, `[`, -1), vapply(x, `[`, character(1), 1))
  # lapply(attributes, parse_line)

  output <- list()
  class(output) <- "force_output"
  output$scan_rate <- parse_line(attributes[[1]])
  output$scans_per_frame <- parse_line(attributes[[2]])
  output$total_scans <- parse_line(attributes[[3]])
  zp_tp <- stringr::str_split(attributes[[4]], pattern = '\t') |> unlist()
  output$ZP <- zp_tp[2] |> as.numeric()
  output$TP <- zp_tp[4] |> as.numeric()
  output$number_of_channels <- parse_line(attributes[[5]])
  output$scaled <- attributes[[6]][2] == "Yes"
  output$Scale_factor <- parse_line(attributes[[7]])
  output$offset <- parse_line(attributes[[8]])
  output$color <- parse_line(attributes[[9]]) |>
    lapply(\(x) read.table(text = x, sep=',', col.names = c('R','G','B')) |> unlist())
  output$label <- parse_line(attributes[[10]])
  output$units <- parse_line(attributes[[11]])

  data <- sub("^Index", "", data) |> trimws()
  output$data <- read.table(text = data, header = TRUE, sep = '\t')

  if (write_data) {
    write.csv(output$data, file = glue::glue("{getwd()}/{basename(fp)}.csv"))
  }

  return(output)
}
