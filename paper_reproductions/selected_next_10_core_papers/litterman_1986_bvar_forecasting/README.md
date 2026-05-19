# Litterman (1986) Replication Note

## 为什么选这篇

Litterman 是 Minnesota prior 的经典源头。后面的 Sims-Zha、Banbura-Giannone-Reichlin、GLP 和 Chan 的 large BVAR prior 都可以看作对这个 shrinkage 思想的扩展。

## 本轮复现内容

- 用 FRED-MD 构造小型月度宏观 VAR；
- 实现 Minnesota prior fixed-sigma posterior；
- 设置 `lambda = 0.20` 作为 Litterman-style baseline；
- 与 OLS VAR 和 GLP-selected BVAR 做 holdout RMSE 比较。

## 数据与代码

- 数据：`../data/processed/small_macro_monthly_1960_2026.csv`
- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/bvar_forecast_comparison.csv`

Minneapolis Fed 的 WP274 PDF 当前返回 403，失败记录在 `../data/raw/DOWNLOAD_FAILURES.md`；脚本已通过可访问的 JBES PDF 镜像下载论文到 `paper/wp274_litterman_1986.pdf`。

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
\operatorname{Var}(B_{\ell,ij})
=
\lambda^2\theta^2\sigma_i^2/(\ell^{2d}\sigma_j^2).
$$

## 当前结果

在 60 期 holdout 中，Minnesota BVAR 相比 OLS VAR 对 unemployment 和 fed funds 的 RMSE 更低。
