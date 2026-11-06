#' Function for reading an au2 file into an R object
read_au2_text <- function(fp, n_channel=8, write_data=FALSE){
  parse_tab_delineated_line <- function(x) {
    df <- read.table(text = x, sep = '\t')
    colnames(df) <- paste0("channel", 1:(ncol(df)))
    return(df)
  }

  txt <- readChar(fp, file.info(fp)$size)
  lines <- stringr::str_split_fixed(txt, "\r\n", 12)
  attributes <- lines[1:11] |>
    lapply(\(x) stringr::str_split(x, ":")) |>
    unlist(recursive = FALSE) |>
    sapply(trimws)
  data <- lines[12]

  output <- list()
  class(output) <- "force_output"
  output$scan_rate <- attributes[[1]][2] |> as.numeric()
  output$scans_per_frame <- attributes[[2]][2] |> as.numeric()
  output$total_scans <- attributes[[3]][2] |> as.numeric()
  zp_tp <- stringr::str_split(attributes[[4]], pattern = '\t') |> unlist()
  output$ZP <- zp_tp[2] |> as.numeric()
  output$TP <- zp_tp[4] |> as.numeric()
  output$number_of_channels <- attributes[[5]][2] |> as.numeric()
  output$scaled <- attributes[[6]][2] == "Yes"
  output$Scale_factor <- parse_tab_delineated_line(attributes[[7]][2])
  output$offset <- parse_tab_delineated_line(attributes[[8]][2])
  output$color <- parse_tab_delineated_line(attributes[[9]][2]) |>
    lapply(\(x) read.table(text = x, sep=',', col.names = c('R','G','B')) |> unlist())
  output$label <- parse_tab_delineated_line(attributes[[10]][2])
  output$units <- parse_tab_delineated_line(attributes[[11]][2])

  data <- sub("^Index", "", data) |> trimws()
  output$data <- read.table(text = data, header = TRUE, sep = '\t')

  if (write_data) {
    write.csv(output$data, file = glue::glue("{getwd()}/{basename(fp)}.csv"))
  }

  return(output)
}
