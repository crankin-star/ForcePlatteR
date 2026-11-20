data_fp <- "data/2026-11-05_15-46_Evt04-Camera1.txt"
cfg_fp <- "calibration_data/A1840_1.acl"

easy_forceplate_process <- function(
  data_fp,
  cfg_fp,
  cutoff,
  channel_to_analyze = "Ch.00"
) {
  au2 <- read_au2(data_fp)
  cfg <- read_config(cfg_fp)

  df <- au2$data
  S <- cfg$S

  lapply(df[, 2:ncol(df)], \(x) low_pass_fourier(time = df[, 1], x=x, cutoff = cutoff))

  offset_interval <- select_offsets(df,
    x = "Time", y = channel_to_analyze,
    viewer = "browser"
  )
  if (is.null(offset_interval)) {
    warning("Operation cancelled by the user")
    return(NA)
  }

  offset <- df[df$Time < offset_interval$upper & df$Time > offset_interval$lower, -1] |>
    colMeans()
  df[-1] <- sweep(df[-1], 2, offset, `-`)

  forces <- .calculate_forces(df, S)

  output <- list(
    au2 = au2,
    cfg = cfg,
    df = df,
    S = S,
    forces = forces
  )
  class(output) <- "processed_force_data"

  return(output)
}
