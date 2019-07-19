# Better Fog

https://iquilezles.org/www/articles/fog/fog.htm

## Colored fog

雾效很关键

![img](assets/gfx00.jpg)

![img](assets/gfx01.jpg)

```c++
vec3 applyFog( in vec3  rgb,       // original color of the pixel
               in float distance ) // camera to point distance
{
    float fogAmount = 1.0 - exp( -distance*b );
    vec3  fogColor  = vec3(0.5,0.6,0.7);
    return mix( rgb, fogColor, fogAmount );
}
```

雾色可以告诉我们太阳光的强度，我们可以让雾色雨方向有关，如视线与阳光相对时，雾色更亮些，否则蓝一些。

```c++
vec3 applyFog( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayDir,   // camera to point vector
               in vec3  sunDir )  // sun light direction
{
    float fogAmount = 1.0 - exp( -distance*b );
    float sunAmount = max( dot( rayDir, sunDir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,0.7), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,8.0) );
    return mix( rgb, fogColor, fogAmount );
}
```

![img](assets/gfx02.jpg)

> 注意太阳附近的山更黄一些

我们可以将 `mix` 展开

```c++
finalColor = pixelColor * (1.0 - exp(-distance*b)) + fogColor*exp(-distance*b);
```

根据经典的大气散射论文，第一项是由于散射 scattering 或 extinction 造成的光的吸收，第二项是 inscattering。这样解释时，我们可以使用不同的 falloff 参数 b 给 extinction 和 inscattering。

```c++
vec3 extColor = vec3( exp(-distance*be.x), exp(-distance*be.y) exp(-distance*be.z) );
vec3 insColor = vec3( exp(-distance*bi.x), exp(-distance*bi.y) exp(-distance*bi.z) );
finalColor = pixelColor*(1.0-extColor) + fogColor*insColor;
```

## Non constant density

上边的 b 称为密度。可以使用不为常数的密度。使用 Crytek[^06Wenzel] 的 trick。

真实大气的密度随高度下降。我们将其建模为指数函数。这样会有解析解
$$
d(y) = a e^{-b y}
$$
> 原文为 $ab^{-by}$，应为笔误
>
> 这个 y 可以直接是相机的 y，也可以是相机与雾的差值。相对于雾。

参数 b 控制下降速率

视线方程为
$$
r(t) = o_y + t k_y
$$
![img](assets/gfx06.jpg)

雾总量为
$$
D=\int_0^Td(y(t))\mathbb{d}t
$$
解得
$$
D=ae^{-bo_y}\frac{1-e^{-bk_yT}}{bk_y}=ce^{-bo_y}\frac{1-e^{-bk_yT}}{k_y}
$$

> 初看，上式与 Crytek[^06Wenzel] 略有不同
>
> 其为
> $$
> D = ce^{-bo_y}T\frac{1-e^{-bd_y}}{d_y}
> $$
> 其中 $d_y=k_y T$，则有
> $$
> D=ce^{-bo_y}T\frac{1-e^{-bk_yT}}{k_yT}=ce^{-bo_y}\frac{1-e^{-bk_yT}}{k_y}
> $$
> 所以两式是相同的

```c++
vec3 applyFog( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayOri,   // camera position
               in vec3  rayDir )  // camera to point vector
{
    float fogAmount = c * exp(-rayOri.y*b) * (1.0-exp( -distance*rayDir.y*b ))/rayDir.y;
    vec3  fogColor  = vec3(0.5,0.6,0.7);
    return mix( rgb, fogColor, fogAmount );
}
```

> 根据 Crytek[^06Wenzel]，最后应该再对 `fogAmount` 来个指数函数，为 `exp(-fogAmount)`，值域为 $[0,1]$。

对比如下

![img](assets/gfx04.jpg)

![img](assets/gfx05.jpg)

## 参考

[^06Wenzel]: Wenzel C. [**Real-time atmospheric effects in games**](https://dl.acm.org/citation.cfm?id=1185831)[C]//ACM SIGGRAPH 2006 Courses. ACM, 2006: 113-128.

