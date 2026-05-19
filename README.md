# Macro Econometrics Notes

This repository collects PhD proposal research notes and paper replications in
macroeconometrics, with a focus on DSGE-VAR model validation, Bayesian VARs, and
large Bayesian VAR shrinkage priors.

The main workspace is:

```text
paper_reproductions/
```

Current replicated papers:

- Paccagnini (2010), "DSGE Model Evaluation in a Bayesian Framework: an
  Assessment";
- Koop and Korobilis (2010), "Bayesian Multivariate Time Series Methods for
  Empirical Macroeconomics";
- Chan (2022), "Asymmetric conjugate priors for large Bayesian VARs".

Each paper folder contains the source paper, reproduction code, raw and
processed data, generated results, figures, references, formula derivations, and
Chinese replication notes.

## Run in VS Code

Open this folder in VS Code:

```sh
code "/Users/appassionata/Documents/New project"
```

Examples:

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/run_replication.R
Rscript paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/code/run_replication.R
Rscript paper_reproductions/chan_2022_asymmetric_conjugate_bvar/code/run_replication.R
```

The older root-level Paccagnini scripts are still available:

```sh
Rscript scripts/run_forward_mc.R
Rscript scripts/run_backward_mc.R
Rscript scripts/run_single_demo.R
```

Paper-specific outputs are written to each paper's `results/` and `figures/`
folders.

## Paper reproduction workspace

Thesis-related replication materials are organized under `paper_reproductions/`.
The cross-paper summary is:

```text
paper_reproductions/replication_overview_zh.md
```

Use `paper_reproductions/_template/` as the starting structure for each new
paper replication. Each paper folder is designed to hold the source paper,
paper-specific code notes, figures, results, and replication logs.

## Notes

Some replications intentionally distinguish between exact table reproduction and
transparent baseline reproduction. Paper-specific caveats are documented in each
folder's `README.md` and `notes/replication_summary_zh.md`.
