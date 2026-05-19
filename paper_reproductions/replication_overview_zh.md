# 论文复现库总览

日期：2026-05-19

## 1. 当前完成情况

| 论文 | 已完成复现 | 真实数据 | 参考文献 | 公式推导 | 当前边界 |
| --- | --- | --- | --- | --- | --- |
| Paccagnini (2010) | DSGE-VAR Monte Carlo baseline、lambda 选择、Table 1/3 对照 | FRED: GDP、CPI、Federal Funds Rate | 已整理 | 已整理 | 目前是 reduced-form 透明复现，未完整实现 DSGE structural-parameter MCMC |
| Koop and Korobilis (2010) | Section 2.3 BVAR empirical illustration、Table 1/3、IRF baseline | 作者数据 + FRED: GDPCTPI、UNRATE、TB3MS | 已整理 | 已整理 | TVP-VAR、FAVAR、SSVS 全量 R 重写尚未完成，但作者 Matlab 代码已收集 |
| Chan (2022) | ACP-BVAR Table 2、closed-form marginal likelihood、R/MATLAB 双重校验 | 作者 workbook + FRED source checks | 已整理 | 已整理 | Sign-restricted Figures 2/3 尚未完整 R 重写；官方 Matlab 主程序已收集 |

## 2. 三篇论文之间的方法链条

这三篇论文可以组成一个比较清晰的 proposal 方法脉络：

1. Paccagnini (2010)：从 DSGE-VAR 角度讨论 structural model restriction 是否能解释数据，用 $\lambda$ 衡量 DSGE restriction 的强弱。
2. Koop and Korobilis (2010)：系统整理 Bayesian VAR、Minnesota prior、natural conjugate prior、SSVS、TVP-VAR、FAVAR 等 empirical macro 方法。
3. Chan (2022)：针对 large BVAR 中 prior shrinkage 的限制提出 asymmetric conjugate prior，让 own lags 和 cross-variable lags 可以被不同程度 shrink，同时保留 closed-form posterior 和 marginal likelihood。

可以把这条线写成：

```text
DSGE model validation -> Bayesian VAR baseline -> large BVAR asymmetric shrinkage
```

## 3. 最适合放进 proposal 的复现证据

Paccagnini (2010):

- 使用 `results/comparison_table3_backward.csv` 说明当 DGP 与候选 DSGE 不一致时，optimal lambda 会贴近 minimum lambda。
- 使用 `notes/formula_derivations.md` 说明 dummy-observation prior 和 marginal likelihood 的来源。

Koop and Korobilis (2010):

- 使用 `results/table1_noninformative_comparison.csv` 说明基础 VAR 后验均值已经精确对齐。
- 使用 `results/table3_predictive_comparison.csv` 说明 analytical priors 的预测分布复现接近论文。
- 使用 `notes/formula_derivations.md` 作为 BVAR prior 的方法论笔记。

Chan (2022):

- 使用 `results/table2_hyperparameter_comparison.csv` 说明 asymmetric prior 的 marginal likelihood 优于 symmetric 和 subjective benchmarks。
- 使用 `results/matlab_table2_check.csv` 说明 R 复现已和作者官方 MATLAB 代码对齐。
- 使用 `notes/formula_derivations.md` 说明 asymmetric conjugate prior 为什么能逐方程闭式估计。

## 4. 真实数据来源原则

当前复现库采用两层数据来源：

1. 表格复现优先使用作者原始数据，因为它最接近论文实际使用的 vintage、变换和样本定义。
2. 数据可追溯性使用官方公开来源，尤其是 FRED；对应链接记录在各论文的 `data/raw/*/SOURCES.md`。

这能避免两个常见问题：

- 用当前 revised FRED 数据硬复现旧论文表格，导致数值不一致；
- 只使用作者数据而不记录真实来源，导致 proposal 中数据可追溯性不足。

## 5. 后续优先级建议

如果 proposal 重点是“方法选择和研究设计”，当前三篇已经足够作为第一轮复现基础。

下一步最值得做的是：

1. 把三篇的 formula derivations 转成 proposal 的 methodology 小节；
2. 从 references.md 中选出核心 15-20 篇，形成 proposal literature review 主干；
3. 如果需要更强实证贡献，再补 Chan (2022) 的 sign-restricted impulse response 图或 Koop and Korobilis (2010) 的 TVP-VAR/FAVAR 模块。
