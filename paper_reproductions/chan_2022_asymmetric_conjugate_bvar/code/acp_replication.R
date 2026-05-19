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

paper_dir <- file.path(root, "paper_reproductions", "chan_2022_asymmetric_conjugate_bvar")
processed <- file.path(paper_dir, "data", "processed")
results <- file.path(paper_dir, "results")
figures <- file.path(paper_dir, "figures")
dir.create(results, recursive = TRUE, showWarnings = FALSE)
dir.create(figures, recursive = TRUE, showWarnings = FALSE)

set.seed(20260519)

read_author_data <- function(nvars = 15) {
  file <- if (nvars == 6) "author_database_6var_1985q1_2019q4.csv" else "author_database_15var_1985q1_2019q4.csv"
  d <- read.csv(file.path(processed, file), stringsAsFactors = FALSE, check.names = FALSE)
  y <- as.matrix(d[, -1])
  storage.mode(y) <- "double"
  list(quarters = d$quarter, y = y, names = names(d)[-1])
}

build_lag_matrix <- function(y0, y, p) {
  t_obs <- nrow(y)
  n <- ncol(y)
  tmp <- rbind(tail(y0, p), y)
  z <- matrix(0, t_obs, n * p)
  for (lag in seq_len(p)) {
    z[, ((lag - 1) * n + 1):(lag * n)] <- tmp[(p - lag + 1):(p - lag + t_obs), , drop = FALSE]
  }
  cbind(1, z)
}

resid_var <- function(y0, y) {
  p <- 4
  sig2 <- numeric(ncol(y))
  for (i in seq_len(ncol(y))) {
    yi0 <- matrix(y0[, i], ncol = 1)
    yi <- matrix(y[, i], ncol = 1)
    z <- build_lag_matrix(yi0, yi, p)
    fit <- lm.fit(z, yi[, 1])
    sig2[i] <- mean(fit$residuals^2)
  }
  sig2
}

prior_acp <- function(n, p, kappa, sig2, idx_ns = integer()) {
  k_beta <- n * p + 1
  beta0 <- matrix(0, k_beta, n)
  vbeta <- matrix(0, k_beta, n)
  alp0 <- numeric(n * (n - 1) / 2)
  valp <- numeric(n * (n - 1) / 2)
  nu <- numeric(n)
  s <- numeric(n)
  count <- 0
  for (i in seq_len(n)) {
    ki <- n * p + i
    mi <- numeric(ki)
    vi <- numeric(ki)
    for (j in seq_len(ki)) {
      if (j <= n * p + 1) {
        lag <- ceiling((j - 1) / n)
        idx <- (j - 1) %% n
        if (idx == 0) idx <- n
      } else {
        idx <- j - (n * p + 1)
      }
      if (j == 1) {
        vi[j] <- kappa[4]
      } else if (j > n * p + 1) {
        vi[j] <- kappa[3] / sig2[idx]
      } else if (idx == i) {
        vi[j] <- kappa[1] / (lag^2 * sig2[idx])
        if (lag == 1 && i %in% idx_ns) mi[j] <- 1
      } else {
        vi[j] <- kappa[2] / (lag^2 * sig2[idx])
      }
    }
    beta0[, i] <- mi[1:k_beta]
    vbeta[, i] <- vi[1:k_beta]
    if (i > 1) {
      alp0[(count + 1):(count + i - 1)] <- mi[(k_beta + 1):ki]
      valp[(count + 1):(count + i - 1)] <- vi[(k_beta + 1):ki]
    }
    nu[i] <- 1 + i / 2
    s[i] <- sig2[i] / 2
    count <- count + i - 1
  }
  list(beta0 = beta0, vbeta = vbeta, alp0 = alp0, valp = valp, nu = nu, s = s)
}

prior_acp_reduced_elicitation <- function(n, p, kappa, sig2, idx_ns = integer()) {
  prior <- prior_acp(n, p, kappa, sig2, idx_ns)
  vbeta_stru <- prior$vbeta
  beta0_stru <- prior$beta0
  for (i in seq_len(n)) {
    if (i == 1) next
    for (j in seq_len(n * p + 1)) {
      prior$vbeta[j, i] <- vbeta_stru[j, i] +
        sum(vbeta_stru[j, 1:(i - 1)] + beta0_stru[j, 1:(i - 1)]^2 / sig2[1:(i - 1)])
    }
  }
  prior
}

log_ml_acp <- function(y, z, prior, p) {
  t_obs <- nrow(y)
  n <- ncol(y)
  lml <- -n * t_obs / 2 * log(2 * pi)
  count <- 0
  for (i in seq_len(n)) {
    yi <- y[, i]
    xi <- cbind(z, -y[, seq_len(i - 1), drop = FALSE])
    ki <- n * p + i
    mi <- c(prior$beta0[, i], if (i > 1) prior$alp0[(count + 1):(count + i - 1)] else numeric())
    vi <- c(prior$vbeta[, i], if (i > 1) prior$valp[(count + 1):(count + i - 1)] else numeric())
    inv_vi <- 1 / vi
    ktheta <- crossprod(xi) + diag(inv_vi, ki)
    chol_k <- chol(ktheta)
    rhs <- inv_vi * mi + crossprod(xi, yi)
    theta_hat <- backsolve(chol_k, forwardsolve(t(chol_k), rhs))
    s_hat <- prior$s[i] + as.numeric(crossprod(yi) + sum(mi^2 * inv_vi) - crossprod(theta_hat, ktheta %*% theta_hat)) / 2
    lml <- lml -
      0.5 * (sum(log(vi)) + 2 * sum(log(diag(chol_k)))) +
      prior$nu[i] * log(prior$s[i]) -
      (prior$nu[i] + t_obs / 2) * log(s_hat) +
      lgamma(prior$nu[i] + t_obs / 2) -
      lgamma(prior$nu[i])
    count <- count + i - 1
  }
  lml
}

evaluate_kappa <- function(y0, y, p, kappa1, kappa2, idx_ns) {
  z <- build_lag_matrix(y0, y, p)
  sig2 <- resid_var(y0, y)
  prior <- prior_acp_reduced_elicitation(ncol(y), p, c(kappa1, kappa2, 1, 100), sig2, idx_ns)
  log_ml_acp(y, z, prior, p)
}

optimize_asymmetric <- function(y0, y, p, idx_ns) {
  obj <- function(x) -evaluate_kappa(y0, y, p, exp(x[1]), exp(x[2]), idx_ns)
  fit <- optim(log(c(0.04, 0.0016)), obj, method = "Nelder-Mead", control = list(maxit = 200))
  c(kappa1 = exp(fit$par[1]), kappa2 = exp(fit$par[2]), log_ml = -fit$value, convergence = fit$convergence)
}

optimize_symmetric <- function(y0, y, p, idx_ns) {
  obj <- function(x) -evaluate_kappa(y0, y, p, exp(x[1]), exp(x[1]), idx_ns)
  fit <- optim(log(0.01), obj, method = "Brent", lower = log(1e-5), upper = log(2))
  c(kappa1 = exp(fit$par[1]), kappa2 = exp(fit$par[1]), log_ml = -fit$value, convergence = fit$convergence)
}

sample_acp <- function(y0, y, p, prior, nsim = 1000) {
  z <- build_lag_matrix(y0, y, p)
  n <- ncol(y)
  k_beta <- n * p + 1
  beta <- array(NA_real_, dim = c(nsim, k_beta, n))
  sig <- matrix(NA_real_, nsim, n)
  count <- 0
  for (i in seq_len(n)) {
    yi <- y[, i]
    xi <- cbind(z, -y[, seq_len(i - 1), drop = FALSE])
    ki <- n * p + i
    mi <- c(prior$beta0[, i], if (i > 1) prior$alp0[(count + 1):(count + i - 1)] else numeric())
    vi <- c(prior$vbeta[, i], if (i > 1) prior$valp[(count + 1):(count + i - 1)] else numeric())
    inv_vi <- 1 / vi
    ktheta <- crossprod(xi) + diag(inv_vi, ki)
    chol_k <- chol(ktheta)
    rhs <- inv_vi * mi + crossprod(xi, yi)
    theta_hat <- backsolve(chol_k, forwardsolve(t(chol_k), rhs))
    s_hat <- prior$s[i] + as.numeric(crossprod(yi) + sum(mi^2 * inv_vi) - crossprod(theta_hat, ktheta %*% theta_hat)) / 2
    sig_i <- 1 / rgamma(nsim, shape = prior$nu[i] + nrow(y) / 2, rate = s_hat)
    u <- matrix(rnorm(nsim * ki), nsim, ki) * sqrt(sig_i)
    theta <- matrix(theta_hat, nsim, ki, byrow = TRUE) + u %*% solve(chol_k)
    beta[, , i] <- theta[, 1:k_beta]
    sig[, i] <- sig_i
    count <- count + i - 1
  }
  list(beta = beta, sig = sig)
}

run_dataset <- function(nvars, idx_ns, nsim = 2000) {
  dat <- read_author_data(nvars)
  p <- 5
  y0 <- dat$y[1:8, , drop = FALSE]
  y <- dat$y[9:nrow(dat$y), , drop = FALSE]
  z <- build_lag_matrix(y0, y, p)
  sig2 <- resid_var(y0, y)
  asym <- optimize_asymmetric(y0, y, p, idx_ns)
  sym <- optimize_symmetric(y0, y, p, idx_ns)
  subj_prior <- prior_acp_reduced_elicitation(nvars, p, c(0.04, 0.0016, 1, 100), sig2, idx_ns)
  subj_ml <- log_ml_acp(y, z, subj_prior, p)
  asym_prior <- prior_acp_reduced_elicitation(nvars, p, c(asym["kappa1"], asym["kappa2"], 1, 100), sig2, idx_ns)
  draws <- sample_acp(y0, y, p, asym_prior, nsim)
  beta_mean <- apply(draws$beta, c(2, 3), mean)
  beta_sd <- apply(draws$beta, c(2, 3), sd)
  list(
    dat = dat,
    y = y,
    hyper = rbind(
      data.frame(dataset = paste0(nvars, "var"), prior = "symmetric", kappa1 = sym["kappa1"], kappa2 = sym["kappa2"], log_ml = sym["log_ml"]),
      data.frame(dataset = paste0(nvars, "var"), prior = "subjective", kappa1 = 0.04, kappa2 = 0.0016, log_ml = subj_ml),
      data.frame(dataset = paste0(nvars, "var"), prior = "asymmetric", kappa1 = asym["kappa1"], kappa2 = asym["kappa2"], log_ml = asym["log_ml"])
    ),
    beta_mean = beta_mean,
    beta_sd = beta_sd,
    sig_mean = colMeans(draws$sig)
  )
}

res6 <- run_dataset(6, idx_ns = c(1, 2, 4, 5), nsim = 2000)
res15 <- run_dataset(15, idx_ns = c(1, 2, 4, 5, 10, 11, 12, 13, 15), nsim = 1000)
hyper <- rbind(res6$hyper, res15$hyper)
write.csv(hyper, file.path(results, "hyperparameter_comparison.csv"), row.names = FALSE)

paper_table2 <- data.frame(
  prior = c("symmetric", "subjective", "asymmetric"),
  kappa1_paper = c(0.008, 0.040, 0.058),
  kappa2_paper = c(0.008, 0.0016, 0.0043),
  log_ml_paper = c(4333.3, 4329.8, 4341.6)
)
table2_comp <- merge(hyper[hyper$dataset == "15var", ], paper_table2, by = "prior", all.x = TRUE)
table2_comp$kappa1_diff <- table2_comp$kappa1 - table2_comp$kappa1_paper
table2_comp$kappa2_diff <- table2_comp$kappa2 - table2_comp$kappa2_paper
table2_comp$log_ml_diff <- table2_comp$log_ml - table2_comp$log_ml_paper
write.csv(table2_comp, file.path(results, "table2_hyperparameter_comparison.csv"), row.names = FALSE)

write.csv(
  data.frame(variable = res15$dat$names, posterior_sigma_mean = res15$sig_mean),
  file.path(results, "posterior_sigma_mean_15var.csv"),
  row.names = FALSE
)

png(file.path(figures, "figure_hyperparameter_table2_comparison.png"), width = 1000, height = 700, res = 140)
op <- par(mfrow = c(1, 2), mar = c(7, 4, 3, 1))
barplot(
  t(as.matrix(table2_comp[match(c("symmetric", "subjective", "asymmetric"), table2_comp$prior), c("kappa1", "kappa1_paper")])),
  beside = TRUE,
  names.arg = c("symmetric", "subjective", "asymmetric"),
  las = 2,
  col = c("#4C78A8", "#F58518"),
  main = "kappa1",
  ylab = "value"
)
legend("topright", legend = c("R replication", "paper"), fill = c("#4C78A8", "#F58518"), bty = "n", cex = 0.8)
barplot(
  t(as.matrix(table2_comp[match(c("symmetric", "subjective", "asymmetric"), table2_comp$prior), c("kappa2", "kappa2_paper")])),
  beside = TRUE,
  names.arg = c("symmetric", "subjective", "asymmetric"),
  las = 2,
  col = c("#4C78A8", "#F58518"),
  main = "kappa2",
  ylab = "value"
)
par(op)
dev.off()

cat("ACP replication outputs written to:", results, "\n")
print(hyper)
print(table2_comp)
