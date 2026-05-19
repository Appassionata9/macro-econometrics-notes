# Koop and Korobilis 2010 Bayesian Multivariate Time Series

## Citation

Koop, G. and Korobilis, D. (2010), "Bayesian Multivariate Time Series Methods
for Empirical Macroeconomics".

## Research Role

This folder reproduces the paper's empirical Bayesian VAR illustration and
collects the real macroeconomic data and original author code needed for broader
replication work.

## Main Replication Scope

The current local R replication covers the Section 2.3 BVAR empirical
illustration:

- quarterly U.S. inflation, unemployment, and 3-month Treasury bill rate;
- sample 1953Q1-2006Q3;
- unrestricted VAR with intercept and four lags;
- noninformative, Minnesota, and natural conjugate analytical priors;
- posterior mean coefficient table;
- one-step predictive density table;
- noninformative-prior impulse response summaries.

The original author Matlab code for BVAR, TVP-VAR, factor models, FAVAR, and
TVP-FAVAR is stored under `data/raw/author_code/` for later deeper replication.

## Full Run

From the repository root:

```sh
Rscript paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/code/run_replication.R
```

This prepares data, runs the BVAR replication, writes result CSVs, and generates
figures.

## Status

- [x] Paper PDF copied into `paper/`
- [x] Paper text extracted for search
- [x] Author Matlab code and data downloaded
- [x] Official FRED data downloaded and processed
- [x] Section 2.3 BVAR illustration reproduced in R
- [x] Table 1 noninformative-prior target compared
- [x] Table 3 analytical-prior forecast target compared
- [x] Figures generated
- [x] Chinese summary note written
- [x] References organized in `notes/references.md`
- [x] Formula derivations documented in `notes/formula_derivations.md`

## Caveat

The R replication is complete for the core BVAR illustration implemented here.
The paper also discusses TVP-VARs, stochastic volatility, factor models, FAVARs,
and TVP-FAVARs. Their original Matlab code is collected, but those later models
are not fully reimplemented in R yet.
