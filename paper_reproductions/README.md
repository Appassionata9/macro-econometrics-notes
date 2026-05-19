# Paper Reproductions

This folder is for thesis-related paper replications. Each paper should have its
own subfolder containing the original paper, reproduction code, figures, notes,
and generated results.

## Folder Layout

```text
paper_reproductions/
  _template/
    paper/              # PDF, appendix, supplement, or citation files
    code/               # reproduction scripts or paper-specific modules
    data/
      raw/              # untouched source data
      processed/        # cleaned data created by scripts
    figures/            # reproduced figures and diagnostic plots
    results/            # tables, logs, model outputs, checkpoints
    notes/              # reading notes and replication decisions
    README.md           # paper-specific replication plan
    replication_log.md  # dated progress log
  paccagnini_2010_dsge_var/
    ...
  koop_korobilis_2010_bayesian_multivariate_time_series/
    ...
  chan_2022_asymmetric_conjugate_bvar/
    ...
  selected_next_10_core_papers/
    ...
```

## Naming Convention

Use:

```text
firstauthor_year_shorttopic
```

Examples:

```text
paccagnini_2010_dsge_var
delnegro_schorfheide_2004_dsge_var
smets_wouters_2007_bayesian_dsge
```

## Suggested Workflow

1. Copy `_template/` and rename it for the target paper.
2. Put the paper PDF, appendix, and any supplement files in `paper/`.
3. Record the paper's core model, data, and target outputs in `README.md`.
4. Keep original data in `data/raw/`; only scripts should create files in
   `data/processed/`.
5. Save reproduced tables, figures, logs, and diagnostics in `results/` and
   `figures/`.
6. Update `replication_log.md` every time a modeling, coding, or data decision
   changes.

## Reproducibility Rules

- Do not edit raw data by hand.
- Keep paper-specific assumptions documented in `notes/`.
- Prefer scripts that can be re-run from a clean checkout.
- Save exact error messages and mismatches when a reproduction fails.
- Distinguish paper targets from exploratory thesis extensions.

## Current Papers

| Folder | Paper | Current status |
| --- | --- | --- |
| `paccagnini_2010_dsge_var` | Paccagnini (2010), DSGE model evaluation in a Bayesian framework | Reduced DSGE-VAR Monte Carlo replication, real FRED data collected, references and formula derivations documented |
| `koop_korobilis_2010_bayesian_multivariate_time_series` | Koop and Korobilis (2010), Bayesian multivariate time series methods | Section 2.3 BVAR illustration replicated, author code/data and FRED data collected, references and formula derivations documented |
| `chan_2022_asymmetric_conjugate_bvar` | Chan (2022), asymmetric conjugate priors for large Bayesian VARs | Table 2 ACP-BVAR marginal-likelihood replication matched, author MATLAB code checked, real source data documented, references and formula derivations documented |
| `selected_next_10_core_papers` | 10 follow-up core papers selected from the first three papers' reference networks | FRED-MD/FRED-QD data collected, GLP and Kadiyala-Karlsson archives downloaded, BVAR/FAVAR/diffusion-index/rolling-VAR baseline replications run, Chinese notes and formula derivations documented |

See `replication_overview_zh.md` for the thesis-proposal-oriented summary across
the first three papers, and `selected_next_10_core_papers/notes/replication_summary_zh.md`
for the 10-paper follow-up batch.
