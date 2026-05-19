# Giannone, Lenza and Primiceri (2015) Replication Note

## 为什么选这篇

GLP 把 BVAR prior tightness 从主观选择推进到 data-informed / hierarchical Bayes 选择，非常适合博士 proposal 里讨论 prior choice。

## 本轮复现内容

- 下载 Harvard Dataverse 原作者 archive；
- 在 R baseline 中实现 fixed-sigma marginal likelihood grid；
- 选择最优 \(\lambda\)，并用它做预测比较。

## 数据与代码

- 原作者 archive：`data/raw/GLPreplicationWeb.zip`
- 本地 R 代码：`../code/run_baseline_replications.R`
- 输出：`../results/glp_lambda_grid_small_bvar.csv`

Archive 中包含 `bvarGLP.m`、`ExampleForecast.m`、`ExampleIRFs.m`、`DataSW.xls`、`DataSW.mat` 等文件，后续可直接转入 exact Matlab replication。

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
\widehat\lambda=\arg\max_\lambda \log p(Y\mid\lambda).
$$

## 当前结果

本地 FRED-MD 小型 VAR baseline 选择：

```text
lambda = 0.30
```
