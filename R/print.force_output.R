print.force_output <- function(x, ...) {
  print(glue::glue(
    "Force plate data with {x$number_of_channels} channels\n"
  ))

  df <- x$data
  names(df) <- c("Time", paste0(x$label, "(", x$units, ")"))
  print(head(df))

  print(
    glue::glue("Scan rate: {x$scan_rate}\tScans per Frame:{x$scans_per_frame}\tTotal scans: {x$total_scans}")
  )
}
