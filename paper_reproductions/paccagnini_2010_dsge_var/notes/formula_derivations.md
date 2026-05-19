# Paccagnini (2010) Formula Derivations

## 1. Benchmark VAR Likelihood

The statistical benchmark is an unrestricted VAR(p):

$$
Y_t = \Phi_0 + \Phi_1 Y_{t-1} + \cdots + \Phi_p Y_{t-p} + u_t,
\qquad u_t \sim N(0,\Sigma_u).
$$

Stack observations into

$$
Y = X\Phi + U,
$$

where:

- $Y$ is $T \times n$;
- $X$ is $T \times k$ with $k = 1 + pn$;
- each row of $X$ is $X_t' = (1, Y_{t-1}', \ldots, Y_{t-p}')$;
- $\Phi$ is $k \times n$.

The matrix-normal likelihood is

$$
p(Y \mid \Phi,\Sigma_u)
\propto
|\Sigma_u|^{-T/2}
\exp\left[
-\frac{1}{2}
\operatorname{tr}
\left\{
\Sigma_u^{-1}(Y-X\Phi)'(Y-X\Phi)
\right\}
\right].
$$

Expanding the quadratic term:

$$
(Y-X\Phi)'(Y-X\Phi)
=Y'Y-\Phi'X'Y-Y'X\Phi+\Phi'X'X\Phi.
$$

Since the middle two terms are transposes with the same scalar trace, the
likelihood can be written in terms of $X'X$, $X'Y$, and $Y'Y$ only. This is what
makes dummy-observation priors convenient.

## 2. DSGE-Implied VAR Moments

The solved DSGE model has a state-space representation:

$$
x_{t+1}=A(\theta)x_t+B(\theta)\varepsilon_{t+1},
$$

$$
y_{t+1}=C(\theta)x_t+D(\theta)\varepsilon_{t+1}.
$$

Under stability conditions, the observed variables have an infinite-order VAR
representation. A finite VAR(p) approximation is:

$$
Y_t = \Phi_0^*(\theta)+\Phi_1^*(\theta)Y_{t-1}
+ \cdots + \Phi_p^*(\theta)Y_{t-p}+u_t^*,
\qquad u_t^* \sim N(0,\Sigma_u^*(\theta)).
$$

Define DSGE-implied population second moments:

$$
\Gamma_{XX}(\theta)=E_\theta^D[X_tX_t'],
\qquad
\Gamma_{XY}(\theta)=E_\theta^D[X_tY_t'],
\qquad
\Gamma_{YY}(\theta)=E_\theta^D[Y_tY_t'].
$$

The probability-limit VAR coefficients implied by the DSGE model are:

$$
\Phi^*(\theta)
=
\Gamma_{XX}(\theta)^{-1}\Gamma_{XY}(\theta).
$$

The DSGE-implied VAR residual covariance is:

$$
\Sigma_u^*(\theta)
=
\Gamma_{YY}(\theta)
-\Gamma_{YX}(\theta)\Gamma_{XX}(\theta)^{-1}\Gamma_{XY}(\theta).
$$

## 3. Dummy-Observation Prior

The DSGE model is introduced as an artificial sample of length $\lambda T$.
The dummy-observation sufficient statistics are:

$$
X_*'X_*=\lambda T\Gamma_{XX}(\theta),
$$

$$
X_*'Y_*=\lambda T\Gamma_{XY}(\theta),
$$

$$
Y_*'Y_*=\lambda T\Gamma_{YY}(\theta).
$$

The hyperparameter $\lambda$ is the weight of DSGE restrictions:

- small $\lambda$: the unrestricted VAR dominates;
- large $\lambda$: the DSGE-implied restrictions dominate.

Conditional on $\theta$, the prior is normal-inverse-Wishart:

$$
\Sigma_u \mid \theta
\sim IW\left(\lambda T\Sigma_u^*(\theta),\lambda T-k,n\right),
$$

$$
\Phi \mid \Sigma_u,\theta
\sim
MN\left(
\Phi^*(\theta),
\left[\lambda T\Gamma_{XX}(\theta)\right]^{-1},
\Sigma_u
\right).
$$

The matrix-normal form above is equivalent to

$$
\operatorname{vec}(\Phi)\mid \Sigma_u,\theta
\sim
N\left(
\operatorname{vec}\Phi^*(\theta),
\Sigma_u \otimes [\lambda T\Gamma_{XX}(\theta)]^{-1}
\right).
$$

## 4. Posterior From Combining Real and Dummy Samples

Because both the real data and dummy data enter through the same sufficient
statistics, the posterior estimator is the OLS estimator on the augmented sample.

Let:

$$
Q_{XX}(\lambda,\theta)=X'X+\lambda T\Gamma_{XX}(\theta),
$$

$$
Q_{XY}(\lambda,\theta)=X'Y+\lambda T\Gamma_{XY}(\theta),
$$

$$
Q_{YY}(\lambda,\theta)=Y'Y+\lambda T\Gamma_{YY}(\theta).
$$

Complete the square in the likelihood and prior:

$$
Q_{YY}-\Phi'Q_{XY}-Q_{YX}\Phi+\Phi'Q_{XX}\Phi
=
Q_{YY}-\widehat{\Phi}_b'Q_{XX}\widehat{\Phi}_b
+(\Phi-\widehat{\Phi}_b)'Q_{XX}(\Phi-\widehat{\Phi}_b).
$$

The augmented-sample posterior mean is therefore:

$$
\widehat{\Phi}_b(\lambda,\theta)
=
Q_{XX}(\lambda,\theta)^{-1}Q_{XY}(\lambda,\theta).
$$

The augmented residual covariance estimator is:

$$
\widehat{\Sigma}_{u,b}(\lambda,\theta)
=
\frac{
Q_{YY}(\lambda,\theta)
-Q_{YX}(\lambda,\theta)
Q_{XX}(\lambda,\theta)^{-1}
Q_{XY}(\lambda,\theta)
}{(1+\lambda)T}.
$$

Hence:

$$
\Sigma_u\mid Y,\theta
\sim
IW\left((1+\lambda)T\widehat{\Sigma}_{u,b},(1+\lambda)T-k,n\right),
$$

$$
\Phi\mid\Sigma_u,Y,\theta
\sim
MN\left(\widehat{\Phi}_b,Q_{XX}^{-1},\Sigma_u\right).
$$

## 5. Minimum Lambda

The prior must be proper before the marginal likelihood is meaningful. In this
paper the lower bound is:

$$
\lambda_{\min}\geq \frac{n+k}{T},
\qquad k=1+pn.
$$

For the Monte Carlo setting with $n=3$ and $T=80$:

$$
\lambda_{\min}(p)=\frac{3+(1+3p)}{80}
=\frac{4+3p}{80}.
$$

This gives the paper's rounded values:

| VAR lag | $\lambda_{\min}$ |
| ---: | ---: |
| 1 | 0.09 |
| 2 | 0.13 |
| 3 | 0.17 |
| 4 | 0.20 |
| 5 | 0.24 |
| 6 | 0.28 |
| 7 | 0.31 |
| 8 | 0.35 |

## 6. Marginal Data Density

For a fixed $\theta$ and $\lambda$, integrate out $\Phi$ and $\Sigma_u$ from the
normal-inverse-Wishart posterior.

Start from:

$$
p(Y\mid\lambda,\theta)
=
\int\int
p(Y\mid\Phi,\Sigma_u)
p(\Phi,\Sigma_u\mid\lambda,\theta)
d\Phi\,d\Sigma_u.
$$

After completing the square in $\Phi$, the Gaussian integral contributes:

$$
\frac{|Q_{XX}|^{-n/2}}{|\lambda T\Gamma_{XX}|^{-n/2}}
$$

up to constants that cancel when comparing $\lambda$ on the same data. The
remaining inverse-Wishart integral contributes determinant and multivariate
gamma terms involving the prior and posterior scale matrices.

A convenient log version used in the local implementation has the structure:

$$
\log p(Y\mid\lambda,\theta)
=
-\frac{nT}{2}\log\pi
+\frac{n}{2}\log|Q_{0,XX}|
-\frac{n}{2}\log|Q_{1,XX}|
+\log\Gamma_n\left(\frac{\nu_1}{2}\right)
-\log\Gamma_n\left(\frac{\nu_0}{2}\right)
+\frac{\nu_0}{2}\log|S_0|
-\frac{\nu_1}{2}\log|S_1|,
$$

where:

- $Q_{0,XX}=\lambda T\Gamma_{XX}$ is the prior precision statistic;
- $Q_{1,XX}=X'X+\lambda T\Gamma_{XX}$ is the posterior statistic;
- $S_0=\lambda T\Sigma_u^*(\theta)$ is the prior scale;
- $S_1=(1+\lambda)T\widehat{\Sigma}_{u,b}$ is the posterior scale;
- $\nu_0=\lambda T-k$ and $\nu_1=(1+\lambda)T-k$.

The optimal DSGE-VAR weight is:

$$
\widehat{\lambda}
=
\arg\max_{\lambda\geq\lambda_{\min}}
p(Y\mid\lambda).
$$

In the full paper this is embedded in a posterior over DSGE structural
parameters $\theta$ and evaluated with a Metropolis-Hastings algorithm. In the
local reduced replication, the same conjugate marginal-likelihood logic is used
with fixed DSGE-implied moments.

## 7. Model-Validation Interpretation

The diagnostic ratio is:

$$
\frac{\widehat{\lambda}-\lambda_{\min}}{\lambda_{\min}}.
$$

Interpretation:

- if $\widehat{\lambda}$ is close to $\lambda_{\min}$, the data prefer little
  DSGE restriction beyond the minimum needed for a proper prior;
- if $\widehat{\lambda}$ is much larger than $\lambda_{\min}$, the data accept a
  stronger tilt toward the DSGE-implied VAR restrictions.

This is why the paper treats the selected $\lambda$ as a model-validation
measure rather than only as a shrinkage parameter.
