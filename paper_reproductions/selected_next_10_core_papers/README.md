# Selected Next 10 Core Papers

This folder contains the next batch of paper replications selected from the
references of the first three replicated papers:

- Paccagnini (2010)
- Koop and Korobilis (2010)
- Chan (2022)

The selection is designed for a PhD proposal centered on macroeconometrics,
DSGE-VAR validation, Bayesian VARs, large BVAR shrinkage, TVP-VARs, and FAVARs.

## Selected Papers

| Rank | Paper | Main role in the proposal |
| ---: | --- | --- |
| 1 | Del Negro and Schorfheide (2004), "Priors from General Equilibrium Models for VARs" | Core DSGE-VAR prior construction behind Paccagnini |
| 2 | Litterman (1986), "Forecasting with Bayesian Vector Autoregressions: Five Years of Experience" | Foundational Minnesota prior and practical BVAR forecasting |
| 3 | Kadiyala and Karlsson (1997), "Numerical Methods for Estimation and Inference in Bayesian VAR Models" | Gibbs/Monte Carlo bridge from conjugate to more general BVARs |
| 4 | Sims and Zha (1998), "Bayesian Methods for Dynamic Multivariate Models" | Dummy priors and Bayesian structural/dynamic VAR inference |
| 5 | Banbura, Giannone and Reichlin (2010), "Large Bayesian VARs" | High-dimensional BVAR shrinkage benchmark |
| 6 | Giannone, Lenza and Primiceri (2015), "Prior Selection for Vector Autoregressions" | Hierarchical/marginal-likelihood shrinkage selection |
| 7 | Carriero, Clark and Marcellino (2015), "Bayesian VARs: Specification Choices and Forecast Accuracy" | Forecast-design choices for practical BVAR work |
| 8 | Primiceri (2005), "Time Varying Structural Vector Autoregressions and Monetary Policy" | Time variation in coefficients and volatility |
| 9 | Bernanke, Boivin and Eliasz (2005), "Measuring the Effects of Monetary Policy: A FAVAR Approach" | Data-rich monetary policy identification |
| 10 | Stock and Watson (2002), "Macroeconomic Forecasting Using Diffusion Indexes" | Principal-component factors from large macro panels |

## Current Replication Scope

The first-pass replication implemented here is a proposal-oriented baseline:

- common FRED-MD/FRED-QD data collection;
- small and medium BVAR forecasting baselines;
- Minnesota-prior and marginal-likelihood shrinkage grids;
- PCA diffusion-index/FAVAR baseline;
- rolling-VAR approximation to time-varying policy coefficients;
- source notes, formula derivations, and paper-specific replication plans.
- paper-specific README files in each selected paper folder;
- Chinese summary notes for selection, data collection, replication results and
  formula derivations.

This is not yet a complete one-for-one reproduction of every original table in
all 10 papers. Papers with public author archives are flagged in
`notes/source_inventory.md` for deeper exact replication.

## Run

From the repository root:

```sh
python3 paper_reproductions/selected_next_10_core_papers/code/download_sources.py
Rscript paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R
Rscript paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R
```

Outputs are written to:

```text
paper_reproductions/selected_next_10_core_papers/results/
paper_reproductions/selected_next_10_core_papers/figures/
```

The verified run on 2026-05-19 selected `lambda = 0.30` for the GLP-style
small BVAR marginal-likelihood grid. See:

```text
paper_reproductions/selected_next_10_core_papers/notes/replication_summary_zh.md
paper_reproductions/selected_next_10_core_papers/notes/exact_replication_status_zh.md
paper_reproductions/selected_next_10_core_papers/notes/reference_matrix_zh.md
```
