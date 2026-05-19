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

python <- "/Users/appassionata/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
message("Preparing author and FRED data...")
status <- system2(python, shQuote(file.path(paper_dir, "code", "prepare_real_data.py")))
if (!identical(status, 0L)) stop("Data preparation failed.")

message("Running asymmetric conjugate BVAR replication...")
source(file.path(paper_dir, "code", "acp_replication.R"), local = TRUE)

message("Full replication log saved to: ", log_file)
