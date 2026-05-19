# Banbura, Giannone and Reichlin (2010) Replication Note

## 为什么选这篇

这篇是 large BVAR 的核心论文。它提供了一个对你很有用的观点：变量越多，prior shrinkage 越重要；大 VAR 并不一定输给 factor model。

## 本轮复现内容

- 用 FRED-MD 真实大面板构造 BVAR baseline；
- 复现 tightness grid 的思想；
- 和 GLP 的 marginal likelihood tightness selection 放在同一套代码里运行。
- 下载作者主页的 `LargeBVARReplicationWeb.zip`；
- 新增 system-size BVAR 预测比较，覆盖 3、10、20、50、68 变量系统。

## 数据与代码

- 数据：`../data/raw/fred_md/2026-04-md.csv`
- 作者 archive：`data/raw/LargeBVARReplicationWeb.zip`
- 代码：`../code/run_baseline_replications.R`、`../code/run_extended_replications.R`
- 输出：`../results/glp_lambda_grid_small_bvar.csv`、`../results/bgr_system_size_bvar_rmse.csv`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键直觉：

$$
k=1+np,\quad \text{parameters}=kn,
$$

所以 \(n\) 变大时，需要更小的 \(\lambda\) 控制估计方差。

## 当前状态

已完成 method-level replication，并已下载作者原始 replication archive。由于原程序是 Matlab，本地 R 版先复现核心机制：随着系统维度扩大，用更强 shrinkage 控制预测误差。
