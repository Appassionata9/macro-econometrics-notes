# First Replication Summary

Date: 2026-05-19

## Scope

This first replication pass runs the current R implementation against the core
Monte Carlo exercises in Paccagnini (2010):

- forward-looking DSGE artificial data;
- backward-looking Rudebusch-Svensson/Linde artificial data;
- DSGE-VAR marginal data density over lambda grids;
- lag orders from 1 to 8;
- 100 Monte Carlo replications.

## Paper Alignment

The scripts now use the paper-style lambda grid and automatically include the
lag-specific minimum lambda:

```text
0, 0.09, 0.10, 0.13, 0.17, 0.20, 0.24, 0.25, 0.28, 0.30,
0.31, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70,
0.80, 0.90, 1, 5, 10
```

For the backward-looking experiment, the maximum lambda is restricted to 1,
matching the grid described around Table 3 in the paper.

## Current Outputs

Generated CSV files:

- `forward_mc_detail.csv`
- `forward_mc_summary.csv`
- `forward_mc_frequency.csv`
- `backward_mc_detail.csv`
- `backward_mc_summary.csv`
- `backward_mc_frequency.csv`
- `single_demo_lambda.csv`
- `single_demo_var_ic.csv`

Generated figures:

- `../figures/forward_lambda_frequency.png`
- `../figures/backward_lambda_frequency.png`

## First Findings

Backward-looking DGP:

- The current implementation chooses the lag-specific minimum lambda in all 100
  replications for every lag order.
- This agrees with the paper's qualitative result that the DSGE-VAR detects
  misspecification by selecting lambda values very close to the minimum lambda.

Forward-looking DGP:

- The current implementation selects large lambda values, especially 5 and 10.
- This agrees only with the broad intuition that the candidate DSGE model has
  strong explanatory power for forward-looking artificial data.
- It does not match Table 1 quantitatively, where optimal lambda values stay
  below 1 in the reported Monte Carlo experiment.

## Important Caveat

The current R code is a transparent reduced replication based on reported
policy-function matrices and conjugate DSGE-VAR calculations. It does not yet
implement the paper's full structural-parameter posterior simulation layer or
Metropolis-Hastings integration. That is the most likely source of the remaining
quantitative gap in the forward-looking experiment.

## Full Current-Project Run Update

The full current project was re-run on 2026-05-19 using:

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/run_replication.R
```

The workflow now also writes comparison files against the paper's Table 1 and
Table 3:

- `paper_table1_forward_frequency.csv`
- `paper_table3_backward_frequency.csv`
- `comparison_table1_forward.csv`
- `comparison_table3_backward.csv`
- `comparison_summary.csv`

Two implementation details were corrected before the final run:

- `lambda_min` now follows the paper's `(n + k) / T` definition and reported
  80-observation minimum lambda values.
- Backward-looking shock standard deviations now distinguish Linde whole-sample
  values from RS whole-sample values.

## Next Technical Tasks

1. Extract the exact reported table values into comparison CSV files.
2. Add a formal comparison script that computes differences against Tables 1 and 3.
3. Decide whether the PhD proposal needs the full MCMC structural layer or whether
   the current reduced replication is sufficient as a methodological scaffold.
