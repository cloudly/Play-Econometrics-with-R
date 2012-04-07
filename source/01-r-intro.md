# 熟悉R

关于R的中文入门有很多，在这里不再一一枚举（也不是本册子的职责所在）。但我也不能在这里说，诸位客官回去学完R的基本结构再来吧。一是有点枯燥，二则我个人窃以为学习一个软件最好的办法就是不断的拿例子来磨练，遇到问题去网上搜寻，否则看再多的入门引导也只似过眼烟云，那些命令一会儿就抛到九霄云外了。所以我把会用到的一些东西直接融入在下面这个简单的例子中，有一些必要的说明，希望可以快速的熟悉R。

下面是来自Papke(1995)的一个例子。他研究的是一个退休金计划和计划的慷慨度。

(@401K) 在401K.DTA这个数据集中，我们关心两个变量。prate是在合法的工人中拥有活跃帐户的比例。mrate是用来衡量这个计划的匹配程度（用来代表慷慨度），即如果mrate = 0:5，则表示工人付出了$10，其工作单位相应的付出了$5。接下来，我们需要面对这么几个问题：

    1. 找到prate和mrate这两个变量的平均值。
    2. 对下面这个方程进行最简单的OLS回归：$\hat{prate} = \hat{\beta}_0 + \hat{\beta}_1mrate$，并报告$R^2$。
    3. 找到当mrate = 3.5的时候，prate的预测值。

做计量分析，离不开的就是数据。所以我们第一步先来导入需要的数据。

## 数据的导入

获取数据有很多办法，在R 里面通过Foreign包可以读/写Minitab, S, SAS, SPSS, Stata, Systat等等格式的数据。当然，R本身是支持从文本文件（包括CSV格式）和剪贴板中直接读取数据的。此外，对于R包里面自带的数据集，我们可以直接用`data("name")`来加载数据集。这里我采取的是读取Stata的数据（DTA格式）。

当然，我们首先要加载**foreign**包，可以在R中直接点击“加载程序包”，也可以手动输入：

``` {r load-foreign}
library(foreign)
````

然后就可以使用`read.dta()`命令：

``` {r read-401k}
K = read.dta("data/401K.DTA", convert.dates=TRUE, convert.factors=TRUE, missing.type=TRUE, convert.underscore=TRUE, warn.missing.labels=TRUE)
summary(K)
````

K是我们赋值后在R里使用的数据表的名字。因为R是基于对象(object)的，所以我们需要在读取数据的时候指定数据存储的对象。同样的，后面会不断的用到对象这一概念。

如果觉得这些东西记起来比较麻烦，一个个字母的打起来也挺麻烦的，怎么办？好在有个包叫做**Rcmdr**。加载这个包之后就会出现图形界面，可以通过点击的方式来操作。

![在R Commander中导入数据](http://i.imgur.com/OvRVp.jpg)

# 数据分析
## 平均值
在介绍关于平均值的函数前，先介绍另一个有用的函数`names()`。这个函数的作用是显示数据表中所有的变量名称。用法和效果见后面的代码例子。

我们可以使用`summary()`来获取该数据表的摘要信息，里面包含平均值、最大最小值 、中位数等。不过我们这里只关心两个变量`prate `和`mrate` ，所以也可以使用`numSummary()`（需加载abind包）。

``` {r load-401k}

load("D:/data/401K.rda")

names(K)

summary(K)
````
可以从上表中读出`prate`和`mrate`的平均值。

`sumSummary()`也可以通过R Commander的图形界面实现。
![R Commander里调用sumSummary()分析数据](2-1-2.JPG)

##线性回归（普通最小二乘法，OLS）
在R里面进行线性回归还是比较容易的，直接使用`lm()`就可以。值得注意的是，由于R的面向对象特性，我们需要不断的赋值。对于赋值，有三种基本方法，分别可以用“->”“<-”“=”实现，其中前两个是有方向的赋值，所以一般来说更为常用。比如我们可以对变量`mrate`和`prate` 求乘积，并将结果赋予一个新变量`mp`，则只需写成`mp<-mrate*prate`。

因此在做回归的时候写成：
``` {r 401k-regression}
RegModel<- lm(prate~mrate, data=K)
summary(RegModel)
````
这样RegModel里面就存储了这次回归所得的数据。

我们还可以采用`attach()`命令，这样就不用每次都指定回归向量所在的数据集了，直接写`RegModel<- lm(prate~mrate)`，然后就可以用`summary(RegModel)`来看回归的结果了。(注：通常情况下不建议使用`attach()`，可能会导致变量名的一定程度混乱，尤其是在函数封装的时候。)


可以看出估计后的回归方程应为：

$\hat{prate}=83.0755+5.8611mrate$ 

其中$R^{2}$为0.0747。呃，这个$R^{2}$为什么这么小？看看散点图就知道了。

#作回归图像
我们可以直接用最简单的`plot()`命令作图(当然更好的一个选择可能是*[ggplot2][]*)，用法如下：

[ggplot2]: ggplot2       "ggplot2"
 
``` {r scatter-the-data}
 plot (mrate,prate) 
abline(RegModel,col="red")
````
第二行命令是添加了那条回归拟合线。
可见这个图本来就很散，也难怪线性拟合效果这么差了。
#点预测
最后，就是依赖估计方程做预测了。这里需要的是做一个点预测。R里面需要依据另一个数据集来预测，而且这个数据集中必须含有mrate 这个变量。新建一个数据集并赋值的办法有许多，最简单的就是直接赋值，方法如下：
``` {r new-variable-generation}
mrate_new <- data.frame(mrate = 3.5)
````
或者更简单的，也可利用数据编辑框来手动输入：
``` {r new-variable-generation-edit}
mrate_new <- edit(as.data.frame(NULL))
````
之后再利用`predict()`就可得到所需的预测值了。
``` {r prediction-of-regression}
mrate_new <- data.frame(mrate = 3.5)
predict(RegModel,mrate_new)
````
#多元线性回归
当然现实中我们很少做一元的线性回归，解释变量往往是两个或者更多。这可以依旧用上面的`lm()`。如下面这个例子，研究的是出勤率和ACT测试成绩、学习成绩之间的关系。

(@ATTEND)  
在ATTEND.DTA这个数据集中，atndrte 是出勤率（采用百分比表示），ACT 为ACT测试的成绩，priGPA 是之前的学习平均分。我们需要估计如下的方程：

$atndrte=\beta_{0}+\beta_{1}priGPA+\beta_{2}ACT+u $

很显然，这里我们和上面的例子一样，代码和结果如下：

``` {r multiple-regression}

library(foreign)

Attend <- read.dta("data/attend.dta", convert.dates=TRUE, convert.factors=TRUE, missing.type=FALSE, convert.underscore=TRUE, warn.missing.labels=TRUE)

Reg2<-lm(atndrte~priGPA+ACT, data=Attend) 

summary(Reg2)
````

#保存和编辑代码

虽然我们有*RCommander*创造的图形界面，但是每次都指定参数也是件很烦的事儿。因此养成一个好习惯，保存好上次运行的代码，下次直接在R里面调用就可以了，有什么修改的也只需要稍作调整即可。*RCommander*里面本身就有`File -> Save Script`，可以把Script Window里面所有代码存储为\*\*\*.R的格式，从而方便下次调用。Script Window里面也是可以直接编辑代码的，删掉一些自己不想要的，调整个别的参数都是很方便的。

需要说明的是，.R文件就是告诉R应该怎么运行的文件，所以可以直接用文本编辑器软件打开并编辑。现在NotePad++, UltraEdit等等文本编辑软件都有支持R的插件，可以方便的把代码传送到R里面调用。R的基本界面中也是可以直接打开.R的脚本文件运行的。此外，推荐一个新兴的R编辑器——RStuidio，集成了R的各种窗口（<red>将在后续章节详述</red>）。

#寻求帮助

有了上述的例子，相信大家已经基本熟悉R了。那么遇到问题怎么办呢？比如`summary()`这个函数，对于不同的模型会有不同的用法，那么我们就需要去查看原始的帮助。在R中，最简单的办法就算再想要查看的命令前加一个“?”号。例如`?summary`之后就会蹦出来帮助页面了。这是查看某一包作者撰写原始文档的最快捷方式。此外也可以用两个连续的问号“??”来搜索所有相关的资料。

但是如果根本不知道有哪些命令，则需要去找包内原始的资料。可以直接在Google等搜索引擎里面搜寻，也可以查看R包自带的说明，亦可以参照各种书籍。总之方法很多，多多利用互联网是最好的办法。国内最佳的地方自然是[统计之都论坛的R版](http://cos.name/cn/ "统计之都论坛的R版")，里面有丰富的资料和资深的UseR为大家解惑。

@