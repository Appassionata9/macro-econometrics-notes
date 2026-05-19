# Koop and Korobilis (2010) 复现总结笔记

日期：2026-05-19

## 1. 当前复现状态

我已经按照 Paccagnini 项目的方式，为 Koop and Korobilis (2010) 建立了独立复现文件夹，并完成了当前项目范围内的完整运行。

一键运行命令：

```sh
Rscript paper_reproductions/koop_korobilis_2010_bayesian_multivariate_time_series/code/run_replication.R
```

这个脚本会完成：

- 重新下载 FRED 官方数据；
- 整理作者原始 `Yraw.dat` 数据；
- 生成 FRED 重构数据和作者数据对照；
- 运行 Section 2.3 的 BVAR empirical illustration；
- 输出 Table 1、Table 3 的复现表和对照表；
- 生成数据图和 impulse response 图。

## 2. 论文和数据

论文的 BVAR 实证例子使用 1953Q1-2006Q3 的美国季度数据：

- inflation：chain-weighted GDP price index 的 annual percentage change；
- unemployment：seasonally adjusted civilian unemployment rate；
- interest rate：3-month Treasury bill yield。

最重要的数据文件是作者原始复现数据：

```text
data/processed/author_yraw_1953q1_2006q3.csv
```

我也从 FRED 收集并处理了可追溯官方数据：

```text
data/processed/fred_reconstructed_1953q1_2006q3.csv
```

FRED 使用的序列是：

- `GDPCTPI`
- `UNRATE`
- `TB3MS`

作者数据更适合用来复现论文表格；FRED 数据更适合用来说明数据来源、可追溯性和后续稳健性检查。

## 3. 作者原始代码

我从 Dimitris Korobilis 的 Matlab code page 下载了作者代码，包括：

- BVAR analytical；
- BVAR full；
- BVAR Gibbs；
- BVAR SSVS；
- TVP-VAR；
- hierarchical TVP-VAR；
- factor models；
- FAVAR；
- TVP-FAVAR。

这些文件都保存在：

```text
data/raw/author_code/
```

当前 R 复现主要覆盖 Section 2.3 的 BVAR illustration。TVP-VAR、FAVAR 和 TVP-FAVAR 的原始 Matlab 代码已经收集好，但尚未全部重写成 R。

## 4. BVAR 复现内容

当前 R 代码复现了论文 Section 2.3 的核心设置：

- unrestricted VAR；
- intercept；
- 4 lags；
- variables ordered as inflation, unemployment, interest rate；
- direct one-step-ahead forecast；
- noninformative prior；
- Minnesota prior；
- natural conjugate prior；
- noninformative-prior impulse responses。

主要脚本：

```text
code/prepare_real_data.R
code/bvar_replication.R
code/run_replication.R
```

## 5. Table 1 复现结果

输出文件：

```text
results/table1_noninformative_posterior_mean.csv
results/paper_table1_noninformative_targets.csv
results/table1_noninformative_comparison.csv
```

Table 1 的 noninformative prior posterior mean 基本复现成功。比如：

- Intercept inflation：当前 `0.2925`，论文 `0.2920`；
- inflation lag 1 -> inflation：当前 `1.5088`，论文 `1.5087`；
- unemployment lag 1 -> unemployment：当前 `1.2730`，论文 `1.2727`；
- interest lag 1 -> interest：当前 `0.7741`，论文 `0.7746`。

这些差异非常小，说明作者数据和 VAR 设定已经对齐。

## 6. Table 3 复现结果

输出文件：

```text
results/table3_predictive_analytical_priors.csv
results/paper_table3_analytical_targets.csv
results/table3_predictive_comparison.csv
```

当前 R 复现了三个 analytical priors：

- noninformative；
- Minnesota；
- natural conjugate。

Table 3 的预测均值和标准差与论文非常接近。例子：

| Prior | Variable | 当前均值 | 论文均值 |
| --- | --- | ---: | ---: |
| Noninformative | inflation | 3.103 | 3.105 |
| Noninformative | unemployment | 4.611 | 4.610 |
| Noninformative | interest rate | 4.380 | 4.382 |
| Natural conjugate | inflation | 3.104 | 3.106 |
| Natural conjugate | interest rate | 4.388 | 4.380 |

Minnesota prior 的标准差略有偏差，尤其 interest rate 的预测标准差当前为约 `0.819`，论文为 `0.741`。这可能来自随机模拟误差、Minnesota prior 方差实现细节，或作者 Matlab 程序中的 predictive draw 具体设定。

## 7. 图像输出

当前生成了两张图：

```text
figures/figure1_author_data.png
figures/figure2_irf_noninformative.png
```

第一张图对应论文 Figure 1 的数据展示；第二张图对应论文 Figure 2 风格的 noninformative prior impulse responses。

## 8. 数据对照

作者数据和当前 FRED 重构数据高度相关，但不完全相同：

- inflation correlation: about 0.998；
- unemployment correlation: about 0.994；
- 3-month T-bill rate correlation: about 0.988。

差异原因主要是：

- FRED 当前数据是 revised data；
- 作者可能使用了当时 FRED vintage 或略有不同的季度转换方式；
- 论文表格最应该用作者 `Yraw.dat` 来复现。

## 9. 当前项目边界

已经完成：

- 论文主 BVAR illustration 的可运行 R 复现；
- 作者原始代码/数据收集；
- FRED 官方真实数据收集；
- 表格和图像输出；
- 中文总结笔记。

尚未完成：

- SSVS prior 的完整 Gibbs sampler R 重写；
- Table 1 的 SSVS-VAR posterior mean；
- Table 2 posterior inclusion probabilities；
- Figure 3 SSVS impulse responses；
- TVP-VAR、stochastic volatility、FAVAR、TVP-FAVAR 的 R 复现。

这些后续模块的作者 Matlab 代码已经下载好了。如果你的 thesis proposal 只需要 Bayesian VAR 方法论和基线复现实证，这个项目已经足够作为第一版 baseline。如果 proposal 要深入 time-varying parameter 或 FAVAR，则下一步可以从作者 TVP-VAR/FAVAR Matlab 代码开始逐步转写。

## 10. 对博士 proposal 的使用建议

这篇论文可以作为 proposal 中 Bayesian empirical macro 方法论的核心参考：

1. 说明 Bayesian VAR 如何通过 prior shrinkage 缓解参数过多问题；
2. 展示 noninformative、Minnesota、natural conjugate、SSVS 等 prior 的差异；
3. 连接到 TVP-VAR、stochastic volatility 和 FAVAR，为后续更复杂模型铺垫；
4. 作为论文复现库中“方法综述 + 可运行实证 baseline”的代表。

我的建议是：先把 Section 2.3 的 BVAR baseline 用在 proposal 里。它已经有真实数据、有表格对照、有图、有作者原始代码背书。TVP-VAR 和 FAVAR 可以作为后续扩展，而不是现在马上全部展开。
