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
old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(root)

paper_dir <- file.path(root, "paper_reproductions", "koop_korobilis_2010_bayesian_multivariate_time_series")
processed <- file.path(paper_dir, "data", "processed")
results <- file.path(paper_dir, "results")
figures <- file.path(paper_dir, "figures")
dir.create(results, recursive = TRUE, showWarnings = FALSE)
dir.create(figures, recursive = TRUE, showWarnings = FALSE)

set.seed(20260519)

vars <- c("inflation", "unemployment", "tbill_rate")
coef_names <- c(
  "Intercept",
  paste0(rep(c("inflation", "unemployment", "tbill_rate"), 4), "_lag", rep(1:4, each = 3))
)

mlag <- function(y, p) {
  y <- as.matrix(y)
  n <- nrow(y)
  m <- ncol(y)
  out <- matrix(0, n, m * p)
  for (lag in seq_len(p)) {
    out[(lag + 1):n, ((lag - 1) * m + 1):(lag * m)] <- y[1:(n - lag), ]
  }
  out
}

build_direct_forecast_var <- function(y, p = 4, h = 1) {
  y <- as.matrix(y)
  n <- nrow(y)
  m <- ncol(y)
  y1 <- y[(h + 1):n, , drop = FALSE]
  y2 <- y[2:(n - h), , drop = FALSE]
  t_raw <- n - h - 1
  y_lag <- mlag(y2, p)
  x1 <- cbind(1, y_lag[(p + 1):t_raw, , drop = FALSE])
  y1 <- y1[(p + 1):t_raw, , drop = FALSE]
  t_eff <- t_raw - p

  y_est <- y1[1:(nrow(y1) - 1), , drop = FALSE]
  x_est <- x1[1:(nrow(x1) - 1), , drop = FALSE]
  t_eff <- t_eff - 1
  x_forecast <- matrix(c(1, y_est[t_eff, ], x_est[t_eff, 2:(m * (p - 1) + 1)]), nrow = 1)
  true_value <- y1[t_eff + 1, , drop = FALSE]

  list(y = y_est, x = x_est, t = t_eff, m = m, k = ncol(x_est), x_forecast = x_forecast, true_value = true_value)
}

ols_var <- function(y, x) {
  beta <- solve(crossprod(x), crossprod(x, y))
  resid <- y - x %*% beta
  sse <- crossprod(resid)
  list(beta = beta, resid = resid, sse = sse)
}

rinvwishart <- function(scale, df) {
  solve(rWishart(1, df, solve(scale))[, , 1])
}

rmvnorm_chol <- function(mean, cov) {
  as.numeric(mean + t(chol((cov + t(cov)) / 2)) %*% rnorm(length(mean)))
}

minnesota_prior <- function(yraw, d, p = 4, p_min = 6) {
  m <- d$m
  k <- d$k
  a_prior_mat <- rbind(matrix(0, 1, m), 0.9 * diag(m), matrix(0, (p - 1) * m, m))
  a_prior <- as.numeric(a_prior_mat)

  sigma_sq <- numeric(m)
  for (i in seq_len(m)) {
    yi <- matrix(yraw[, i], ncol = 1)
    yi_lag <- mlag(yi, p)
    x_i <- cbind(1, yi_lag[(p_min + 1):nrow(yraw), , drop = FALSE])
    y_i <- yi[(p_min + 1):nrow(yraw), , drop = FALSE]
    beta_i <- solve(crossprod(x_i), crossprod(x_i, y_i))
    sigma_sq[i] <- as.numeric(crossprod(y_i - x_i %*% beta_i) / (nrow(yraw) - p_min))
  }

  a_bar_1 <- 0.5
  a_bar_2 <- 0.5
  a_bar_3 <- 100
  v_i <- matrix(0, k, m)
  own_lags <- matrix(0, m, p)
  for (i in seq_len(m)) own_lags[i, ] <- 1 + i + (0:(p - 1)) * m

  for (i in seq_len(m)) {
    for (j in seq_len(k)) {
      if (j == 1) {
        v_i[j, i] <- a_bar_3 * sigma_sq[i]
      } else if (j %in% own_lags[i, ]) {
        lag <- ceiling((j - 1) / m)
        v_i[j, i] <- a_bar_1 / lag^2
      } else {
        source_var <- which(apply(own_lags, 1, function(idx) j %in% idx))
        lag <- ceiling((j - 1) / m)
        v_i[j, i] <- (a_bar_2 * sigma_sq[i]) / (lag^2 * sigma_sq[source_var])
      }
    }
  }

  list(a_prior = a_prior, v_prior = diag(as.numeric(v_i)), sigma = diag(sigma_sq))
}

posterior_draws <- function(prior_name, yraw, d, ndraw = 10000) {
  fit <- ols_var(d$y, d$x)
  beta_ols <- fit$beta
  a_ols <- as.numeric(beta_ols)
  sse <- fit$sse
  xpx_inv <- solve(crossprod(d$x))

  draws <- matrix(NA_real_, ndraw, d$k * d$m)
  sigma_draws <- array(NA_real_, dim = c(ndraw, d$m, d$m))
  pred_draws <- matrix(NA_real_, ndraw, d$m)
  beta_mean <- NULL

  if (prior_name == "noninformative") {
    beta_mean <- beta_ols
    for (r in seq_len(ndraw)) {
      sigma <- rinvwishart(sse, d$t - d$k)
      alpha <- rmvnorm_chol(a_ols, kronecker(sigma, xpx_inv))
      beta <- matrix(alpha, d$k, d$m)
      pred_mean <- as.numeric(d$x_forecast %*% beta)
      pred <- rmvnorm_chol(pred_mean, sigma)
      draws[r, ] <- alpha
      sigma_draws[r, , ] <- sigma
      pred_draws[r, ] <- pred
    }
  } else if (prior_name == "minnesota") {
    prior <- minnesota_prior(yraw, d)
    sigma <- prior$sigma
    v_post <- solve(solve(prior$v_prior) + kronecker(solve(sigma), crossprod(d$x)))
    a_post <- v_post %*% (solve(prior$v_prior) %*% prior$a_prior + kronecker(solve(sigma), crossprod(d$x)) %*% a_ols)
    beta_mean <- matrix(a_post, d$k, d$m)
    for (r in seq_len(ndraw)) {
      alpha <- rmvnorm_chol(as.numeric(a_post), v_post)
      beta <- matrix(alpha, d$k, d$m)
      pred_mean <- as.numeric(d$x_forecast %*% beta)
      pred <- rmvnorm_chol(pred_mean, sigma)
      draws[r, ] <- alpha
      sigma_draws[r, , ] <- sigma
      pred_draws[r, ] <- pred
    }
  } else if (prior_name == "natural_conjugate") {
    a_prior_mat <- matrix(0, d$k, d$m)
    v_prior <- 10 * diag(d$k)
    s_prior <- diag(d$m)
    v_prior_df <- d$m + 1
    v_post <- solve(solve(v_prior) + crossprod(d$x))
    beta_post <- v_post %*% (solve(v_prior) %*% a_prior_mat + crossprod(d$x) %*% beta_ols)
    s_post <- sse + s_prior + t(beta_ols) %*% crossprod(d$x) %*% beta_ols +
      t(a_prior_mat) %*% solve(v_prior) %*% a_prior_mat -
      t(beta_post) %*% (solve(v_prior) + crossprod(d$x)) %*% beta_post
    df_post <- d$t + v_prior_df
    beta_mean <- beta_post
    for (r in seq_len(ndraw)) {
      sigma <- rinvwishart(s_post, df_post)
      alpha <- rmvnorm_chol(as.numeric(beta_post), kronecker(sigma, v_post))
      beta <- matrix(alpha, d$k, d$m)
      pred_mean <- as.numeric(d$x_forecast %*% beta)
      pred <- rmvnorm_chol(pred_mean, sigma)
      draws[r, ] <- alpha
      sigma_draws[r, , ] <- sigma
      pred_draws[r, ] <- pred
    }
  } else {
    stop("Unknown prior: ", prior_name)
  }

  list(beta_mean = beta_mean, alpha_draws = draws, sigma_draws = sigma_draws, pred_draws = pred_draws)
}

impulse_response <- function(beta, sigma, p = 4, horizon = 24) {
  m <- ncol(beta)
  b <- array(0, dim = c(m, m, p))
  for (lag in seq_len(p)) {
    rows <- 1 + ((lag - 1) * m + 1):(lag * m)
    b[, , lag] <- t(beta[rows, , drop = FALSE])
  }
  shock <- t(chol(sigma))
  shock <- solve(diag(diag(shock)), shock)

  phi <- array(0, dim = c(horizon, m, m))
  phi[1, , ] <- diag(m)
  for (h in 2:horizon) {
    acc <- matrix(0, m, m)
    for (lag in seq_len(min(p, h - 1))) {
      acc <- acc + b[, , lag] %*% phi[h - lag, , ]
    }
    phi[h, , ] <- acc
  }
  out <- array(0, dim = c(horizon, m, m))
  for (h in seq_len(horizon)) out[h, , ] <- phi[h, , ] %*% shock
  out
}

author <- read.csv(file.path(processed, "author_yraw_1953q1_2006q3.csv"))
yraw <- as.matrix(author[, vars])
d <- build_direct_forecast_var(yraw, p = 4, h = 1)

png(file.path(figures, "figure1_author_data.png"), width = 1200, height = 800, res = 140)
op <- par(mfrow = c(3, 1), mar = c(3, 4, 2, 1))
for (v in vars) {
  plot(author[[v]], type = "l", col = "#2F6B9A", xlab = "", ylab = v, main = v, lwd = 1.4)
}
par(op)
dev.off()

ndraw <- 15000
priors <- c("noninformative", "minnesota", "natural_conjugate")
posterior <- lapply(priors, posterior_draws, yraw = yraw, d = d, ndraw = ndraw)
names(posterior) <- priors

table1_noninfo <- data.frame(
  coefficient = coef_names,
  round(posterior$noninformative$beta_mean, 4),
  row.names = NULL
)
names(table1_noninfo)[2:4] <- vars
write.csv(table1_noninfo, file.path(results, "table1_noninformative_posterior_mean.csv"), row.names = FALSE)

paper_table1_noninfo <- data.frame(
  coefficient = coef_names,
  inflation_paper = c(0.2920, 1.5087, -0.2664, -0.0570, -0.4678, 0.1967, 0.0626, -0.0774, -0.0142, -0.0073, 0.0369, 0.0372, -0.0013),
  unemployment_paper = c(0.3222, 0.0040, 1.2727, -0.0211, 0.1005, -0.3102, -0.0229, -0.1879, -0.1293, 0.0967, 0.1150, 0.0669, -0.0254),
  tbill_rate_paper = c(-0.0138, 0.5493, -0.7192, 0.7746, -0.7745, 0.7883, -0.0288, 0.8170, -0.3547, 0.0996, -0.4851, 0.3108, 0.0591)
)
write.csv(paper_table1_noninfo, file.path(results, "paper_table1_noninformative_targets.csv"), row.names = FALSE)

table1_comparison <- merge(table1_noninfo, paper_table1_noninfo, by = "coefficient")
for (v in vars) {
  table1_comparison[[paste0(v, "_diff")]] <- table1_comparison[[v]] - table1_comparison[[paste0(v, "_paper")]]
}
write.csv(table1_comparison, file.path(results, "table1_noninformative_comparison.csv"), row.names = FALSE)

forecast_table <- do.call(rbind, lapply(priors, function(pr) {
  pred <- posterior[[pr]]$pred_draws
  data.frame(
    prior = pr,
    inflation_mean = mean(pred[, 1]),
    inflation_sd = sd(pred[, 1]),
    unemployment_mean = mean(pred[, 2]),
    unemployment_sd = sd(pred[, 2]),
    tbill_rate_mean = mean(pred[, 3]),
    tbill_rate_sd = sd(pred[, 3])
  )
}))
true_row <- data.frame(
  prior = "true_value",
  inflation_mean = d$true_value[1, 1],
  inflation_sd = NA_real_,
  unemployment_mean = d$true_value[1, 2],
  unemployment_sd = NA_real_,
  tbill_rate_mean = d$true_value[1, 3],
  tbill_rate_sd = NA_real_
)
forecast_table <- rbind(forecast_table, true_row)
write.csv(forecast_table, file.path(results, "table3_predictive_analytical_priors.csv"), row.names = FALSE)

paper_table3 <- data.frame(
  prior = c("noninformative", "minnesota", "natural_conjugate", "true_value"),
  inflation_mean_paper = c(3.105, 3.124, 3.106, 3.275),
  inflation_sd_paper = c(0.315, 0.302, 0.313, NA),
  unemployment_mean_paper = c(4.610, 4.628, 4.611, 4.700),
  unemployment_sd_paper = c(0.318, 0.319, 0.314, NA),
  tbill_rate_mean_paper = c(4.382, 4.350, 4.380, 4.600),
  tbill_rate_sd_paper = c(0.776, 0.741, 0.748, NA)
)
write.csv(paper_table3, file.path(results, "paper_table3_analytical_targets.csv"), row.names = FALSE)
comparison <- merge(forecast_table, paper_table3, by = "prior", all.x = TRUE)
for (v in vars) {
  comparison[[paste0(v, "_mean_diff")]] <- comparison[[paste0(v, "_mean")]] - comparison[[paste0(v, "_mean_paper")]]
  comparison[[paste0(v, "_sd_diff")]] <- comparison[[paste0(v, "_sd")]] - comparison[[paste0(v, "_sd_paper")]]
}
write.csv(comparison, file.path(results, "table3_predictive_comparison.csv"), row.names = FALSE)

ir_draws <- posterior$noninformative
horizon <- 24
keep <- seq(1, ndraw, length.out = 3000)
ir_array <- array(NA_real_, dim = c(length(keep), horizon, 3, 3))
for (ii in seq_along(keep)) {
  r <- keep[ii]
  beta <- matrix(ir_draws$alpha_draws[r, ], d$k, d$m)
  sigma <- ir_draws$sigma_draws[r, , ]
  ir_array[ii, , , ] <- impulse_response(beta, sigma, p = 4, horizon = horizon)
}
ir_summary <- data.frame()
for (shock in seq_len(3)) {
  for (response in seq_len(3)) {
    vals <- ir_array[, , response, shock]
    qs <- apply(vals, 2, quantile, probs = c(0.10, 0.50, 0.90), na.rm = TRUE)
    ir_summary <- rbind(
      ir_summary,
      data.frame(
        shock = vars[shock],
        response = vars[response],
        horizon = seq_len(horizon),
        q10 = qs[1, ],
        median = qs[2, ],
        q90 = qs[3, ]
      )
    )
  }
}
write.csv(ir_summary, file.path(results, "irf_noninformative_summary.csv"), row.names = FALSE)

png(file.path(figures, "figure2_irf_noninformative.png"), width = 1300, height = 1000, res = 140)
op <- par(mfrow = c(3, 3), mar = c(3, 3, 3, 1))
for (shock in vars) {
  for (response in vars) {
    sub <- ir_summary[ir_summary$shock == shock & ir_summary$response == response, ]
    ylim <- range(c(sub$q10, sub$q90, 0), na.rm = TRUE)
    plot(sub$horizon, sub$median, type = "l", lwd = 1.5, col = "#1F4E79", ylim = ylim,
         xlab = "", ylab = "", main = paste(response, "to", shock))
    lines(sub$horizon, sub$q10, lty = 2, col = "#777777")
    lines(sub$horizon, sub$q90, lty = 2, col = "#777777")
    abline(h = 0, col = "#BBBBBB")
  }
}
par(op)
dev.off()

cat("BVAR replication outputs written to:", results, "\n")
print(table1_noninfo)
print(forecast_table)
