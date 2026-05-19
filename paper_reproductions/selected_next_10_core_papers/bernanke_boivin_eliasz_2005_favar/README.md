# Bernanke, Boivin and Eliasz (2005) Replication Note

## 为什么选这篇

FAVAR 解决小型 VAR 信息集过窄的问题，是 data-rich monetary policy analysis 的核心论文。

## 本轮复现内容

- 下载 FEDS 版本 PDF；
- 用 FRED-MD 提取前三个 PCA 因子；
- 将 FEDFUNDS 作为可观测政策变量；
- 估计两步法 FAVAR 并生成 policy shock IRF。

## 数据与代码

- 数据：`../data/raw/fred_md/2026-04-md.csv`
- 论文：`paper/feds_2004_03_favar.pdf`
- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/favar_policy_irf_baseline.csv`
- 图像：`../figures/favar_policy_irf_baseline.png`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
X_t=\Lambda^fF_t+\Lambda^rR_t+e_t.
$$

## 当前状态

已完成两步法 FAVAR baseline。后续 exact replication 可进一步匹配原文变量分组、slow/fast variables 和 policy shock identification。
