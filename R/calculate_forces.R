#' Use the matrix cross product to calculate forces from channel inputs and a
#' calibration input file.
#'
#' @param df dataframe of channel inputs (including time)
#' @param S The calibration matrix
#' @param offset offset of channel inputs from zero.
#'
#' @returns a force_output object with forces and moments measured.
#' @export
calculate_forces <- function(df, S, offset = 0) {
  df <- df - offset
  time <- df$Time

  df <- subset(df, select = -Time) |> as.matrix()
  S <- as.matrix(S)

  result <- (df %*% t(S)) |> as.data.frame()
  colnames(result) <- c("Fx", "Fy", "Fz", "Mx", "My", "Mz")
  result$Time <- time
  class(result) <- c("force_output", "data.frame")
  return(result)
}

#' Plotting for force_output objects
#' @exportS3Method base::plot
#' @export
plot.force_output <- function(x, component = c("Fz", "Fx", "Fy", "Mz", "Mx", "My"), ...) {
  match.arg(component)
  plot(x[["Time"]], x[[component]], type = "l", xlab = "Time (s)", ylab = component, ...)
}
