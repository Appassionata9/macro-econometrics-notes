# Kadiyala and Karlsson (1997) Replication Note

## 为什么选这篇

这篇系统比较了 Bayesian VAR 的数值估计方法，特别适合作为 Koop-Korobilis 方法综述和后续 large BVAR / non-conjugate prior 的桥梁。

## 本轮复现内容

- 下载 JAE 官方 archive；
- 保存原作者数据、命令文件、Fortran 代码和输出；
- 整理 independent Normal-Wishart prior 下 Gibbs sampler 的条件 posterior 推导。

## 数据与代码

- `data/raw/data.zip`：原作者数据、命令文件和输出；
- `data/raw/var.zip`：Fortran 程序；
- `data/raw/readme.kk.txt`：JAE archive 说明。

这些文件来自 JAE Data Archive，适合后续做 exact table replication。

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
\beta\mid\Sigma,Y\sim N(\beta_1,V_1),\quad
\Sigma^{-1}\mid\beta,Y\sim W((S_0+E'E)^{-1},\nu_0+T).
$$

## 当前状态

官方数据和代码已收集完成；本轮完成公式和复现入口，下一轮可针对 archive 中的 `.OUT` 文件逐项对照。
