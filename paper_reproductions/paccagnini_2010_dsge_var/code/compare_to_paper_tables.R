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

paper_dir <- file.path(root, "paper_reproductions", "paccagnini_2010_dsge_var")
results_dir <- file.path(paper_dir, "results")

compare_frequency_table <- function(paper_file, replication_file, output_file, label) {
  paper <- read.csv(file.path(results_dir, paper_file))
  replication <- read.csv(file.path(results_dir, replication_file))

  paper$lambda_key <- round(paper$lambda, 4)
  replication$lambda_key <- round(replication$lambda, 4)

  names(paper)[names(paper) == "frequency"] <- "paper_frequency"
  names(replication)[names(replication) == "frequency"] <- "replication_frequency"

  merged <- merge(
    paper[, c("lags", "lambda_key", "paper_frequency")],
    replication[, c("lags", "lambda_key", "replication_frequency")],
    by = c("lags", "lambda_key"),
    all = TRUE
  )

  merged$paper_frequency[is.na(merged$paper_frequency)] <- 0
  merged$replication_frequency[is.na(merged$replication_frequency)] <- 0
  merged$frequency_difference <- merged$replication_frequency - merged$paper_frequency
  merged$absolute_difference <- abs(merged$frequency_difference)
  merged <- merged[order(merged$lags, merged$lambda_key), ]
  names(merged)[names(merged) == "lambda_key"] <- "lambda"

  write.csv(merged, file.path(results_dir, output_file), row.names = FALSE)

  summary <- aggregate(
    absolute_difference ~ lags,
    merged,
    sum
  )
  names(summary)[2] <- "total_absolute_frequency_difference"
  summary$experiment <- label
  summary[, c("experiment", "lags", "total_absolute_frequency_difference")]
}

forward_summary <- compare_frequency_table(
  "paper_table1_forward_frequency.csv",
  "forward_mc_frequency.csv",
  "comparison_table1_forward.csv",
  "forward"
)

backward_summary <- compare_frequency_table(
  "paper_table3_backward_frequency.csv",
  "backward_mc_frequency.csv",
  "comparison_table3_backward.csv",
  "backward"
)

comparison_summary <- rbind(forward_summary, backward_summary)
write.csv(
  comparison_summary,
  file.path(results_dir, "comparison_summary.csv"),
  row.names = FALSE
)

print(comparison_summary)
