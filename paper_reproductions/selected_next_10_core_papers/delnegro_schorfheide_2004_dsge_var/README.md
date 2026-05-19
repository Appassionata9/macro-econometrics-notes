# Del Negro and Schorfheide (2004) Replication Note

## 为什么选这篇

这篇是 DSGE-VAR prior construction 的源头论文，也是前面 Paccagnini (2010) 复现工作的理论底座。它回答的问题是：如何把 DSGE 模型隐含的动态矩条件转化为 VAR 的 Bayesian prior。

## 本轮复现内容

- 整理 DSGE-VAR 的 dummy-observation / artificial-sample 推导；
- 将公式和前面 Paccagnini 的 DSGE-VAR 复现逻辑连接起来；
- 在 10 篇总复现脚本中保留 method mapping，方便后续写 proposal 时引用。

## 数据与代码

本篇当前采用 method-level replication。核心数据复现依赖前面 Paccagnini 文件夹中的 DSGE-VAR 实现，以及本批 FRED-MD/FRED-QD 公共数据 baseline。

## 公式入口

- `../notes/formula_derivations.md`
- `../notes/formula_derivation_walkthrough_zh.md`

关键式：

$$
\widehat B_\lambda=
(X'X+\lambda T\Gamma_{XX})^{-1}
(X'Y+\lambda T\Gamma_{XY}).
$$

## 当前状态

已完成 proposal 阶段的理论复现。下一步如果要 exact replication，需要进一步重建原文 New Keynesian DSGE 模型的参数化和原样本。
