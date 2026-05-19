# 10篇论文复现完成度与 exact replication 状态

日期：2026-05-19

这份表专门补上上一轮没有说清楚的部分：每篇论文到底拿到了什么真实资料、能复现到哪一层、哪些部分已经运行、哪些部分受限于原始软件或公开资料。

| 论文 | 真实论文/数据/代码 | 本地状态 | 已运行输出 | exact replication 判断 |
| --- | --- | --- | --- | --- |
| Del Negro and Schorfheide (2004) | DOI、FRB Atlanta/RePEc/EconStor 条目已记录；PDF 下载入口当前返回网页而非 PDF | DSGE-VAR 公式与 dummy-observation prior 已复现 | `notes/formula_derivation_walkthrough_zh.md` | 当前为理论 exact，即公式层完整；原始样本和 DSGE 求解代码未公开稳定下载 |
| Litterman (1986) | JBES PDF 镜像已下载；Minneapolis Fed PDF 返回 403 | Minnesota prior fixed-sigma BVAR 已运行 | `results/bvar_forecast_comparison.csv` | 方法 exact；原文五年实时预测档案未公开，无法逐表 exact |
| Kadiyala and Karlsson (1997) | JAE 官方数据、Fortran/Gauss 程序和输出已下载 | Gibbs / Normal-Wishart 推导已整理 | `kadiyala_karlsson_1997_bvar_numerical/data/raw/` | 数据代码 exact；本地缺 Gauss/gfortran，因此暂未重跑原 Fortran |
| Sims and Zha (1998) | DOI/RePEc/ResearchGate PDF 信息已记录 | dummy-observation sufficient statistics 已复现 | `notes/formula_derivations.md` | 方法 exact；未发现稳定原作者代码档案 |
| Banbura et al. (2010) | 作者主页 `LargeBVARReplicationWeb.zip` 已下载 | FRED-MD system-size BVAR baseline 已运行 | `results/bgr_system_size_bvar_rmse.csv` | 数据代码已拿到；本地未用 Matlab 重跑作者全表，但 R 版已复现核心机制 |
| Giannone et al. (2015) | Harvard Dataverse `GLPreplicationWeb.zip` 已下载 | marginal likelihood tightness grid 已运行 | `results/glp_lambda_grid_small_bvar.csv` | 数据代码 exact；R 版复现了核心 lambda selection |
| Carriero et al. (2015) | JAE archive readme/data/programs 已下载 | lag/tightness/horizon specification grid 已运行 | `results/carriero_specification_grid.csv` | 数据代码 exact；原程序为 RATS/Gauss 风格，本地转为 R baseline |
| Primiceri (2005) | 作者工作稿 PDF 已下载；Corrigendum 信息已记录 | rolling-window TVP proxy 与敏感性已运行 | `results/primiceri_rolling_window_sensitivity.csv` | 公式和诊断复现完成；完整 TVP-SVAR MCMC 仍需专门模块 |
| Bernanke et al. (2005) | FEDS PDF、BBE 原始 Excel、R notebook 已下载 | BBE Table-I 风格 contribution/R2 已运行 | `results/bbe_table_i_replication.csv` | 两步法 FAVAR 核心表已复现；bootstrap IRF 可继续加深 |
| Stock and Watson (2002) | JBES PDF 已下载；NBER 页面已记录 | diffusion-index PCA 和直接预测已运行 | `results/stock_watson_diffusion_forecast_rmse.csv` | 方法 exact；原 1970-1998 real-time vintage panel 未公开完整归档，当前用 FRED-MD 替代 |

## 本轮新增运行命令

```sh
python3 paper_reproductions/selected_next_10_core_papers/code/download_sources.py
Rscript paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R
Rscript paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R
```

## 关键补强

1. **真实资料补齐**：BGR、CCM、BBE、Litterman、Primiceri 的新增数据/代码/PDF 已落地。
2. **论文级结果补齐**：新增了 BGR system-size、CCM specification grid、BBE Table-I、Stock-Watson diffusion forecast、Primiceri window sensitivity。
3. **边界透明**：把 exact replication 受限项单独写出，避免把替代性 method replication 误写成原文逐表复现。
