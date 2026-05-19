# 10篇核心文献复现总结

日期：2026-05-19

## 选择逻辑

这 10 篇是从前面三篇已整理论文的参考文献脉络中筛出来的，目标不是单纯堆文献，而是给博士 proposal 搭一条可执行的方法路线：

```text
DSGE-VAR 先验构造
-> Minnesota / Sims-Zha / conjugate BVAR
-> large BVAR 与超参数选择
-> FAVAR / diffusion index / TVP-SVAR 的 data-rich 与 time-varying 扩展
```

最终选择：

1. Del Negro and Schorfheide (2004)
2. Litterman (1986)
3. Kadiyala and Karlsson (1997)
4. Sims and Zha (1998)
5. Banbura, Giannone and Reichlin (2010)
6. Giannone, Lenza and Primiceri (2015)
7. Carriero, Clark and Marcellino (2015)
8. Primiceri (2005)
9. Bernanke, Boivin and Eliasz (2005)
10. Stock and Watson (2002)

## 已完成的数据获取

本批复现使用了真实公开数据，而不是模拟数据。

| 数据/资料 | 本地位置 | 用途 |
| --- | --- | --- |
| FRED-MD 2026-04 monthly CSV | `data/raw/fred_md/2026-04-md.csv` | large BVAR、diffusion index、FAVAR、small BVAR baseline |
| FRED-QD 2026-04 quarterly CSV | `data/raw/fred_qd/2026-04-qd.csv` | quarterly macro robustness check |
| FRED 单序列 | `data/raw/fred_series/` | 小型 VAR/BVAR 基准变量 |
| GLP replication archive | `giannone_lenza_primiceri_2015_prior_selection/data/raw/GLPreplicationWeb.zip` | 原作者 Matlab 代码、DataSW 数据和 marginal-likelihood 例子 |
| BGR replication archive | `banbura_giannone_reichlin_2010_large_bvar/data/raw/LargeBVARReplicationWeb.zip` | 原作者 Matlab 代码、HoF 数据和 large BVAR 表图复现入口 |
| CCM JAE archive | `carriero_clark_marcellino_2015_bvar_specification/data/raw/` | 原作者数据和 specification-choice 程序 |
| Kadiyala-Karlsson JAE archive | `kadiyala_karlsson_1997_bvar_numerical/data/raw/` | 原作者数据、Fortran/Gauss 代码和输出 |
| Litterman JBES PDF | `litterman_1986_bvar_forecasting/paper/wp274_litterman_1986.pdf` | Minnesota prior 论文版本 |
| Primiceri working paper PDF | `primiceri_2005_tvp_svar/paper/tvsvar_final_july_04.pdf` | TVP-SVAR 论文版本 |
| Bernanke-Boivin-Eliasz FEDS PDF | `bernanke_boivin_eliasz_2005_favar/paper/feds_2004_03_favar.pdf` | FAVAR 论文版本 |
| BBE 原始 Excel | `bernanke_boivin_eliasz_2005_favar/data/raw/bbe_data.xlsx` | Table I / Figure II 风格 FAVAR 复现 |
| Stock-Watson JBES PDF | `stock_watson_2002_diffusion_indexes/paper/stock_watson_2002_diffusion_indexes.pdf` | diffusion index 论文版本 |

仍需注意：Litterman (1986) 的 Minneapolis Fed PDF 链接当前返回 403，因此下载脚本把它记录在 `data/raw/DOWNLOAD_FAILURES.md`。文献信息和 DOI 已记录，方法复现不受影响。

## 已运行的复现实验

运行命令：

```sh
python3 paper_reproductions/selected_next_10_core_papers/code/download_sources.py
Rscript paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R
Rscript paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R
```

本地输出：

| 输出 | 解释 |
| --- | --- |
| `data/processed/small_macro_monthly_1960_2026.csv` | 从 FRED-MD 构造的小型月度宏观样本 |
| `results/glp_lambda_grid_small_bvar.csv` | GLP 风格的 marginal likelihood tightness grid |
| `results/bvar_forecast_comparison.csv` | OLS VAR、Litterman Minnesota BVAR、GLP-selected BVAR 的预测 RMSE |
| `results/diffusion_factor_variance.csv` | FRED-MD PCA 因子解释方差 |
| `results/favar_policy_irf_baseline.csv` | 两步法 FAVAR 中联邦基金利率冲击的 IRF |
| `results/rolling_policy_rule_coefficients.csv` | Primiceri 风格 time variation 的 rolling VAR 近似 |
| `figures/diffusion_factor_variance.png` | diffusion index 方差解释图 |
| `figures/favar_policy_irf_baseline.png` | FAVAR policy shock IRF 图 |
| `figures/rolling_policy_rule_coefficients.png` | rolling policy coefficients 图 |
| `results/stock_watson_diffusion_forecast_rmse.csv` | Stock-Watson 风格 diffusion-index 直接预测 |
| `results/bgr_system_size_bvar_rmse.csv` | Banbura-Giannone-Reichlin 风格 system-size BVAR 比较 |
| `results/carriero_specification_grid.csv` | Carriero-Clark-Marcellino 风格 lag/tightness/horizon grid |
| `results/primiceri_rolling_window_sensitivity.csv` | Primiceri 风格 rolling window 敏感性 |
| `results/bbe_table_i_replication.csv` | Bernanke-Boivin-Eliasz Table-I 风格 contribution/R2 |

## 关键结果

GLP 风格 marginal likelihood grid 选择的 tightness：

```text
lambda = 0.30
```

小型月度 BVAR 的 60 期 holdout 预测 RMSE：

| 模型 | IP growth | inflation | unemployment | fed funds |
| --- | ---: | ---: | ---: | ---: |
| OLS VAR | 11.480 | 3.337 | 0.253 | 0.198 |
| Litterman Minnesota BVAR, lambda=0.20 | 11.486 | 3.303 | 0.218 | 0.180 |
| GLP-selected BVAR, lambda=0.30 | 11.482 | 3.307 | 0.232 | 0.185 |

解释：在这个当前 FRED-MD 样本上，shrinkage 对利率和失业率预测改善更明显；工业生产增长的预测没有明显改善。这正好可以作为 proposal 中“BVAR shrinkage 的收益与变量、样本、目标函数有关”的实证例子。

FRED-MD PCA diffusion index 的前 3 个因子累计解释约 36.9% 的 transformed panel variation，前 20 个因子累计解释约 75.0%。这支持 Stock-Watson 和 FAVAR 的核心直觉：大信息集可以被少数 common factors 压缩。

扩展结果里，BBE 原始 Excel 的 Table-I 风格复现显示，Fed funds、industrial production、CPI 的 R-squared 分别约为 1.000、0.746、0.863；monetary policy shock contribution 分别约为 0.151、0.093、0.082。本地数值和公开 R 复现笔记中的数量级一致，但由于当前脚本使用 point-estimate VAR 而非 500 次 bootstrap，置信区间没有在这一轮生成。

## 10篇论文对应的本地复现内容

| 论文 | 本地复现方式 | 主要输出 |
| --- | --- | --- |
| Del Negro and Schorfheide (2004) | DSGE-implied moments 作为 dummy observations 的公式复现，并连接前面 Paccagnini DSGE-VAR 文件夹 | `notes/formula_derivations.md` |
| Litterman (1986) | Minnesota prior BVAR，lambda=0.20 的 forecasting baseline | `results/bvar_forecast_comparison.csv` |
| Kadiyala and Karlsson (1997) | 下载 JAE 官方数据和代码，整理 independent Normal-Wishart / Gibbs 推导 | `kadiyala_karlsson_1997_bvar_numerical/data/raw/` |
| Sims and Zha (1998) | dummy-observation prior 的 sufficient statistics 复现 | `notes/formula_derivations.md` |
| Banbura et al. (2010) | 用 FRED-MD baseline 展示 large BVAR tightness grid | `results/glp_lambda_grid_small_bvar.csv` |
| Giannone et al. (2015) | marginal likelihood 选择 tightness，下载原作者 GLP archive | `results/glp_lambda_grid_small_bvar.csv` |
| Carriero et al. (2015) | 预测设定比较：OLS vs fixed Minnesota vs selected tightness | `results/bvar_forecast_comparison.csv` |
| Primiceri (2005) | rolling VAR 作为 TVP-SVAR 第一轮透明近似 | `results/rolling_policy_rule_coefficients.csv` |
| Bernanke et al. (2005) | 两步 PCA FAVAR 与 policy IRF | `results/favar_policy_irf_baseline.csv` |
| Stock and Watson (2002) | FRED-MD principal components / diffusion indexes | `results/diffusion_factor_variance.csv` |

更细的 exact/data/code 状态见 `notes/exact_replication_status_zh.md`；参考文献路线图见 `notes/reference_matrix_zh.md`。

## 公式推导位置

- 总公式：`notes/formula_derivations.md`
- 中文逐步推导：`notes/formula_derivation_walkthrough_zh.md`
- 每篇论文的入口说明：各论文子文件夹中的 `README.md`

## 当前复现的边界

这一轮已经完成 proposal 阶段最需要的四件事：真实数据、可运行代码、核心公式推导、参考文献路线图。对于有公开 archive 的 BGR、GLP、CCM、Kadiyala-Karlsson 和 BBE，资料已落地；对于没有稳定公开代码的论文，本项目用 FRED-MD/FRED-QD 或公开复现数据做 method-level replication，并在 `exact_replication_status_zh.md` 中标明边界。
