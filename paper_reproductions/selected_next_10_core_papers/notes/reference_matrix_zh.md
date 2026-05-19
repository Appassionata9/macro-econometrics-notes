# 10篇核心论文参考文献路线图

日期：2026-05-19

这份参考文献矩阵不是把每篇 bibliography 机械抄一遍，而是把 10 篇论文中对你当前博士 proposal 最有价值的引用关系整理出来。它可以直接转成 literature review 的骨架。

## 1. DSGE-VAR 与结构先验

| 核心文献 | 为什么重要 | 连接到哪篇 |
| --- | --- | --- |
| Del Negro and Schorfheide (2004), "Priors from General Equilibrium Models for VARs" | DSGE implied moments 转化为 VAR prior 的源头 | Paccagnini、DSGE-VAR proposal 主线 |
| DeJong, Ingram and Whiteman (2000), Bayesian approach to dynamic macroeconomics | 把校准/动态宏观模型和 Bayesian estimation 接起来 | Del Negro-Schorfheide |
| Smets and Wouters (2003/2007), estimated DSGE models | DSGE-VAR empirical prior 的大模型背景 | Del Negro-Schorfheide、Paccagnini |
| Leeper and Zha (2003), modest policy interventions | 结构 VAR 与政策情景分析 | Del Negro-Schorfheide、Sims-Zha |
| Lucas (1976), econometric policy evaluation critique | 解释为什么需要结构模型和政策不变性 | DSGE-VAR motivation |

## 2. Minnesota prior 与 BVAR 基础

| 核心文献 | 为什么重要 | 连接到哪篇 |
| --- | --- | --- |
| Litterman (1986), "Forecasting with Bayesian Vector Autoregressions" | Minnesota prior 和 BVAR forecasting 的经典起点 | Litterman、BGR、GLP、Chan |
| Doan, Litterman and Sims (1984), forecasting and conditional projection | 实用 BVAR prior 和条件预测 | Litterman、Sims-Zha |
| Sims (1980), macroeconomics and reality | VAR 作为宏观实证工具的源头 | Sims-Zha、Primiceri、BBE |
| Sims and Zha (1998), Bayesian methods for dynamic multivariate models | dummy observations、error bands、large dynamic systems | Sims-Zha、Carriero、Del Negro-Schorfheide |
| Kadiyala and Karlsson (1997), numerical methods for BVARs | 共轭/非共轭 posterior 与 Gibbs sampler | Koop-Korobilis、Chan |

## 3. Large BVAR 与 prior selection

| 核心文献 | 为什么重要 | 连接到哪篇 |
| --- | --- | --- |
| Banbura, Giannone and Reichlin (2010), "Large Bayesian VARs" | 大维 VAR 不必输给因子模型，关键是 shrinkage | BGR、Chan |
| De Mol, Giannone and Reichlin (2008), Bayesian shrinkage and many predictors | large predictors 的理论基础 | BGR |
| Giannone, Lenza and Primiceri (2015), "Prior Selection for VARs" | tightness 用 marginal likelihood/hierarchical Bayes 选择 | GLP、Carriero、Chan |
| Carriero, Clark and Marcellino (2015), specification choices | lag、tightness、forecast horizon、levels/growth 的实证设计 | CCM、proposal empirical design |
| Koop and Korobilis (2010), Bayesian multivariate time series methods | BVAR/TVP-VAR/FAVAR 方法综述与代码来源 | 全部 Bayesian block |
| Chan (2022), asymmetric conjugate priors | large BVAR 新型 asymmetric prior | 你的下一阶段方法创新入口 |

## 4. Data-rich macro: factors, FAVAR, diffusion indexes

| 核心文献 | 为什么重要 | 连接到哪篇 |
| --- | --- | --- |
| Stock and Watson (2002), "Macroeconomic Forecasting Using Diffusion Indexes" | PCA/common factors 做宏观预测 | Stock-Watson、BBE |
| Bernanke, Boivin and Eliasz (2005), FAVAR | 把大信息集因子放进 monetary policy VAR | BBE |
| Bai and Ng (2002), number of factors | 因子数选择的标准理论 | Stock-Watson、BBE |
| Forni, Hallin, Lippi and Reichlin (2000/2005), generalized dynamic factor model | dynamic factor 的欧洲传统 | Stock-Watson、BGR |
| Boivin and Ng (2005/2006), factor forecasting and large panels | 大面板中变量选择和因子估计问题 | BBE、Stock-Watson |

## 5. Time-varying macro dynamics

| 核心文献 | 为什么重要 | 连接到哪篇 |
| --- | --- | --- |
| Primiceri (2005), TVP-SVAR and monetary policy | 系数和波动率都时变的货币政策 SVAR | Primiceri、Koop-Korobilis |
| Cogley and Sargent (2001/2005), drifting coefficients and volatility | TVP 宏观模型先驱 | Primiceri |
| Kim, Shephard and Chib (1998), stochastic volatility mixture sampler | stochastic volatility block 的核心算法 | Primiceri、Del Negro-Primiceri corrigendum |
| Carter and Kohn (1994), simulation smoother | 状态空间 posterior 抽样基础 | Primiceri |
| Del Negro and Primiceri (2015), corrigendum | 修正 Primiceri MCMC 步骤顺序 | Primiceri exact replication 必读 |

## Proposal 中的优先阅读顺序

1. Litterman (1986)
2. Sims and Zha (1998)
3. Del Negro and Schorfheide (2004)
4. Banbura, Giannone and Reichlin (2010)
5. Giannone, Lenza and Primiceri (2015)
6. Carriero, Clark and Marcellino (2015)
7. Stock and Watson (2002)
8. Bernanke, Boivin and Eliasz (2005)
9. Primiceri (2005)
10. Chan (2022)

这个顺序适合写 proposal：先讲 BVAR prior 的来源，再讲大维 shrinkage 与 prior selection，最后扩展到 data-rich 和 time-varying monetary policy。
