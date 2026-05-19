# Chan (2022) 复现总结笔记

日期：2026-05-19

## 1. 当前复现状态

我已经按照前两篇论文的方式，为 Chan (2022) 建立了独立复现文件夹，并完整跑通当前项目范围内的 R 复现流程。

一键运行命令：

```sh
Rscript paper_reproductions/chan_2022_asymmetric_conjugate_bvar/code/run_replication.R
```

这个脚本会完成：

- 读取作者官方 `database_2019Q4.xlsx` 数据；
- 生成 6-variable 和 15-variable 的 processed CSV；
- 下载 FRED 公开源数据用于来源核查；
- 构造 asymmetric conjugate prior；
- 计算 closed-form log marginal likelihood；
- 优化 symmetric、subjective、asymmetric 三种 prior 的 shrinkage hyperparameters；
- 生成 Table 2 对照表和图像；
- 输出 15-variable 模型的 posterior variance summary。

## 2. 论文和数据

这篇论文使用 1985Q1-2019Q4 的美国季度宏观和金融变量。作者官方代码包中提供的核心数据文件是：

```text
data/raw/author_code/BVAR_ACP_R1_code/database_2019Q4.xlsx
```

我已经处理出：

```text
data/processed/author_database_6var_1985q1_2019q4.csv
data/processed/author_database_15var_1985q1_2019q4.csv
```

其中 6-variable 数据用于小系统结构冲击示例，15-variable 数据用于论文 Table 2 的主要 hyperparameter comparison。

## 3. 真实数据来源

官方表格复现使用作者 workbook，因为它已经包含论文使用的 transformed quarterly variables。

同时，我从 FRED 下载了公开可追溯序列作为 source checks：

- `TB3MS`
- `GPDIC1`
- `BAA`
- `FEDFUNDS`
- `GS10`
- `MORTGAGE30US`
- `CPIAUCSL`
- `PCEPI`
- `CE16OV`
- `INDPRO`
- `GS1`
- `DJIA`

需要注意：论文 Appendix A 说明原始序列还涉及 Federal Reserve Bank of Philadelphia、Yahoo Finance 和 Board of Governors 等来源；有些变量是 spread、ratio、real variable 或指数变换。因此，FRED 数据适合说明可追溯来源，精确表格复现仍应使用作者 workbook。

## 4. 作者原始代码

我找到了并下载了 Joshua Chan 官方 replication code：

```text
data/raw/author_code/BVAR_ACP_R1_code.zip
```

主要文件包括：

- `main_ACP_apps.m`
- `main_ACP_jointden.m`
- `database_2019Q4.xlsx`
- prior、marginal likelihood、posterior sampler 和 impulse response 相关 helper functions。

另外也保存了旧版 forecasting application 代码：

```text
data/raw/author_code/BVAR_ACP_code.zip
```

当前 R 复现优先使用 2022 journal-version code。

## 5. 已复现的核心内容

当前 R 复现覆盖了论文最核心的 computational contribution：

- 用 triangular structural VAR 把大 BVAR 拆成逐方程条件回归；
- 对每个方程设置 normal-inverse-gamma conjugate prior；
- 允许 own lags 和 other-variable lags 使用不同 shrinkage hyperparameters；
- 用 reduced-form elicitation 修正 structural prior variance；
- 通过 closed-form marginal likelihood 选择 hyperparameters；
- 对比 symmetric prior、subjective prior 和 asymmetric prior。

核心代码：

```text
code/prepare_real_data.py
code/acp_replication.R
code/run_replication.R
```

## 6. Table 2 复现结果

论文 Table 2 的目标是比较 15-variable VAR 下三种 prior 的最优 hyperparameters 和 log marginal likelihood。

当前 R 复现结果：

| prior | kappa1 | kappa2 | log marginal likelihood |
| --- | ---: | ---: | ---: |
| symmetric | 0.008321 | 0.008321 | 4333.299 |
| subjective | 0.040000 | 0.001600 | 4329.768 |
| asymmetric | 0.058099 | 0.004270 | 4341.550 |

论文 Table 2 报告：

| prior | kappa1 | kappa2 | log marginal likelihood |
| --- | ---: | ---: | ---: |
| symmetric | 0.008 | 0.008 | 4333.3 |
| subjective | 0.040 | 0.0016 | 4329.8 |
| asymmetric | 0.058 | 0.0043 | 4341.6 |

差异基本都是 rounding。

## 7. MATLAB 官方代码交叉验证

为了确认 R 代码不是“看起来接近但公式不一致”，我还直接运行了作者 MATLAB 代码，并保存结果：

```text
results/matlab_table2_check.csv
```

MATLAB 输出：

| prior | kappa1 | kappa2 | log marginal likelihood |
| --- | ---: | ---: | ---: |
| symmetric | 0.0083108653 | 0.0083108653 | 4333.298534 |
| subjective | 0.0400000000 | 0.0016000000 | 4329.768311 |
| asymmetric | 0.0581102487 | 0.0042692800 | 4341.550491 |

这说明 R 复现已经和官方 replication package 对齐。

## 8. 当前项目边界

已经完成：

- 官方数据收集；
- FRED 真实数据来源核查；
- Table 2 的完整可运行复现；
- R 与 MATLAB 双重校验；
- references 和公式推导笔记。

尚未完成：

- Figure 1 的 posterior density contour 完整重画；
- Figure 2 和 Figure 3 的 sign-restricted impulse responses 完整 R 重写；
- 所有 structural shock identification 结果的图形复现。

这些没有阻碍 proposal 使用，因为这篇论文对你当前最重要的贡献是 asymmetric prior 和 closed-form marginal likelihood。

## 9. 对博士 proposal 的使用建议

这篇论文可以作为 proposal 中“大维度 Bayesian VAR prior 设计”的核心文献：

1. 它解决 natural conjugate prior 不能区分 own-lag 和 cross-lag shrinkage 的问题；
2. 它保留 closed-form posterior 和 marginal likelihood，因此适合大系统；
3. 它把 prior selection 从主观设定推进到 marginal likelihood 选择；
4. 它可以和 Koop and Korobilis (2010) 的标准 BVAR 框架、Paccagnini (2010) 的 DSGE-VAR model validation 形成方法链条。

我的建议是：proposal 中把 Chan (2022) 放在“large Bayesian VAR shrinkage and model comparison”部分，用 Table 2 复现作为强证据；sign restrictions 可以作为后续扩展，而不是第一阶段必须完成的复现任务。
