# FRED Source Links

Downloaded on 2026-05-19 from FRED.

## Real GDP

- Series: `GDPC1`
- Link: https://fred.stlouisfed.org/series/GDPC1
- Source agency: U.S. Bureau of Economic Analysis
- Units on FRED: Billions of Chained 2017 Dollars, Seasonally Adjusted Annual Rate
- Frequency: Quarterly

## CPI

- Series: `CPIAUCSL`
- Link: https://fred.stlouisfed.org/series/CPIAUCSL
- Source agency: U.S. Bureau of Labor Statistics
- Units on FRED: Index 1982-1984=100, Seasonally Adjusted
- Frequency: Monthly

## Federal Funds Rate

- Series: `DFF`
- Link: https://fred.stlouisfed.org/series/DFF
- Source agency: Board of Governors of the Federal Reserve System
- Units on FRED: Percent, Not Seasonally Adjusted
- Frequency: Daily, 7-Day

The processed quarterly federal funds rate uses the average daily `DFF` value
over business days in the first month of each quarter, matching the paper's
description as closely as FRED permits.

The exact-length processed files use 1981Q4-2001Q3 for the 80-observation sample
and 1961Q4-2001Q3 for the 160-observation sample, following the
Del Negro-Schorfheide data window that ends in 2001Q3.
