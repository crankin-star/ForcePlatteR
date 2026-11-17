read_config <- function(fp){
  raw <- read.csv(fp)

  attributes <- raw[1:7,1]
  attributes <- lapply(attributes, stringr::str_split_fixed, pattern=":", n = 2) |>
    lapply(trimws)

  output <- list()
  output$mn <- attributes[[1]][2]
  output$date <- attributes[[2]][2]
  output$length <- attributes[[3]][2] |> as.numeric()
  output$width <- attributes[[4]][2] |> as.numeric()
  output$x_offset <- attributes[[5]][2] |> as.numeric()
  output$y_offset <- attributes[[6]][2] |> as.numeric()
  output$z_offset <- attributes[[7]][2] |> as.numeric()


  S <- raw[8:13,2:ncol(raw)]
  rownames(S) <- 1:nrow(S)
  colnames(S) <- 1:ncol(S)

  output$S <- S

  class(output) <- "force_plate_cfg"
  return(output)
}
