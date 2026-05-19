find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (dir.exists(file.path(path, "paper_reproductions"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) stop("Could not find project root from: ", start)
    path <- parent
  }
}

root <- find_project_root()
base_dir <- file.path(root, "paper_reproductions", "selected_next_10_core_papers")
raw_dir <- file.path(base_dir, "data", "raw")
processed_dir <- file.path(base_dir, "data", "processed")
results_dir <- file.path(base_dir, "results")
figures_dir <- file.path(base_dir, "figures")
dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

as_num <- function(x) suppressWarnings(as.numeric(gsub(",", "", x)))

read_fred_md <- function(path) {
  raw <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  transform_codes <- as.integer(raw[1, -1])
  names(transform_codes) <- names(raw)[-1]
  data <- raw[-1, , drop = FALSE]
  dates <- as.Date(data$sasdate, format = "%m/%d/%Y")
  values <- data[, -1, drop = FALSE]
  values[] <- lapply(values, as_num)
  list(dates = dates, values = values, transform_codes = transform_codes)
}

fred_transform <- function(x, code) {
  x <- as.numeric(x)
  out <- rep(NA_real_, length(x))
  if (code == 1) {
    out <- x
  } else if (code == 2) {
    out[-1] <- diff(x)
  } else if (code == 3) {
    out[-(1:2)] <- diff(x, differences = 2)
  } else if (code == 4) {
    out <- log(x)
  } else if (code == 5) {
    out[-1] <- diff(log(x))
  } else if (code == 6) {
    out[-(1:2)] <- diff(log(x), differences = 2)
  } else if (code == 7) {
    growth <- rep(NA_real_, length(x))
    growth[-1] <- x[-1] / x[-length(x)] - 1
    out[-(1:2)] <- diff(growth[-1])
  }
  out
}

make_stationary_panel <- function(md) {
  x <- md$values
  z <- data.frame(date = md$dates)
  for (nm in names(x)) {
    code <- md$transform_codes[[nm]]
    if (is.na(code)) next
    z[[nm]] <- fred_transform(x[[nm]], code)
  }
  z
}

make_small_macro <- function(md) {
  x <- md$values
  n <- nrow(x)
  out <- data.frame(
    date = md$dates,
    ip_growth = rep(NA_real_, n),
    inflation = rep(NA_real_, n),
    unemployment = x$UNRATE,
    fedfunds = x$FEDFUNDS
  )
  out$ip_growth[-1] <- 1200 * diff(log(x$INDPRO))
  out$inflation[-1] <- 1200 * diff(log(x$CPIAUCSL))
  out <- out[out$date >= as.Date("1960-01-01"), ]
  out <- out[complete.cases(out), ]
  out
}

lag_matrix <- function(y, p) {
  y <- as.matrix(y)
  tt <- nrow(y)
  n <- ncol(y)
  y_resp <- y[(p + 1):tt, , drop = FALSE]
  x <- matrix(1, nrow = tt - p, ncol = 1 + n * p)
  colnames(x) <- c("const", unlist(lapply(seq_len(p), function(l) paste0(colnames(y), "_L", l))))
  for (l in seq_len(p)) {
    x[, ((l - 1) * n + 2):(l * n + 1)] <- y[(p + 1 - l):(tt - l), , drop = FALSE]
  }
  list(y = y_resp, x = x)
}

ols_var <- function(y, p) {
  dat <- lag_matrix(y, p)
  b <- solve(crossprod(dat$x), crossprod(dat$x, dat$y))
  e <- dat$y - dat$x %*% b
  sigma <- crossprod(e) / (nrow(e) - ncol(dat$x))
  list(b = b, sigma = sigma, residuals = e, x = dat$x, y = dat$y)
}

minnesota_prior <- function(n, p, sigma2, lambda = 0.2, theta = 0.5, decay = 1, intercept_var = 100) {
  k <- 1 + n * p
  b0 <- matrix(0, k, n)
  v0 <- matrix(0, k, n)
  v0[1, ] <- intercept_var
  for (eq in seq_len(n)) {
    for (lag in seq_len(p)) {
      for (var in seq_len(n)) {
        row <- 1 + (lag - 1) * n + var
        if (var == eq) {
          v0[row, eq] <- lambda^2 / lag^(2 * decay)
          if (lag == 1) b0[row, eq] <- 0.9
        } else {
          v0[row, eq] <- lambda^2 * theta^2 * sigma2[eq] / (lag^(2 * decay) * sigma2[var])
        }
      }
    }
  }
  list(b0 = b0, v0 = v0)
}

bvar_fit_fixed_sigma <- function(y, p, lambda = 0.2, theta = 0.5) {
  y <- as.matrix(y)
  dat <- lag_matrix(y, p)
  ols <- ols_var(y, p)
  sigma2 <- pmax(diag(ols$sigma), 1e-8)
  prior <- minnesota_prior(ncol(y), p, sigma2, lambda, theta)
  k <- ncol(dat$x)
  n <- ncol(y)
  b <- matrix(NA_real_, k, n)
  for (i in seq_len(n)) {
    inv_v0 <- diag(1 / prior$v0[, i], k)
    v1_inv <- inv_v0 + crossprod(dat$x) / sigma2[i]
    rhs <- inv_v0 %*% prior$b0[, i] + crossprod(dat$x, dat$y[, i]) / sigma2[i]
    b[, i] <- solve(v1_inv, rhs)
  }
  e <- dat$y - dat$x %*% b
  sigma <- crossprod(e) / nrow(e)
  list(b = b, sigma = sigma, x = dat$x, y = dat$y, sigma2 = sigma2, prior = prior)
}

log_ml_fixed_sigma <- function(y, p, lambda = 0.2, theta = 0.5) {
  y <- as.matrix(y)
  dat <- lag_matrix(y, p)
  ols <- ols_var(y, p)
  sigma2 <- pmax(diag(ols$sigma), 1e-8)
  prior <- minnesota_prior(ncol(y), p, sigma2, lambda, theta)
  k <- ncol(dat$x)
  out <- 0
  for (i in seq_len(ncol(y))) {
    inv_v0 <- diag(1 / prior$v0[, i], k)
    v1_inv <- inv_v0 + crossprod(dat$x) / sigma2[i]
    rhs <- inv_v0 %*% prior$b0[, i] + crossprod(dat$x, dat$y[, i]) / sigma2[i]
    b1 <- solve(v1_inv, rhs)
    logdet_v0 <- sum(log(prior$v0[, i]))
    chol_v1_inv <- chol(v1_inv)
    logdet_v1 <- -2 * sum(log(diag(chol_v1_inv)))
    quad <- sum(dat$y[, i]^2) / sigma2[i] +
      as.numeric(crossprod(prior$b0[, i], inv_v0 %*% prior$b0[, i])) -
      as.numeric(crossprod(b1, v1_inv %*% b1))
    out <- out - nrow(dat$y) / 2 * log(2 * pi * sigma2[i]) +
      0.5 * (logdet_v1 - logdet_v0) - 0.5 * quad
  }
  out
}

forecast_rmse <- function(y, p, model = c("ols", "bvar"), lambda = 0.2, test_size = 60) {
  model <- match.arg(model)
  y <- as.matrix(y)
  train_end <- nrow(y) - test_size
  fit_y <- y[1:train_end, , drop = FALSE]
  fit <- if (model == "ols") ols_var(fit_y, p) else bvar_fit_fixed_sigma(fit_y, p, lambda)
  preds <- matrix(NA_real_, test_size, ncol(y))
  actual <- y[(train_end + 1):nrow(y), , drop = FALSE]
  for (h in seq_len(test_size)) {
    t_idx <- train_end + h - 1
    xrow <- c(1)
    for (l in seq_len(p)) xrow <- c(xrow, y[t_idx + 1 - l, ])
    preds[h, ] <- xrow %*% fit$b
  }
  sqrt(colMeans((actual - preds)^2))
}

irf_var <- function(fit, p, horizon, shock_index) {
  b <- fit$b
  n <- ncol(b)
  shock <- t(chol(fit$sigma))[, shock_index]
  resp <- array(0, dim = c(horizon + 1, n))
  resp[1, ] <- shock
  amat <- vector("list", p)
  for (l in seq_len(p)) {
    amat[[l]] <- t(b[((l - 1) * n + 2):(l * n + 1), , drop = FALSE])
  }
  for (h in 1:horizon) {
    r <- rep(0, n)
    for (l in seq_len(min(p, h))) r <- r + amat[[l]] %*% resp[h - l + 1, ]
    resp[h + 1, ] <- r
  }
  resp
}

md <- read_fred_md(file.path(raw_dir, "fred_md", "2026-04-md.csv"))
small <- make_small_macro(md)
write.csv(small, file.path(processed_dir, "small_macro_monthly_1960_2026.csv"), row.names = FALSE)

p <- 4
small_y <- as.matrix(small[, c("ip_growth", "inflation", "unemployment", "fedfunds")])
colnames(small_y) <- c("ip_growth", "inflation", "unemployment", "fedfunds")
grid <- seq(0.05, 1.0, by = 0.05)
logml <- sapply(grid, function(lam) log_ml_fixed_sigma(small_y, p, lam))
lambda_star <- grid[which.max(logml)]
lambda_grid <- data.frame(lambda = grid, log_marginal_likelihood = logml)
write.csv(lambda_grid, file.path(results_dir, "glp_lambda_grid_small_bvar.csv"), row.names = FALSE)

rmse_ols <- forecast_rmse(small_y, p, "ols")
rmse_lit <- forecast_rmse(small_y, p, "bvar", lambda = 0.2)
rmse_glp <- forecast_rmse(small_y, p, "bvar", lambda = lambda_star)
forecast_comp <- rbind(
  data.frame(model = "OLS VAR", variable = names(rmse_ols), rmse = as.numeric(rmse_ols), lambda = NA_real_),
  data.frame(model = "Litterman Minnesota BVAR", variable = names(rmse_lit), rmse = as.numeric(rmse_lit), lambda = 0.2),
  data.frame(model = "GLP selected-tightness BVAR", variable = names(rmse_glp), rmse = as.numeric(rmse_glp), lambda = lambda_star)
)
write.csv(forecast_comp, file.path(results_dir, "bvar_forecast_comparison.csv"), row.names = FALSE)

stationary <- make_stationary_panel(md)
use <- stationary[stationary$date >= as.Date("1985-01-01"), ]
candidate_cols <- setdiff(names(use), "date")
ok <- sapply(use[candidate_cols], function(z) mean(is.finite(z)) > 0.85 && sd(z, na.rm = TRUE) > 0)
panel <- use[, c("date", candidate_cols[ok]), drop = FALSE]
for (j in names(panel)[-1]) {
  z <- panel[[j]]
  z[!is.finite(z)] <- NA_real_
  z[is.na(z)] <- mean(z, na.rm = TRUE)
  panel[[j]] <- z
}
panel_scaled <- scale(panel[, -1])
pca <- prcomp(panel_scaled, center = FALSE, scale. = FALSE)
variance <- pca$sdev^2 / sum(pca$sdev^2)
factor_summary <- data.frame(factor = seq_along(variance), variance_share = variance, cumulative_share = cumsum(variance))
write.csv(factor_summary[1:20, ], file.path(results_dir, "diffusion_factor_variance.csv"), row.names = FALSE)

png(file.path(figures_dir, "diffusion_factor_variance.png"), width = 900, height = 600, res = 130)
plot(
  factor_summary$factor[1:20],
  factor_summary$cumulative_share[1:20],
  type = "b",
  pch = 19,
  xlab = "Number of principal components",
  ylab = "Cumulative variance share",
  main = "FRED-MD Diffusion Index Variance"
)
grid()
dev.off()

factors <- pca$x[, 1:3, drop = FALSE]
colnames(factors) <- paste0("factor", 1:3)
fed <- md$values$FEDFUNDS[match(panel$date, md$dates)]
favar_data <- data.frame(date = panel$date, factors, fedfunds = fed)
favar_data <- favar_data[complete.cases(favar_data), ]
favar_y <- as.matrix(favar_data[, -1])
favar_fit <- bvar_fit_fixed_sigma(favar_y, p, lambda = 0.2)
favar_resp <- irf_var(favar_fit, p, horizon = 36, shock_index = ncol(favar_y))
favar_irf <- data.frame(horizon = 0:36, favar_resp)
names(favar_irf)[-1] <- colnames(favar_y)
write.csv(favar_irf, file.path(results_dir, "favar_policy_irf_baseline.csv"), row.names = FALSE)

png(file.path(figures_dir, "favar_policy_irf_baseline.png"), width = 1000, height = 700, res = 130)
op <- par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
for (j in colnames(favar_y)) {
  plot(favar_irf$horizon, favar_irf[[j]], type = "l", lwd = 2, xlab = "Months", ylab = "Response", main = j)
  abline(h = 0, col = "gray50")
  grid()
}
par(op)
dev.off()

tvp_y <- as.matrix(small[, c("inflation", "unemployment", "fedfunds")])
colnames(tvp_y) <- c("inflation", "unemployment", "fedfunds")
window <- 120
tvp_rows <- list()
for (end in seq(window, nrow(tvp_y))) {
  ywin <- tvp_y[(end - window + 1):end, , drop = FALSE]
  fit <- ols_var(ywin, p = 2)
  coef_infl_l1_on_ffr <- fit$b[2, "fedfunds"]
  coef_unemp_l1_on_ffr <- fit$b[3, "fedfunds"]
  tvp_rows[[length(tvp_rows) + 1]] <- data.frame(
    date = small$date[end],
    inflation_lag1_in_fedfunds_eq = coef_infl_l1_on_ffr,
    unemployment_lag1_in_fedfunds_eq = coef_unemp_l1_on_ffr
  )
}
tvp <- do.call(rbind, tvp_rows)
write.csv(tvp, file.path(results_dir, "rolling_policy_rule_coefficients.csv"), row.names = FALSE)

png(file.path(figures_dir, "rolling_policy_rule_coefficients.png"), width = 1000, height = 600, res = 130)
plot(tvp$date, tvp$inflation_lag1_in_fedfunds_eq, type = "l", lwd = 2, col = "#3B6FB6",
     xlab = "Date", ylab = "Rolling VAR coefficient", main = "Rolling Policy Equation Coefficients")
lines(tvp$date, tvp$unemployment_lag1_in_fedfunds_eq, lwd = 2, col = "#B64C3B")
abline(h = 0, col = "gray60")
legend("topright", legend = c("Inflation L1", "Unemployment L1"), col = c("#3B6FB6", "#B64C3B"), lwd = 2, bty = "n")
grid()
dev.off()

method_map <- data.frame(
  paper = c(
    "Del Negro and Schorfheide (2004)",
    "Litterman (1986)",
    "Kadiyala and Karlsson (1997)",
    "Sims and Zha (1998)",
    "Banbura, Giannone and Reichlin (2010)",
    "Giannone, Lenza and Primiceri (2015)",
    "Carriero, Clark and Marcellino (2015)",
    "Primiceri (2005)",
    "Bernanke, Boivin and Eliasz (2005)",
    "Stock and Watson (2002)"
  ),
  local_baseline = c(
    "DSGE-VAR dummy-observation formulas linked to existing Paccagnini code",
    "Minnesota BVAR forecast baseline with lambda = 0.2",
    "Official JAE data/code archive downloaded; formulas for Gibbs posterior documented",
    "Dummy-observation interpretation documented; Minnesota/Sims-Zha bridge baseline",
    "Medium/large FRED-MD BVAR shrinkage grid",
    "Marginal-likelihood lambda grid",
    "Forecast RMSE comparison across OLS, fixed Minnesota, selected lambda",
    "Rolling VAR coefficients as first-pass TVP approximation",
    "Two-step PCA FAVAR with policy IRF",
    "FRED-MD principal-component diffusion indexes"
  )
)
write.csv(method_map, file.path(results_dir, "selected_10_method_mapping.csv"), row.names = FALSE)

summary_md <- c(
  "# Baseline Replication Run",
  "",
  paste("Run date:", Sys.Date()),
  "",
  paste("Small BVAR selected lambda:", lambda_star),
  "",
  "## Outputs",
  "",
  "- `results/glp_lambda_grid_small_bvar.csv`",
  "- `results/bvar_forecast_comparison.csv`",
  "- `results/diffusion_factor_variance.csv`",
  "- `results/favar_policy_irf_baseline.csv`",
  "- `results/rolling_policy_rule_coefficients.csv`",
  "- `figures/diffusion_factor_variance.png`",
  "- `figures/favar_policy_irf_baseline.png`",
  "- `figures/rolling_policy_rule_coefficients.png`"
)
writeLines(summary_md, file.path(results_dir, "baseline_replication_summary.md"))

cat("Selected-next-10 baseline replication complete.\n")
cat("Selected lambda:", lambda_star, "\n")
print(forecast_comp)
