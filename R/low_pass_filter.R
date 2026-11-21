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

  output <- list(
    data = Re(fft(X, inverse = TRUE)) / length(X),
    cutoff = cutoff
  )
  class(output) <- "fft_filtered"

  return(output)
}

low_pass_fourier.df <- function(df, cutoff) {
  time <- df$Time
  data_cols <- df[, colnames(df) != "Time"] |> as.matrix()
  N <- length(time)
  f <- 1 / (time[2] - time[1])


  m <- mvfft(data_cols)

  for (i in 1:(N / 2)) {
    if (f * 1 / N > cutoff) {
      X[i] <- 0
      X[N - i] <- 0
    }
  }

  df <- cbind(Time = time, mvfft(m, inverse = TRUE))
}

#' plot filtered data
#'
#' @param output The data to plot
#' @param ... other aesthetic information
#'
#' @exportS3Method base::plot
plot.fft_filtered <- function(output, ...) {
  plot(output$data, type = "l", main = glue::glue("cutoff={output$cutoff}"), ...)
}
