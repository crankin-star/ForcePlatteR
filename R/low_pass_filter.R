#' Apply a low-pass Fourier filter to a vector
#'
#' @param time a time vector
#' @param x a forces vector to be filtered
#' @param cutoff a number (in hertz) above which frequencies will be set to 0
#' @export
low_pass_fourier <- function(time, x, cutoff = 60) {
  X <- fft(as.vector(x))
  N <- length(time)
  f <- 1 / (time[2] - time[1])

  for (i in 1:((N + 1) / 2)) {
    if (f * i / N > cutoff) {
      X[i] <- 0
      X[N - i] <- 0
    }
  }

  output <- Re(fft(X, inverse = TRUE)) / length(X)
  class(output) <- "fft_filtered"
  attributes(output)$cutoff = cutoff
  attributes(output)$time = time

  return(output)
}

#' Apply a low-pass Fourier filter to a vector
#'
#' @param df a dataframe of values (including time) to be filtered
#' @param cutoff a number (in hertz) above which frequencies will be set to 0
#' @export
low_pass_fourier.df <- function(df, cutoff = 60) {
  time <- df$Time
  data_cols <- df[, colnames(df) != "Time"] |> as.matrix()
  N <- length(time)
  f <- 1 / (time[2] - time[1])


  m <- mvfft(data_cols)

  N <- nrow(data_cols)
  i <- seq_len(ceiling((N + 1) / 2))

  idx <- i[f * i / N > cutoff]

  m[idx, ] <- 0
  m[N + 1 - idx, ] <- 0

  output <- fft(m, inverse = TRUE) |>
    Re() |>
    as.data.frame() / nrow(m)

  output$Time <- time
  class(output) <- c("fft_filtered_df", "data.frame")
  attributes(output)$cutoff = cutoff

  return(output)
}

#' plot filtered data
#'
#' @param output The data to plot
#' @param ... other aesthetic information
#'
#' @exportS3Method base::plot
plot.fft_filtered <- function(output, ...) {
  cutoff <- attributes(output)$cutoff
  plot(
    x = attributes(output)$time,
    y = output,
    type = "l",
    main = glue::glue("cutoff={cutoff}"),
    ...
  )
}

#' plot filtered data
#'
#' @param output The data to plot
#' @param ... other aesthetic information
#'
#' @exportS3Method base::plot
plot.fft_filtered_df <- function(output, component = c("Fz", "Fx", "Fy", "Mz", "Mx", "My"), ...) {
  component <- match.arg(component)
  cutoff <- attributes(output)$cutoff
  plot(
    x = output[, "Time"],
    y = output[, component],
    type = "l",
    main = glue::glue("cutoff={cutoff}"),
    ylab = component,
    xlab = "Time",
    ...
  )
}
