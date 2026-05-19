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
raw_author <- file.path(paper_dir, "data", "raw", "author_code", "BVAR_FULL")
raw_fred <- file.path(paper_dir, "data", "raw", "fred")
processed <- file.path(paper_dir, "data", "processed")
dir.create(raw_fred, recursive = TRUE, showWarnings = FALSE)
dir.create(processed, recursive = TRUE, showWarnings = FALSE)

download_fred <- function(series_id) {
  url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", series_id)
  dest <- file.path(raw_fred, paste0(series_id, ".csv"))
  download.file(url, dest, mode = "wb", quiet = FALSE)
  dest
}

for (series_id in c("GDPCTPI", "UNRATE", "TB3MS")) {
  download_fred(series_id)
}

quarter_from_yearlab <- function(x) {
  year <- floor(x)
  q <- round((x - year) * 4) + 1
  paste0(year, "Q", q)
}

author_y <- as.matrix(read.table(file.path(raw_author, "Yraw.dat")))
author_dates <- scan(file.path(raw_author, "yearlab.dat"), quiet = TRUE)
author <- data.frame(
  quarter = quarter_from_yearlab(author_dates),
  inflation = author_y[, 1],
  unemployment = author_y[, 2],
  tbill_rate = author_y[, 3]
)
write.csv(author, file.path(processed, "author_yraw_1953q1_2006q3.csv"), row.names = FALSE)

read_fred <- function(series_id) {
  d <- read.csv(file.path(raw_fred, paste0(series_id, ".csv")), stringsAsFactors = FALSE)
  names(d) <- c("date", "value")
  d$date <- as.Date(d$date)
  d$value <- suppressWarnings(as.numeric(d$value))
  d[!is.na(d$value), ]
}

quarter_label <- function(date) {
  lt <- as.POSIXlt(date)
  paste0(lt$year + 1900, "Q", lt$mon %/% 3 + 1)
}

gdp_price <- read_fred("GDPCTPI")
gdp_price$quarter <- quarter_label(gdp_price$date)
gdp_price <- gdp_price[order(gdp_price$date), ]
gdp_price$inflation <- c(rep(NA_real_, 4), 100 * diff(log(gdp_price$value), lag = 4))
infl <- gdp_price[, c("quarter", "inflation")]

quarterly_average <- function(d, value_name) {
  d$quarter <- quarter_label(d$date)
  out <- aggregate(value ~ quarter, d, mean)
  names(out) <- c("quarter", value_name)
  out
}

unemp <- quarterly_average(read_fred("UNRATE"), "unemployment")
tbill <- quarterly_average(read_fred("TB3MS"), "tbill_rate")

fred <- Reduce(function(x, y) merge(x, y, by = "quarter", all = FALSE), list(infl, unemp, tbill))
fred <- fred[fred$quarter >= "1953Q1" & fred$quarter <= "2006Q3", ]
fred <- fred[order(substr(fred$quarter, 1, 4), substr(fred$quarter, 6, 6)), ]
write.csv(fred, file.path(processed, "fred_reconstructed_1953q1_2006q3.csv"), row.names = FALSE)

comparison <- merge(author, fred, by = "quarter", suffixes = c("_author", "_fred"))
for (var in c("inflation", "unemployment", "tbill_rate")) {
  comparison[[paste0(var, "_diff")]] <- comparison[[paste0(var, "_fred")]] - comparison[[paste0(var, "_author")]]
}
write.csv(comparison, file.path(processed, "author_vs_fred_quarterly_comparison.csv"), row.names = FALSE)

summary_rows <- lapply(c("inflation", "unemployment", "tbill_rate"), function(var) {
  diff <- comparison[[paste0(var, "_diff")]]
  data.frame(
    variable = var,
    observations = length(diff),
    mean_absolute_difference = mean(abs(diff), na.rm = TRUE),
    max_absolute_difference = max(abs(diff), na.rm = TRUE),
    correlation = cor(comparison[[paste0(var, "_author")]], comparison[[paste0(var, "_fred")]], use = "complete.obs")
  )
})
summary <- do.call(rbind, summary_rows)
write.csv(summary, file.path(processed, "author_vs_fred_comparison_summary.csv"), row.names = FALSE)

cat("Wrote real-data files to:", processed, "\n")
print(summary)
