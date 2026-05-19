# Carriero, Clark and Marcellino (2015) Replication Note

## 为什么选这篇

这篇关注实际 forecasting design choices：levels vs growth、lag length、tightness、direct/iterated forecast、point/density forecasts。它对你后面自己的实证设计很实用。

## 本轮复现内容

- 构造 OLS VAR、fixed Minnesota BVAR、GLP-selected BVAR 的 forecast comparison；
- 用同一 FRED-MD 小样本评估 RMSE；
- 作为后续扩展 forecast-design grid 的入口。

## 数据与代码

- 数据：`../data/processed/small_macro_monthly_1960_2026.csv`
- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/bvar_forecast_comparison.csv`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

本轮主要使用固定 \(\Sigma\) 的 Normal posterior 和 one-step recursive forecast。

## 当前结果

Shrinkage BVAR 在 unemployment 和 fed funds 的 RMSE 上优于 OLS VAR。这个结果可以放在 proposal 的 preliminary replication evidence 中。
