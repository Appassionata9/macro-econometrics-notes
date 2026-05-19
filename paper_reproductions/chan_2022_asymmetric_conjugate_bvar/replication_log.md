# Replication Log

## 2026-05-19

- Created the Chan (2022) replication folder and copied the paper PDF.
- Extracted paper text for formula, data, and reference search.
- Located Joshua Chan's official code page for "Asymmetric Conjugate Priors for
  Large Bayesian VARs".
- Downloaded the official 2022 journal-version replication package:
  `BVAR_ACP_R1_code.zip`.
- Extracted the author workbook `database_2019Q4.xlsx`, which contains the 15
  quarterly U.S. variables from 1985Q1 to 2019Q4.
- Also archived the older `BVAR_ACP_code.zip`; this is not the main
  journal-version package, but it is useful for comparing the earlier
  forecasting application.
- Wrote `code/prepare_real_data.py` to:
  - convert the author workbook into processed CSV files;
  - create 6-variable and 15-variable subsets;
  - download public FRED source checks.
- Wrote `code/acp_replication.R` to:
  - construct the lag matrix;
  - compute univariate AR(4) residual variances, matching the author MATLAB
    helper `get_resid_var.m`;
  - construct asymmetric conjugate priors;
  - implement reduced-form prior elicitation;
  - evaluate the closed-form log marginal likelihood;
  - optimize symmetric and asymmetric shrinkage hyperparameters;
  - draw posterior samples independently equation by equation.
- Wrote `code/run_replication.R` as the one-command entry point.
- Ran the full R replication successfully.
- Validated Table 2 against the official MATLAB code using local MATLAB
  R2025b. The MATLAB check is saved as `results/matlab_table2_check.csv`.
- Inspected the official MATLAB main scripts:
  - `main_ACP_jointden.m` reproduces the joint posterior contour for
    `kappa1_tilde` and `kappa2_tilde`;
  - `main_ACP_apps.m` reproduces the sign-restricted 6-variable or 15-variable
    impulse response application. The 15-variable setting is explicitly noted
    by the author code as potentially taking a few days to obtain the requested
    accepted sign-restricted draws.

## Results Snapshot

The R replication writes:

- `results/hyperparameter_comparison.csv`
- `results/table2_hyperparameter_comparison.csv`
- `results/posterior_sigma_mean_15var.csv`
- `figures/figure_hyperparameter_table2_comparison.png`

The R results for the 15-variable model are:

```text
symmetric:  kappa1 = 0.008321, kappa2 = 0.008321, log ML = 4333.299
subjective: kappa1 = 0.040000, kappa2 = 0.001600, log ML = 4329.768
asymmetric: kappa1 = 0.058099, kappa2 = 0.004270, log ML = 4341.550
```

These match the paper's Table 2 up to rounding and match the author's MATLAB
code almost exactly.

## Remaining Extension

The remaining natural extension is to reproduce the full sign-restricted
structural impulse response figures. The posterior sampler is already present,
but the Rubio-Ramirez, Waggoner, and Zha sign-restriction draw/filtering step
still needs to be completed in R.
