# Deep Inverse Rendering for High-resolution SVBRDF Estimation from an Arbitrary Number of Images 

通过图像推 BRDF， deep inverse rendering framework

图像越多越精确

直接优化隐藏层 latent embeded space 的外观参数，无需引入人工的启发性。这个隐藏层通过 fully convolutional auto-encoder 来学习。

支持任意图片，且高精度

# 1. 导论

这一类问题称为材质捕获 material capture。充足大量图片来获取准确估计的方法有 Dong[^Dong14] 和 Hui[^Hui17]。少量图片难以生成可信结果。最近许多新方法专注于用单图片生成可信结果，然而高光特征难以捕获。更多图片肯定更好，但这些方法难以扩展到多图片输入。

本文提出一个统一的框架通过任意数量的图片来高精度地估计平面材质样本的 BRDF 反射参数。

![1566887232263](assets/1566887232263.png)

估计的 BRDF 精度从 plausible 到 accurate。方法称为 deep inverse rendering，结合了 deep learning 和 inverse rendering。

初始值通过只需一个图像的方法来提供。通过扩展 latent feature map 的精度就可以支持高精度 BRDF 了，不需要重新训练模型。

总结有三点

- 任意数量的图像
- 不固定输入和输出的精度 resolution
- 单一图像的表现比前人工作好

# 2. 相关工作

- Multi-Image Heuristics-based Apperance Modeling
- Single/Few Image Reflectance Modeling
- Learning-based Apperance Modeling
- Optimizing with Auto-encoders

# 3. 综述

## 预设

带法向贴图的平面，Cook-Torrance Microfacet BRDF（GGX）

- normal map
- diffuse albedo
- specular albedo
- roughness

此外，假设每个图片靠一个在相机附近的点光源打光。

虽然样本中相机与平面的距离固定，但没有严格限制。

要求至少一个图像是正对的。

每一张图片，相机的内参和外参已知。

顶视图？

## Deep Inverse Rendering

材质参数 $s=(n,k_d,\alpha,k_s)$，损失函数 L，图像 $I_i$，渲染 R，相机（和光源）参数 $C_i$
$$
\begin{align}
\underset { s } { \operatorname { argmin } } \sum _ { i } \mathcal { L } \left( I _ { i } , R \left( s , C _ { i } \right) \right)
\end{align}
$$
损失函数为
$$
\begin{align}
\mathcal { L } ( x , y ) = \| \log ( x + 0.01 ) - \log ( y + 0.01 ) \| _ { 1 }
\end{align}
$$
不同于传统的 inverse rendering 方法，我们不直接优化反射参数 s，而是寻找



# 参考

[^Dong14]: Yue Dong, Guojun Chen, Pieter Peers, Jiawan Zhang, and Xin Tong. 2014. **Appearance-from-motion: Recovering Spatially Varying Surface Reﬂectance Under Unknown Lighting**. ACM Trans. Graph. 33, 6, Article 193 (2014). 
[^Hui17]: Zhuo Hui, Kalyan Sunkavalli, Joon-Young Lee, Sunil Hadap, and Aswin Sankara-narayanan. 2017. **Reﬂectance Capture using Univariate Sampling of BRDFs**. In ICCV.



