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
