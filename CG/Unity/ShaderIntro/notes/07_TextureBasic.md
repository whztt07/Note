# 第 7 章  基础纹理

Unity 中的纹理坐标

![texture_coordinate.jpg-349.3kB](assets/texture_coordinate.jpg)

## 7.1  单张纹理

在 Properties 中添加纹理属性

```c++
Properties {
    _Color ("Color Tint", Color) = (1, 1, 1, 1)
    _MainTex ("Main Tex", 2D) = "white" {}
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    _Gloss ("Gloss", Range(8.0, 256)) = 20
}
```

CG 中添加 `_MainTex_ST` 

```c++
fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST; // 纹理名 + _ST
fixed4 _Specular;
float _Gloss;
```

ST 是缩放 scale 和平移 translation 的缩写，他们可在材质面板中调节

![texture_tiling_offset.jpg-16.9kB](assets/texture_tiling_offset.jpg)

我们需要使用 `_MainTex_ST` 对纹理坐标进行缩放，可以使用 `UnityCG.cginc` 定义的 `TRANSFORM_TEX` 来实现

```c++
o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
```

`TRANSFORM_TEX` 的原理为

```c++
// Transforms 2D UV by scale/bias property
#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
```

![single_texture.jpg-71.3kB](assets/single_texture.jpg)

## 7.2  凹凸映射

凹凸映射 nump mapping，修改发现，不改变模型顶点位置。

有两种方法

- 高度纹理 height map
- 法线纹理 normal map

### 7.2.1  高度纹理

![heightmap.jpg-134.5kB](assets/heightmap.jpg)

### 7.2.2  法线纹理

法线方向的分量范围是 [-1, 1]，需要映射到 [0, 1] 来存储，通常使用的映射就是
$$
pixel = \frac{normal+1}{2}
$$
有两种发现纹理，一种是模型空间的法线纹理，另一种是切线空间的法线纹理

![object_tangent_space_normal.jpg-320.3kB](assets/object_tangent_space_normal.jpg)

左图法线空间，右图切线空间

切线空间的法线纹理更好

### 7.2.3  实践

