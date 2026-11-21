dir_path <- r"(C:\Users\MovementEcology1\Desktop\2026-11-15 trial run)"

directory <- dir(dir_path, recursive = TRUE, full.names = TRUE)
au2s <- directory[grepl("*\\.au2$", x = directory)]

forces <- setNames(
  lapply(au2s, easy_forceplate_process, cfg_fp = "calibration_data/A1840_1.acl"),
  basename(au2s)
)

plot_forces <- function(force,backend = "base", main = "Z-Forces"){
  if (length(force) == 1 && all(is.na(force))){
    warning("force is NA")
    return (NA)
  }
  Fz <- cbind(force$df$Time, force$forces$Fz * 4.45) |> as.data.frame()
  colnames(Fz) <- c("time", "force")

  if (backend == "ggplot2") {
  p <- ggplot(Fz, aes(x=time, y=force)) +
    geom_line()

  } else if (backend == "base") {
    p <- plot(Fz$time, Fz$force, type = 'l', xlab = "Time (s)", ylab = "Force_z (N)")
  } else {
    warning("unrecognized backend")
    p <- NA
  }

  return(p)
}

pdf("test run z-forces.pdf")
lapply(forces, plot_forces)
dev.off()
