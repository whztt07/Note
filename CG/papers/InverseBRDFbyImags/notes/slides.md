# 引言

物体包含几何和材质

![1566891729892](assets/1566891729892.png)

材质的获得可以用 PS，也可以从图像反推

![1566891723033](assets/1566891723033.png)

目标就是用统一的框架 unified framework 来获取材质

![1566891778543](assets/1566891778543.png)

# 相关工作

Deschaintre et al. 2018 采用了基于学习的方法，单一图像，结果大致 ok，不支持多图像

![1566891898793](assets/1566891898793.png)

Aittala et al. 2015 和 Dong et al. 2014 使用了 classic inverse rendering，支持多图像，结果精确，但不支持单一图像

![1566891983218](assets/1566891983218.png)

总的来说

![1566892030591](assets/1566892030591.png)

# 我们的工作

既支持单一图像，又支持多图像

![1566892053185](assets/1566892053185.png)

![1566892359593](assets/1566892359593.png)

方式是 deep inverse rendering

- deep: SVBRDF auto-encoder

  ![1566892734227](assets/1566892734227.png)

- inverse rendering: optimize in leraned latent space

  ![1566892748556](assets/1566892748556.png)

# 主要挑战

- loss：均衡各 map 的重要性
- smooth space：适合于优化
- initialization

## 假设

- 平面

- 点光源在相机上

- 相机与平面距离固定

![1566893060354](assets/1566893060354.png)

## Training Loss

模型

![1566893080240](assets/1566893080240.png)

训练误差结合了贴图误差和渲染结果误差
$$
L_\text{train} = L_\text{map} + \lambda_\text{render}L_\text{render}
$$
![1566893221601](assets/1566893221601.png)

## Smoothness regularization

外加 latent space smoothness 的误差
$$
L_\text{smooth}=\lambda_\text{smooth}\|D(z)-D(z+\xi)\|_1
$$
![1566893341503](assets/1566893341503.png)

## Initialization strategy

优化策略需要一个初始值，也就是自动编码器的 latent code。

我们前边已经训练好 SVBRDF auto-encouder 了，那么我们只需要恰当的材质贴图就可以了。

我们可以利用只需要一张图片的方法来获得材质贴图，从而得到初始的 latent code。

![1566893764356](assets/1566893764356.png)

# latent space 优化

![1566893962043](assets/1566893962043.png)

这就是一个简单的优化问题了

# 结果

## 单一图片效果好

![1566894269651](assets/1566894269651.png)

## 支持多图片

![1566894291666](assets/1566894291666.png)

## 比经典方法好

![1566894314807](assets/1566894314807.png)

## 支持高精度

![1566894358751](assets/1566894358751.png)

## 真实情况

![1566894394022](assets/1566894394022.png)

# 总结

- unified deep inverse rendering framework
  - 训练 SVBRDF auto-encoder
  - 使用单一图像方法初始化
  - 在 latent code 空间优化
- future work
  - better initialization
  - getometry + apperance estimation

