#'
#'

.calculate_forces <- function(df, S, offset = 0) {
  df <- df - offset
  time <- df$Time

  df <- subset(df, select = -Time) |> as.matrix()
  S <- as.matrix(S)

  result <- (df %*% t(S)) |> as.data.frame()
  colnames(result) <- c("Fx", "Fy", "Fz", "Mx", "My", "Mz")
  class(result) <- c("force_output", "data.frame")
  return(result)
}
