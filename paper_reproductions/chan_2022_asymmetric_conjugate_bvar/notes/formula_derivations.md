# Chan (2022) Formula Derivations

## 1. Reduced-Form VAR

The usual reduced-form VAR(p) is:

$$
y_t=\tilde b+\tilde B_1y_{t-1}+\cdots+\tilde B_py_{t-p}
+\tilde\varepsilon_t,
\qquad
\tilde\varepsilon_t\sim N(0,\tilde\Sigma).
$$

In large Bayesian VARs, the standard natural conjugate prior often imposes a
Kronecker covariance structure that treats own lags and other-variable lags
symmetrically. Chan's contribution is to keep conjugacy while allowing
asymmetric shrinkage.

## 2. Triangular Structural Reparameterization

Write the VAR in structural recursive form:

$$
Ay_t=b+B_1y_{t-1}+\cdots+B_py_{t-p}+\varepsilon_t,
\qquad
\varepsilon_t\sim N(0,\Sigma),
$$

where:

- $A$ is lower triangular with ones on the diagonal;
- $\Sigma=\operatorname{diag}(\sigma_1^2,\ldots,\sigma_n^2)$;
- $b$ is $n\times 1$;
- each $B_\ell$ is $n\times n$.

Reduced-form parameters are recovered by:

$$
\tilde b=A^{-1}b,
\qquad
\tilde B_\ell=A^{-1}B_\ell,
\qquad
\tilde\Sigma=A^{-1}\Sigma(A^{-1})'.
$$

Because $A$ is triangular with diagonal ones, the Jacobian of the transformation
from structural shocks to $y_t$ is one. This gives a product likelihood.

## 3. Equation-by-Equation Regression

For equation $i$, define:

$$
\beta_i=(b_i,b_{1,i}',\ldots,b_{p,i}')',
$$

where $b_{\ell,i}'$ is the $i$th row of $B_\ell$. Let:

$$
\alpha_i=(A_{i1},\ldots,A_{i,i-1})'
$$

be the free contemporaneous coefficients in row $i$ of $A$. Define:

$$
\tilde x_t=(1,y_{t-1}',\ldots,y_{t-p}'),
\qquad
\tilde w_{i,t}=(-y_{1,t},\ldots,-y_{i-1,t}).
$$

Then:

$$
y_{i,t}=\tilde x_t\beta_i+\tilde w_{i,t}\alpha_i+\varepsilon_{i,t}.
$$

Let:

$$
\theta_i=(\beta_i',\alpha_i')',
\qquad
x_{i,t}=(\tilde x_t,\tilde w_{i,t}),
$$

so:

$$
y_{i,t}=x_{i,t}\theta_i+\varepsilon_{i,t},
\qquad
\varepsilon_{i,t}\sim N(0,\sigma_i^2).
$$

Stacking over $t$:

$$
y_i=X_i\theta_i+\varepsilon_i,
\qquad
\varepsilon_i\sim N(0,\sigma_i^2 I_T).
$$

The parameter dimension is:

$$
k_i=np+i.
$$

The full likelihood factorizes:

$$
p(y\mid\theta,\sigma^2)
=
\prod_{i=1}^n
(2\pi\sigma_i^2)^{-T/2}
\exp\left[
-\frac{1}{2\sigma_i^2}
(y_i-X_i\theta_i)'(y_i-X_i\theta_i)
\right].
$$

## 4. Asymmetric Conjugate Prior

For each equation:

$$
\theta_i\mid\sigma_i^2
\sim
N(m_i,\sigma_i^2V_i),
$$

$$
\sigma_i^2\sim IG(\nu_i,S_i).
$$

The prior is independent across equations:

$$
p(\theta,\sigma^2)=\prod_{i=1}^n p(\theta_i,\sigma_i^2).
$$

The joint normal-inverse-gamma density is proportional to:

$$
p(\theta_i,\sigma_i^2)
\propto
(\sigma_i^2)^{-(\nu_i+1+k_i/2)}
\exp\left[
-\frac{1}{\sigma_i^2}
\left\{
S_i+\frac{1}{2}(\theta_i-m_i)'V_i^{-1}(\theta_i-m_i)
\right\}
\right].
$$

This form is conjugate because the likelihood contributes the same quadratic
form in $\theta_i$ and the same inverse-gamma kernel in $\sigma_i^2$.

## 5. Prior Hyperparameters

Partition:

$$
m_i=(m_{\beta,i}',m_{\alpha,i}')',
\qquad
V_i=\operatorname{diag}(V_{\beta,i},V_{\alpha,i}).
$$

For the covariance/impact part, the baseline values imply an inverse-Wishart
prior on the reduced-form covariance:

$$
\tilde\Sigma\sim IW(n+2,S),
\qquad
S=\operatorname{diag}(s_1^2,\ldots,s_n^2),
$$

where $s_i^2$ is the residual variance from a univariate AR(4) for variable
$i$. The implied structural-form hyperparameters are:

$$
\nu_i=1+\frac{i}{2},
\qquad
S_i=\frac{s_i^2}{2},
$$

$$
m_{\alpha,i}=0,
\qquad
V_{\alpha,i}=\operatorname{diag}(1/s_1^2,\ldots,1/s_{i-1}^2)
$$

before applying the scale $\sigma_i^2$ in the prior covariance.

For VAR coefficients, Chan uses Minnesota-style diagonal prior variances.
Let coefficient $k$ correspond to lag $\ell$ of variable $j$ in equation $i$.
Then:

$$
(V_{\beta,i})_k=
\begin{cases}
\kappa_1/(\ell^2s_i^2), & j=i,\\
\kappa_2/(\ell^2s_j^2), & j\neq i,\\
\kappa_4, & \text{intercept}.
\end{cases}
$$

The local code uses the paper's convention:

- $\kappa_1$ controls own-lag shrinkage;
- $\kappa_2$ controls cross-lag shrinkage;
- $\kappa_3$ controls contemporaneous $\alpha_i$ shrinkage;
- $\kappa_4=100$ leaves intercepts weakly shrunk.

For nonstationary variables, the prior mean on the first own lag is set to one:

$$
E(B_{1,ii})=1,
$$

and other VAR-coefficient prior means are zero.

## 6. Reduced-Form Elicitation Adjustment

The empirical application uses prior beliefs elicited on reduced-form VAR
coefficients and then maps them to structural-form hyperparameters.

The author code implements this by starting from the structural prior and
adjusting the coefficient variances equation by equation. For equation $i>1$
and coefficient row $j$:

$$
V_{\beta,i}^{redu}(j)
=
V_{\beta,i}^{stru}(j)
+\sum_{\ell=1}^{i-1}
\left[
V_{\beta,\ell}^{stru}(j)
+\frac{(m_{\beta,\ell}^{stru}(j))^2}{s_\ell^2}
\right].
$$

For $i=1$:

$$
V_{\beta,1}^{redu}(j)=V_{\beta,1}^{stru}(j).
$$

This step is crucial for matching the paper's Table 2.

## 7. Posterior Derivation

Combine the likelihood and the prior for equation $i$:

$$
p(\theta_i,\sigma_i^2\mid y_i)
\propto
p(y_i\mid\theta_i,\sigma_i^2)
p(\theta_i,\sigma_i^2).
$$

The exponent contains:

$$
(y_i-X_i\theta_i)'(y_i-X_i\theta_i)
+(\theta_i-m_i)'V_i^{-1}(\theta_i-m_i).
$$

Expand:

$$
y_i'y_i
-2\theta_i'X_i'y_i
+\theta_i'X_i'X_i\theta_i
+\theta_i'V_i^{-1}\theta_i
-2\theta_i'V_i^{-1}m_i
+m_i'V_i^{-1}m_i.
$$

Collect terms:

$$
\theta_i'(V_i^{-1}+X_i'X_i)\theta_i
-2\theta_i'(V_i^{-1}m_i+X_i'y_i)
+y_i'y_i+m_i'V_i^{-1}m_i.
$$

Define:

$$
K_{\theta_i}=V_i^{-1}+X_i'X_i,
$$

$$
\widehat\theta_i
=
K_{\theta_i}^{-1}(V_i^{-1}m_i+X_i'y_i).
$$

Complete the square:

$$
\theta_i'K_{\theta_i}\theta_i
-2\theta_i'K_{\theta_i}\widehat\theta_i
=
(\theta_i-\widehat\theta_i)'K_{\theta_i}
(\theta_i-\widehat\theta_i)
-\widehat\theta_i'K_{\theta_i}\widehat\theta_i.
$$

Define:

$$
\widehat S_i
=
S_i+
\frac{
y_i'y_i
+m_i'V_i^{-1}m_i
-\widehat\theta_i'K_{\theta_i}\widehat\theta_i
}{2}.
$$

Then:

$$
(\theta_i,\sigma_i^2)\mid y
\sim
NIG\left(
\widehat\theta_i,
K_{\theta_i}^{-1},
\nu_i+\frac{T}{2},
\widehat S_i
\right).
$$

Therefore:

$$
\sigma_i^2\mid y
\sim
IG\left(\nu_i+\frac{T}{2},\widehat S_i\right),
$$

$$
\theta_i\mid\sigma_i^2,y
\sim
N(\widehat\theta_i,\sigma_i^2K_{\theta_i}^{-1}).
$$

This posterior is independent across equations, so posterior draws can be
generated directly rather than by a Gibbs sampler.

## 8. Efficient Sampling

Let $C_i$ be the Cholesky factor:

$$
K_{\theta_i}=C_iC_i'.
$$

To draw $\theta_i$ without explicitly inverting $K_{\theta_i}$:

1. Draw

$$
\sigma_i^2\sim IG\left(\nu_i+\frac{T}{2},\widehat S_i\right).
$$

2. Draw $u_i\sim N(0,\sigma_i^2I_{k_i})$.

3. Set:

$$
\theta_i=\widehat\theta_i+C_i'^{-1}u_i.
$$

Since:

$$
\operatorname{Var}(C_i'^{-1}u_i)
=
\sigma_i^2 C_i'^{-1}C_i^{-1}
=
\sigma_i^2K_{\theta_i}^{-1},
$$

the draw has the correct conditional posterior distribution.

## 9. Marginal Likelihood

The marginal likelihood factors by equation:

$$
p(y)=\prod_{i=1}^n p(y_i).
$$

For each equation:

$$
p(y_i)
=
\int\int
p(y_i\mid\theta_i,\sigma_i^2)
p(\theta_i,\sigma_i^2)
d\theta_i\,d\sigma_i^2.
$$

Using the completed square above, the integral becomes the normalizing constant
of a normal-inverse-gamma distribution:

$$
p(y_i)
=
(2\pi)^{-T/2}
|V_i|^{-1/2}
|K_{\theta_i}|^{-1/2}
\frac{\Gamma(\nu_i+T/2)S_i^{\nu_i}}
{\Gamma(\nu_i)\widehat S_i^{\nu_i+T/2}}.
$$

Thus:

$$
p(y)
=
\prod_{i=1}^n
(2\pi)^{-T/2}
|V_i|^{-1/2}
|K_{\theta_i}|^{-1/2}
\frac{\Gamma(\nu_i+T/2)S_i^{\nu_i}}
{\Gamma(\nu_i)\widehat S_i^{\nu_i+T/2}}.
$$

The log marginal likelihood is:

$$
\log p(y)
=
-\frac{Tn}{2}\log(2\pi)
+\sum_{i=1}^n
\left[
-\frac{1}{2}\{\log|V_i|+\log|K_{\theta_i}|\}
+\log\Gamma\left(\nu_i+\frac{T}{2}\right)
+\nu_i\log S_i
-\log\Gamma(\nu_i)
-\left(\nu_i+\frac{T}{2}\right)\log\widehat S_i
\right].
$$

This is the expression implemented in:

```text
code/acp_replication.R
```

and in the author's MATLAB helper:

```text
data/raw/author_code/BVAR_ACP_R1_code/utility/ml_VAR_ACP.m
```

## 10. Hyperparameter Optimization

The empirical comparison maximizes the log marginal likelihood over shrinkage
hyperparameters:

$$
(\widehat\kappa_1,\widehat\kappa_2)
=
\arg\max_{\kappa_1,\kappa_2}
\log p(y\mid\kappa_1,\kappa_2).
$$

The symmetric benchmark imposes:

$$
\kappa_1=\kappa_2.
$$

The subjective benchmark fixes:

$$
\kappa_1=0.04,
\qquad
\kappa_2=0.0016.
$$

The asymmetric prior estimates $\kappa_1$ and $\kappa_2$ separately. The local
15-variable replication obtains:

| prior | $\kappa_1$ | $\kappa_2$ | log marginal likelihood |
| --- | ---: | ---: | ---: |
| symmetric | 0.008321 | 0.008321 | 4333.299 |
| subjective | 0.040000 | 0.001600 | 4329.768 |
| asymmetric | 0.058099 | 0.004270 | 4341.550 |

The higher marginal likelihood for the asymmetric prior is the paper's main
evidence that own-lag and cross-lag shrinkage should not be forced to be the
same in large BVARs.
