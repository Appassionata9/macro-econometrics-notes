# Real Data Sources

This folder stores real U.S. macroeconomic data for the Paccagnini (2010)
real-data exercises.

## Official Sources

The paper states that the real-data variables are:

- real GDP from the Bureau of Economic Analysis;
- CPI-U all items from the Bureau of Labor Statistics;
- Federal Funds Rate, constructed as the average rate during the first month of
  each quarter using business days only.

The current project downloads the closest official public FRED series:

| Variable | FRED series | Original agency | Frequency | Notes |
| --- | --- | --- | --- | --- |
| Real GDP | `GDPC1` | BEA | Quarterly | Billions of chained 2017 dollars, SAAR |
| CPI-U all items | `CPIAUCSL` | BLS | Monthly | Index 1982-1984=100, seasonally adjusted |
| Fed funds rate | `DFF` | Federal Reserve Board | Daily | Percent, not seasonally adjusted |

## Reproducibility Caveat

These are current revised FRED series. Paccagnini (2010) cites the Del Negro and
Schorfheide (2004) data setup, which used vintage/then-current definitions such
as chained 1996-dollar real GDP and Haver Analytics for the interest rate. Exact
published-table replication may therefore require archived vintage data or the
original authors' replication files.

## Processing

Run from the repository root:

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/download_real_data.R
```

The processed quarterly file is:

```text
processed/paccagnini_real_data_1981q1_2001q4.csv
```

The script also writes exact-length alignment files:

```text
processed/paccagnini_real_data_1981q4_2001q3_80obs.csv
processed/paccagnini_real_data_1961q4_2001q3_160obs.csv
```

These match the 80- and 160-observation samples implied by the Del
Negro-Schorfheide data window ending in 2001Q3. They are likely the better files
to use when reproducing the paper's real-data tables.
