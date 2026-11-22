#' A simple function for processing force plate output with no special treatments
#'
#' @param data_fp file path to the au2 file to analyze
#' @param cfg_fp file path to the calibration file to analyze
#' @param correct_lbs_to_n multiply forces by 4.45 to get values from pounds to Newtons
#' @param cutoff cutoff value (in Hz) for the low-pass Fourier filter
#' @param channel_to_analyze The channel to display in the offset-selection GUI
#' @param fps Currently unused. frames per second used to calculate time column.
#'
#' @returns a processed_force_data object containing the original au2 and
#' calibration objects, the channel output and calibration matrices, and
#' calculated forces and moments.
#' @export
easy_forceplate_process <- function(
  data_fp,
  cfg_fp,
  correct_lbs_to_n = TRUE,
  cutoff = 60,
  channel_to_analyze = "Ch.00",
  fps = NULL
) {
  au2 <- read_au2(data_fp)
  cfg <- read_config(cfg_fp)

  df <- au2$data
  S <- cfg$S

  offset_interval <- select_range_gui(df,
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
  if (correct_lbs_to_n) {
    df[-1] <- df[-1] * 4.45
  }

  forces <- calculate_forces(df, S)
  forces <- lapply(forces, \(x) low_pass_fourier(time = time, x = x, cutoff = cutoff))


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

#' Conveniently plot processed forceplate data
#'
#' @param x the plot.processed_force_data object to display
#' @param dim dimension of the force to display, one of 'x', 'y', or 'z'
#'
#' @exportS3Method base::plot
plot.processed_force_data <- function(x, dim = "z", ...) {
  plot(x$df$Fz, x$df$Time, ..., type = "l", xlab = "Vertical forces", ylab = "Time")
}
