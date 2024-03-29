[TOC]

# 天气系统

## 雨

### 粒子

- 稀疏：丑

- 密集：效率问题（CPU 粒子扛不住，GPU 粒子有像素填充率的问题）

  > 像素填充率？

![1562235703058](assets/1562235703058.jpg)

### 屏幕纹理动画

- 无法表达风朝向
- 视角 bug（向下看，雨像是横着运动）

![1562235731294](assets/1562235731294.jpg)

[ATIDemo: TOYSHOP](https://www.youtube.com/watch?v=LtxvpS5AYHQ) 

[Artist-Directable Real-Time Rain Rendering in City Environments](https://dl.acm.org/citation.cfm?id=1185828) 

### 微软 | 双锥雨[^04 Wang][^12 Lagarde]

- **世界空间中，跟随相机移动的椎体，在椎体上做纹理动画** 

  ![1562236873845](assets/1562236873845.jpg)

  ![1562237076622](assets/1562237076622.jpg)

- 调节两个端点的**顶点色透明度** 

  ![1562237158684](assets/1562237158684.jpg)

  ![1562237164287](assets/1562237164287.jpg)

- 根据**风向**、相机**移动方向**、**速度**，椎体有不同的**倾斜度** 

  ![1562237197391](assets/1562237197391.jpg)

  ![1562237202349](assets/1562237202349.jpg)

- 改进一（用不同 Tiling 和 UV 来提升视差感，还有轻微不同的 UV 旋转来产生交错感）

  ![1562240865808](assets/1562240865808.jpg)

- 改进二（场景遮挡，遮挡物下不下雨，类似 shadowmap）

  - 下雨方向深度图

    ![1562241226436](assets/1562241226436.jpg)

    ![1562241231393](assets/1562241231393.jpg)

  - 雨滴深度

    - 四次纹理采样，每层一段深度范围
    - 贴图带雨滴深度，映射到每层范围内

    ![1562293387119](assets/1562293387119.jpg)

## 天气粒子



## 潮湿、涟漪、积水、水花

## 打雷

# 昼夜系统

## 天空、雾

## 体积云

## 月、星、银河

# 昼夜天气变换

# 参考

[^04 Wang]: Wang N, Wade B. [**Rendering falling rain and snow**](https://dl.acm.org/citation.cfm?id=1186241)[C]//ACM SIGGRAPH 2004 Sketches. ACM, 2004: 14.

[^12 Lagarde]: Sébastien Lagarde. [**Water Drop**](https://seblagarde.wordpress.com/2012/12/10/observe-rainy-world/). 2012.

