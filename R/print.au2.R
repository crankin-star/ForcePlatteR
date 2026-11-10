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
