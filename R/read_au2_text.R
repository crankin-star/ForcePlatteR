#' Function for reading an au2 file into an R object
read_au2_text <- function(fp, ncol=10, write_data=FALSE){
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
  output$scaled <- attributes[[5]][2] == "Yes"
  output$Scale_factor <- attributes[[7]][2] |> stringr::str_split('\t') |> unlist() |> as.numeric()
  output$color <- attributes[[7]][2] |> stringr::str_split('\t') |> unlist() |> as.numeric()
  output$label <- attributes[[7]][2] |> stringr::str_split('\t') |> unlist() |> as.numeric()
  output$units <- attributes[[7]][2] |> stringr::str_split('\t') |> unlist() |> as.numeric()

  data <- sub("^Index", "", data) |> trimws()
  output$data <- read.table(text = data, header = TRUE, sep = '\t')

  if (write_data) {
    write.csv(output$data, file = "")
  }

  return(output)
}
