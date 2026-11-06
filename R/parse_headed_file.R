.parse.headed.file <- function(fp){
  txt <- readChar(fp, file.info(fp)$size)
  lines <- stringr::str_split_fixed(txt, "\r\n", 12)
  attributes <- lines[1:11] |>
    lapply(\(x) stringr::str_split(x, ":")) |>
    unlist(recursive = FALSE) |>
    sapply(trimws)
  data <- lines[12]
  return(list(attributes, data))
}
