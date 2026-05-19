# Stock and Watson (2002) Replication Note

## 为什么选这篇

Stock-Watson diffusion index 是大维宏观面板因子提取和 forecasting 的基础，直接支撑 FAVAR 和 large-data macro forecasting。

## 本轮复现内容

- 下载 JBES 论文 PDF；
- 使用 FRED-MD 真实大面板；
- 对 transformed panel 做 PCA；
- 输出前 20 个 principal components 的解释方差。

## 数据与代码

- 数据：`../data/raw/fred_md/2026-04-md.csv`
- 论文：`paper/stock_watson_2002_diffusion_indexes.pdf`
- 代码：`../code/run_baseline_replications.R`
- 输出：`../results/diffusion_factor_variance.csv`
- 图像：`../figures/diffusion_factor_variance.png`

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
X_t=\Lambda F_t+e_t,\quad
\widehat F=\sqrt{T}\times \text{eigenvectors of }XX'.
$$

## 当前结果

本地 FRED-MD 样本中，前三个因子累计解释约 36.9% 的 transformed panel variation，前二十个因子累计解释约 75.0%。
