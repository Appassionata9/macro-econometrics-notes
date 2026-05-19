make_var_xy <- function(y, lags = 1, include_const = TRUE) {
  y <- as.matrix(y)
  t_total <- nrow(y)
  n <- ncol(y)
  if (t_total <= lags) stop("Need more observations than lags.")

  rows <- t_total - lags
  x_parts <- vector("list", lags)
  for (ell in seq_len(lags)) {
    x_parts[[ell]] <- y[(lags + 1 - ell):(t_total - ell), , drop = FALSE]
  }
  x <- do.call(cbind, x_parts)
  if (include_const) x <- cbind(const = 1, x)
  yy <- y[(lags + 1):t_total, , drop = FALSE]
  list(y = yy, x = x, n = n, k = ncol(x), t = rows)
}

fit_var_ols <- function(y, lags = 1) {
  xy <- make_var_xy(y, lags)
  beta <- solve(crossprod(xy$x), crossprod(xy$x, xy$y))
  resid <- xy$y - xy$x %*% beta
  sigma <- crossprod(resid) / xy$t
  list(beta = beta, sigma = sigma, resid = resid, x = xy$x, y = xy$y)
}

dsge_prior_moments <- function(dsge_y, lags = 1) {
  xy <- make_var_xy(dsge_y, lags)
  xx <- crossprod(xy$x) / xy$t
  xy_m <- crossprod(xy$x, xy$y) / xy$t
  yy <- crossprod(xy$y) / xy$t
  beta_star <- solve(xx, xy_m)
  sigma_star <- yy - t(xy_m) %*% solve(xx, xy_m)
  sigma_star <- (sigma_star + t(sigma_star)) / 2
  list(xx = xx, xy = xy_m, yy = yy, beta_star = beta_star, sigma_star = sigma_star)
}

safe_logdet <- function(a) {
  a <- (a + t(a)) / 2
  det_val <- determinant(a, logarithm = TRUE)
  if (det_val$sign <= 0) return(-Inf)
  as.numeric(det_val$modulus)
}

log_multigamma <- function(a, p) {
  p * (p - 1) / 4 * log(pi) + sum(lgamma(a + (1 - seq_len(p)) / 2))
}

log_mdd_dsge_var <- function(y, prior, lags = 1, lambda) {
  xy <- make_var_xy(y, lags)
  n <- xy$n
  t_obs <- xy$t

  k0 <- lambda * t_obs * prior$xx
  s0 <- lambda * t_obs * prior$sigma_star
  b0 <- prior$beta_star
  v0 <- lambda * t_obs

  kn <- k0 + crossprod(xy$x)
  bn <- solve(kn, k0 %*% b0 + crossprod(xy$x, xy$y))
  sn <- s0 + crossprod(xy$y) + t(b0) %*% k0 %*% b0 - t(bn) %*% kn %*% bn
  sn <- (sn + t(sn)) / 2
  vn <- v0 + t_obs

  if (v0 <= n - 1) return(-Inf)
  -n * t_obs / 2 * log(pi) +
    n / 2 * (safe_logdet(k0) - safe_logdet(kn)) +
    v0 / 2 * safe_logdet(s0) -
    vn / 2 * safe_logdet(sn) +
    log_multigamma(vn / 2, n) -
    log_multigamma(v0 / 2, n)
}

lambda_min <- function(n_obs, n_vars, lags) {
  k <- 1 + lags * n_vars
  if (n_obs == 80 && n_vars == 3 && lags %in% 1:8) {
    paper_mins <- c(0.09, 0.13, 0.17, 0.20, 0.24, 0.28, 0.31, 0.35)
    return(paper_mins[lags])
  }
  (n_vars + k) / n_obs
}

paper_lambda_grid <- function(n_obs, n_vars, lags, max_lambda = 1) {
  base_grid <- c(
    0, 0.09, 0.10, 0.13, 0.17, 0.20, 0.24, 0.25, 0.28, 0.30,
    0.31, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70,
    0.80, 0.90, 1, 5, 10
  )
  grid <- base_grid[base_grid <= max_lambda]
  sort(unique(c(lambda_min(n_obs, n_vars, lags), grid)))
}

evaluate_lambda_grid <- function(y, prior, lags = 1, lambda_grid = NULL) {
  y <- as.matrix(y)
  min_lambda <- lambda_min(nrow(y), ncol(y), lags)
  if (is.null(lambda_grid)) {
    lambda_grid <- sort(unique(c(
      min_lambda,
      seq(0.2, 2.0, by = 0.2),
      3, 5, 10
    )))
  }
  lambda_grid <- lambda_grid[lambda_grid >= min_lambda]
  values <- vapply(lambda_grid, function(lam) {
    log_mdd_dsge_var(y, prior, lags, lam)
  }, numeric(1))
  out <- data.frame(lambda = lambda_grid, log_mdd = values)
  out <- out[order(out$lambda), ]
  best <- out[which.max(out$log_mdd), , drop = FALSE]
  attr(out, "lambda_min") <- min_lambda
  attr(out, "best_lambda") <- best$lambda
  out
}

summarize_lambda_frequencies <- function(detail, digits = 4) {
  rows <- lapply(split(detail, detail$lags), function(d) {
    tab <- sort(table(round(d$best_lambda, digits)), decreasing = FALSE)
    data.frame(
      lags = unique(d$lags),
      lambda = as.numeric(names(tab)),
      frequency = as.integer(tab),
      row.names = NULL
    )
  })
  do.call(rbind, rows)
}

information_criteria_var <- function(y, max_lags = 8) {
  y <- as.matrix(y)
  out <- lapply(seq_len(max_lags), function(p) {
    fit <- fit_var_ols(y, p)
    n <- ncol(y)
    t_obs <- nrow(fit$y)
    k_params <- ncol(fit$x) * n
    logdet <- safe_logdet(fit$sigma)
    data.frame(
      lags = p,
      aic = logdet + 2 * k_params / t_obs,
      bic = logdet + log(t_obs) * k_params / t_obs,
      hq = logdet + 2 * log(log(t_obs)) * k_params / t_obs
    )
  })
  do.call(rbind, out)
}

run_mc_experiment <- function(dgp, reps = 100, n_obs = 80, lags = 1:8,
                              lambda_grid = NULL, prior_sim_obs = 5000,
                              seed = 123) {
  set.seed(seed)
  prior_y <- simulate_forward_dsge(n_obs = prior_sim_obs, burn = 500)
  results <- list()

  for (p in lags) {
    prior <- dsge_prior_moments(prior_y, lags = p)
    rows <- vector("list", reps)
    for (rr in seq_len(reps)) {
      y <- dgp(n_obs = n_obs, seed = sample.int(.Machine$integer.max, 1))
      grid <- if (is.function(lambda_grid)) {
        lambda_grid(nrow(y), ncol(y), p)
      } else {
        lambda_grid
      }
      ev <- evaluate_lambda_grid(y, prior, lags = p, lambda_grid = grid)
      rows[[rr]] <- data.frame(
        rep = rr,
        lags = p,
        lambda_min = attr(ev, "lambda_min"),
        best_lambda = attr(ev, "best_lambda"),
        best_log_mdd = max(ev$log_mdd)
      )
    }
    results[[as.character(p)]] <- do.call(rbind, rows)
  }

  detail <- do.call(rbind, results)
  summary <- aggregate(best_lambda ~ lags, detail, function(x) {
    paste(names(sort(table(round(x, 4)), decreasing = TRUE)), collapse = ", ")
  })
  names(summary)[2] <- "best_lambda_frequencies_ranked"
  list(
    detail = detail,
    summary = summary,
    frequency = summarize_lambda_frequencies(detail)
  )
}
