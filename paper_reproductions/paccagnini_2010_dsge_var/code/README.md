# Code Notes

The working R implementation for this replication currently lives in the
repository root rather than inside this folder:

- `R/models.R`
- `R/dsge_var.R`
- `scripts/run_forward_mc.R`
- `scripts/run_backward_mc.R`
- `scripts/run_single_demo.R`

Run from the repository root:

```sh
Rscript scripts/run_forward_mc.R
Rscript scripts/run_backward_mc.R
Rscript scripts/run_single_demo.R
```

Generated CSV outputs are written to root-level `output/`. Copies of the current
outputs are stored in this paper folder under `results/` for paper-specific
tracking.

## Full Paper-Specific Run

To run the complete current replication workflow for this paper:

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/run_replication.R
```

This runs:

- single forward-looking DSGE-VAR demo;
- forward-looking Monte Carlo;
- backward-looking Monte Carlo;
- CSV synchronization into this paper folder;
- lambda-frequency figures;
- comparison tables against the paper's Table 1 and Table 3.
