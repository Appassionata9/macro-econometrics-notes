# Replication Log

## 2026-05-19

### Goal

- Create a dedicated paper replication workspace for thesis proposal work.

### What Changed

- Added `paper_reproductions/` with a reusable template and a first paper folder
  for Paccagnini (2010).

### Result

- Existing R replication code remains in the project root.
- Paper-specific artifacts can now be organized under
  `paper_reproductions/paccagnini_2010_dsge_var/`.

### Next Step

- Add the original paper PDF and appendix to `paper/`, then compare generated
  `output/*.csv` results with the paper's reported tables.

## 2026-05-19 First Replication Run

### Goal

- Start the Paccagnini (2010) replication using the existing R implementation.

### What Changed

- Copied the Paccagnini PDF into this paper folder.
- Extracted a searchable text version of the PDF.
- Updated the Monte Carlo scripts to use the paper-style lambda grid and include
  lag-specific minimum lambda values.
- Added frequency-table outputs for optimal lambda values.
- Added paper-specific scripts for running the replication and plotting lambda
  frequency figures.

### Result

- `single_demo`, forward-looking Monte Carlo, and backward-looking Monte Carlo
  all run successfully.
- Backward-looking results choose the minimum lambda for every lag and
  replication in this reduced implementation.
- Forward-looking results choose high lambda values, mainly 5 and 10, which is
  qualitatively but not quantitatively aligned with the paper.

### Differences From Paper

- The paper's Table 1 reports forward-looking optimal lambda values below 1.
- The current implementation uses reported policy-function matrices and a
  conjugate marginal data density calculation, not the full structural-parameter
  posterior/MCMC layer.

### Next Step

- Build explicit comparison CSVs for the paper's Tables 1 and 3, then decide
  whether to implement the full structural posterior simulation layer.

## 2026-05-19 Full Current-Project Run

### Goal

- Run the complete current Paccagnini replication project and update all derived
  outputs, figures, comparisons, and notes.

### What Changed

- Added `compare_to_paper_tables.R`.
- Added hand-transcribed frequency targets for the paper's Table 1 and Table 3.
- Fixed the full-run script so it copies root-level `output/*.csv` files into
  the paper-specific `results/` folder.
- Updated the paper-specific full-run script to generate figures and comparison
  outputs automatically.
- Corrected the `lambda_min` definition to follow the paper's `(n + k) / T`
  formula and the reported 80-observation lambda minima.
- Corrected backward-model shock standard deviations so `linde_whole` uses
  Table A4's Linde whole-sample values and `rs_whole` uses the RS whole-sample
  values.

### Result

- The full current R workflow runs successfully.
- Updated outputs are stored in `results/`.
- Updated figures are stored in `figures/`.
- A Chinese summary note is stored in `notes/replication_summary_zh.md`.

### Differences From Paper

- Forward-looking Monte Carlo remains quantitatively different from Table 1:
  the current implementation strongly selects `lambda = 5` or `lambda = 10`.
- Backward-looking Monte Carlo is qualitatively aligned with Table 3 because it
  selects the minimum lambda, but it is more concentrated than the paper's
  reported distribution.
- The remaining gap is expected because this project still uses a reduced
  closed-form DSGE-VAR implementation rather than the paper's full
  structural-parameter posterior/MCMC computation.

### Next Step

- Use this run as the reproducible reduced baseline. Implement the full
  Metropolis-Hastings structural layer only if the thesis proposal requires
  quantitative table-level matching.

## 2026-05-19 Real Data Search

### Goal

- Locate official real U.S. macro data for the paper's real-data exercises.

### What Changed

- Downloaded current revised FRED data for `GDPC1`, `CPIAUCSL`, and `DFF`.
- Added a data README and source note under `data/`.
- Added `download_real_data.R` to re-download and process the data.
- Created processed quarterly files for 1981Q1-2001Q4 and 1961Q1-2001Q4.
- Created exact-length 80-observation and 160-observation files ending in
  2001Q3, which better match the Del Negro-Schorfheide sample description.

### Result

- Real-data files are available under `data/raw/fred/` and `data/processed/`.
- The federal funds rate is constructed from daily `DFF` as the average over
  business days in the first month of each quarter.

### Caveat

- These are current revised FRED series. Exact replication of the paper's real
  data tables may require vintage data or the original Del Negro-Schorfheide
  replication dataset.
