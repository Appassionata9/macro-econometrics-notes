# Data Sources

This folder contains the data used for Chan (2022), "Asymmetric conjugate
priors for large Bayesian VARs".

## Author Replication Data

The table-matching replication data are from Joshua Chan's official code package:

- `data/raw/author_code/BVAR_ACP_R1_code/database_2019Q4.xlsx`

The workbook contains 15 U.S. quarterly variables from 1985Q1 to 2019Q4. The
processed files are:

```text
data/processed/author_database_6var_1985q1_2019q4.csv
data/processed/author_database_15var_1985q1_2019q4.csv
```

## Public Source Data

Appendix A of the paper says the raw series come from the Federal Reserve Bank
of St. Louis, the Federal Reserve Bank of Philadelphia, Yahoo Finance, and the
Board of Governors of the Federal Reserve System.

The project downloads public FRED approximations for the most directly
available series:

- `TB3MS`
- `GPDIC1`
- `BAA`
- `FEDFUNDS`
- `GS10`
- `MORTGAGE30US`
- `CPIAUCSL`
- `PCEPI`
- `CE16OV`
- `INDPRO`
- `GS1`
- `DJIA`

The author workbook remains the replication source for matching the paper's
tables and figures.
