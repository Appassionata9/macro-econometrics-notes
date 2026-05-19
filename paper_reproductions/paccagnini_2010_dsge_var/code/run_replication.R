find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (
      file.exists(file.path(path, "R", "models.R")) &&
        file.exists(file.path(path, "R", "dsge_var.R")) &&
        dir.exists(file.path(path, "paper_reproductions"))
    ) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not find project root from: ", start)
    }
    path <- parent
  }
}

root <- find_project_root()
old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(root)

source("R/models.R")
source("R/dsge_var.R")

paper_results <- file.path(
  root,
  "paper_reproductions",
  "paccagnini_2010_dsge_var",
  "results"
)
dir.create(paper_results, recursive = TRUE, showWarnings = FALSE)

log_file <- file.path(
  paper_results,
  paste0("full_replication_log_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
)
log_con <- file(log_file, open = "wt")
sink(log_con, split = TRUE)
sink(log_con, type = "message")
on.exit({
  sink(type = "message")
  sink()
  close(log_con)
}, add = TRUE)

dir.create("output", showWarnings = FALSE)

message("Project root: ", root)
message("Running single forward-looking demo...")
source("scripts/run_single_demo.R", local = TRUE)

message("Running forward-looking Monte Carlo...")
source("scripts/run_forward_mc.R", local = TRUE)

message("Running backward-looking Monte Carlo...")
source("scripts/run_backward_mc.R", local = TRUE)

output_csv <- list.files("output", pattern = "[.]csv$", full.names = TRUE)
if (length(output_csv) == 0) {
  stop("No CSV files found in output/.")
}
file.copy(output_csv, paper_results, overwrite = TRUE)

message("Generating lambda-frequency figures...")
source(
  file.path("paper_reproductions", "paccagnini_2010_dsge_var", "code", "plot_lambda_frequencies.R"),
  local = TRUE
)

message("Comparing replication outputs with paper tables...")
source(
  file.path("paper_reproductions", "paccagnini_2010_dsge_var", "code", "compare_to_paper_tables.R"),
  local = TRUE
)

message("Replication outputs copied to: ", paper_results)
message("Full replication log saved to: ", log_file)
