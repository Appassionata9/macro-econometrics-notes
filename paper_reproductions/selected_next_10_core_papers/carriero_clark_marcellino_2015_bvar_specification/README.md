# Carriero, Clark and Marcellino (2015) Replication Note

## 为什么选这篇

这篇关注实际 forecasting design choices：levels vs growth、lag length、tightness、direct/iterated forecast、point/density forecasts。它对你后面自己的实证设计很实用。

## 本轮复现内容

- 构造 OLS VAR、fixed Minnesota BVAR、GLP-selected BVAR 的 forecast comparison；
- 用同一 FRED-MD 小样本评估 RMSE；
- 作为后续扩展 forecast-design grid 的入口。
- 下载 JAE archive 中的 readme、数据和程序；
- 新增 lag length、tightness、forecast horizon 的 specification grid。

## 数据与代码

- 数据：`../data/processed/small_macro_monthly_1960_2026.csv`
- JAE archive：`data/raw/readme.ccm.txt`、`data/raw/ccm-data-txt.zip`、`data/raw/ccm-data-zip.zip`、`data/raw/ccm-programs.zip`
- 代码：`../code/run_baseline_replications.R`、`../code/run_extended_replications.R`
- 输出：`../results/bvar_forecast_comparison.csv`、`../results/carriero_specification_grid.csv`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

本轮主要使用固定 \(\Sigma\) 的 Normal posterior 和 one-step recursive forecast。

## 当前结果

Shrinkage BVAR 在 unemployment 和 fed funds 的 RMSE 上优于 OLS VAR。扩展 grid 进一步记录了 `p in {2,4,6}`、`lambda in {0.10,0.20,0.30,0.50}`、`h in {1,6,12}` 的预测误差，可直接用于 proposal 的 specification-choice 小节。
