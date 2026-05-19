# Sims and Zha (1998) Replication Note

## 为什么选这篇

Sims-Zha 让 Bayesian prior 以 dummy observations 的方式进入动态多变量模型，是理解 structural BVAR、large system prior 和 DSGE-VAR prior 的关键节点。

## 本轮复现内容

- 整理 dummy-observation sufficient statistics；
- 说明它如何连接 Minnesota prior 和 DSGE-VAR prior；
- 在本批 baseline 中作为 BVAR prior construction 的理论模块。

## 数据与代码

本篇当前采用 method-level replication。实际估计使用共同的 FRED-MD baseline：

- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/selected_10_method_mapping.csv`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
X'X\to X'X+X_*'X_*,\quad
X'Y\to X'Y+X_*'Y_*.
$$

## 当前状态

已完成公式复现和本地方法映射。下一步可以把 Sims-Zha 的多个 dummy-prior blocks 写成独立函数并对比 Minnesota prior。
