# Paccagnini 2010 DSGE-VAR

## Citation

Paccagnini, A. (2010), "DSGE Model Evaluation in a Bayesian Framework: an
Assessment".

## Research Role

This is the first replication target in the thesis proposal workflow. The current
repository already contains an R scaffold for reproducing core DSGE-VAR Monte
Carlo components from the paper.

## Existing Project Files

Current implementation lives in the repository root:

- `R/models.R`
- `R/dsge_var.R`
- `scripts/run_forward_mc.R`
- `scripts/run_backward_mc.R`
- `scripts/run_single_demo.R`
- `output/`

This folder collects paper-specific notes, figures, and replication artifacts
without moving the existing working code.

## Replication Target

Main outputs currently targeted:

- forward-looking New Keynesian state-space simulation;
- backward-looking Rudebusch-Svensson/Linde data-generating process;
- unrestricted VAR estimation;
- DSGE-VAR dummy-observation priors;
- marginal data density over lambda grids;
- Monte Carlo summary tables.

## Status

- [x] Paper PDF saved in `paper/`
- [x] Appendix text extracted from PDF
- [x] Initial R implementation scaffold exists
- [x] Monte Carlo output folder exists
- [x] Reproduced tables compared against paper values
- [x] Reproduced figures collected in `figures/`
- [x] First-pass deviations documented
- [x] Chinese replication summary written in `notes/`
- [x] Real-data source files downloaded from FRED
- [x] References organized in `notes/references.md`
- [x] Formula derivations documented in `notes/formula_derivations.md`

## Full Run Command

From the repository root:

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/run_replication.R
```

This reproduces the current R project end to end and updates the paper-specific
CSV outputs, figures, comparison tables, and run log.

## Next Steps

1. Decide whether the proposal needs a reduced replication or a full
   structural-posterior/MCMC replication.
2. If full replication is required, implement the Metropolis-Hastings layer over
   DSGE structural parameters.
3. Extend the project to the paper's real-data and forecasting tables if those
   are needed for the thesis proposal.
