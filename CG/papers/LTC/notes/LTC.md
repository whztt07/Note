[TOC]

# LTC

> 笔记忽略了纹理部分以及一些不相关的理论，还补充了其他论文里的内容

## 0. 摘要

球面分布 $\max(0, \cos\theta)$ 经过线性变换得到一分布族，称为 Linearly Transformed Cosines (LTCs)，用来近似 BRDF。 
$$
\max(0,\cos\theta)\overset{\text{LT}}{\longrightarrow}\text{LTC} \approx \text{BRDF}
$$
$\max(0, \cos\theta)$ 可以解析地积分任意球面多边形。所以 LTC 也可以。
$$
\int_P BRDF\ \mathbb{d}\pmb{l}
\approx \int_P \text{LTC}\ \mathbb{d}\pmb{l}
\xlongequal{\text{LT}^{-1}}\int_{P'}\max(0,\cos\theta)\ \mathbb{d}\pmb{l}
$$

## 1. 线性变换球面分布

> Linearly Transformed Spherical Distributions, LTSD

![1569121242804](assets/1569121242804.jpg)

### 1.1 定义

$D_o$ 是原始分布。

线性变换 $M$ 可用 3 x 3 的矩阵表示。注意本文只是用**单位向量**，具体的变换是 $\omega=M\omega_o/\|M\omega_o\|$，逆变换为 $\omega_o = M^{-1}\omega/\|M^{-1}\omega\|$。注意在线性变换后进行**标准化**使得最终的变换**非线性**。但为了直观还是使用“线性”这个词。

> 示例
>
> ![1569121421010](assets/1569121421010.jpg)

LTSD 是 $D_0$ 乘上一个 Jacobian
$$
\begin{align}
D ( \omega ) = D _ { o } \left( \omega _ { o } \right) \frac { \partial \omega _ { o } } { \partial \omega } = D _ { o } \left( \frac { M ^ { - 1 } \omega } { \left\| M ^ { - 1 } \omega \right\| } \right) \frac { \left| M ^ { - 1 } \right| } { \left\| M ^ { - 1 } \omega \right\| ^ { 3 } }
\end{align} \tag{1}
$$
其中 $\frac { \partial \omega _ { o } } { \partial \omega }=\frac { \left| M ^ { - 1 } \right| } { \left\| M ^ { - 1 } \omega \right\| ^ { 3 } }$ 是变换 M 的 Jacobian，证明看附录 A。

当 M 是缩放和旋转时，M 不改变分布的形状，此时 $\frac { \partial \omega _ { o } } { \partial \omega }=1$。

> 证明
>
> 当 M 是缩放时，有
> $$
> M =\lambda I\\
> |M^{-1}|=\lambda^3\\
> \|M^{-1}\omega\|=\lambda\\
> \frac { \partial \omega _ { o } } { \partial \omega }=\frac { \left| M ^ { - 1 } \right| } { \left\| M ^ { - 1 } \omega \right\| ^ { 3 } }=1
> $$
> 当 M 是旋转时，有
> $$
> M=R\\
> |M^{-1}|=1\\
> \|M^{-1}\omega\|=1\\
> \frac { \partial \omega _ { o } } { \partial \omega }=\frac { \left| M ^ { - 1 } \right| } { \left\| M ^ { - 1 } \omega \right\| ^ { 3 } }=1
> $$

### 1.2 性质

#### 范数

$$
\int _ { \Omega } D ( \omega ) \mathrm { d } \omega = \int _ { \Omega } D _ { o } \left( \omega _ { o } \right) \frac { \partial \omega _ { o } } { \partial \omega } \mathrm { d } \omega = \int _ { \Omega } D _ { o } \left( \omega _ { o } \right) \mathrm { d } \omega _ { o }
$$

#### 多边形积分

$$
\int_P D(\omega)\ \mathbb{d}\omega=\int_{P_o}D_o(\omega_o)\ \mathbb{d}\omega_o
$$

其中 $P_o=M^{-1}P$。

![1569122985349](assets/1569122985349.jpg)

## 2. 用 LTC 近似 BRDF

### 2.1 LTC

$$
D_o(\omega_o=(x,y,z))=\frac{1}{\pi}\max(0,z)
$$

将 $D_o$ 代入式 (1) 即可得到 LTC

### 2.2 拟合

使用了 GGX BRDF，近似的 BRDF 为
$$
D\approx\rho(\omega_v,\omega_l)\cos\theta_l
$$

> 用 D 去近似右边的 GGX BRDF

对于各项同性的 BRDF，BRDF 只取决于入射方向 $\omega_v(\sin\theta_v,0,\cos\theta_v)$ 和粗糙度 $\alpha$。对于任意 $(\theta_v,\alpha)$ 我们找到一个 LTC 来近似，也就是找到一个 M。由于各向同性 BRDF 有平面对称性且 LTC 有缩放不变性，M 可表示为
$$
M=
\left[\begin{matrix}
a &0 &b\\
0 &c &0\\
d &0 &1\\
\end{matrix}\right]
$$

> 在实践中发现，这样子 a b c d 随 $(\theta,\alpha)$ 的变化不平缓[^rnd]
>
> ![1569123652336](assets/1569123652336.jpg)
>
> 在最终的实现[^quad]中使用的矩阵是
> $$
> M=
> \left[\begin{matrix}
> a &0 &b\\
> 0 &1 &0\\
> c &0 &d\\
> \end{matrix}\right]
> $$
> 采样所用坐标[^quad]，注意不是 `ndotv`。
>
> ```c++
> float ndotv = saturate(dot(N, V));
> vec2 uv = vec2(roughness, sqrt(1.0 - ndotv));
> ```

拟合只需要考虑 4 个变量

> 示例
>
> ![1569124384382](assets/1569124384382.jpg)

我们要存储逆变换的四个变量参数还有被拟合的 BRDF 的范数 $\int_\Omega \rho(\omega_v,\omega_l)\cos\theta_l\mathbb{d}\omega_l$。

> BRDF 的积分由于几何阴影和遮挡，总是小于 1
> $$
> \int_\Omega\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l\le1
> $$
> 相比之下，LTC 的积分总为 1。
>
> 因此存储了 BRDF 的范数 $n_D$ 来**准确**拟合 BRDF
> $$
> n_D=\int_\Omega \rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l
> $$
> 因此 LTC 捕捉了 BRDF 的形状，$n_D$ 确定了其大小
>
> ---
>
> 后续 Stephen Hill 给出了考虑 Fresnel 的情况[^fresnel]。
>
> 并不是让 LTC 去拟合含 Fresnel 的 BRDF，而是将其作为 BRDF 的范数
> $$
> \begin{align}
> n
> &= \int_\Omega F(\omega_v,\omega_l)\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l\\
> &= \int_\Omega \left[F_0+(1-F_0)(1-\langle\omega_v,\omega_h\rangle)^5\right]\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l\\
> &= F_0\int_\Omega \rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l + (1-F_0)\int_\Omega (1-\langle\omega_v,\omega_h\rangle)^5\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l\\
> &= F_0 n_D+(1-F_0)f_D
> \end{align}
> $$
> 其中 $f_D=\int_\Omega (1-\langle\omega_v,\omega_h\rangle)^5\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l$。

## 3. Real-Time Polygonal-Light Shading with LTC

假设 $L(\omega_l)=L$，光照积分方程为
$$
\begin{align}
I
&= \int_P L(\omega_l)\rho(\omega_v,\omega_l)\cos\theta_l\ \mathbb{d}\omega_l\\
&\approx \int_P L(\omega_l)D(\omega_l)\ \mathbb{d}\omega_l\\
&= L\int_P D(\omega_l)\ \mathbb{d}\omega_l\\
&= L\int_{P_o} D_o(\omega_o)\ \mathbb{d}\omega_o\\
&= LE(P_o)
\end{align}
$$
其中 $E(P_o)$ 是 $P_o=M^{-1}P$ 的 irradiance，有解析解
$$
\mathrm { E } \left( p _ { 1 } , \ldots , p _ { n } \right) = \frac { 1 } { 2 \pi } \sum _ { i = 1 } ^ { n } \operatorname { acos } \left( \left\langle p _ { i } , p _ { j } \right\rangle \right) \left\langle \frac { p _ { i } \times p _ { j } } { \left\| p _ { i } \times p _ { j } \right\| } , \left[ \begin{array} { l } { 0 } \\ { 0 } \\ { 1 } \end{array} \right] \right\rangle
$$
其中 $j=(i+1)\mod n$。注意公式假设多边形位于上半球，实践中我们需要首先裁剪多边形。

## 4. 实现细节

### 4.1 精度

在 [2.2 拟合](#2.2 拟合) 中提到了最新的矩阵的存储方式与当时的论文不同。

此外在计算多边形积分时，由精度问题会引发 artifacts

![1569142385319](assets/1569142385319.jpg)

问题出在线积分的 `acos` 上（内部使用了拟合）。

```c++
float EdgeIntegral(float3 v1, float3 v2, float3 n) {
    float theta = acos(dot(v1, v2));
    float3 u = cross(v1, v2) / sin(theta);
    return theta * dot(u, n);
}
```

我们用拟合的方式直接得到 $\theta/\sin\theta\approx f(\cos\theta)$，省去 `acos`。

![1569142156181](assets/1569142156181.jpg)

对于 diffuse，精度要求不高，可以使用更简单的计算

![1569142500809](assets/1569142500809.jpg)

### 4.2 裁剪

裁剪涉及非常繁杂的条件语句

![1569144001742](assets/1569144001742.jpg)

vector form factor
$$
F = \sum_{i=1}^n\operatorname { acos } \left( \left\langle p _ { i } , p _ { j } \right\rangle \right) \frac { p _ { i } \times p _ { j } } { \left\| p _ { i } \times p _ { j } \right\| }
$$
> $0\le\|F\|\le1$ 

我们可以找一个代理，它的 form factor 就是 F，且易于计算。

而球的积分[^poly]就是
$$
I=\frac{r^2}{d^2}\cos\theta
$$
记球所占的角度范围一半为 $\sigma$，所以 $\sigma = \operatorname{asin}\sqrt{\|F\|}$。

考虑裁剪的情形[^rnd][^Snyder96] 
$$
I _ { \text {hemi-sub } } ( \omega , \sigma ) \equiv \frac { 1 } { \pi } \left\{ \begin{array} { l l } { \pi \cos \omega \sin ^ { 2 } \sigma , } & { \omega \in \left[ 0 , \frac { \pi } { 2 } - \sigma \right] } \\ { \pi \cos \omega \sin ^ { 2 } \sigma + G ( \omega , \sigma , \gamma ) , } & { \omega \in \left[ \frac { \pi } { 2 } - \sigma , \frac { \pi } { 2 } \right] } \\ { G ( \omega , \sigma , \gamma ) + H ( \omega , \sigma , \gamma ) , } & { \omega \in \left[ \frac { \pi } { 2 } , \frac { \pi } { 2 } + \sigma \right] } \\ { 0 , } & { \omega \in \left[ \frac { \pi } { 2 } + \sigma , \pi \right] } \end{array} \right.
$$
其中
$$
\begin{array} { c } { \gamma \equiv \sin ^ { - 1 } \left( \frac { \cos \sigma } { \sin \omega } \right) } \\ { G ( \omega , \sigma , \gamma ) \equiv - 2 \sin \omega \cos \sigma \cos \gamma + \frac { \pi } { 2 } - \gamma + \sin \gamma \cos \gamma } \\ { H ( \omega , \sigma , \gamma ) \equiv \cos \omega \left[ \cos \gamma \sqrt { \sin ^ { 2 } \sigma - \cos ^ { 2 } \gamma } + \sin ^ { 2 } \sigma \sin ^ { - 1 } \left( \frac { \cos \gamma } { \sin \sigma } \right) \right] } \end{array}
$$
我们可以将不同仰角 elevation angle 和角度范围 $\sigma$ （由 $\|F\|$ 决定）的结果存储在 LUT 中。

如果不用 LUT 也可以用一个近似公式来求解

![1569145994497](assets/1569145994497.jpg)

对比如下

![1569146439936](assets/1569146439936.jpg)

> sphere approximation 看上去好像很美好，其实问题还是有的
>
> 如下
>
> ![img](assets/X`DM8P6MOSK]@JIUJL0DJ]L.png)
>
> 在球的背面出现了高光，这是有问题的，果然最终还是得靠裁剪

## 参考

[^rnd]: Stephen Hill, Eric Heitz. [**Real-Time Area Lighting:  a Journey From Research to Production**](https://blog.selfshadow.com/publications/s2016-advances/), 2016.

[^quad]: (WebGL Demo)  [Quad lights](http://blog.selfshadow.com/ltc/webgl/ltc_quad.html).

[^fresnel]: Stephen Hill. [**LTC Fresnel Approximation**](https://blog.selfshadow.com/publications/s2016-advances/s2016_ltc_fresnel.pdf).

[^poly]: Eric Heitz. [**Geometric Derivation of the Irradiance of Polygonal Lights**](https://hal.archives-ouvertes.fr/hal-01458129). 2017.

[^Snyder96]: **Area Light Sources for Real-Time Graphics**, Technical Report, 1996.

