# Real-Time Polygonal-Light Shading with Linearly Transformed Cosines

> Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt

[Real-Time Polygonal-Light Shading with Linearly Transformed Cosines](https://eheitzresearch.wordpress.com/415-2/) 

## 示例

### vedio

<video id="video" controls="" preload="none">
    <source id="mp4" src="/resources/LTC.mp4" type="video/mp4">
</video>
### demo shader

https://blog.selfshadow.com/sandbox/ltc.html

### exe

[ltc_demo.exe](./resources/ltc_demo/bgfx/examples/runtime/ltc_demo.exe)

## 复现

- [ ] 总结论文
- [ ] 拟合（有源码）
- [ ] 实现（有 shader 示例）



```c++
vec3 LTC_Evaluate(
    vec3 N, vec3 V, vec3 P, mat3 Minv, vec4 points[4], bool twoSided, sampler2D texFilteredMap)
{
    // construct orthonormal basis around N
    vec3 T1, T2;
    T1 = normalize(V - N*dot(V, N));
    T2 = cross(N, T1);

    // rotate area light in (T1, T2, R) basis
    Minv = mul(Minv, mat3_from_rows(T1, T2, N));

    // polygon (allocate 5 vertices for clipping)
    vec3 L[5];
    L[0] = mul(Minv, points[0].xyz - P);
    L[1] = mul(Minv, points[1].xyz - P);
    L[2] = mul(Minv, points[2].xyz - P);
    L[3] = mul(Minv, points[3].xyz - P);
    L[4] = L[3]; // avoid warning

    vec3 textureLight = vec3(1, 1, 1);
#if LTC_TEXTURED
    textureLight = FetchDiffuseFilteredTexture(texFilteredMap, L[0], L[1], L[2], L[3]);
#endif

    int n;
    ClipQuadToHorizon(L, n);
    
    if (n == 0)
        return vec3(0, 0, 0);

    // project onto sphere
    L[0] = normalize(L[0]);
    L[1] = normalize(L[1]);
    L[2] = normalize(L[2]);
    L[3] = normalize(L[3]);
    L[4] = normalize(L[4]);

    // integrate
    float sum = 0.0;

    sum += IntegrateEdge(L[0], L[1]);
    sum += IntegrateEdge(L[1], L[2]);
    sum += IntegrateEdge(L[2], L[3]);
    if (n >= 4)
        sum += IntegrateEdge(L[3], L[4]);
    if (n == 5)
        sum += IntegrateEdge(L[4], L[0]);

    // note: negated due to winding order
    sum = twoSided ? abs(sum) : max(0.0, -sum);

    vec3 Lo_i = vec3(sum, sum, sum);

    // scale by filtered light color
    Lo_i *= textureLight;

    return Lo_i;
}
```

疑点

- [ ] 第二张贴图的 R 意义不明（）
- [ ] 第二张贴图的 G 意义不明
- [ ] filter 贴图生成方式不明

