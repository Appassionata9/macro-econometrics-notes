source("R/models.R")
source("R/dsge_var.R")

dir.create("output", showWarnings = FALSE)

res <- run_mc_experiment(
  dgp = function(n_obs, seed) simulate_forward_dsge(n_obs = n_obs, seed = seed),
  reps = 100,
  n_obs = 80,
  lags = 1:8,
  lambda_grid = function(n_obs, n_vars, lags) paper_lambda_grid(n_obs, n_vars, lags, max_lambda = 10),
  prior_sim_obs = 5000,
  seed = 2026
)

write.csv(res$detail, "output/forward_mc_detail.csv", row.names = FALSE)
write.csv(res$summary, "output/forward_mc_summary.csv", row.names = FALSE)
write.csv(res$frequency, "output/forward_mc_frequency.csv", row.names = FALSE)

print(res$summary)
print(res$frequency)
