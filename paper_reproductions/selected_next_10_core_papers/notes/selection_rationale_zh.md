# 10篇后续核心论文筛选理由

日期：2026-05-19

## 筛选标准

这 10 篇不是简单按引用次数挑出来的，而是按你当前研究阶段的实际需要筛选：

1. 能从前 3 篇已复现论文自然延伸出来；
2. 能支撑博士 proposal 的方法论主线；
3. 尽量有可复现的数据、代码或可替代的公开数据；
4. 能形成从 DSGE-VAR 到 BVAR、large BVAR、TVP-VAR、FAVAR 的递进链条；
5. 公式推导适合写入 proposal methodology。

## 推荐顺序

1. **Del Negro and Schorfheide (2004)**  
   Paccagnini (2010) 的 DSGE-VAR 框架直接来自这篇。它是解释 DSGE prior 如何进入 VAR 的必读源头。

2. **Litterman (1986)**  
   Minnesota prior 的经典来源。理解 BVAR shrinkage 必须先把这篇吃透。

3. **Kadiyala and Karlsson (1997)**  
   这篇把 BVAR 的 conjugate、independent normal-Wishart、Gibbs sampling 等数值估计方法系统化，适合连接 Koop and Korobilis (2010) 的方法综述。

4. **Sims and Zha (1998)**  
   适合补足 dummy-observation priors、large dynamic systems 和 structural VAR Bayesian inference。

5. **Banbura, Giannone and Reichlin (2010)**  
   Large BVAR 的关键论文，和 Chan (2022) 的 large BVAR asymmetric prior 直接相连。

6. **Giannone, Lenza and Primiceri (2015)**  
   把 shrinkage tightness 当作超参数用 marginal likelihood / hierarchical Bayes 选择，非常适合你的 proposal 中“prior choice should be data-informed”的论点。

7. **Carriero, Clark and Marcellino (2015)**  
   这篇偏实证设计：levels vs growth、direct vs iterated forecast、lag length、tightness、variance treatment。适合指导你之后自己的实证部分怎么设定。

8. **Primiceri (2005)**  
   TVP-SVAR 经典论文，是 Koop and Korobilis 后半部分 TVP-VAR 讨论的核心基础。

9. **Bernanke, Boivin and Eliasz (2005)**  
   FAVAR 经典论文，解决小型 VAR 信息集过窄的问题，适合和 Stock-Watson 因子模型一起构成 data-rich macro block。

10. **Stock and Watson (2002)**  
    diffusion indexes / principal components 的核心实证来源。FAVAR 和大数据宏观预测都离不开这篇。

## Proposal 中的建议结构

可以把文献综述写成四层：

```text
DSGE-VAR model validation:
  Del Negro and Schorfheide (2004) -> Paccagnini (2010)

Bayesian VAR shrinkage:
  Litterman (1986) -> Kadiyala and Karlsson (1997) -> Sims and Zha (1998)

Large BVAR prior selection:
  Banbura et al. (2010) -> Giannone et al. (2015) -> Carriero et al. (2015) -> Chan (2022)

Data-rich and time-varying macro models:
  Stock and Watson (2002) -> Bernanke et al. (2005) -> Primiceri (2005)
```

## 当前复现策略

这 10 篇的逐表完全复现工作量很大，因此当前第一轮采用两层策略：

1. 对有明确公开 archive 的论文，保存官方数据和代码来源，后续可逐表复现。
2. 对方法型论文，先用共同的 FRED-MD/FRED-QD 数据实现 core method replication，保证公式、代码和结果能支撑 proposal。
