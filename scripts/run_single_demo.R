source("R/models.R")
source("R/dsge_var.R")

dir.create("output", showWarnings = FALSE)

set.seed(2026)
prior_y <- simulate_forward_dsge(n_obs = 5000, burn = 500)
actual_y <- simulate_forward_dsge(n_obs = 80, burn = 300)

prior <- dsge_prior_moments(prior_y, lags = 2)
lambda_grid <- c(lambda_min(nrow(actual_y), ncol(actual_y), 2), 0.2, 0.4, 0.6, 0.8, 1, 1.4, 1.8, 3, 5, 10)
lambda_table <- evaluate_lambda_grid(actual_y, prior, lags = 2, lambda_grid = lambda_grid)
ic_table <- information_criteria_var(actual_y, max_lags = 8)

write.csv(lambda_table, "output/single_demo_lambda.csv", row.names = FALSE)
write.csv(ic_table, "output/single_demo_var_ic.csv", row.names = FALSE)

print(lambda_table)
print(ic_table)

