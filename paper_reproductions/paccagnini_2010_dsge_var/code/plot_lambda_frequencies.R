find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (
      file.exists(file.path(path, "R", "models.R")) &&
        file.exists(file.path(path, "R", "dsge_var.R")) &&
        dir.exists(file.path(path, "paper_reproductions"))
    ) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not find project root from: ", start)
    }
    path <- parent
  }
}

root <- find_project_root()
old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(root)

plot_frequency <- function(input, output, title) {
  d <- read.csv(input)
  d$lambda_label <- format(d$lambda, trim = TRUE, scientific = FALSE)

  png(output, width = 1400, height = 900, res = 150)
  op <- par(mfrow = c(2, 4), mar = c(4, 4, 3, 1))
  on.exit({
    par(op)
    dev.off()
  }, add = TRUE)

  for (p in sort(unique(d$lags))) {
    sub <- d[d$lags == p, ]
    barplot(
      sub$frequency,
      names.arg = sub$lambda_label,
      ylim = c(0, 100),
      col = "#4C78A8",
      border = NA,
      main = paste0("VAR(", p, ")"),
      xlab = "lambda",
      ylab = "frequency"
    )
  }
  mtext(title, outer = TRUE, line = -2, cex = 1.2)
}

fig_dir <- file.path(root, "paper_reproductions", "paccagnini_2010_dsge_var", "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

plot_frequency(
  "output/forward_mc_frequency.csv",
  file.path(fig_dir, "forward_lambda_frequency.png"),
  "Forward-looking DGP: optimal lambda frequencies"
)

plot_frequency(
  "output/backward_mc_frequency.csv",
  file.path(fig_dir, "backward_lambda_frequency.png"),
  "Backward-looking DGP: optimal lambda frequencies"
)
