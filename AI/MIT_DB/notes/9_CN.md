# 9. 卷积网络

> Convolutional Networks

卷积网络是指那些至少在网络的一层中使用卷积运算来替代一般的矩阵乘法运算的神经网络。 

## 9.1 卷积运算

$$
s ( t ) = \int x ( a ) w ( t - a ) d a
$$

卷积运算通常用星号表示： 
$$
s ( t ) = ( x * w ) ( t )
$$
卷积的第一个参数（在这个例子中，函数 x）通常叫做 **输入**（ input），第二个参数（函数 w）叫做 **核函数**（kernel function）。输出有时被称作 **特征映射**（ feature map）。 

离散形式的卷积 
$$
s ( t ) = ( x * w ) ( t ) = \sum _ { a = - \infty } ^ { \infty } x ( a ) w ( t - a )
$$
通常假设在存储了数值的有限点集以外，这些函数的值都为零。 

> 这意味着在实际操作中，我们可以通过对有限个数组元素的求和来实现无限求和。 

最后，我们经常一次在多个维度上进行卷积运算。

> 示例
>
> 如果把一张二维的图像 $I$ 作为输入，我们也许也想要使用一个二维的核 $K$：
> $$
> S ( i , j ) = ( I * K ) ( i , j ) = \sum _ { m } \sum _ { n } I ( m , n ) K ( i - m , j - n )
> $$
> 卷积是可交换的 (commutative)，我们可以等价地写作： 
> $$
> S ( i , j ) = ( K * I ) ( i , j ) = \sum _ { m } \sum _ { n } I ( i - m , j - n ) K ( m , n )
> $$

卷积运算可交换性的出现是因为我们将核相对输入进行了 **翻转**（ flip），从 m 增大的角度来看，输入的索引在增大，但是核的索引在减小。 

与之不同的是，许多神经网络库会实现一个相关的函数，称为 **互相关函数**（ cross-correlation），和卷积运算几乎一样但是并没有对核进行翻转： 
$$
S ( i , j ) = ( I * K ) ( i , j ) = \sum _ { m } \sum _ { n } I ( i + m , j + n ) K ( m , n )
$$
许多机器学习的库实现的是互相关函数但是称之为卷积。 

离散卷积可以看作矩阵的乘法 

> 示例
>
> ![1547525513255](assets/1547525513255.jpg)

## 9.2 动机

卷积运算通过三个重要的思想来帮助改进机器学习系统： **稀疏交互**（ sparseinteractions）、 **参数共享**（parameter sharing）、 **等变表示**（ equivariant representations）。另外，卷积提供了一种处理大小可变的输入的方法。 

传统的神经网络使用矩阵乘法来建立输入与输出的连接关系。其中，参数矩阵中每一个单独的参数都描述了一个输入单元与一个输出单元间的交互。这意味着每一个输出单元与每一个输入单元都产生交互。然而，卷积网络具有 **稀疏交互**（ sparse interactions）（也叫做 **稀疏连接**（ sparse connectivity）或者 **稀疏权重**（ sparse weights））的特征。这是使核的大小远小于输入的大小来达到的。 

如果有 m 个输入和 n 个输出，那么矩阵乘法需要 m × n 个参数并且相应算法的时间复杂度为 O(m × n)。如果我们限制每一个输出拥有的连接数为 k，那么稀疏的连接方法只需要 k × n 个参数以及 O(k × n) 的运行时间。 

> 示例
>
> ![1547526122861](assets/1547526122861.jpg)

**参数共享**（ parameter sharing）是指在一个模型的多个函数中使用相同的参数。 

在传统的神经网络中，当计算一层的输出时，权重矩阵的每一个元素只使用一次，当它乘以输入的一个元素后就再也不会用到了。 

作为参数共享的同义词，我们可以说一个网络含有 **绑定的权重**（ tied weights），因为用于一个输入的权重也会被绑定在其他的权重上。 

对于卷积，参数共享的特殊形式使得神经网络层具有对平移 **等变**（ equivariance）的性质。 如果函数 f(x) 与 g(x) 满足 $f(g(x)) = g(f(x))$，我们就说 f(x) 对于变换 g 具有等变性。 

卷积对其他的一些变换并不是天然等变的，例如对于图像的放缩或者旋转变换，需要其他的一些机制来处理这些变换。 

## 9.3 池化

卷积网络中一个典型层包含三级（如下图）。在第一级中，这一层并行地计算多个卷积产生一组线性激活响应。在第二级中，每一个线性激活响应将会通过一个非线性的激活函数，例如整流线性激活函数。这一级有时也被称为 **探测级**（ detector stage）。在第三级中，我们使用 **池化函数**（ pooling function）来进一步调整这一层的输出。 

![1547527213703](assets/1547527213703.jpg)

> 上图是一个典型卷积神经网络层的组件。 有两组常用的术语用于描述这些层。 (左) 在这组术语中，卷积网络被视为少量相对复杂的层，每层具有许多 ‘‘级’’。在这组术语中，核张量与网络层之间存在一一对应关系。 (右) 在这组术语中，卷积网络被视为更多数量的简单层；每一个处理步骤都被认为是一个独立的层。这意味着不是每一 ‘‘层’’ 都有参数。 

池化函数使用某一位置的相邻输出的总体统计特征来代替网络在该位置的输出。 

**最大池化**（ max pooling）函数 (Zhou and Chellappa, 1988) 给出相邻矩形区域内的最大值。其他常用的池化函数包括相邻矩形区域内的平均值、 L2 范数以及基于据中心像素距离的加权平均函数。 

当输入作出少量平移时，池化能够帮助输入的表示近似 **不变**（ invariant）。对于平移的不变性是指当我们对输入进行少量平移时，经过池化函数后的大多数输出并不会发生改变。 

局部平移不变性是一个很有用的性质，尤其是当我们关心某个特征是否出现而不关心它出现的具体位置时。 

使用池化可以看作是增加了一个无限强的先验：这一层学得的函数必须具有对少量平移的不变性。当这个假设成立时，池化可以极大地提高网络的统计效率。 

对空间区域进行池化产生了平移不变性，但当我们对分离参数的卷积的输出进行池化时，特征能够学得应该对于哪种变换具有不变性。

> 示例
>
> ![1547530519340](assets/1547530519340.jpg)
>
> 使用分离的参数学得多个特征，再使用池化单元进行池化，可以学得对输入的某些变换的不变性。这里我们展示了用三个学得的过滤器和一个最大池化单元可以学得对旋转变换的不变性。这三个过滤器都旨在检测手写的数字 5。每个过滤器尝试匹配稍微不同方向的 5。当输入中出现 5 时，相应的过滤器会匹配它并且在探测单元中引起大的激活。然后，无论哪个探测单元被激活，最大池化单元都具有大的激活。 

因为池化综合了全部邻居的反馈，这使得池化单元少于探测单元成为可能，我们可以通过综合池化区域的 k 个像素的统计特征而不是单个像素来实现。 

## 9.4 卷积与池化作为一种无限强的先验

先验被认为是强或者弱取决于先验中概率密度的集中程度。弱先验具有较高的熵值，例如方差很大的高斯分布。这样的先验允许数据对于参数的改变具有或多或少的自由性。强先验具有较低的熵值，例如方差很小的高斯分布。这样的先验在决定参数最终取值时起着更加积极的作用。 

我们可以把卷积网络类比成全连接网络，但对于这个全连接网络的权重有一个无限强的先验。这个无限强的先验是说一个隐藏单元的权重必须和它邻居的权重相同，但可以在空间上移动。这个先验也要求除了那些处在隐藏单元的小的空间连续的接受域内的权重以外，其余的权重都为零。总之，我们可以把卷积的使用当作是对网络中一层的参数引入了一个无限强的先验概率分布。这个先验说明了该层应该学得的函数只包含局部连接关系并且对平移具有等变性。类似的，使用池化也是一个无限强的先验：每一个单元都具有对少量平移的不变性。 

其中一个关键的洞察是卷积和池化可能导致欠拟合。与任何其他先验类似，卷积和池化只有当先验的假设合理且正确时才有用。如果一项任务依赖于保存精确的空间信息，那么在所有的特征上使用池化将会增大训练误差。 

## 9.5 基本卷积函数的变体

当我们提到神经网络中的卷积时，我们通常是指由多个并行卷积组成的运算。这是因为具有单个核的卷积只能提取一种类型的特征，尽管它作用在多个空间位置上。我们通常希望网络的每一层能够在多个位置提取多种类型的特征。 

另外，输入通常也不仅仅是实值的网格，而是由一系列观测数据的向量构成的网格。 当处理图像时，我们通常把卷积的输入输出都看作是 3 维的张量 。

假定我们有一个 4 维的核张量 K，它的每一个元素是 $K_{[i]\gets[j],(k,l)}$，表示输出中处于通道 i 的一个单元和输入中处于通道 j 中的一个单元的连接强度，输出单元和输入单元之间有k 行 l 列的偏置(offset)。假定我们的输入由观测数据 V 组成，它的每一个元素是 $V_{[i],(j,k)}​$，表示处在通道 i 中第 j 行第 k 列的值。假定我们的输出 Z 和输入V 具有相同的形式。如果输出 Z 是通过对 K 和 V 进行卷积而不涉及翻转 K 得到的，那么 
$$
Z _ { [i] , (j , k) } = \sum _ { [l] , (m , n) } V _ { [l] , (j + m - 1 , k + n - 1) } K _ { [i] \gets [l] , (m , n) }
$$

> 在线性代数中，向量的索引通常从 1 开始，这就是上述公式中 -1 的由来。 但是像 C 或 Python 这类编程语言索引通常从 0 开始，这使得上述公式可以更加简洁。 
> $$
> Z _ { [i] , (j , k) } = \sum _ { [l] , (m , n) } V _ { [l] , (j + m, k + n) } K _ { [i] \gets [l] , (m , n) }
> $$

我们可以把这一过程看作是对全卷积函数输出的 **下采样** (downsampling)。如果我们只想在输出的每个方向上每间隔 s 个像素进行采样，那么我们可以定义一个下采样卷积函数 c 使得 
$$
Z _ { [i] , (j , k) } = c ( \mathbf { K } , \mathbf { V } , s ) _ { [i] , (j , k
)} = \sum _ { [l] , (m , n) } \left[ V _ { [l] , (( j - 1 ) s+ m , ( k - 1 ) s + n) , } K _ { [i] \gets [l] , (m , n) } \right]
$$

> 简洁版本
> $$
> Z _ { [i] , (j , k) } = c ( \mathbf { K } , \mathbf { V } , s ) _ { [i] , (j , k
> )} = \sum _ { [l] , (m , n) } \left[ V _ { [l] , (j s+ m , k s + n) , } K _ { [i] \gets [l] , (m , n) } \right]
> $$

我们把 s 称为下采样卷积的 **步幅**（ stride）。当然也可以对每个移动方向定义不同的步幅。 

在任何卷积网络的实现中都有一个重要性质，那就是能够隐含地对输入 V 用零进行填充 (pad) 使得它加宽。如果没有这个性质，表示的宽度在每一层就会缩减，缩减的幅度是比核少一个像素这么多。对输入进行零填充允许我们对核的宽度和输出的大小进行独立的控制。如果没有零填充，我们就被迫面临二选一的局面，要么选择网络空间宽度的快速缩减，要么选择一个小型的核——这两种情境都会极大得限制网络的表示能力。 

> 示例
>
> ![1547532701650](assets/1547532701650.jpg)

有三种零填充设定的情况值得注意。 

- 有效（ valid）卷积 ：无论怎样都不使用零填充，并且卷积核只允许访问那些图像中能够完全包含整个核的位置。 如果输入的图像宽度是 m，核的宽度是 k，那么输出的宽度就会变成**m - k + 1**。 
- 相同（ same）卷积 ：只进行足够的零填充来保持输出和输入具有**相同**的大小。 
- 全（ full）卷积 ：它进行了足够多的零填充使得每个像素在每个方向上恰好被访问了 k 次，最终输出图像的宽度为 **m + k - 1**。 

在一些情况下，我们并不是真的想使用卷积，而是想用一些局部连接的网络层(LeCun, 1986, 1989)。在这种情况下，我们的多层感知机对应的邻接矩阵是相同的，但每一个连接都有它自己的权重，用一个 6 维的张量 W 来表示。 W 的索引分别是：输出的通道 i，输出的行 j 和列 k，输入的通道 l，输入的行偏置 m 和列偏置 n。局部连接层的线性部分可以表示为 
$$
Z _ { [i] , (j , k) } = \sum _ { [l] , (m , n) } \left[ V _ { [l] , (j + m - 1 , k + n - 1) } w _ { [i] , (j , k), [l] , (m , n) } \right]
$$
这有时也被称为 **非共享卷积**（ unshared convolution），因为它和具有一个小核的离散卷积运算很像，但并不横跨位置来共享参数。 

当我们知道每一个特征都是一小块空间的函数并且相同的特征不会出现在所有的空间上时，局部连接层是很有用的。 

每一个输出的通道 i 仅仅是输入通道 l 的一部分的函数时。实现这种情况的一种通用方法是使输出的前 m 个通道仅仅连接到输入的前 n 个通道，输出的接下来的 m个通道仅仅连接到输入的接下来的 n 个通道，以此类推。 

**平铺卷积**（ tiled convolution） (Gregor and LeCun, 2010a; Le et al., 2010) 对卷积层和局部连接层进行了折衷。这里并不是对每一个空间位置的权重集合进行学习，我们学习一组核使得当我们在空间移动时它们可以循环利用。这意味着在近邻的位置上拥有不同的过滤器，就像局部连接层一样，但是对于这些参数的存储需求仅仅会增长常数倍，这个常数就是核的集合的大小，而不是整个输出的特征映射的大小。 

为了用代数的方法定义平铺卷积，令 K 是一个 6 维的张量5，其中的两维对应着输出映射中的不同位置。 K 在这里并没有对输出映射中的每一个位置使用单独的索引，输出的位置在每个方向上在 t 个不同的核组成的集合中进行循环。如果 t 等于输出的宽度，这就是局部连接层了。 

$$
Z _ { [i] , (j , k) } = \sum _ { [l] , (m , n) } V _ { [l] , (j + m - 1 , k + n - 1) } K _ { [i] \gets [l] , (m , n) , (j \% t + 1 , k \%  t + 1) }
$$
局部连接层与平铺卷积层都和最大池化有一些有趣的关联：这些层的探测单元都是由不同的过滤器驱动的。如果这些过滤器能够学会探测相同隐含特征的不同变换形式，那么最大池化的单元对于学得的变换就具有不变性（参考9.3）。卷积层对于平移具有内置的不变性。 

## 9.6 结构化输出

卷积神经网络可以用于输出高维的结构化对象，而不仅仅是预测分类任务的类标签或回归任务的实数值。通常这个对象只是一个张量，由标准卷积层产生。 

## 9.7 数据类型

|      | 单通道                                                       | 多通道                                                       |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1维  | 音频波形：卷积的轴对应于时间。我们将时间离散化并且在每个时间点测量一次波形的振幅。 | 骨架动画 (skeleton animation) 数据：计算机渲染的 3D 角色动画是通过随时间调整 ‘‘骨架’’ 的姿势而生成的。在每个时间点，角色的姿势通过骨架中的每个关节的角度来描述。我们输入到卷积模型的数据的每个通道，表示一个关节关于一个轴的角度。 |
| 2维  | 已经使用傅立叶变换预处理过的音频数据：我们可以将音频波形变换成 2 维张量，不同的行对应不同的频率，不同的列对应不同的时间点。在时间轴上使用卷积使模型等效于在时间上移动。在频率轴上使用卷积使得模型等效于在频率上移动，这使得在不同八度音阶中播放的相同旋律产生相同的表示，但处于网络输出中的不同高度。 | 彩色图像数据：其中一个通道包含红色像素，另一个包含绿色像素，最后一个包含蓝色像素。在图像的水平轴和竖直轴上移动卷积核，赋予了两个方向上平移等变性。 |
| 3维  | 体积数据：这种数据一般来源于医学成像技术，例如 CT 扫描等。   | 彩色视频数据：其中一个轴对应着时间，另一个轴对应着视频帧的高度，最后一个对应着视频帧的宽度。 |

## 9.8 高效的卷积算法

## 9.9 随机或无监督的特征

## 9.10 卷积网络的神经科学基础

有三种基本策略可以不通过监督训练而得到卷积核。其中一种是简单地随机初始化它们。另一种是手动设计它们，例如设置每个核在一个特定的方向或尺度来检测边缘。最后，可以使用无监督的标准来学习核。例如， Coates et al. (2011) 将 k 均值聚类算法应用于小图像块，然后使用每个学得的中心作为卷积核。 

## 9.11 卷积网络与深度学习的历史

卷积网络的历史始于神经科学实验，远早于相关计算模型的发展。为了确定关于哺乳动物视觉系统如何工作的许多最基本的事实，神经生理学家 David Hubel 和Torsten Wiesel 合作多年 (Hubel and Wiesel, 1959, 1962, 1968)。他们的成就最终获得了诺贝尔奖。他们的发现对当代深度学习模型有最大影响的是基于记录猫的单个神经元的活动。他们观察了猫的脑内神经元如何响应投影在猫前面屏幕上精确位置的图像。他们的伟大发现是，处于视觉系统较为前面的神经元对非常特定的光模式（例如精确定向的条纹）反应最强烈，但对其他模式几乎完全没有反应。 

在简化的视图中，我们关注被称为 V1 的大脑的一部分，也称为 初级视觉皮层（ primary visual cortex）。 V1 是大脑对视觉输入开始执行显著高级处理的第一个区域。在该草图视图中，图像是由光到达眼睛并刺激视网膜（眼睛后部的光敏组织）形成的。视网膜中的神经元对图像执行一些简单的预处理，但是基本不改变它被表示的方式。然后图像通过视神经和称为外侧膝状核的脑部区域。这些解剖区域的主要作用是仅仅将信号从眼睛传递到位于头后部的 V1。 

卷积网络层被设计为描述 V1 的三个性质： 

1. V1 可以进行空间映射。它实际上具有二维结构来反映视网膜中的图像结构。例如，到达视网膜下半部的光仅影响 V1 相应的一半。卷积网络通过用二维映射定义特征的方式来描述该特性。 
2. V1 包含许多 简单细胞（ simple cell）。简单细胞的活动在某种程度上可以概括为在一个小的空间位置感受野内的图像的线性函数。卷积网络的检测器单元被设计为模拟简单细胞的这些性质。 
3. V1 还包括许多 复杂细胞（ complex cell）。这些细胞响应类似于由简单细胞检测的那些特征，但是复杂细胞对于特征的位置微小偏移具有不变性。这启发了卷积网络的池化单元。复杂细胞对于照明中的一些变化也是不变的，不能简单地通过在空间位置上池化来刻画。这些不变性激发了卷积网络中的一些跨通道池化策略，例如 maxout 单元 (Goodfellow et al., 2013b)。 

虽然我们最了解 V1，但是一般认为相同的基本原理也适用于视觉系统的其他区域。在我们视觉系统的草图视图中，当我们逐渐深入大脑时，遵循池化的基本探测策略被反复执行。当我们穿过大脑的多个解剖层时，我们最终找到了响应一些特定概念的细胞，并且这些细胞对输入的很多种变换都具有不变性。这些细胞被昵称为‘‘祖母细胞’’——这个想法是一个人可能有一个神经元，当看到他祖母的照片时该神经元被激活，无论祖母是出现在照片的左边或右边，无论照片是她的脸部的特写镜头还是她的全身照，也无论她处在光亮还是黑暗中，等等。 

多数的 V1 细胞具有由 Gabor 函数（ Gabor function）所描述的权重。  

> 示例
>
> ![1547536457758](assets/1547536457758.jpg)
>
> 具有各种参数设置的Gabor 函数。 

神经科学和机器学习之间最显著的对应关系，是从视觉上比较机器学习模型学得的特征与使用 V1 得到的特征。  

我们发现，当应用于自然图像时，极其多样的统计学习算法学习类Gabor 函数的特征。 

> 示例
>
> ![1547536616612](assets/1547536616612.jpg)

## 9.11 卷积网络与深度学习的历史
