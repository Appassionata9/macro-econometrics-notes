# Chan 2022 Asymmetric Conjugate BVAR

## Citation

Chan, Joshua C. C. (2022), "Asymmetric conjugate priors for large Bayesian
VARs", Quantitative Economics, 13(3), 1145-1169.

## Research Role

This project reproduces the paper's core empirical marginal-likelihood exercise
for asymmetric conjugate priors in large Bayesian VARs. It is useful for the
proposal as the bridge from standard conjugate Bayesian VARs to large-system
shrinkage priors that allow different shrinkage on own lags and cross-variable
lags.

## Main Replication Scope

The local replication covers:

- the official 6-variable and 15-variable author data set, 1985Q1-2019Q4;
- the triangular structural BVAR representation used by the asymmetric
  conjugate prior;
- residual-variance scaling from univariate AR(4) regressions;
- reduced-form prior elicitation;
- closed-form log marginal likelihood;
- optimization of symmetric, subjective, and asymmetric shrinkage settings;
- posterior simulation for the asymmetric-prior 15-variable model;
- a paper Table 2 comparison.

The exact Table 2 check was also run in the author's original MATLAB code to
confirm that the R implementation matches the official replication package.

## Full Run

From the repository root:

```sh
Rscript paper_reproductions/chan_2022_asymmetric_conjugate_bvar/code/run_replication.R
```

This prepares data, downloads public FRED source checks, runs the ACP-BVAR
replication, writes CSV outputs, and generates the comparison figure.

## Data Sources

The table-matching data come from Joshua Chan's official replication package:

```text
data/raw/author_code/BVAR_ACP_R1_code/database_2019Q4.xlsx
```

The project also downloads public FRED approximations for source transparency:

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

For exact replication, use the author workbook. Some variables in the paper are
constructed from transformed raw series, spreads, ratios, Philadelphia Fed
series, or non-FRED sources.

## Status

- [x] Paper PDF copied into `paper/`
- [x] Paper text extracted for search
- [x] Official author code and data downloaded
- [x] Older forecasting-code package saved for reference
- [x] Public FRED source series downloaded
- [x] 6-variable and 15-variable author data processed
- [x] ACP marginal likelihood implemented in R
- [x] Table 2 hyperparameter comparison reproduced
- [x] MATLAB author-code check completed
- [x] Chinese summary note written
- [x] References and formula derivations documented

## Current Results

The 15-variable Table 2 comparison is effectively matched:

```text
prior        R kappa1   R kappa2   R log ML
symmetric    0.00832    0.00832    4333.299
subjective   0.04000    0.00160    4329.768
asymmetric   0.05810    0.00427    4341.550
```

The author's MATLAB code produced:

```text
symmetric    0.00831    0.00831    4333.299
subjective   0.04000    0.00160    4329.768
asymmetric   0.05811    0.00427    4341.550
```

The small difference from the paper table is rounding.

## Caveat

The current R replication focuses on the paper's closed-form prior,
hyperparameter optimization, and Table 2. The full sign-restriction impulse
response exercise in Figures 2 and 3 is documented and partially supported by
the posterior sampler, but it has not yet been fully reimplemented in R.
