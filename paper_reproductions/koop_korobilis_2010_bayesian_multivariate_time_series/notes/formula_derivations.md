# Koop and Korobilis (2010) Formula Derivations

## 1. VAR Regression Form

The baseline VAR(p) is:

$$
y_t = a_0 + A_1y_{t-1}+\cdots + A_py_{t-p}+\varepsilon_t,
\qquad
\varepsilon_t\sim N(0,\Sigma).
$$

Let $M$ be the number of variables and $K=1+Mp$ be the number of regressors per
equation. Define:

$$
x_t=(1,y_{t-1}',\ldots,y_{t-p}')',
\qquad
A=(a_0,A_1,\ldots,A_p)'.
$$

Stacking $T$ observations gives:

$$
Y=XA+E,
\qquad
E\sim MN(0,I_T,\Sigma).
$$

Vectorizing:

$$
y=\operatorname{vec}(Y),
\qquad
\alpha=\operatorname{vec}(A),
$$

$$
y=(I_M\otimes X)\alpha+\varepsilon,
\qquad
\varepsilon\sim N(0,\Sigma\otimes I_T).
$$

The OLS estimator is:

$$
\widehat A=(X'X)^{-1}X'Y,
\qquad
\widehat\alpha=\operatorname{vec}(\widehat A).
$$

The residual sum of squares is:

$$
SSE=(Y-X\widehat A)'(Y-X\widehat A).
$$

## 2. Likelihood Kernel

The matrix-normal likelihood is:

$$
p(Y\mid A,\Sigma)
\propto
|\Sigma|^{-T/2}
\exp\left[
-\frac{1}{2}
\operatorname{tr}\{
\Sigma^{-1}(Y-XA)'(Y-XA)
\}
\right].
$$

Complete the square around $\widehat A$:

$$
(Y-XA)'(Y-XA)
=
SSE+(A-\widehat A)'X'X(A-\widehat A).
$$

Thus:

$$
A\mid\Sigma,Y
\sim
MN\left(\widehat A,(X'X)^{-1},\Sigma\right)
$$

under a diffuse prior, and all conjugate posterior formulas can be read as
weighted versions of this square-completion result.

## 3. Noninformative Prior

The noninformative prior is the limiting case:

$$
p(A,\Sigma)\propto |\Sigma|^{-(M+1)/2}.
$$

The posterior is:

$$
A\mid\Sigma,Y
\sim
MN\left(\widehat A,(X'X)^{-1},\Sigma\right),
$$

$$
\Sigma\mid Y
\sim
IW(SSE,T-K).
$$

After integrating out $\Sigma$, $\alpha=\operatorname{vec}(A)$ follows a
multivariate Student-t distribution with:

$$
E(\alpha\mid Y)=\widehat\alpha,
$$

and covariance proportional to:

$$
SSE\otimes (X'X)^{-1}.
$$

This is the analytical posterior used for the local reproduction of Table 1.

## 4. Minnesota Prior

The Minnesota prior shrinks the VAR toward random-walk or white-noise
benchmarks. For coefficient $A_{\ell,ij}$ on lag $\ell$ of variable $j$ in
equation $i$:

$$
E(A_{\ell,ij})=
\begin{cases}
\rho_i, & i=j,\ell=1,\\
0, & \text{otherwise},
\end{cases}
$$

where $\rho_i$ is often set near one for persistent level variables and zero for
stationary growth/rate variables.

A common variance structure is:

$$
\operatorname{Var}(A_{\ell,ij})
=
\begin{cases}
\lambda_1^2/\ell^{2\lambda_3}, & i=j,\\
\lambda_1^2\lambda_2^2 s_i^2/(\ell^{2\lambda_3}s_j^2), & i\neq j,
\end{cases}
$$

where:

- $\lambda_1$ controls overall shrinkage;
- $\lambda_2$ controls cross-variable shrinkage;
- $\lambda_3$ controls lag decay;
- $s_i^2$ is usually estimated from a univariate autoregression for variable
  $i$.

In the simplest analytical implementation, $\Sigma$ is treated as known or
diagonal. Let:

$$
\alpha\sim N(\alpha_0,V_0),
\qquad
y\mid\alpha\sim N(Z\alpha,\Omega),
$$

where $Z=I_M\otimes X$ and $\Omega=\Sigma\otimes I_T$. Then:

$$
V_1=(V_0^{-1}+Z'\Omega^{-1}Z)^{-1},
$$

$$
\alpha_1=V_1(V_0^{-1}\alpha_0+Z'\Omega^{-1}y).
$$

Hence:

$$
\alpha\mid Y\sim N(\alpha_1,V_1).
$$

The Minnesota prior is useful because it gives direct coefficient-level
shrinkage, but it is less analytically convenient than the natural conjugate
prior when $\Sigma$ is unknown.

## 5. Natural Conjugate Prior

The natural conjugate prior is:

$$
A\mid\Sigma\sim MN(A_0,V_0,\Sigma),
$$

$$
\Sigma\sim IW(S_0,\nu_0).
$$

Equivalently:

$$
\operatorname{vec}(A)\mid\Sigma
\sim
N(\operatorname{vec}(A_0),\Sigma\otimes V_0).
$$

The prior and likelihood have the same matrix-normal kernel. Combine their
quadratic forms:

$$
(Y-XA)'(Y-XA)+(A-A_0)'V_0^{-1}(A-A_0).
$$

Complete the square:

$$
V_1=(V_0^{-1}+X'X)^{-1},
$$

$$
A_1=V_1(V_0^{-1}A_0+X'X\widehat A).
$$

The posterior scale matrix is:

$$
S_1
=
S_0+SSE+\widehat A'X'X\widehat A
+A_0'V_0^{-1}A_0
-A_1'(V_0^{-1}+X'X)A_1.
$$

The posterior degrees of freedom are:

$$
\nu_1=\nu_0+T.
$$

Therefore:

$$
A\mid\Sigma,Y\sim MN(A_1,V_1,\Sigma),
$$

$$
\Sigma\mid Y\sim IW(S_1,\nu_1).
$$

After integrating out $\Sigma$:

$$
\operatorname{vec}(A)\mid Y
\sim
t_{\nu_1-M+1}
\left(
\operatorname{vec}(A_1),
\frac{S_1\otimes V_1}{\nu_1-M+1}
\right),
$$

up to the exact Student-t parameterization used by the software. This
integrated form is why posterior means and one-step predictive densities can be
computed analytically.

## 6. Predictive Distribution

For a one-step forecast with regressor row $x_{T+1}$:

$$
y_{T+1}=A'x_{T+1}+\varepsilon_{T+1}.
$$

Conditional on $(A,\Sigma)$:

$$
y_{T+1}\mid A,\Sigma,Y
\sim
N(A'x_{T+1},\Sigma).
$$

Under the natural conjugate posterior, integrating out $(A,\Sigma)$ gives a
multivariate Student-t predictive density with mean:

$$
E(y_{T+1}\mid Y)=A_1'x_{T+1}.
$$

The covariance is proportional to:

$$
\left(1+x_{T+1}'V_1x_{T+1}\right)S_1.
$$

For horizons greater than one, the paper notes that one can use direct
forecasting or posterior predictive simulation, because a simple closed form is
not generally available.

## 7. Independent Normal-Wishart Prior

The independent Normal-Wishart prior separates coefficients and covariance:

$$
\beta\sim N(\beta_0,V_\beta),
$$

$$
\Sigma^{-1}\sim W(S_0^{-1},\nu_0).
$$

For a possibly restricted VAR written as:

$$
y_t=Z_t\beta+\varepsilon_t,
\qquad
\varepsilon_t\sim N(0,\Sigma),
$$

the joint posterior is not natural conjugate, but the conditional posteriors are
standard:

$$
V_{\beta,1}
=
\left(
V_\beta^{-1}
+\sum_{t=1}^T Z_t'\Sigma^{-1}Z_t
\right)^{-1},
$$

$$
\beta_1
=
V_{\beta,1}
\left(
V_\beta^{-1}\beta_0
+\sum_{t=1}^T Z_t'\Sigma^{-1}y_t
\right).
$$

Thus:

$$
\beta\mid\Sigma,Y
\sim N(\beta_1,V_{\beta,1}).
$$

And:

$$
\Sigma^{-1}\mid\beta,Y
\sim
W(S_1^{-1},\nu_1),
$$

where:

$$
S_1=S_0+\sum_{t=1}^T(y_t-Z_t\beta)(y_t-Z_t\beta)' ,
\qquad
\nu_1=\nu_0+T.
$$

This yields a Gibbs sampler alternating between $\beta$ and $\Sigma^{-1}$.

## 8. SSVS Prior

Stochastic search variable selection places a mixture prior on each coefficient
$\alpha_j$:

$$
\alpha_j\mid\gamma_j
\sim
(1-\gamma_j)N(0,\kappa_{0j}^2)
+\gamma_jN(0,\kappa_{1j}^2),
$$

where:

- $\gamma_j=0$ selects the tight near-zero component;
- $\gamma_j=1$ selects the diffuse component;
- $\kappa_{0j}^2\ll \kappa_{1j}^2$.

The inclusion indicator has:

$$
P(\gamma_j=1)=q_j,
\qquad
P(\gamma_j=0)=1-q_j.
$$

Let $D$ be diagonal with:

$$
d_j=
\begin{cases}
\kappa_{0j}, & \gamma_j=0,\\
\kappa_{1j}, & \gamma_j=1.
\end{cases}
$$

Then:

$$
\alpha\mid\gamma\sim N(0,DD).
$$

Conditional on $\gamma$ and $\Sigma$, the coefficient posterior is:

$$
V_\alpha
=
\left[
\Sigma^{-1}\otimes X'X+(DD)^{-1}
\right]^{-1},
$$

$$
\alpha_1
=
V_\alpha
\left[
(\Sigma^{-1}\otimes X'X)\widehat\alpha
\right].
$$

The posterior inclusion probability is:

$$
P(\gamma_j=1\mid \alpha_j)
=
\frac{
q_j\kappa_{1j}^{-1}\exp[-\alpha_j^2/(2\kappa_{1j}^2)]
}{
q_j\kappa_{1j}^{-1}\exp[-\alpha_j^2/(2\kappa_{1j}^2)]
+(1-q_j)\kappa_{0j}^{-1}\exp[-\alpha_j^2/(2\kappa_{0j}^2)]
}.
$$

This gives a Gibbs sampler over $\alpha$, $\gamma$, and possibly $\Sigma^{-1}$.

## 9. Impulse Response Simulation

Impulse responses are nonlinear functions of $(A,\Sigma)$, so even when
analytical posterior moments exist for coefficients, impulse responses are
usually computed by Monte Carlo:

1. Draw $\Sigma^{(r)}$ from its posterior.
2. Draw $A^{(r)}$ conditional on $\Sigma^{(r)}$.
3. Identify structural shocks, often using a Cholesky/lower-triangular
   restriction.
4. Convert $A^{(r)}$ into companion form and compute dynamic responses.
5. Summarize posterior means and credible bands across draws.

In the paper's empirical illustration, variables are ordered as inflation,
unemployment, and the interest rate. Under the lower-triangular identification,
the interest-rate innovation can be interpreted as a monetary policy shock.
