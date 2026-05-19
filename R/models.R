forward_model_matrices <- function() {
  t_mat <- matrix(c(
    0, 0, 3.2930, 0, 0.7251, 0.0476, 0, 0,
    0, 0, 0.1551, 0, 0.0932, 0.0169, 0, 0,
    0, 0, 0.3631, 0, 0.0246, 0.0157, 0, 0,
    0, 0, 0.2738, 0, 0.0492, 0.0313, 0, 0,
    0, 0, 0, 0, 0.8000, 0, 0, 0,
    0, 0, 0, 0, 0, 0.3000, 0, 0,
    0, 0, 0.1196, 0, 0.5882, 0.0091, 0, 0,
    0, 0, 0.0563, 0, 0.0708, 0.0026, 0, 0
  ), nrow = 8, byrow = TRUE)

  r_mat <- matrix(c(
    0.6585, 0.9064, 0.1587,
    0.3102, 0.1166, 0.0564,
    0.7262, 0.0308, 0.0522,
    0.5476, 0.0615, 0.1045,
    0, 0.6300, 0,
    0, 0, 0.8750,
    0.2391, 0.7352, 0.0304,
    0.1126, 0.0885, 0.0088
  ), nrow = 8, byrow = TRUE)

  list(t_mat = t_mat, r_mat = r_mat)
}

simulate_forward_dsge <- function(n_obs = 80, burn = 200, seed = NULL,
                                  log_gamma = 0.5, log_pi_star = 1.0,
                                  log_r_star = 0.5) {
  if (!is.null(seed)) set.seed(seed)
  mats <- forward_model_matrices()
  total <- n_obs + burn + 1
  states <- matrix(0, total, 8)

  for (tt in 2:total) {
    eps <- rnorm(3)
    states[tt, ] <- mats$t_mat %*% states[tt - 1, ] + mats$r_mat %*% eps
  }

  keep <- (burn + 1):total
  s <- states[keep, , drop = FALSE]
  dx <- c(NA_real_, diff(s[, 1])) + s[, 6] + log_gamma
  infl <- s[, 2] + log_pi_star
  rate <- 4 * (log_r_star + log_pi_star + s[, 3])
  y <- cbind(output_growth = dx, inflation = infl, interest_rate = rate)
  y <- y[-1, , drop = FALSE]
  y[seq_len(n_obs), , drop = FALSE]
}

backward_params <- function(sample = c("linde_whole", "linde_greenspan", "rs_whole")) {
  sample <- match.arg(sample)
  params <- switch(sample,
    linde_whole = c(
      a1 = 0.559, a2 = 0.293, a3 = 0.129, a4 = 0.019, ay = 0.052,
      by1 = 0.824, by2 = 0.099, br = -0.015, gamma_i = 0.80,
      sig_pi = 4.47, sig_y = 2.83, sig_i = 1.00
    ),
    linde_greenspan = c(
      a1 = 0.174, a2 = 0.077, a3 = 0.042, a4 = 0.002, ay = -0.003,
      by1 = 0.694, by2 = 0.214, br = -0.014, gamma_i = 0.80,
      sig_pi = 2.65, sig_y = 2.00, sig_i = 1.00
    ),
    rs_whole = c(
      a1 = 0.700, a2 = -0.100, a3 = 0.280, a4 = 0.120, ay = 0.140,
      by1 = 1.160, by2 = -0.250, br = -0.100, gamma_i = 0.80,
      sig_pi = 3.46, sig_y = 2.24, sig_i = 1.00
    )
  )
  params
}

simulate_backward_model <- function(n_obs = 80, burn = 200, seed = NULL,
                                    sample = "linde_whole") {
  if (!is.null(seed)) set.seed(seed)
  p <- backward_params(sample)
  total <- n_obs + burn + 4
  pi <- y <- i <- numeric(total)

  for (tt in 5:total) {
    real_rate_avg <- mean((i - pi)[(tt - 1):(tt - 4)])
    pi[tt] <- p["a1"] * pi[tt - 1] + p["a2"] * pi[tt - 2] +
      p["a3"] * pi[tt - 3] + p["a4"] * pi[tt - 4] +
      p["ay"] * y[tt - 1] + rnorm(1, sd = p["sig_pi"])
    y[tt] <- p["by1"] * y[tt - 1] + p["by2"] * y[tt - 2] +
      p["br"] * real_rate_avg + rnorm(1, sd = p["sig_y"])
    i[tt] <- p["gamma_i"] * i[tt - 1] + rnorm(1, sd = p["sig_i"])
  }

  keep <- (burn + 5):total
  out <- cbind(inflation = pi[keep], output_gap = y[keep], interest_rate = i[keep])
  out[seq_len(n_obs), , drop = FALSE]
}
