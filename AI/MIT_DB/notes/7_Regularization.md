# 7. 深度学习中的正则化

## 7.1 参数范数惩罚

正则化后的目标函数为
$$
\tilde{J}(\pmb\theta;X,\mathbf{y})=J(\pmb\theta;X,\mathbf{y})+\alpha\Omega(\pmb\theta)
$$
其中 $α \in [0, \infty)$ 是权衡范数惩罚项 Ω 和标准目标函数 $J(\pmb \theta;X,\mathbf{y})$ 相对贡献的超参数。 

当我们的训练算法最小化正则化后的目标函数 $\tilde{J}$ 时，它会降低原始目标 $J​$ 关于训练数据的误差并同时减小在某些衡量标准下参数 θ（或参数子集）的规模。选择不同的参数范数 Ω 会偏好不同的解。 在神经网络中，参数包
括每一层仿射变换的权重和偏置，我们通常只对权重做惩罚而不对偏置做正则惩罚。

 在神经网络的情况下，有时希望对网络的每一层使用单独的惩罚，并分配不同的 α 系数。寻找合适的多个超参数的代价很大，因此为了减少搜索空间，我们会在所有层使用相同的权重衰减。 正则化偏置参数可能会导致明显的欠拟合。因此，我们使用向量 $\mathbf{w}$ 表示所有应受范数惩罚影响的权重，而向量 $\pmb{\theta}$ 表示所有参数 (包括 $\mathbf{w}$ 和无需正则化的参数)。

### 7.1.1 $L^2$ 参数正则化

$L^2$ 参数范数惩罚通常被称为 **权重衰减**（weight decay）。这个正则化策略通过向目标函数添加一个正则项 $Ω(\pmbθ) = \frac{1}{2} ∥\mathbf{w}∥_2^2​$，使权重更加接近原点。 

目标函数为
$$
\tilde{J}(\mathbf{w};X,\mathbf{y})=\frac{\alpha}{2}\mathbf{w}^\top\mathbf{w}+J(\mathbf{w};X,\mathbf{y})
$$
**单步影响** 

梯度为
$$
\nabla_\mathbf{w}\tilde{J}(\mathbf{w};X,\mathbf{y})=\alpha\mathbf{w}+\nabla_\mathbf{w}J(\mathbf{w};X,\mathbf{y})
$$
使用单步梯度下降更新权重，即执行以下更新： 
$$
\begin{align}
\mathbf{w}&\gets\mathbf{w}-\epsilon(\alpha\mathbf{w}+\nabla_\mathbf{w}J(\mathbf{w};X,\mathbf{y}))\\
&\gets(1-\epsilon\alpha)\mathbf{w}-\epsilon \nabla_\mathbf{w}J(\mathbf{w};X,\mathbf{y})
\end{align}
$$
可以看到，加入权重衰减后会引起学习规则的修改，即在每步执行通常的梯度更新之前先收缩权重向量（将权重向量乘以一个常数因子）。

**全局影响** 

令 $\mathbf{w}^∗$ 为未正则化的目标函数取得最小训练误差时的权重向量，即 $\mathbf{w}^∗ = \arg \min_\mathbf{w} J(\mathbf{w})$，并在 $\mathbf{w}^∗$ 的邻域对目标函数做二次近似。如果目标函数确实是二次的 (如以均方误差拟合线性回归模型的情况)，则该近似是完美的。近似的 $\hat{J}(θ)$ 如下

$$
\hat{J}(\pmb\theta)=J(\mathbf{w}^*)+\frac{1}{2}(\mathbf{w}-\mathbf{w}^*)^\top H(\mathbf{w}-\mathbf{w}^*)
$$
其中 H 是 J 在 $\mathbf{w}^*$ 处计算的 Hessian 矩阵 (关于 $\mathbf{w}$)。 因为 $\mathbf{w}^*$ 被定义为最优，即梯度消失为 0，所以该二次近似中没有一阶项。同样地，因为 w∗ 是 J 的一个最优点，我们可以得出 H 是半正定的结论。当 $\hat{J}$ 取得最小时，其梯度
$$
∇_\mathbf{w}\hat{J}(\mathbf{w}) = H(\mathbf{w} - \mathbf{w}^∗)
$$
为 0。 

现在我们探讨最小化正则化后的 $\hat{J}$。我们使用变量 $\tilde{\mathbf{w}}$ 表示此时的最优点: 




$$
\begin{align}
\alpha\tilde{\mathbf{w}}+H(\tilde{\mathbf{w}}-\mathbf{w}^*)&=0\\
(H+\alpha I)\tilde{\mathbf{w}}&=H\mathbf{w}^*\\
\tilde{\mathbf{w}}&=(H+\alpha I)^{-1}H\mathbf{w}^*\\
\end{align}
$$
当 $α$ 趋向于 0 时，正则化的解 $\tilde{\mathbf{w}}$ 会趋向 $\mathbf{w}^*$。那么当 $α$ 增加时会发生什么呢？因为 $H$ 是实对称的，所以我们可以将其分解为一个对角矩阵 $Λ$ 和一组特征向量的标准正交基 $Q$，并且有 $H = QΛQ^⊤$。可得：
$$
\begin{align}
\tilde{\mathbf{w}}
&=(Q\Lambda Q^\top+\alpha I)^{-1}Q\Lambda Q^\top\mathbf{w}^*\\
&=[Q(\Lambda+\alpha I)Q^\top]^{-1}Q\Lambda Q^\top\mathbf{w}^*\\
&=Q(\Lambda+\alpha I)^{-1}\Lambda Q^\top\mathbf{w}^*\\
\end{align}
$$
我们可以看到权重衰减的效果是沿着由 $H$ 的特征向量所定义的轴缩放 $\mathbf{w}^*$。具体来说，我们会根据 $\frac{\lambda_i}{\lambda_i+\alpha}$ 因子缩放与 $H$ 第 i 个特征向量对齐的 $\mathbf{w}^*$ 的分量。 

沿着 H 特征值较大的方向 (如 $λ_i ≫ α$)正则化的影响较小。而 $λ_i ≪ α$ 的分量将会收缩到几乎为零。 

![1547289434871](assets/1547289434871.jpg)

> 实线椭圆表示没有正则化目标的等值线。虚线圆圈表示 $L^2$ 正则化项的等值线。在 $\tilde{\mathbf{w}}$ 点，这两个竞争目标达到平衡。 

只有在显著减小目标函数方向上的参数会保留得相对完好。在无助于目标函数减小的方向（对应 Hessian 矩阵较小的特征值）上改变参数不会显著增加梯度。这种不重要方向对应的分量会在训练过程中因正则化而衰减掉。 

### 7.1.2 $L^1$ 参数正则化

对模型参数 $\mathbf{w}$ 的 $L^1$ 正则化被定义为： 
$$
\Omega(\pmb\theta)=||\mathbf{w}||_1=\sum_i{|w_i|}
$$
即各个参数的绝对值之和。

正则化的目标函数为
$$
\tilde{J}(\mathbf{w};X,\mathbf{y})=\alpha||\mathbf{w}||_1+J(\mathbf{w};X,\mathbf{y})
$$
**单步影响** 

对应的梯度（实际上是次梯度）：
$$
\nabla_\mathbf{w}\tilde{J}(\mathbf{w};X,\mathbf{y})=\alpha\text{sign}(\mathbf{w})+\nabla J(\mathbf{w};X,\mathbf{y})
$$
使用单步梯度下降更新权重，即执行以下更新： 
$$
\begin{align}
\mathbf{w}
&\gets\mathbf{w}-\epsilon(\alpha\text{sign}(\mathbf{w})+\nabla J(\mathbf{w};X,\mathbf{y}))\\
&\gets(\mathbf{w}-\epsilon\alpha\text{sign}(\mathbf{w}))-\epsilon\nabla J(\mathbf{w};X,\mathbf{y})\\
\end{align}
$$
可以看到正则化对梯度的影响不再是线性地缩放每个 $w_i$；而是减去了一项与$\text{sign}(w_i)$ 同号的常数。 

由于 $L^1$ 惩罚项在完全一般化的 Hessian 的情况下，无法得到直接清晰的代数表达式，因此我们将进一步简化假设 Hessian 是对角的，即 $H = \text{diag}([H_{1,1},...,H_{n,n}])$，其中每个 $H_{i,i} > 0$。

 我们可以将 L1正则化目标函数的二次近似分解成关于参数的求和： 
$$
\tilde{J}(\mathbf{w};X,\mathbf{y})=J(\mathbf{w}^*;X,\mathbf{y})+\sum_i\Big[\frac{1}{2}H_{i,i}(w_i-w_i^*)^2+\alpha|w_i|\Big]
$$
如下列形式的解析解（对每一维 i）可以最小化这个近似代价函数： 
$$
w_i=\text{sign}(w_i^*)\max\Big\{|w_i^*|-\frac{\alpha}{H_{i,i}},0\Big\}
$$
产生的影响如下

![1547292053625](assets/1547292053625.jpg)

> $H_{i,i}$ 比较小时，$w_i$ 受较大的影响，相反，$H_{i,i}$ 比较大时，$w_i​$ 受较小的影响。

相比 $L^2$正则化， $L^1$正则化会产生更 稀疏（ sparse）的解。此处稀疏性指的是最优值中的一些参数为 0。 

对于 $L^1$正则化，用于正则化代价函数的惩罚项 $αΩ(\mathbf{w}) = α ∑_i |w_i|$ 与通过 MAP 贝叶斯推断最大化的对数先验项是等价的（ $\mathbf{w} \in \mathbb{R}^n​$ 并且权重先验是各向同性的拉普拉斯分布）：
$$
\log p(\mathbf{w})=\sum_i\log \text{Laplace}(w_i;0,\frac{1}{\alpha})=-\alpha||\mathbf{w}||_1+n\log\alpha-n\log 2
$$

## 7.2 作为约束的范数惩罚

如果我们想约束 Ω(θ) 小于某个常数 k，我们可以构建广义 Lagrange 函数 
$$
\mathcal{L}(\pmb\theta,\alpha;X,\mathbf{y})=J(\pmb\theta;X,\mathbf{y})+\alpha(\Omega(\pmb\theta)-k)
$$
这个约束问题的解由下式给出 
$$
\pmb\theta^*=\arg\min_{\pmb\theta}\max_{\alpha,\alpha\ge0}\mathcal{L}(\pmb\theta,\alpha)
$$
为了洞察约束的影响，我们可以固定 $α^∗$，把这个问题看成只跟 θ 有关的函数： 
$$
\pmb\theta^*=\arg\min_{\pmb\theta}\mathcal{L}(\pmb\theta,\alpha^*)=\arg\min_{\pmb\theta}J(\pmb\theta;X,\mathbf{y})+\alpha^*\Omega(\pmb\theta)
$$
这和最小化 $\hat{J}$ 的正则化训练问题是完全一样的。因此，我们可以把参数范数惩罚看作对权重强加的约束。 

有时候，我们希望使用显式的限制，而不是惩罚。我们可以修改下降算法（如随机梯度下降算法），使其先计算 J(θ) 的下降步，然后将 θ 投影到满足 Ω(θ) < k 的最近点。如果我们知道什么样的 k 是合适的，而不想花时间寻找对应于此 k 处的 α 值，这会非常有用。 

另一个使用显式约束和重投影而不是使用惩罚强加约束的原因是惩罚可能会导致目标函数非凸而使算法陷入局部极小 (对应于小的 θ）。 

## 7.3 正则化和欠约束问题

机器学习中许多线性模型，包括线性回归和 PCA，都依赖于对矩阵 $X^⊤X$ 求逆。只要 $X^⊤X$ 是奇异的，这些方法就会失效。 在这种情况下，正则化的许多形式对应求逆 $X^⊤X + αI$。这个正则化矩阵可以保证是可逆的。 

我们可以使用 Moore-Penrose 求解欠定线性方程，伪逆的一个定义如下：
$$
X^+=\lim\limits_{\alpha\to0}(X^\top X+\alpha I)^{-1}X^\top
$$
现在我们可以将上式看作进行具有权重衰减的线性回归。 我们可以将伪逆解释为使用正则化来稳定欠定问题。

## 7.4 数据集增强

让机器学习模型泛化得更好的最好办法是使用更多的数据进行训练。当然，在实践中，我们拥有的数据量是很有限的。解决这个问题的一种方法是创建假数据并添加到训练集中。对于一些机器学习任务，创建新的假数据相当简单。 

对分类来说这种方法是最简单的。分类器需要一个复杂的高维输入 x，并用单个类别标识 y 概括 x。这意味着分类面临的一个主要任务是要对各种各样的变换保持不变。我们可以轻易通过转换训练集中的 x 来生成新的 (x; y) 对。 

数据集增强对一个具体的分类问题来说是特别有效的方法：对象识别。图像是高维的并包括各种巨大的变化因素，其中有许多可以轻易地模拟。即使模型已使用卷积和池化技术对部分平移保持不变，沿训练图像每个方向平移几个像素的操作通常可以大大改善泛化。许多其他操作如旋转图像或缩放图像也已被证明非常有效。 

我们必须要小心，不能使用会改变类别的转换。 

> 如"b"与"d"，"6"与"9"

## 7.5 噪声鲁棒性

在一般情况下，注入噪声远比简单地收缩参数强大，特别是噪声被添加到隐藏单元时会更加强大。 

另一种正则化模型的噪声使用方式是将其加到权重。 

在某些假设下，施加于权重的噪声可以被解释为与更传统的正则化形式等同，鼓励要学习的函数保持稳定。 

我们研究回归的情形，也就是训练将一组特征 $\mathbf{x}$ 映射成一个标量的函数 $\hat{y}(\mathbf{x})$，并使用最小二乘代价函数衡量模型预测值 $\hat{y}(\mathbf{x})​$ 与真实值 y的误差： 
$$
J=\mathbb{E}_{p(x,y)}[(\hat{y}(\mathbf{x})-y)^2]
$$
现在我们假设对每个输入表示，网络权重添加随机扰动 $ϵ_\mathbf{w} ∼ \mathcal{N}(\pmb ϵ; 0; ηI )$。想象我们有一个标准的 $l$ 层 MLP。我们将扰动模型记为 $\hat{y}_{ϵW}(\mathbf{x})$。尽管有噪声注入，我们仍然希望减少网络输出误差的平方。因此目标函数变为： 
$$
\begin{align}
\hat{J}_W
&=\mathbb{E}_{p(\mathbf{x},y,\epsilon_W)}[(\hat{y}_{\epsilon_W}(\mathbf{x})-y)^2]
\end{align}
$$
对于小的 η，最小化带权重噪声（方差为 $ηI$ ）的 J 等同于最小化附加正则化项：$η\mathbb{E}_{p(x;y)}[∥∇_W \hat{y}(\mathbf{x})∥^2]​$ 的 J。这种形式的正则化鼓励参数进入权重小扰动对输出相对影响较小的参数空间区域。 换句话说，它推动模型进入对权重小的变化相对不敏感的区域，找到的点不只是极小点，还是由平坦区域所包围的极小点 (Hochreiter and Schmidhuber, 1995)。 

> 在简化的线性回归中（例如， $\hat{y}(\mathbf{x}) = \mathbf{w}^⊤\mathbf{x} + b$），正则项退化为$η\mathbb{E}_{p(\mathbf{x})}[∥\mathbf{x}∥^2]$，这与函数的参数无关，因此不会对 $\tilde{J}_\mathbf{w}$ 关于模型参数的梯度有影响。 

### 7.5.1 向输出目标注入噪声

大多数数据集的 y 标签都有一定错误。错误的 y 不利于最大化 $\log p(y | \mathbf{x})$。避免这种情况的一种方法是显式地对标签上的噪声进行建模。 

## 7.6 半监督学习

## 7.7 多任务学习

多任务学习 (Caruana, 1993) 是通过合并几个任务中的样例（可以视为对参数施加的软约束）来提高泛化的一种方式。 当模型的一部分被多个额外的任务共享时，这部分将被约束为良好的值（如果共享合理），通常会带来更好的泛化能力。 

> 示例
>
> ![1547298663794](assets/1547298663794.jpg)
>
> 不同的监督任务（给定 $\mathbf{x}$预测 $y^{(i)}$）共享相同的输入 $\mathbf{x}$ 以及一些中间层表示 $\mathbf{h}^{(share)}$，能学习共同的因素池。该模型通常可以分为两类相关的参数： 
>
> - 具体任务的参数（只能从各自任务的样本中实现良好的泛化）。 如图中的上层。
> - 所有任务共享的通用参数（从所有任务的汇集数据中获益）。 如图中的下层。

## 7.8 提前终止

当训练有足够的表示能力甚至会过拟合的大模型时，我们经常观察到，训练误差会随着时间的推移逐渐降低但验证集的误差会再次上升。 

![1547299068401](assets/1547299068401.jpg)

这意味着我们只要返回使验证集误差最低的参数设置，就可以获得验证集误差更低的模型（并且因此有希望获得更好的测试误差）。在每次验证集误差有所改善后，我们存储模型参数的副本。当训练算法终止时，我们返回这些参数而不是最新的参数。当验证集上的误差在事先指定的循环次数内没有进一步改善时，算法就会终止。 

算法如下

![1547298979492](assets/1547298979492.jpg)

我们可以认为提前终止是非常高效的超参数选择算法。按照这种观点，训练步数仅是另一个超参数。 

**利用验证集训练** 

提前终止需要验证集，这意味着某些训练数据不能被馈送到模型。为了更好地利用这一额外的数据，我们可以在完成提前终止的首次训练之后，进行额外的训练。在第二轮，即额外的训练步骤中，所有的训练数据都被包括在内。这里有两个基本的策略都可以用于第二轮训练过程。 

- 策略一

  再次初始化模型，然后使用所有数据再次训练。 

  > 此过程有一些细微之处。例如，我们没有办法知道重新训练时，对参数进行相同次数的更新和对数据集进行相同次数的遍历哪一个更好。由于训练集变大了，在第二轮训练时，每一次遍历数据集将会更多次地更新参数。 

  ![1547299820351](assets/1547299820351.jpg)

- 策略二

  保持从第一轮训练获得的参数，然后使用全部的数据继续训练。 

  > 在这个阶段，已经没有验证集指导我们需要在训练多少步后终止。取而代之，我们可以监控验证集的平均损失函数，并继续训练，直到它低于提前终止过程终止时的目标值。此策略避免了重新训练模型的高成本，但表现并没有那么好。例如，验证集的目标不一定能达到之前的目标值，所以这种策略甚至不能保证终止。 

  ![1547299864947](assets/1547299864947.jpg)

**提前终止带来的正则化效果** 

提前终止对减少训练过程的计算成本也是有用的。除了由于限制训练的迭代次数而明显减少的计算成本，还带来了正则化的益处（不需要添加惩罚项的代价函数或计算这种附加项的梯度）。 

Bishop (1995a) 和 Sjöberg and Ljung(1995) 认为提前终止可以将优化过程的参数空间限制在初始参数值 $\pmb θ_0$ 的小邻域内。 

![1547300763739](assets/1547300763739.jpg)

当然，提前终止比简单的轨迹长度限制更丰富；取而代之，提前终止通常涉及监控验证集误差，以便在空间特别好的点处终止轨迹。因此提前终止比权重衰减更具有优势，提前终止能自动确定正则化的正确量，而权重衰减需要进行多个不同超参数值的训练实验。 

## 7.9 参数绑定和参数共享

目前为止，本章讨论对参数添加约束或惩罚时，一直是相对于固定的区域或点。例如， $L^2$正则化（或权重衰减）对参数偏离零的固定值进行惩罚。然而，有时我们可能需要其他的方式来表达我们对模型参数适当值的先验知识。有时候，我们可能无法准确地知道应该使用什么样的参数，但我们根据相关领域和模型结构方面的知识得知模型参数之间应该存在一些相关性。 

我们经常想要表达的一种常见依赖是某些参数应当彼此接近。 
$$
\hat{y}^{(A)}=f(\mathbf{w}^{(A)},\mathbf{x})\\
\hat{y}^{(B)}=f(\mathbf{w}^{(B)},\mathbf{x})\\
\Omega(\mathbf{w}^{(A)},\mathbf{w}^{(B)})=||\mathbf{w}^{(A)}-\mathbf{w}^{(B)}||_2^2
$$
参数范数惩罚是正则化参数使其彼此接近的一种方式，而更流行的方法是使用约束： 强迫某些参数相等。由于我们将各种模型或模型组件解释为共享唯一的一组参数，这种正则化方法通常被称为 **参数共享**（ parameter sharing）。 

> **参数共享示例——卷积神经网络**
>
> 自然图像有许多统计属性是对转换不变的。例如，猫的照片即使向右边移了一个像素，仍保持猫的照片。 CNN通过在图像多个位置共享参数来考虑这个特性。相同的特征（具有相同权重的隐藏单元）在输入的不同位置上计算获得。这意味着无论猫出现在图像中的第 i 列或 i + 1 列，我们都可以使用相同的猫探测器找到猫。 
>
> 参数共享显著降低了CNN模型的参数数量，并显著提高了网络的大小而不需要相应地增加训练数据。它仍然是将领域知识有效地整合到网络架构的最佳范例之一。 

## 7.10 稀疏表示

前文所述的权重衰减直接惩罚模型参数。另一种策略是惩罚神经网络中的激活单元，稀疏化激活单元。这种策略间接地对模型参数施加了复杂惩罚。 

表示的稀疏描述了许多元素是零（或接近零）的表示。 

> 示例——线性回归
>
> ![1547301912810](assets/1547301912810.jpg)
>
> 第一个表达式是参数稀疏的线性回归模型的例子。第二个表达式是数据 $\mathbf{x}$ 具有稀疏表示 $\mathbf{h}$ 的线性回归。也就是说， $\mathbf{h}$ 是 $\mathbf{x}$ 的一个函数，在某种意义上表示存在于 $\mathbf{x}$ 中的信息，但只是用一个稀疏向量表示。

表示的正则化可以使用参数正则化中同种类型的机制实现。 

表示的范数惩罚正则化是通过向损失函数 $J$ 添加对表示的范数惩罚来实现的。我们将这个惩罚记作 $Ω(\mathbf{h})$。和以前一样，我们将正则化后的损失函数记作 $\hat{J}$： 
$$
\tilde{J}(\pmb \theta;X,\mathbf{y})=J(\pmb \theta;X,\mathbf{y})+\alpha\Omega(\mathbf{h})
$$
正如对参数的 L1 惩罚诱导参数稀疏性，对表示元素的 $L^1$ 惩罚诱导稀疏的表示：$Ω(\mathbf{h}) = ∥\mathbf{h}∥^1 = ∑_i |h_i|$。当然 $L^1$ 惩罚是使表示稀疏的方法之一。其他方法还包括从表示上的Student-t 先验导出的惩罚 (Olshausen and Field, 1996; Bergstra, 2011)和KL 散度惩罚 (Larochelle and Bengio, 2008b)，这些方法对于将表示中的元素约束于单位区间上特别有用。  

还有一些其他方法通过激活值的硬性约束来获得表示稀疏。 

> 例如， 正交匹配追踪 (orthogonal matching pursuit)(Pati et al., 1993) 通过解决以下约束优化问题将输
> 入值 $\mathbf{x}$ 编码成表示 $\mathbf{h}$：
> $$
> \arg\min_{\mathbf{h},||\mathbf{h}||_0<k}||\mathbf{x}-W\mathbf{h}||^2
> $$
> 其中 $∥\mathbf{h}∥^0$ 是 $\mathbf{h}$ 中非零项的个数。当 W 被约束为正交时，我们可以高效地解决这个问题。这种方法通常被称为OMP-k，通过 k 指定允许的非零特征数量。 Coates and Ng (2011) 证明OMP-1 可以成为深度架构中非常有效的特征提取器。 

## 7.11 Bagging 和其他集成方法

Bagging（ bootstrap aggregating）是通过结合几个模型降低泛化误差的技术(Breiman, 1994)。主要想法是分别训练几个不同的模型，然后让所有模型表决测试样例的输出。这是机器学习中常规策略的一个例子，被称为 **模型平均**（ model averaging）。采用这种策略的技术被称为集成方法。

模型平均（ model averaging）奏效的原因是不同的模型通常不会在测试集上产生完全相同的误差。 

假设我们有 k 个回归模型。假设每个模型在每个例子上的误差是 $ϵ_i$，这个误差服从零均值方差为 $E[ϵ^2_i ] = v$ 且协方差为 $E[ϵ_iϵ_j] = c$ 的多维正态分布。通过所有集成模型的平均预测所得误差是 $\frac{1}{k} ∑_i ϵ_i$。集成预测器平方误差的期望是 
$$
\begin{aligned} \mathbb { E } \left[ \left( \frac { 1 } { k } \sum _ { i } \epsilon _ { i } \right) ^ { 2 } \right] & = \frac { 1 } { k ^ { 2 } } \mathbb { E } \left[ \sum _ { i } \left( \epsilon _ { i } ^ { 2 } + \sum _ { j \neq i } \epsilon _ { i } \epsilon _ { j } \right) \right] \\ & = \frac { 1 } { k } v + \frac { k - 1 } { k } c \end{aligned}
$$
在误差完全相关即 c = v 的情况下，均方误差减少到 v，所以模型平均没有任何帮助。在错误完全不相关即 c = 0 的情况下，该集成平方误差的期望仅为 $\frac{1}{k}v$。这意味着集成平方误差的期望会随着集成规模增大而线性减小。换之，平均上，集成至少与它的任何成员表现得一样好，并且如果成员的误差是独立的，集成将显著地比其成员表现得更好。 

Bagging是一种允许重复多次使用同一种模型、训练算法和目标函数的方法。 具体来说， Bagging涉及构造 k 个不同的数据集。每个数据集从原始数据集中重复采样构成，和原始数据集具有相同数量的样例。这意味着，每个数据集以高概率缺少一些来自原始数据集的例子，还包含若干重复的例子（如果所得训练集与原始数据集大小相同，那所得数据集中大概有原始数据集 2/3 的实例）。模型 i 在数据集 i 上训练。每个数据集所含样本的差异导致了训练模型之间的差异。 

> 示例
>
> ![1547442216370](assets/1547442216370.jpg)
>
> 假设我们在上述数据集（包含一个 8、一个 6 和一个 9）上训练数字 8 的检测器。假设我们制作了两个不同的重采样数据集。 Bagging训练程序通过有放回采样构建这些数据集。第一个数据集忽略 9 并重复 8。在这个数据集上，检测器得知数字顶部有一个环就对应于一个 8。第二个数据集中，我们忽略 6 并重复 9。在这种情况下，检测器得知数字底部有一个环就对应于一个 8。这些单独的分类规则中的每一个都是不可靠的，但如果我们平均它们的输出，就能得到鲁棒的检测器，只有当 8 的两个环都存在时才能实现最大置信度。 

## 7.12 Dropout

Dropout训练的集成包括所有从基础网络除去非输出单元后形成的子网络

> 示例
>
> ![1547443375245](assets/1547443375245.jpg)

Dropout的目标是在指数级数量的神经网络上近似这个过程。具体来说，在训练中使用Dropout时，我们会使用基于小批量产生较小步长的学习算法，如随机梯度下降等。我们每次在小批量中加载一个样本，然后随机抽样应用于网络中所有输入和隐藏单元的不同二值掩码。对于每个单元，掩码是独立采样的。掩码值为 1 的采样概率（导致包含一个单元）是训练开始前一个固定的超参数。它不是模型当前参数值或输入样本的函数。通常在每一个小批量训练的神经网络中，一个输入单元被包括的概率为 0:8，一个隐藏单元被包括的概率为 0:5。然后，我们运行和之前一样的前向传播、反向传播以及学习更新。 

> 示例——Dropout下的前向传播
>
> ![1547443570462](assets/1547443570462.jpg)
>
> (顶部) 在此示例中，我们使用具有两个输入单元，具有两个隐藏单元的隐藏层以及一个输出单元的前馈网络。 (底部) 为了执行具有Dropout的前向传播，我们随机地对向量 µ 进行采样，其中网络中的每个输入或隐藏单元对应一项。 网络中的每个单元乘以相应的掩码，然后正常地继续沿着网络的其余部分前向传播。这相当于从上个示例的图中随机选择一个子网络并沿着前向传播。 

更正式地说，假设一个掩码向量 $\pmb\mu$ 指定被包括的单元， $J(\pmb θ; \pmb µ)$ 是由参数 $\pmb θ$ 和掩码 $\pmb \mu$ 定义的模型代价。那么Dropout训练的目标是最小化 $\mathbb{E}_{\pmb \mu}J(\pmb θ; \pmb \mu)$。这个期望包含多达指数级的项，但我们可以通过**抽样** $\pmb \mu$ 获得梯度的无偏估计。

然而，一个更好的方法能不错地近似整个集成的预测，且只需一个前向传播的代价。要做到这一点，我们改用集成成员预测分布的几何平均而不是算术平均。Warde-Farley et al. (2014) 提出的论点和经验证据表明，在这个情况下几何平均与算术平均表现得差不多。 

多个概率分布的几何平均不能保证是一个概率分布。为了保证结果是一个概率分布，我们要求没有子模型给某一事件分配概率 0，并重新标准化所得分布。通过几何平均直接定义的非标准化概率分布由下式给出
$$
\tilde { p } _ { \text { ensemble } } ( y | \boldsymbol { x } ) = \sqrt [ 2^d ] { \prod _ { \mu } p ( y | \boldsymbol { x } , \boldsymbol { \mu } ) }
$$
其中 d 是可被丢弃的单元数。这里为简化介绍，我们使用均匀分布的 $\boldsymbol{\mu}$，但非均匀分布也是可以的。为了作出预测，我们必须重新标准化集成： 
$$
p_\text{ensemble}(y|\boldsymbol{x})=\frac{\tilde{p}_\text{ensemble}(y|\boldsymbol{x})}{\sum_{y'}\tilde{p}_\text{ensemble}(y'|\boldsymbol{x})}
$$
涉及Dropout的一个重要观点 (Hinton et al., 2012c) 是，我们可以通过评估模型中 $p(y | \mathbf{x})​$ 来近似 $p_\text{ensemble}​$：该模型具有所有单元，但我们将单元 i 的输出的权重乘以单元 i 的被包含概率。这个修改的动机是得到从该单元输出的正确期望值。我们把这种方法称为 **权重比例推断规则**（ weight scaling inference rule）。 目前还没有在深度非线性网络上对这种近似推断规则的准确性作任何理论分析，但经验上表现得很好。 

## 7.13 对抗训练

Szegedy et al. (2014b) 发现，在精度达到人类水平的神经网络上通过优化过程故意构造数据点，其上的误差率接近100%，模型在这个输入点 $\mathbf{x}′$ 的输出与附近的数据点 $\mathbf{x}$ 非常不同。在许多情况下， $\mathbf{x}′$ 与 $\mathbf{x}$ 非常近似，人类观察者不会察觉原始样本和 对抗样本（ adversarial example）之间的差异，但是网络会作出非常不同的预测。 

> 示例
>
> ![1547444586447](assets/1547444586447.jpg)

Goodfellow et al. (2014b) 表明，这些对抗样本的主要原因之一是过度线性。神经网络主要是基于线性块构建的。因此在一些实验中，它们实现的整体函数被证明是高度线性的。这些线性函数很容易优化。不幸的是，如果一个线性函数具有许多输入，那么它的值可以非常迅速地改变。如果我们用 $ϵ$ 改变每个输入，那么权重为$\mathbf{w}$ 的线性函数可以改变 $ϵ ∥\mathbf{w}∥_1$ 之多，如果 $\mathbf{w}$ 是高维的这会是一个非常大的数。对抗训练通过鼓励网络在训练数据附近的局部区域恒定来限制这一高度敏感的局部线性行为。这可以被看作是一种明确地向监督神经网络引入局部恒定先验的方法。 

对抗样本也提供了一种实现半监督学习的方法。在与数据集中的标签不相关联的点 $\mathbf{x}$ 处，模型本身为其分配一些标签 $\hat{y}$。模型的标记 $\hat{y}$ 未必是真正的标签，但如果模型是高品质的，那么 $\hat{y}$ 提供正确标签的可能性很大。我们可以搜索一个对抗样本 $\mathbf{x}′$，导致分类器输出一个标签 $\hat{y}$ 且 $y′ \neq \hat{y}$。不使用真正的标签，而是由训练好的模型提供标签产生的对抗样本被称为 **虚拟对抗样本**（ virtual adversarial example）(Miyato et al., 2015)。我们可以训练分类器为 $\mathbf{x}$ 和 $\mathbf{x}′​$ 分配相同的标签。这鼓励分类器学习一个沿着未标签数据所在流形上任意微小变化都很鲁棒的函数。驱动这种方法的假设是，不同的类通常位于分离的流形上，并且小扰动不会使数据点从一个类的流形跳到另一个类的流形上。 

## 7.14 切面距离、正切传播和流形正切分类器

**正切传播**（ tangent prop）算法 (Simard et al., 1992)训练带有额外惩罚的神经网络分类器，使神经网络的每个输出 $f(\mathbf{x})$ 对已知的变化因素是局部不变的。这些变化因素对应于沿着的相同样本聚集的流形的移动。这里实现局部不变性的方法是要求 $∇_\mathbf{x}f(\mathbf{x})$ 与已知流形的切向 $v^{(i)}$ 正交，或者等价地通过正则化惩罚 Ω 使 f 在 x 的 $v^{(i)}$ 方向的导数较小： 
$$
\Omega ( f ) = \sum _ { i } \left( \left( \nabla _ \boldsymbol { x } f ( \boldsymbol { x } ) ^ { \top } \boldsymbol { v } ^ { ( i ) } \right) \right) ^ { 2 }
$$
我们根据切向量推导先验，通常从变换（如平移、旋转和缩放图像）的效果获得形式知识。 

流形正切分类器 (Rifai et al., 2011d) 无需知道切线向量的先验。自编码器可以估算流形的切向量。流形正切分类器使用这种技术来避免 用户指定切向量。 

> 示例
>
> ![1547445801382](assets/1547445801382.jpg)
>
> 每条曲线表示不同类别的流形，这里表示嵌入二维空间中的一维流形。在一条曲线上，我们选择单个点并绘制一个与类别流形（平行并接触流形）相切的向量以及与类别流形（与流形正交）垂直的向量。在多维情况下，可以存在许多切线方向和法线方向。我们希望分类函数在垂直于流形方向上快速改变，并且在类别流形的方向上保持不变。正切传播和流形正切分类器都会正则化 f(x)，使其不随 x 沿流形的移动而剧烈变化。正切传播需要用户手动指定正切方向的计算函数（例如指定小平移后的图像保留在相同类别的流形中），而流
> 形正切分类器通过训练自编码器拟合训练数据来估计流形的正切方向。 
