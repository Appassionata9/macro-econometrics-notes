# 10篇核心文献公式推导讲义

日期：2026-05-19

这份笔记把本批 10 篇论文背后的共同公式从最基础的 VAR likelihood 推到 BVAR posterior、marginal likelihood、DSGE-VAR、FAVAR 和 TVP-SVAR。写 proposal 时可以直接把它拆成 methodology 小节。

## 1. 从 VAR 到矩阵似然

设

$$
y_t=c+A_1y_{t-1}+\cdots+A_py_{t-p}+\varepsilon_t,\quad
\varepsilon_t\sim N(0,\Sigma).
$$

把所有有效样本堆叠为

$$
Y=XB+E,
$$

其中 \(Y\) 是 \(T\times n\)，\(X\) 是 \(T\times k\)，\(B\) 是 \(k\times n\)。由于每期误差满足多元正态，

$$
p(Y\mid B,\Sigma)
\propto
|\Sigma|^{-T/2}
\exp\left[-\frac{1}{2}\operatorname{tr}\{\Sigma^{-1}(Y-XB)'(Y-XB)\}\right].
$$

OLS 估计量为

$$
\widehat B=(X'X)^{-1}X'Y.
$$

对残差平方项配方：

$$
(Y-XB)'(Y-XB)
=
(Y-X\widehat B)'(Y-X\widehat B)
+(B-\widehat B)'X'X(B-\widehat B).
$$

这个恒等式是共轭 BVAR、Minnesota posterior 和 marginal likelihood 的共同起点。

## 2. Minnesota prior 到单方程 posterior

Litterman prior 把每个方程写成普通回归：

$$
y_i=X\beta_i+u_i,\quad u_i\sim N(0,\sigma_i^2I_T).
$$

先验为

$$
\beta_i\sim N(b_{0i},V_{0i}).
$$

似然核为

$$
\exp\left[-\frac{1}{2\sigma_i^2}(y_i-X\beta_i)'(y_i-X\beta_i)\right].
$$

先验核为

$$
\exp\left[-\frac{1}{2}(\beta_i-b_{0i})'V_{0i}^{-1}(\beta_i-b_{0i})\right].
$$

两者相乘，把关于 \(\beta_i\) 的二次项合并：

$$
\beta_i'\left(V_{0i}^{-1}+X'X/\sigma_i^2\right)\beta_i
-2\beta_i'\left(V_{0i}^{-1}b_{0i}+X'y_i/\sigma_i^2\right).
$$

所以 posterior variance 和 mean 为

$$
V_{1i}=\left(V_{0i}^{-1}+X'X/\sigma_i^2\right)^{-1},
$$

$$
b_{1i}=V_{1i}\left(V_{0i}^{-1}b_{0i}+X'y_i/\sigma_i^2\right).
$$

Minnesota prior 的紧缩强度通过 \(V_{0i}\) 控制：

$$
\operatorname{Var}(B_{\ell,ij})=
\begin{cases}
\lambda^2/\ell^{2d}, & i=j,\\
\lambda^2\theta^2\sigma_i^2/(\ell^{2d}\sigma_j^2), & i\ne j.
\end{cases}
$$

\(\lambda\) 越小，posterior 越贴近随机游走/零系数先验；\(\lambda\) 越大，posterior 越贴近 OLS。

## 3. GLP marginal likelihood 选择 tightness

Giannone-Lenza-Primiceri 的核心思想是把 \(\lambda\) 视为超参数，用数据选择先验 tightness。

对单个方程积分掉 \(\beta_i\)：

$$
p(y_i\mid \lambda)=\int p(y_i\mid \beta_i,\sigma_i^2)p(\beta_i\mid\lambda)d\beta_i.
$$

因为 likelihood 和 prior 都是 Gaussian，这个积分仍有闭式解。由上一节 posterior 结果得到：

$$
\log p(y_i\mid\lambda)
=
-\frac{T}{2}\log(2\pi\sigma_i^2)
+\frac{1}{2}\log |V_{1i}|
-\frac{1}{2}\log |V_{0i}|
-\frac{1}{2}
\left[
\frac{y_i'y_i}{\sigma_i^2}
+b_{0i}'V_{0i}^{-1}b_{0i}
-b_{1i}'V_{1i}^{-1}b_{1i}
\right].
$$

跨方程求和：

$$
\log p(Y\mid\lambda)=\sum_{i=1}^n \log p(y_i\mid\lambda).
$$

本地复现用 grid search：

$$
\widehat\lambda=\arg\max_{\lambda\in\{0.05,\ldots,1.00\}}\log p(Y\mid\lambda).
$$

本次 FRED-MD 小型 VAR baseline 得到 \(\widehat\lambda=0.30\)。

## 4. Sims-Zha dummy observations

Sims-Zha prior 可以写成人工观测：

$$
Y_*=X_*B+E_*.
$$

把真实样本和 dummy 样本合并：

$$
\widetilde X=
\begin{bmatrix}
X\\X_*
\end{bmatrix},
\quad
\widetilde Y=
\begin{bmatrix}
Y\\Y_*
\end{bmatrix}.
$$

于是 OLS/Bayesian posterior 的 sufficient statistics 变成

$$
X'X\to X'X+X_*'X_*,
$$

$$
X'Y\to X'Y+X_*'Y_*.
$$

这个写法的优点是直观：所有 prior information 都被转化成“像数据一样进入估计”的对象。Del Negro-Schorfheide 的 DSGE-VAR 也可以从这个角度理解。

## 5. Del Negro-Schorfheide DSGE-VAR

DSGE 模型在参数 \(\theta\) 下给出 VAR 所需的理论矩：

$$
\Gamma_{XX}(\theta),\quad \Gamma_{XY}(\theta),\quad \Gamma_{YY}(\theta).
$$

用 \(\lambda T\) 表示 DSGE artificial sample size：

$$
X_*'X_*=\lambda T\Gamma_{XX}(\theta),
$$

$$
X_*'Y_*=\lambda T\Gamma_{XY}(\theta).
$$

代入 dummy-observation posterior mean：

$$
\widehat B_\lambda
=
\left(X'X+\lambda T\Gamma_{XX}\right)^{-1}
\left(X'Y+\lambda T\Gamma_{XY}\right).
$$

当 \(\lambda\to 0\)，模型接近 unrestricted VAR；当 \(\lambda\to\infty\)，模型越来越服从 DSGE implied restrictions。这正是 Paccagnini DSGE-VAR validation 的理论根。

## 6. Kadiyala-Karlsson independent Normal-Wishart Gibbs

自然共轭 prior 会把 \(B\) 和 \(\Sigma\) 绑在一起，计算方便但限制强。Kadiyala-Karlsson 讨论更一般的 independent Normal-Wishart：

$$
\beta=\operatorname{vec}(B)\sim N(\beta_0,V_\beta),
$$

$$
\Sigma^{-1}\sim W(S_0^{-1},\nu_0).
$$

联合 posterior 没有简单闭式形式，但两个条件分布可以写出：

$$
\beta\mid \Sigma,Y\sim N(\beta_1,V_1),
$$

其中

$$
V_1=\left[V_\beta^{-1}+(\Sigma^{-1}\otimes X'X)\right]^{-1},
$$

$$
\beta_1=V_1\left[V_\beta^{-1}\beta_0+(\Sigma^{-1}\otimes X')\operatorname{vec}(Y)\right].
$$

给定 \(\beta\)，残差 \(E=Y-XB\)，则

$$
\Sigma^{-1}\mid \beta,Y
\sim
W\left((S_0+E'E)^{-1},\nu_0+T\right).
$$

交替抽样 \(\beta\) 和 \(\Sigma^{-1}\) 就得到 Gibbs sampler。

## 7. Large BVAR shrinkage

Banbura-Giannone-Reichlin 的关键经验是：变量数 \(n\) 越大，VAR 参数数量增长越快，需要更强 shrinkage。直觉上：

$$
k=1+np,\quad \text{parameters}=kn,
$$

因此 \(n\) 增大时，OLS 方差急速上升。Minnesota prior 通过降低 \(\lambda\) 把大系统向简单随机游走或 AR benchmark 收缩：

$$
\lambda_{large}<\lambda_{small}.
$$

本地脚本复现的是这一思想的基础版本：在 FRED-MD 构造的宏观 VAR 上用 marginal likelihood grid 选择 \(\lambda\)，并把选出的 tightness 用于预测比较。

## 8. Stock-Watson diffusion indexes

对 large macro panel \(X\) 做标准化，设因子模型：

$$
X_t=\Lambda F_t+e_t.
$$

主成分估计可以写成最小化：

$$
\min_{F,\Lambda}\sum_{t=1}^T\|X_t-\Lambda F_t\|^2
\quad
\text{s.t. } F'F/T=I_r.
$$

给定 \(F\)，最优 loading 是

$$
\widehat\Lambda=X'F/T.
$$

代回目标函数后，问题等价于选择 \(XX'\) 最大的 \(r\) 个特征向量。因此

$$
\widehat F=\sqrt{T}\times \text{eigenvectors of }XX'.
$$

预测方程为

$$
y_{t+h}=\alpha+\rho(L)y_t+\gamma'\widehat F_t+\eta_{t+h}.
$$

本地复现提取了 FRED-MD 的 PCA 因子，并输出前 20 个因子的累计解释方差。

## 9. Bernanke-Boivin-Eliasz FAVAR

FAVAR 把少数可观测政策变量 \(R_t\) 和潜在因子 \(F_t\) 放进 VAR：

$$
\begin{bmatrix}
F_t\\R_t
\end{bmatrix}
=
\Phi(L)
\begin{bmatrix}
F_{t-1}\\R_{t-1}
\end{bmatrix}
+v_t.
$$

大面板观测方程为

$$
X_t=\Lambda^f F_t+\Lambda^r R_t+e_t.
$$

两步法：

1. 对标准化后的 \(X_t\) 做 PCA，得到 \(\widehat F_t\)；
2. 用 \((\widehat F_t,R_t)\) 估计 VAR；
3. 对 \(R_t\) 的结构冲击计算 impulse response。

本地复现用 FRED-MD 提取 3 个因子，并把 FEDFUNDS 作为可观测政策因子。

## 10. Primiceri TVP-SVAR

Primiceri 的模型让系数和波动率随时间变化：

$$
y_t=B_t x_t+A_t^{-1}\Sigma_t\varepsilon_t.
$$

状态方程：

$$
B_t=B_{t-1}+u_t,
$$

$$
\alpha_t=\alpha_{t-1}+\zeta_t,
$$

$$
\log\sigma_t=\log\sigma_{t-1}+\eta_t.
$$

完整复现需要 MCMC、simulation smoother 和 stochastic volatility block。本批先做 proposal 阶段的透明版本：用 rolling VAR 估计政策方程系数，观察利率对 inflation/unemployment 滞后项的反应是否随时间变化。这个结果不能替代完整 TVP-SVAR posterior，但适合作为后续 exact replication 的 diagnostic baseline。
