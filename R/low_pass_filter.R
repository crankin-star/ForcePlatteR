low_pass_fourier <- function(time,x,cutoff=10){
  X <- fft(as.vector(x))
  N <- length(time)
  f = 1 / (time[2] - time[1])

  for (i in 1:((N+1)/2)){
    if (f * i/N > cutoff){
      X[i] <- 0
      X[N-i] <- 0
    }
  }

  output <- Re(fft(X, inverse = TRUE))

  return(output)
}

low_pass_fourier.df(df, cutoff){
  time <- df$Time
  data_cols <- df[, colnames(df) != "Time"] |> as.matrix()
  N <- length(time)
  f <-  1 / (time[2] - time[1])


  m <- mvfft(data_cols)

  for (i in 1:(N/2)){
    if (f * 1/N > cutoff){
      X[i] <- 0
      X[N-i] <- 0
    }
  }

  df <- cbind(Time = time, mvfft(m, inverse = TRUE))
}
