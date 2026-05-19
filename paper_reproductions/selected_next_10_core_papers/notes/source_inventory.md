# Source Inventory

## Primary Web Sources Checked

- FRED-MD/FRED-QD official page: https://www.stlouisfed.org/research/economists/mccracken/fred-databases
- Giannone, Lenza and Primiceri replication archive: https://doi.org/10.7910/DVN/27345
- Kadiyala and Karlsson JAE data archive: http://qed.econ.queensu.ca/jae/1997-v12.2/kadiyala-karlsson/
- Litterman working paper, Minneapolis Fed: https://www.minneapolisfed.org/research/wp/wp274.pdf
- Litterman Fed in Print record: https://fedinprint.org/item/fedmwp/42678/original
- Bernanke, Boivin and Eliasz FEDS version: https://www.federalreserve.gov/pubs/feds/2004/200403/200403pap.pdf
- Bernanke, Boivin and Eliasz QJE DOI page: https://doi.org/10.1162/0033553053327452
- Stock and Watson NBER working paper page: https://www.nber.org/papers/w6702
- Stock and Watson paper PDF: https://scholar.harvard.edu/files/stock/files/macroeconomic_forecasting_using_diffusion_indexes.pdf
- Stock and Watson backup PDF: https://www.princeton.edu/~mwatson/papers/Stock_Watson_JBES_2002.pdf
- Primiceri journal page: https://academic.oup.com/restud/article/72/3/821/1556589
- Giannone, Lenza and Primiceri NBER page: https://www.nber.org/papers/w18467
- Bernanke, Boivin and Eliasz NBER page: https://www.nber.org/papers/w10220
- Carriero, Clark and Marcellino repository page: https://hdl.handle.net/1814/39410

## Local Sources Already Available

Several author-code packages downloaded for Koop and Korobilis (2010) are useful
for this next batch:

- `paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/data/raw/author_code/BVAR_FULL/`
- `paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/data/raw/author_code/BVAR_Analytical/`
- `paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/data/raw/author_code/TVP_VAR_CK/`
- `paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/data/raw/author_code/FAVAR/`
- `paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/data/raw/author_code/TVP_FAVAR/`

These provide practical Matlab baselines for BVAR, TVP-VAR and FAVAR methods.

## Data Strategy

The batch replication uses:

- FRED-MD current monthly data for large BVAR, diffusion-index and FAVAR baselines;
- FRED-QD current quarterly data for quarterly macro checks;
- FRED single-series downloads for small VAR/BVAR examples;
- GLP and Kadiyala-Karlsson official archives where exact replication data are available.

For historical exact table replication, use the original archives when available
instead of current revised FRED data.

## Download Caveats

- `download_sources.py` currently records a 403 for the Minneapolis Fed
  Litterman PDF. The bibliographic source is still documented through Fed in
  Print and DOI records.
- The Harvard Stock-Watson PDF endpoint was unreliable during this run, so the
  script uses the Princeton author PDF as a fallback.
