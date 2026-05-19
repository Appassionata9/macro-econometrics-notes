source("R/models.R")
source("R/dsge_var.R")

dir.create("output", showWarnings = FALSE)

res <- run_mc_experiment(
  dgp = function(n_obs, seed) simulate_backward_model(n_obs = n_obs, seed = seed, sample = "linde_whole"),
  reps = 100,
  n_obs = 80,
  lags = 1:8,
  lambda_grid = function(n_obs, n_vars, lags) paper_lambda_grid(n_obs, n_vars, lags, max_lambda = 1),
  prior_sim_obs = 5000,
  seed = 2027
)

write.csv(res$detail, "output/backward_mc_detail.csv", row.names = FALSE)
write.csv(res$summary, "output/backward_mc_summary.csv", row.names = FALSE)
write.csv(res$frequency, "output/backward_mc_frequency.csv", row.names = FALSE)

print(res$summary)
print(res$frequency)
