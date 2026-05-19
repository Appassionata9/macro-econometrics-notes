# Paccagnini (2010) 复现总结笔记

日期：2026-05-19

## 1. 当前复现状态

我已经完整跑完当前 R 项目中针对 Paccagnini (2010) 的复现流程。这里的“完整”指的是本项目现有代码所覆盖的复现范围，而不是论文全部结构估计、MCMC、真实数据和预测附录的完全复刻。

当前项目已经可以一键运行：

```sh
Rscript paper_reproductions/paccagnini_2010_dsge_var/code/run_replication.R
```

这个总脚本会依次完成：

- forward-looking DSGE-VAR single demo；
- forward-looking DGP 的 100 次 Monte Carlo；
- backward-looking DGP 的 100 次 Monte Carlo；
- 把 `output/*.csv` 同步到本论文 `results/` 文件夹；
- 生成 optimal lambda 频数图；
- 和论文 Table 1、Table 3 做频数对照。

## 2. 已复现的核心内容

当前 R 代码复现的是论文最核心的 DSGE-VAR model validation 逻辑：

- 用 forward-looking New Keynesian DSGE 生成候选模型和 dummy-observation priors；
- 用 backward-looking Rudebusch-Svensson/Linde 模型生成 alternative DGP；
- 对 VAR lag 从 1 到 8 逐一计算 DSGE-VAR marginal data density；
- 在论文式 lambda grid 上选择 optimal lambda；
- 观察 optimal lambda 是否靠近 minimum lambda，从而判断 DSGE 模型是否解释数据。

代码主要对应：

- `R/models.R`
- `R/dsge_var.R`
- `scripts/run_single_demo.R`
- `scripts/run_forward_mc.R`
- `scripts/run_backward_mc.R`

## 3. 本次更新

这次我做了几项关键更新：

- 把论文 Table 1 和 Table 3 的目标频数整理成 CSV：
  - `results/paper_table1_forward_frequency.csv`
  - `results/paper_table3_backward_frequency.csv`
- 新增论文对照脚本：
  - `code/compare_to_paper_tables.R`
- 修正 `lambda_min`：
  - 论文公式是 `lambda_min >= (n + k) / T`，其中 `k = 1 + p * n`；
  - 本项目现在对 80 个观测、3 个变量、1 到 8 阶 VAR 使用论文报告的 minimum lambda：
    `0.09, 0.13, 0.17, 0.20, 0.24, 0.28, 0.31, 0.35`。
- 修正 backward-looking model 的 shock 标准差：
  - `linde_whole` 现在使用 Table A4 的 Linde whole-sample 标准差；
  - `rs_whole` 现在使用 RS whole-sample 标准差。
- 修正总脚本的 CSV 同步逻辑，让每次 full run 都会更新 paper-specific `results/`。

## 4. 复现结果

### Single Demo

在单次 forward-looking demo 中：

- lambda grid 上的 log marginal data density 随 lambda 增大而改善；
- 当前 single demo 的最佳 lambda 是 `10`；
- 信息准则方面：
  - AIC 选择 VAR(3)；
  - BIC 选择 VAR(2)；
  - HQ 选择 VAR(3)。

这与论文中“forward-looking DGP 可以被有限阶 VAR 近似，VAR(2) 是重要候选”的讨论方向有关，但当前 single demo 不是论文表格本身。

### Forward-Looking Monte Carlo

当前复现中，forward-looking DGP 下 optimal lambda 非常偏向大值：

| VAR lag | 主要 optimal lambda |
| --- | --- |
| 1 | `10` 出现 68 次，`5` 出现 20 次 |
| 2 | `10` 出现 64 次，`5` 出现 29 次 |
| 3 | `10` 出现 81 次，`5` 出现 18 次 |
| 4 | `10` 出现 81 次，`5` 出现 18 次 |
| 5 | `10` 出现 85 次，`5` 出现 15 次 |
| 6 | `10` 出现 82 次，`5` 出现 18 次 |
| 7 | `10` 出现 90 次，`5` 出现 10 次 |
| 8 | `10` 出现 92 次，`5` 出现 8 次 |

这说明当前实现认为候选 DSGE 对 forward-looking artificial data 的解释力很强。但是它没有数量级匹配论文 Table 1。论文 Table 1 的 optimal lambda 基本集中在 1 以下，而当前结果大量集中在 `5` 和 `10`。

### Backward-Looking Monte Carlo

当前复现中，backward-looking DGP 下每个 lag 都 100 次选择 minimum lambda：

| VAR lag | 当前 optimal lambda | 出现次数 |
| --- | --- | --- |
| 1 | 0.09 | 100 |
| 2 | 0.13 | 100 |
| 3 | 0.17 | 100 |
| 4 | 0.20 | 100 |
| 5 | 0.24 | 100 |
| 6 | 0.28 | 100 |
| 7 | 0.31 | 100 |
| 8 | 0.35 | 100 |

这个结果与论文 Table 3 的核心判断一致：当真实 DGP 是 backward-looking model，而候选模型仍然是 forward-looking DSGE 时，DSGE-VAR 会倾向于选择靠近 minimum lambda 的值，说明 DSGE restriction 对数据解释力弱，应当拒绝“数据来自 forward-looking DSGE”的 null hypothesis。

但当前结果比论文更极端。论文 Table 3 不是每个 lag 都 100% 选择 minimum lambda，而是有一部分质量分散到邻近 lambda。

## 5. 与论文表格的对照

对照文件：

- `results/comparison_table1_forward.csv`
- `results/comparison_table3_backward.csv`
- `results/comparison_summary.csv`

当前对照结论：

- Forward-looking Table 1：每个 lag 的 total absolute frequency difference 都是 `200`，表示当前频数分布和论文 Table 1 基本不重叠。
- Backward-looking Table 3：方向一致，但当前分布更集中在 minimum lambda；差异在 lag 2 最小，在 lag 5 和 lag 6 较大。

Backward-looking 对照摘要：

| VAR lag | total absolute frequency difference |
| --- | ---: |
| 1 | 64 |
| 2 | 6 |
| 3 | 58 |
| 4 | 22 |
| 5 | 168 |
| 6 | 106 |
| 7 | 32 |
| 8 | 32 |

## 6. 为什么当前结果不能完全等于论文

当前项目是一个 reduced-form / transparent R replication。它复现了 DSGE-VAR 的主要机制，但还没有实现论文完整的结构参数后验计算。

主要差异来源：

- 论文通过 structural parameters 的 posterior/MCMC 来计算 marginal data density；
- 当前实现使用附录报告的 policy-function matrices，并把它们作为固定的 DSGE prior moment 来源；
- 当前 marginal data density 是 conjugate DSGE-VAR 的闭式计算，没有对 DSGE 参数 `theta` 做 Metropolis-Hastings 积分；
- 当前还没有复现论文后半部分的真实数据表、forecasting appendix 和其他 robustness tables。

所以，当前项目适合作为 thesis proposal 的方法论复现基础，但如果目标是逐表逐数值完全匹配论文，还需要实现完整 MCMC structural layer。

## 7. 对博士 proposal 的使用建议

这篇论文目前可以在 proposal 中承担三个角色：

1. 方法论来源：说明 DSGE-VAR 如何用 lambda 衡量 DSGE restriction 的强弱。
2. 模型验证案例：forward-looking DGP 与 backward-looking DGP 的对比可以作为 model validation 的直观例子。
3. 研究缺口：当前复现显示 reduced DSGE-VAR 与 full structural Bayesian implementation 之间可能存在明显数值差异，这可以发展成 proposal 中关于 reproducibility、model uncertainty 或 empirical validation 的讨论点。

如果 proposal 重点是理论框架和研究设计，当前 reduced replication 已经足够支撑初步讨论。如果 proposal 需要严谨声称“完全复现 Paccagnini Table 1 和 Table 3”，下一步必须实现完整的 Metropolis-Hastings posterior integration。

## 8. 下一步建议

优先级最高的下一步：

1. 明确 thesis proposal 是否需要“完全数值匹配”。
2. 如果需要，新增 structural parameter sampling：
   - 写出 DSGE 参数 prior；
   - 用 Sims solver 从 `theta` 得到 policy matrices；
   - 用 Metropolis-Hastings 抽样；
   - 对每个 lambda 积分 marginal data density。
3. 如果不需要，把当前 reduced replication 固定为 baseline，并开始复现下一篇关键论文。

我的建议是：先把这篇作为 proposal 的 DSGE-VAR validation baseline，不急着投入完整 MCMC。除非你的 proposal 明确要以“复现 Paccagnini 原始数值结果”为主要贡献，否则现在更应该并行整理第二篇、第三篇文献，构建你的研究问题链条。
