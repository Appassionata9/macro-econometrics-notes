# Formula Derivations for the Selected 10 Papers

This note collects the core formulas needed for the first-pass replication of
the 10 selected papers. The goal is proposal readiness: each derivation explains
the method that will later be expanded in the paper-specific folders.

## 1. VAR Likelihood

For all BVAR, large BVAR, TVP-VAR and FAVAR baselines, start from:

$$
y_t = c + A_1y_{t-1}+\cdots+A_py_{t-p}+\varepsilon_t,
\qquad
\varepsilon_t\sim N(0,\Sigma).
$$

Stacking observations:

$$
Y=XB+E,
\qquad
E\sim MN(0,I_T,\Sigma).
$$

The likelihood is:

$$
p(Y\mid B,\Sigma)
\propto
|\Sigma|^{-T/2}
\exp\left[
-\frac{1}{2}\operatorname{tr}
\{\Sigma^{-1}(Y-XB)'(Y-XB)\}
\right].
$$

Completing the square around

$$
\widehat B=(X'X)^{-1}X'Y
$$

gives:

$$
(Y-XB)'(Y-XB)
=
SSE+(B-\widehat B)'X'X(B-\widehat B).
$$

This square-completion identity drives the conjugate and Minnesota-prior
posterior formulas.

## 2. Litterman Minnesota Prior

For coefficient on lag $\ell$ of variable $j$ in equation $i$:

$$
E(B_{\ell,ij})=
\begin{cases}
1, & i=j,\ell=1 \text{ for random-walk variables},\\
0, & \text{otherwise}.
\end{cases}
$$

Prior variances take the form:

$$
\operatorname{Var}(B_{\ell,ij})
=
\begin{cases}
\lambda^2/\ell^{2d}, & i=j,\\
\lambda^2\theta^2\sigma_i^2/(\ell^{2d}\sigma_j^2), & i\neq j,
\end{cases}
$$

where $\lambda$ is overall tightness, $\theta$ controls cross-variable shrinkage,
and $d$ controls lag decay.

## 3. Fixed-Sigma Normal Posterior

For one equation:

$$
y_i=X\beta_i+u_i,
\qquad
u_i\sim N(0,\sigma_i^2I).
$$

Prior:

$$
\beta_i\sim N(b_{0i},V_{0i}).
$$

Posterior:

$$
V_{1i}
=
\left(V_{0i}^{-1}+X'X/\sigma_i^2\right)^{-1},
$$

$$
b_{1i}
=
V_{1i}\left(V_{0i}^{-1}b_{0i}+X'y_i/\sigma_i^2\right).
$$

This is the baseline used here for Litterman (1986), Banbura et al. (2010),
Carriero et al. (2015), and the GLP shrinkage grid.

## 4. Marginal Likelihood for Prior Tightness

For a fixed $\sigma_i^2$, integrate $\beta_i$ out:

$$
p(y_i\mid\lambda)
=
\int
p(y_i\mid\beta_i,\sigma_i^2)p(\beta_i\mid\lambda)d\beta_i.
$$

Using Gaussian integration:

$$
\log p(y_i\mid\lambda)
=
-\frac{T}{2}\log(2\pi\sigma_i^2)
+\frac{1}{2}\log|V_{1i}|
-\frac{1}{2}\log|V_{0i}|
-\frac{1}{2}
\left[
\frac{y_i'y_i}{\sigma_i^2}
+b_{0i}'V_{0i}^{-1}b_{0i}
-b_{1i}'V_{1i}^{-1}b_{1i}
\right].
$$

Summing across equations gives:

$$
\log p(Y\mid\lambda)=\sum_{i=1}^n \log p(y_i\mid\lambda).
$$

The GLP-style tightness selection chooses:

$$
\widehat\lambda
=
\arg\max_\lambda \log p(Y\mid\lambda).
$$

## 5. Large BVAR Shrinkage

Banbura, Giannone and Reichlin (2010) argue that as the number of variables
increases, shrinkage must become tighter. In practice:

$$
\lambda_N < \lambda_{small}
$$

for a large system. The local baseline compares medium-system BVAR forecast
performance over a grid of $\lambda$ values and records the selected tightness.

## 6. Sims-Zha Dummy-Observation Priors

Sims-Zha priors can be represented as artificial observations:

$$
Y_* = X_*B + E_*.
$$

Adding dummy observations changes the sufficient statistics:

$$
X'X \rightarrow X'X+X_*'X_*,
$$

$$
X'Y \rightarrow X'Y+X_*'Y_*.
$$

This connects Sims-Zha, Minnesota priors, DSGE-VAR priors and the
dummy-observation interpretation in Del Negro and Schorfheide.

## 7. Del Negro-Schorfheide DSGE-VAR

Let DSGE-implied moments be:

$$
\Gamma_{XX}(\theta),\quad
\Gamma_{XY}(\theta),\quad
\Gamma_{YY}(\theta).
$$

The DSGE artificial sample has:

$$
X_*'X_*=\lambda T\Gamma_{XX}(\theta),
\qquad
X_*'Y_*=\lambda T\Gamma_{XY}(\theta).
$$

The DSGE-VAR posterior mean is:

$$
\widehat B_\lambda
=
\left(X'X+\lambda T\Gamma_{XX}\right)^{-1}
\left(X'Y+\lambda T\Gamma_{XY}\right).
$$

This formula is the conceptual ancestor of Paccagnini's replication.

## 8. Kadiyala-Karlsson Gibbs Sampler

For the independent Normal-Wishart prior:

$$
\beta\sim N(\beta_0,V_\beta),
\qquad
\Sigma^{-1}\sim W(S_0^{-1},\nu_0),
$$

the joint posterior is not natural conjugate, but the conditional posteriors are:

$$
\beta\mid\Sigma,Y
\sim
N(\beta_1,V_1),
$$

$$
\Sigma^{-1}\mid\beta,Y
\sim
W(S_1^{-1},\nu_1).
$$

Alternating these two draws gives the Gibbs sampler.

## 9. Stock-Watson Diffusion Indexes

For a large transformed macro panel $X_t$:

$$
X_t=\Lambda F_t+e_t.
$$

Principal components estimate the common factors:

$$
\widehat F
=
\sqrt{T}\,\text{eigenvectors of } XX'/N.
$$

Forecasting uses:

$$
y_{t+h}=\alpha+\rho(L)y_t+\gamma'\widehat F_t+\eta_{t+h}.
$$

The local baseline extracts principal components from FRED-MD and reports
variance explained by the first factors.

## 10. Bernanke-Boivin-Eliasz FAVAR

FAVAR augments a policy VAR with latent factors:

$$
\begin{bmatrix}
F_t\\
R_t
\end{bmatrix}
=
\Phi(L)
\begin{bmatrix}
F_{t-1}\\
R_{t-1}
\end{bmatrix}
+v_t.
$$

The observation equation is:

$$
X_t=\Lambda^fF_t+\Lambda^rR_t+e_t.
$$

In the two-step version, $F_t$ is estimated by principal components and then
included with the policy instrument $R_t$ in a VAR.

## 11. Primiceri TVP-SVAR

The TVP-VAR is:

$$
y_t=B_t x_t+A_t^{-1}\Sigma_t\varepsilon_t.
$$

Time variation is modeled as random walks:

$$
B_t=B_{t-1}+u_t,
\qquad
\alpha_t=\alpha_{t-1}+\zeta_t,
\qquad
\log\sigma_t=\log\sigma_{t-1}+\eta_t.
$$

The exact paper uses MCMC with state-space simulation smoothers. The local
first-pass baseline uses rolling VAR estimates as a transparent approximation to
visualize time variation in policy reaction coefficients.
