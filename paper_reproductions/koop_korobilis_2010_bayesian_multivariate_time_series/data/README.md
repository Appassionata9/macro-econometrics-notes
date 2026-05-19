# Data Sources

This folder contains two data tracks for Koop and Korobilis (2010).

## Author Replication Data

The closest data for reproducing the paper's Section 2.3 BVAR tables are the
author-provided files:

- `data/raw/author_code/BVAR_FULL/Yraw.dat`
- `data/raw/author_code/BVAR_FULL/yearlab.dat`

These contain 215 quarterly observations from 1953Q1 to 2006Q3:

- inflation: annual percentage change in a chain-weighted GDP price index;
- unemployment: seasonally adjusted civilian unemployment rate;
- interest rate: 3-month Treasury bill yield.

The processed version is:

```text
data/processed/author_yraw_1953q1_2006q3.csv
```

## FRED Reconstructed Data

The paper states that the data are from FRED. The current project downloads
the closest public FRED series:

| Variable | FRED series | Description |
| --- | --- | --- |
| Inflation source | `GDPCTPI` | Gross Domestic Product: Chain-type Price Index |
| Unemployment | `UNRATE` | Civilian Unemployment Rate |
| Interest rate | `TB3MS` | 3-Month Treasury Bill Secondary Market Rate |

The processed FRED reconstruction is:

```text
data/processed/fred_reconstructed_1953q1_2006q3.csv
```

The comparison between author data and current revised FRED data is:

```text
data/processed/author_vs_fred_quarterly_comparison.csv
data/processed/author_vs_fred_comparison_summary.csv
```

## Reproducibility Caveat

The author `Yraw.dat` should be treated as the replication target for matching
the paper's tables. Current FRED data are revised and can differ slightly from
the historical data used by the authors.
