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
results <- file.path(paper_dir, "results")
dir.create(results, recursive = TRUE, showWarnings = FALSE)

log_file <- file.path(results, paste0("full_replication_log_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt"))
log_con <- file(log_file, open = "wt")
sink(log_con, split = TRUE)
sink(log_con, type = "message")
on.exit({
  sink(type = "message")
  sink()
  close(log_con)
}, add = TRUE)

message("Preparing real data...")
source(file.path(paper_dir, "code", "prepare_real_data.R"), local = TRUE)

message("Running BVAR empirical illustration replication...")
source(file.path(paper_dir, "code", "bvar_replication.R"), local = TRUE)

message("Full replication log saved to: ", log_file)
