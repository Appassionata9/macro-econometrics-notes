# FRED Source Links

Downloaded on 2026-05-19.

## GDP Price Index

- Series: `GDPCTPI`
- Link: https://fred.stlouisfed.org/series/GDPCTPI
- Description: Gross Domestic Product: Chain-type Price Index
- Source: U.S. Bureau of Economic Analysis
- Frequency: Quarterly

## Unemployment

- Series: `UNRATE`
- Link: https://fred.stlouisfed.org/series/UNRATE
- Description: Civilian Unemployment Rate
- Source: U.S. Bureau of Labor Statistics
- Frequency: Monthly

## 3-Month Treasury Bill Rate

- Series: `TB3MS`
- Link: https://fred.stlouisfed.org/series/TB3MS
- Description: 3-Month Treasury Bill Secondary Market Rate
- Source: Board of Governors of the Federal Reserve System
- Frequency: Monthly

The processing script converts `UNRATE` and `TB3MS` to quarterly averages and
computes inflation as the annual log percentage change in `GDPCTPI`.
