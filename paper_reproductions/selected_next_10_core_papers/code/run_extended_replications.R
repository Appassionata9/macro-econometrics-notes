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
  xtx <- crossprod(dat$x)
  b <- solve(xtx + diag(1e-8, ncol(xtx)), crossprod(dat$x, dat$y))
  e <- dat$y - dat$x %*% b
  sigma <- crossprod(e) / max(1, nrow(e) - ncol(dat$x))
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

iterated_forecast <- function(fit, history, p, h) {
  y_hist <- as.matrix(history)
  n <- ncol(y_hist)
  y_aug <- y_hist
  for (step in seq_len(h)) {
    xrow <- c(1)
    for (l in seq_len(p)) xrow <- c(xrow, y_aug[nrow(y_aug) + 1 - l, ])
    pred <- as.numeric(xrow %*% fit$b)
    y_aug <- rbind(y_aug, pred)
  }
  y_aug[nrow(y_aug), seq_len(n)]
}

holdout_rmse_h <- function(y, p, model = c("ols", "bvar"), lambda = 0.2, horizons = c(1, 6, 12), test_size = 60) {
  model <- match.arg(model)
  y <- as.matrix(y)
  train_end <- nrow(y) - test_size - max(horizons)
  fit_y <- y[1:train_end, , drop = FALSE]
  fit <- if (model == "ols") ols_var(fit_y, p) else bvar_fit_fixed_sigma(fit_y, p, lambda)
  out <- list()
  for (h in horizons) {
    preds <- matrix(NA_real_, test_size, ncol(y))
    actual <- matrix(NA_real_, test_size, ncol(y))
    for (i in seq_len(test_size)) {
      origin <- train_end + i - 1
      preds[i, ] <- iterated_forecast(fit, y[1:origin, , drop = FALSE], p, h)
      actual[i, ] <- y[origin + h, ]
    }
    rmse <- sqrt(colMeans((actual - preds)^2))
    out[[as.character(h)]] <- data.frame(horizon = h, variable = colnames(y), rmse = as.numeric(rmse))
  }
  do.call(rbind, out)
}

irf_var <- function(fit, p, horizon, shock_index) {
  b <- fit$b
  n <- ncol(b)
  shock <- t(chol(fit$sigma + diag(1e-8, ncol(fit$sigma))))[, shock_index]
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

direct_forecast_rmse <- function(y, factors, p = 4, horizons = c(6, 12, 24), test_size = 60) {
  y <- as.numeric(y)
  factors <- as.matrix(factors)
  out <- list()
  for (h in horizons) {
    rows <- (p + 1):(length(y) - h)
    target <- y[rows + h]
    x_ar <- matrix(1, nrow = length(rows), ncol = 1 + p)
    colnames(x_ar) <- c("const", paste0("y_L", seq_len(p)))
    for (l in seq_len(p)) x_ar[, l + 1] <- y[rows + 1 - l]
    x_di <- cbind(x_ar, factors[rows, , drop = FALSE])
    train_end <- length(rows) - test_size
    fit_ar <- lm.fit(x_ar[1:train_end, , drop = FALSE], target[1:train_end])
    fit_di <- lm.fit(x_di[1:train_end, , drop = FALSE], target[1:train_end])
    pred_ar <- x_ar[(train_end + 1):length(rows), , drop = FALSE] %*% fit_ar$coefficients
    pred_di <- x_di[(train_end + 1):length(rows), , drop = FALSE] %*% fit_di$coefficients
    actual <- target[(train_end + 1):length(rows)]
    out[[as.character(h)]] <- data.frame(
      horizon = h,
      model = c("AR", "AR plus diffusion factors"),
      rmse = c(
        sqrt(mean((actual - pred_ar)^2, na.rm = TRUE)),
        sqrt(mean((actual - pred_di)^2, na.rm = TRUE))
      )
    )
  }
  do.call(rbind, out)
}

md <- read_fred_md(file.path(raw_dir, "fred_md", "2026-04-md.csv"))
small <- make_small_macro(md)
small_y <- as.matrix(small[, c("ip_growth", "inflation", "unemployment", "fedfunds")])
colnames(small_y) <- c("ip_growth", "inflation", "unemployment", "fedfunds")

stationary <- make_stationary_panel(md)
use <- stationary[stationary$date >= as.Date("1985-01-01"), ]
candidate_cols <- setdiff(names(use), "date")
ok <- sapply(use[candidate_cols], function(z) mean(is.finite(z)) > 0.90 && sd(z, na.rm = TRUE) > 0)
panel <- use[, c("date", candidate_cols[ok]), drop = FALSE]
for (j in names(panel)[-1]) {
  z <- panel[[j]]
  z[!is.finite(z)] <- NA_real_
  z[is.na(z)] <- mean(z, na.rm = TRUE)
  panel[[j]] <- z
}
panel_scaled <- scale(panel[, -1])
pca <- prcomp(panel_scaled, center = FALSE, scale. = FALSE)
factors5 <- pca$x[, 1:5, drop = FALSE]
colnames(factors5) <- paste0("factor", 1:5)

sw_rows <- list()
for (target in c("ip_growth", "inflation")) {
  aligned <- merge(
    small[, c("date", target)],
    data.frame(date = panel$date, factors5),
    by = "date"
  )
  y <- aligned[[target]]
  f <- as.matrix(aligned[, paste0("factor", 1:5)])
  res <- direct_forecast_rmse(y, f, p = 4, horizons = c(6, 12, 24), test_size = 60)
  res$target <- target
  sw_rows[[target]] <- res
}
sw_forecasts <- do.call(rbind, sw_rows)
sw_forecasts <- sw_forecasts[, c("target", "horizon", "model", "rmse")]
write.csv(sw_forecasts, file.path(results_dir, "stock_watson_diffusion_forecast_rmse.csv"), row.names = FALSE)

system_sizes <- c(3, 10, 20, 50, 68)
lambda_by_size <- c("3" = 0.20, "10" = 0.10, "20" = 0.05, "50" = 0.02, "68" = 0.02)
target_cols <- c("INDPRO", "CPIAUCSL", "FEDFUNDS")
available_cols <- colnames(panel_scaled)
other_cols <- setdiff(available_cols, target_cols)
ordered_cols <- c(target_cols[target_cols %in% available_cols], other_cols)
bgr_rows <- list()
for (m in system_sizes[system_sizes <= length(ordered_cols)]) {
  y <- as.matrix(panel_scaled[, ordered_cols[seq_len(m)], drop = FALSE])
  fit_rows <- holdout_rmse_h(y, p = 4, model = "bvar", lambda = lambda_by_size[as.character(m)], horizons = c(1, 6, 12), test_size = 60)
  fit_rows <- fit_rows[fit_rows$variable %in% target_cols, , drop = FALSE]
  fit_rows$system_size <- m
  fit_rows$lambda <- lambda_by_size[as.character(m)]
  bgr_rows[[as.character(m)]] <- fit_rows
}
bgr <- do.call(rbind, bgr_rows)
bgr <- bgr[, c("system_size", "lambda", "horizon", "variable", "rmse")]
write.csv(bgr, file.path(results_dir, "bgr_system_size_bvar_rmse.csv"), row.names = FALSE)

ccm_rows <- list()
idx <- 1
for (p in c(2, 4, 6)) {
  for (lambda in c(0.10, 0.20, 0.30, 0.50)) {
    res <- holdout_rmse_h(small_y, p = p, model = "bvar", lambda = lambda, horizons = c(1, 6, 12), test_size = 60)
    res$p <- p
    res$lambda <- lambda
    ccm_rows[[idx]] <- res
    idx <- idx + 1
  }
}
ccm <- do.call(rbind, ccm_rows)
ccm <- ccm[, c("p", "lambda", "horizon", "variable", "rmse")]
write.csv(ccm, file.path(results_dir, "carriero_specification_grid.csv"), row.names = FALSE)

tvp_rows <- list()
idx <- 1
for (window in c(60, 120, 180)) {
  coefs <- list()
  tvp_y <- as.matrix(small[, c("inflation", "unemployment", "fedfunds")])
  colnames(tvp_y) <- c("inflation", "unemployment", "fedfunds")
  for (end in seq(window, nrow(tvp_y))) {
    ywin <- tvp_y[(end - window + 1):end, , drop = FALSE]
    fit <- ols_var(ywin, p = 2)
    coefs[[length(coefs) + 1]] <- data.frame(
      date = small$date[end],
      inflation_lag1 = fit$b[2, "fedfunds"],
      unemployment_lag1 = fit$b[3, "fedfunds"]
    )
  }
  coefs <- do.call(rbind, coefs)
  tvp_rows[[idx]] <- data.frame(
    window = window,
    coefficient = c("inflation_lag1", "unemployment_lag1"),
    mean = c(mean(coefs$inflation_lag1), mean(coefs$unemployment_lag1)),
    sd = c(sd(coefs$inflation_lag1), sd(coefs$unemployment_lag1)),
    min = c(min(coefs$inflation_lag1), min(coefs$unemployment_lag1)),
    max = c(max(coefs$inflation_lag1), max(coefs$unemployment_lag1))
  )
  idx <- idx + 1
}
tvp_sensitivity <- do.call(rbind, tvp_rows)
write.csv(tvp_sensitivity, file.path(results_dir, "primiceri_rolling_window_sensitivity.csv"), row.names = FALSE)

if (requireNamespace("readxl", quietly = TRUE)) {
  bbe_path <- file.path(base_dir, "bernanke_boivin_eliasz_2005_favar", "data", "raw", "bbe_data.xlsx")
  if (file.exists(bbe_path)) {
    bbe_data <- readxl::read_excel(bbe_path)
    bbe_x <- as.matrix(bbe_data[, -1])
    storage.mode(bbe_x) <- "numeric"
    bbe_scaled <- scale(bbe_x, center = TRUE, scale = TRUE)
    slow_vars <- c("IP", "LHUR", "PUNEW", "IPP", "IPF", "IPC", "IPCD", "IPCN", "IPE", "IPI", "IPM",
                   "IPMD", "IPMND", "IPMFG", "IPD", "IPN", "IPMIN", "IPUT", "IPXMCA", "PMI", "PMP",
                   "GMPYQ", "GMYXPQ", "LHEL", "LHELX", "LHEM", "LHNAG", "LHU680", "LHU5", "LHU14",
                   "LHU15", "LHU26", "LPNAG", "LP", "LPGD", "LPMI", "LPCC", "LPEM", "LPED", "LPEN",
                   "LPSP", "LPTU", "LPT", "LPFR", "LPS", "LPGOV", "LPHRM", "LPMOSA", "PMEMP", "GMCQ",
                   "GMCDQ", "GMCNQ", "GMCSQ", "GMCANQ", "PWFSA", "PWFCSA", "PWIMSA", "PWCMSA", "PSM99Q",
                   "PU83", "PU84", "PU85", "PUC", "PUCD", "PUS", "PUXF", "PUXHS", "PUXM", "LEHCC", "LEHM")
    slow_vars <- slow_vars[slow_vars %in% colnames(bbe_scaled)]
    pc_all <- prcomp(bbe_scaled, center = FALSE, scale. = FALSE, rank. = 3)$x[, 1:3]
    pc_slow <- prcomp(bbe_scaled[, slow_vars, drop = FALSE], center = FALSE, scale. = FALSE, rank. = 3)$x[, 1:3]
    fyff <- bbe_scaled[, "FYFF"]
    clean_reg <- lm(pc_all ~ pc_slow + fyff)
    f_hat <- pc_all - fyff %*% matrix(coef(clean_reg)[5, ], nrow = 1)
    colnames(f_hat) <- paste0("factor", 1:3)
    favar_y <- cbind(f_hat, FYFF = fyff)
    favar_fit <- ols_var(favar_y, p = 13)
    load_reg <- lm(bbe_scaled ~ 0 + f_hat + fyff)
    loadings <- coef(load_reg)
    load_summary <- summary(load_reg)
    variable_names <- c("Fed Funds Rate", "Industrial Production", "CPI", "3m Treasury Bills", "5y Treasury Bonds",
                        "Monetary Base", "M2", "Exchange Rate Yen", "Commodity Price Index", "Capacity Util Rate",
                        "Personal Consumption", "Durable Cons", "Nondurable Cons", "Unemployment", "Employment",
                        "Avg Hourly Earnings", "Housing Starts", "New Orders", "Dividends", "Consumer Expectations")
    variables <- c("FYFF", "IP", "PUNEW", "FYGM3", "FYGT5", "FMFBA", "FM2", "EXRJAN", "PMCP", "IPXMCA",
                   "GMCQ", "GMCDQ", "GMCNQ", "LHUR", "PMEMP", "LEHM", "HSFR", "PMNO", "FSDXP", "HHSNTN")
    variables <- variables[variables %in% colnames(bbe_scaled)]
    variable_names <- variable_names[seq_along(variables)]
    hor <- 60
    shock_irfs <- lapply(seq_len(ncol(favar_y)), function(s) irf_var(favar_fit, p = 13, horizon = hor, shock_index = s))
    policy_shock <- shock_irfs[[ncol(favar_y)]]
    scale_25bp <- (0.25 / sd(bbe_data$FYFF)) / policy_shock[1, ncol(favar_y)]
    bbe_rows <- list()
    for (i in seq_along(variables)) {
      var <- variables[i]
      idx <- which(colnames(bbe_scaled) == var)
      response_by_shock <- sapply(shock_irfs, function(irf) as.numeric(irf %*% loadings[, idx]))
      response_by_shock <- response_by_shock * scale_25bp
      shock_ss <- colSums(response_by_shock^2)
      sigma_e <- load_summary[[idx]]$sigma^2
      total <- sum(shock_ss) + sigma_e
      bbe_rows[[i]] <- data.frame(
        variable = variable_names[i],
        mnemonic = var,
        policy_contribution = shock_ss[ncol(favar_y)] / total,
        r_squared = load_summary[[idx]]$r.squared,
        factor_y_total = sum(shock_ss),
        measurement_error = sigma_e,
        total_variance_proxy = total
      )
    }
    bbe_table <- do.call(rbind, bbe_rows)
    write.csv(bbe_table, file.path(results_dir, "bbe_table_i_replication.csv"), row.names = FALSE)
  }
}

summary_md <- c(
  "# Extended Replication Run",
  "",
  paste("Run date:", Sys.Date()),
  "",
  "## Added Outputs",
  "",
  "- `results/stock_watson_diffusion_forecast_rmse.csv`",
  "- `results/bgr_system_size_bvar_rmse.csv`",
  "- `results/carriero_specification_grid.csv`",
  "- `results/primiceri_rolling_window_sensitivity.csv`",
  "- `results/bbe_table_i_replication.csv`",
  "",
  "These outputs extend the first-pass baseline toward paper-specific replication targets."
)
writeLines(summary_md, file.path(results_dir, "extended_replication_summary.md"))

cat("Selected-next-10 extended replication complete.\n")
cat("Wrote Stock-Watson, BGR, CCM, Primiceri and BBE extended outputs.\n")
