# Primiceri (2005) Replication Note

## 为什么选这篇

Primiceri 是 TVP-SVAR 和 stochastic volatility 在货币政策实证中的经典来源。它适合连接 Koop-Korobilis 的 TVP-VAR 代码和你未来的 policy transmission 问题。

## 本轮复现内容

- 整理 TVP-SVAR 的 state equations；
- 用 rolling VAR 对政策反应系数做第一轮透明近似；
- 输出 inflation/unemployment 滞后项在 fed funds 方程中的 rolling coefficients。

## 数据与代码

- 数据：`../data/processed/small_macro_monthly_1960_2026.csv`
- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/rolling_policy_rule_coefficients.csv`
- 图像：`../figures/rolling_policy_rule_coefficients.png`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
y_t=B_t x_t+A_t^{-1}\Sigma_t\varepsilon_t,\quad
B_t=B_{t-1}+u_t.
$$

## 当前状态

当前是 diagnostic baseline，不是完整 MCMC TVP-SVAR posterior。后续可用前面 Koop-Korobilis author code 中的 TVP-VAR 模块继续 exact-style replication。
