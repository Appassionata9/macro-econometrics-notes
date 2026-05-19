# Replication Log

## 2026-05-19 Initial Full Current-Project Run

### Goal

- Build a paper-specific replication project for Koop and Korobilis (2010).
- Collect the author data/code and official FRED data.
- Reproduce the main BVAR empirical illustration in Section 2.3.

### What Changed

- Copied the paper PDF into this folder and extracted searchable text.
- Downloaded author Matlab code and data from Dimitris Korobilis's code page.
- Downloaded official FRED series `GDPCTPI`, `UNRATE`, and `TB3MS`.
- Added `prepare_real_data.R` to process author data and reconstruct FRED data.
- Added `bvar_replication.R` to reproduce the BVAR empirical illustration.
- Added `run_replication.R` as the full paper-specific run script.

### Result

- Real data are available in `data/processed/`.
- Table 1 noninformative posterior means are reproduced closely.
- Table 3 analytical-prior predictive results are reproduced closely for
  noninformative, Minnesota, and natural conjugate priors.
- Figure 1 data plot and Figure 2-style noninformative IRF plot are generated.

### Differences From Paper

- The R replication does not yet implement the SSVS Gibbs samplers or the later
  TVP-VAR/FAVAR/TVP-FAVAR models.
- Current FRED data differ slightly from author data because FRED series are
  revised and may not be identical to the authors' vintage data.

### Next Step

- Use the BVAR replication as the main proposal-ready baseline.
- Implement SSVS and TVP-VAR only if the proposal needs those sections as
  quantitative replication targets.
