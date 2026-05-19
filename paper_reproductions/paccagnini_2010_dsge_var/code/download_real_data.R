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
raw_dir <- file.path(paper_dir, "data", "raw", "fred")
processed_dir <- file.path(paper_dir, "data", "processed")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)

download_fred <- function(series_id) {
  url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", series_id)
  dest <- file.path(raw_dir, paste0(series_id, ".csv"))
  download.file(url, dest, mode = "wb", quiet = FALSE)
  dest
}

for (series_id in c("GDPC1", "CPIAUCSL", "DFF")) {
  download_fred(series_id)
}

read_fred <- function(series_id) {
  path <- file.path(raw_dir, paste0(series_id, ".csv"))
  d <- read.csv(path, stringsAsFactors = FALSE)
  names(d) <- c("date", "value")
  d$date <- as.Date(d$date)
  d$value <- suppressWarnings(as.numeric(d$value))
  d[!is.na(d$value), ]
}

quarter_label <- function(date) {
  lt <- as.POSIXlt(date)
  year <- lt$year + 1900
  quarter <- lt$mon %/% 3 + 1
  paste0(year, "Q", quarter)
}

is_quarter_first_month <- function(date) {
  month <- as.POSIXlt(date)$mon + 1
  month %in% c(1, 4, 7, 10)
}

is_business_day <- function(date) {
  weekday <- as.POSIXlt(date)$wday
  weekday %in% 1:5
}

gdp <- read_fred("GDPC1")
cpi <- read_fred("CPIAUCSL")
dff <- read_fred("DFF")

gdp$quarter <- quarter_label(gdp$date)
gdp_q <- gdp[, c("quarter", "date", "value")]
names(gdp_q) <- c("quarter", "gdp_date", "real_gdp")

cpi$quarter <- quarter_label(cpi$date)
cpi$month <- as.POSIXlt(cpi$date)$mon + 1
cpi_first_month <- cpi[cpi$month %in% c(1, 4, 7, 10), c("quarter", "date", "value")]
names(cpi_first_month) <- c("quarter", "cpi_date_first_month", "cpi_first_month")

cpi_q_avg <- aggregate(value ~ quarter, cpi, mean)
names(cpi_q_avg) <- c("quarter", "cpi_quarter_average")

dff_first_month <- dff[is_quarter_first_month(dff$date) & is_business_day(dff$date), ]
dff_first_month$quarter <- quarter_label(dff_first_month$date)
dff_q <- aggregate(value ~ quarter, dff_first_month, mean)
names(dff_q) <- c("quarter", "fedfunds_first_month_business_day_avg")

merged <- Reduce(
  function(x, y) merge(x, y, by = "quarter", all = FALSE),
  list(gdp_q, cpi_first_month, cpi_q_avg, dff_q)
)

merged$year <- as.integer(substr(merged$quarter, 1, 4))
merged$qtr <- as.integer(substr(merged$quarter, 6, 6))
merged <- merged[order(merged$year, merged$qtr), ]

merged$gdp_log_diff_pct <- c(NA_real_, 100 * diff(log(merged$real_gdp)))
merged$cpi_first_month_log_diff_pct <- c(NA_real_, 100 * diff(log(merged$cpi_first_month)))
merged$cpi_quarter_average_log_diff_pct <- c(NA_real_, 100 * diff(log(merged$cpi_quarter_average)))
merged$gdp_log_diff_annualized_pct <- 4 * merged$gdp_log_diff_pct
merged$cpi_first_month_log_diff_annualized_pct <- 4 * merged$cpi_first_month_log_diff_pct
merged$cpi_quarter_average_log_diff_annualized_pct <- 4 * merged$cpi_quarter_average_log_diff_pct

sample_small <- merged[
  merged$year >= 1981 & merged$year <= 2001,
  c(
    "quarter",
    "gdp_date",
    "cpi_date_first_month",
    "real_gdp",
    "cpi_first_month",
    "cpi_quarter_average",
    "fedfunds_first_month_business_day_avg",
    "gdp_log_diff_pct",
    "cpi_first_month_log_diff_pct",
    "cpi_quarter_average_log_diff_pct",
    "gdp_log_diff_annualized_pct",
    "cpi_first_month_log_diff_annualized_pct",
    "cpi_quarter_average_log_diff_annualized_pct"
  )
]

sample_large <- merged[
  merged$year >= 1961 & merged$year <= 2001,
  names(sample_small)
]

sample_80 <- sample_small[
  sample_small$quarter >= "1981Q4" & sample_small$quarter <= "2001Q3",
  names(sample_small)
]

sample_160 <- sample_large[
  sample_large$quarter >= "1961Q4" & sample_large$quarter <= "2001Q3",
  names(sample_small)
]

write.csv(
  sample_small,
  file.path(processed_dir, "paccagnini_real_data_1981q1_2001q4.csv"),
  row.names = FALSE
)

write.csv(
  sample_large,
  file.path(processed_dir, "paccagnini_real_data_1961q1_2001q4.csv"),
  row.names = FALSE
)

write.csv(
  sample_80,
  file.path(processed_dir, "paccagnini_real_data_1981q4_2001q3_80obs.csv"),
  row.names = FALSE
)

write.csv(
  sample_160,
  file.path(processed_dir, "paccagnini_real_data_1961q4_2001q3_160obs.csv"),
  row.names = FALSE
)

cat("Wrote processed data files:\n")
cat(file.path(processed_dir, "paccagnini_real_data_1981q1_2001q4.csv"), "\n")
cat(file.path(processed_dir, "paccagnini_real_data_1961q1_2001q4.csv"), "\n")
cat(file.path(processed_dir, "paccagnini_real_data_1981q4_2001q3_80obs.csv"), "\n")
cat(file.path(processed_dir, "paccagnini_real_data_1961q4_2001q3_160obs.csv"), "\n")
