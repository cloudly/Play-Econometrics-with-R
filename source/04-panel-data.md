面板数据分析
============

这一章开始我们着重关注面板数据。面板数据在当代计量经济学尤其是应用计量经济学领域的重要性不必多说，然而正是由于它在数据结构上拥有了时间和个体二重维度，所以其估计方法也较截面数据更为复杂。但从另外一个层面来说，由于其时间维度的引入使得很多截面数据下难以估计的量可以实现一致估计，所以其应用的现实意义颇大。此章主要围绕**plm**包展开，该包提供了大量的成熟的面板数据分析工具。

一阶差分法（First-Differenced）
-----------------------------

在对付面板数据的时候，一阶差分法有时是一种简便易行且有效的方法。如 \citet{wooldridge_introductory_2009} 第14章所指出的，

> 在只有两期数据的情况下，一阶差分法（FD）和固定效应模型（FE）等价；当多于两期的时候，两者在满足假定的条件下都是小样本下无偏且大样本下一致的。然而在误差项$u_{it}$序列不相关时，FE比FD更为有效；当$u_{it}$为随机游走（Random Walk）时，FD显然更有效；当$\Delta u_{it}$呈现序列负相关特性时，FE更有效。
> 然而在长面板（即时间维度长而观测个体少）的情况下，FE更为敏感，故FD更有优势。更需值得注意的是，FD和FE都对解释变量是否服从经典假设很敏感，但是在解释变量和残差项不相关的情况下，即使其他假设被违反，FE估计量比FD的偏差会小些（除非时间$T=2$）。”

在R中，使用**pml**包中的`plm()`函数就可以完成该估计，由于该函数同时可同于估计多种面板数据模型（包括固定效应模型、混合模型pooled
model、随机效应模型、一阶差分法、组间估计法between
model等），所以用法在下面的例子中一并给出。

固定效应模型（Fixed Effects Model）和随机效应模型（Random Effects Model）
---------------------------------------------------------------------

由于固定效应模型允许不可观测效应与解释变量之间存在相关性，而随机效应模型则不可以，所以FE被广泛认为在其他条件相同下更有说服力。不过随机效应模型在特定情况下也需得到应有，比如当关键的解释变量不随时间变化的时候，我们就无法用FE去估计它的效应。实际上在更多的时候，我们会两种估计都进行，然后进行进一步的检验（如Hausman检验，见后）。

(@WAGEPAN)
在劳动经济学中，我们经常关注各种因素对于工资的影响。WAGEPAN.rda这个数据集中，有对545个劳动者1980到1987年间从事工作的情况调查数据。其中一些变量会随着时间而改变，比如工作经验($exper$)、婚姻状况($married$)和工会状况($union$)。还有一些变量不会改变，比如种族($hispan$和$black$)、教育($educ$)。

在下面我们依次进行混合回归、一阶差分法、固定效应、随机效应来估计该例。然而在进行分析之前，我们需要先调用`plm.data()`命令来将现有数据集中的数据转换为面板数据模式。

``` {r label='panel-data'}
load("data/WAGEPAN.rdata")
library("plm")
WAGE_data <- plm.data(WAGEPAN, index = c("nr", "year"))
#混合OLS
WAGE_PLM_Pooled <- plm(lwage~educ+black+hisp+exper+I(exper^2)+married+union, data=WAGE_data, model="pooling")
summary(WAGE_PLM_Pooled)
#一阶差分
WAGE_PLM_FD <-plm(lwage~educ+black+hisp+exper+I(exper^2)+married+union, data=WAGE_data, model="fd")
summary(WAGE_PLM_FD)
#固定效应模型
WAGE_PLM_fixed <- plm(lwage~educ+black+hisp+exper+I(exper^2)+married+union, data=WAGE_data, model="within")
summary(WAGE_PLM_fixed)
#随机效应模型
WAGE_PLM_random <- plm(lwage~educ+black+hisp+exper+I(exper^2)+married+union, data=WAGE_data, model="random")
summary(WAGE_PLM_random)
#组内模型
WAGE_PLM_between <- plm(lwage~educ+black+hisp+exper+I(exper^2)+married+union, data=WAGE_data, model="between")
````

一般说来，OLS估计（混合回归）不如其他方法有效。而在上例中我们可以看出，为了估计不随时间变化的量（种族、受教育程度），我们必须用到随机效应模型。然而对于随时间变化的量（经验等），固定效应模型或一阶差分法显然更为有效。此外，对于随机效应模型，还可以使用`fixef()`函数来提取其中的固定效应。

实际上，`plm()`函数不仅仅支持这些基本的模型，而且对于每种模型还提供了不同参数以调整具体方法，如双向模型（two-way model）和时间效应等。例如，在使用双向模型的时候，只需在调用函数`plm()`中加一个参数`effect = "twoways"`即可，但此时如果使用`fixef()`函数来提取其中的固定效应则需写成`` fixef(YOUR_MODLE, effect = "time") ``。具体说来，随机效应模型支持增加参数`random.method`，可选择 `amemiya、swar、walhus、nerlove`，而对应的误差分量的变化可以直接调用`ercomp()`函数指定`method`和`effect`来估计。

非平衡面板（Unbalanced panels）
-----------------------------

如果在不同时期的个体是不同的（增加或减少），那么该面板数据就成为了非平衡面板。目前**plm**包中对于非平衡面板还不能进行双向效应估计，能提供的误差分量估计法也只有一种。Baltagi(2001)重新估计了房地产市场的特徽价格方程（hedonic housing prices function），代码如下：

``` {r label='panel-data-unbalanced-panels'}
data("Hedonic", package = "plm")
Hed <- plm(mv~crim + zn + indus + chas + nox + rm + age + dis + rad + tax + ptratio + blacks + lstat, Hedonic, model = "random", index = "townid")
summary(Hed)
````

面板数据相关检验
----------------

### 可混合性检验（Tests of poolability）

在进行面板数据分析前，一般会考虑到一个问题：对于每个个体，解释变量系数都是一样的吗？换言之，个体效应是否存在？当然，一般说来个体效应都会存在的，否则后面的分析就没有意义了，直接采用混合模型就好。可混合性检验就是用来检验个体效应的。我们这里需要调用`pooltest()`函数进行检验。回到例2.8，继续看公司的投资与真实价值和资本存量的关系。最简单的调用方法如下：

``` {r label='Tests-of-poolability'}
data(Grunfeld, package="plm")
pooltest(inv~value + capital, data = Grunfeld, model = "within")
````

其实，该函数需要的由两部分组成，一为通过`plm()`得到的模型，二为通过`pvcm()`得到的固定效应模型。因此，上面的代码实则等价于：
```
znp <- pvcm(inv~value + capital, data = Grunfeld, model = "within") 
zplm <- plm(inv~value + capital, data = Grunfeld)
pooltest(zplm, znp) 
```

实际上，这里的`pvcm()`函数进行的正是变系数回归，而可混合性检验的实质也就是对这两种模型进行比较的F检验。

### 个体效应或时间效应检验（Tests for individual and time effects）

用拉格朗格乘子法可以检验相对于混合模型的个体或时间效应。这里可以调用`plmtest()`函数。调用方式有两种，其一可以先做一个混合回归再进行检验（如双向效应）：

``` {r label='effects-test'}
g_pooled <- plm(inv~value + capital, data = Grunfeld, model = "pooling")
plmtest(g_pooled, effect = "twoways", type = "ghm")
````

此外也可以直接在调用检验函数的同时指定回归模型，如：

``` {r label='effects-test2'}
plmtest(inv~value + capital, data = Grunfeld, effect = "twoways", type = "ghm")
````

对于该函数来说，还可以附加参数`type`，可选`bp, honda, kw, ghm`之一。至于必须指明的`effect`参数，可选`individual, time, twoways`之一。

此外，还可以做各种效应的F检验（基于混合模型与固定效应模型之间的比较）。依旧用例2.8：

``` {r label='f-test'}
g_fixed_twoways <- plm(inv~value + capital, data = Grunfeld, effect = "twoways", model = "within")
pFtest(g_fixed_twoways, g_pooled)
````

当然，`pFtest()`函数也提供了另外一种直接的调用形式，如`` pFtest(inv value + capital, data = Grunfeld, effect = "twoways") ``。

### Hausman检验

为了判断到底是采用固定效应还是随机效应模型，我们一般采取经典的Hausman检验，这可以通过调用`phtest()`函数实现。注：这里我们只展示Hausman检验的用法，至于实际应用中该检验结果是否足以支撑模型选择，则需另作学术讨论。

``` {r label='Hausman-test'}
gw <- plm(inv~value + capital, data = Grunfeld, model = "within")
gr <- plm(inv~value + capital, data = Grunfeld, model = "random")
phtest(gw, gr)
````

同理，对于例4.1，我们也可以采用该检验来判断应该使用哪个模型。因为我们上面已经分别作了固定效应和随机效应的回归，所以此时直接调用两个回归模型结果就可以。

``` {r label='Hausman-test2'}
phtest(WAGE_PLM_fixed, WAGE_PLM_random)
````

注意Hasuman检验的原假设是“随机效应模型优于固定效应模型”，所以对于例2.8，我们可以接受原假设，采用随机效应模型；对于例4.1，则应考虑固定效应模型。

变系数模型（Variable coeffcients model）
--------------------------------------

一般说来在固定或随机效应模型中，系数都被假设为不变的而截距项是变化的。下面我们可以考虑系数也变化的情形。依旧以2.8（Grunfeld）为例，欲使用变系数模型我们只需要调用`pvcm()`函数即可。

``` {r label='Variable-coeffcients-model'}
g_varw <- pvcm(inv~value + capital, data = Grunfeld, model ="within")
g_varr <- pvcm(inv~value + capital, data = Grunfeld, model ="random")
summary(g_varr)
````

面板工具变量法
--------------

### Hausman-Taylor估计法

前面说到，使用固定效应模型的时候无法估计不随时间变化的量的影响。在没有理想的外部工具变量的情况下，我们可以采用Hausman-Taylor估计法来进行工具变量的运用。但是该方法有一个前提假设，就是有部分变量为外生，和残差项不相关；另一部分变量为内生，和残差项相关，在具体研究中需要证明这一点才能保证估计的一致性。

调用该方法的函数为`pht()`。我们下面再来看一个工资的问题，这个时候使用Wages数据集，其包含了1976到1982年美国595个个体的数据。

``` {r label='hausman-taylor'}
data("Wages", package = "plm")
ht <- pht(lwage~wks + south + smsa + married + exp + I(exp2) + bluecol + ind + union + sex + black + ed sex + black + bluecol + south + smsa + ind, data = Wages, index = 595)
summary(ht)
````

### 外部工具变量

当存在一些外部的工具变量满足工具变量的要求的时候，我们可以直接使用它们代替原有变量进行回归，只是需要在调用`plm()`函数的时候用
符号指定就好。

我们依旧来看那个犯罪率的问题。这里我们扩展到整个面板数据，调用**plm**包中的Crime数据集，里面包含了1981-1987年间美国90个郡的数据。我们这里依旧想研究影响犯罪率的因素。

因为变量比较多，所以不一一解释其含义，可以直接参照包中的说明。下面我们希望以$log(taxpc)$和$log(mix)$作为工具变量，分别代替$log(prbarr)$和$log(polpc)$，故只需要在原始回归方程中加入` . - log(prbarr) - log(polpc) + log(taxpc) + log(mix)`即可。

``` {r label='iv-panel-data'}
data("Crime", package = "plm")
cr <- plm(log(crmrte)~log(prbarr) + log(polpc) + log(prbconv) + log(prbpris) + log(avgsen) + log(density) + log(wcon) + log(wtuc) + log(wtrd) + log(wfir) + log(wser) + log(wmfg) + log(wfed) + log(wsta) + log(wloc) + log(pctymle) + log(pctmin) + region + smsa + factor(year) . - log(prbarr) - log(polpc) + log(taxpc) + log(mix), data = Crime, model = "random")
summary(cr)
````

序列相关性检验（Tests of serial correlation）
-------------------------------------------

横截面的依赖性检验（Tests for cross-sectional dependence）
--------------------------------------------------------

动态面板分析：广义矩估计（GMM）
----------------------------

当回归方程中有被解释变量的滞后值作为解释变量的时候，便形成了动态面板数据。由于滞后项的存在，原来的估计成为了不一致的估计，即“动态面板偏差”。对于此种情况的出现，分别有差分GMM（difference GMM）和系统GMM（system GMM）可以用来解决。R中对应的函数为`pgmm()`。

在EmplUK数据集中，涵盖了1976到1984年间英国工厂的就业和工资情况的数据，且该面板为非平衡面板。我们这里关系就业情况。由于上一期的就业会很直接的影响当期就业水平，所以回归方程中包含了就业作为解释变量，该问题成为了动态面板分析。

在这里我们首先用差分GMM来估计，选择双向效应和两步法。

``` {r label='difference-gmm'}
data("EmplUK", package = "plm")
emp.gmm <- pgmm(log(emp)~lag(log(emp), 1:2) + lag(log(wage), + 0:1) + log(capital) + lag(log(output), 0:1)+lag(log(emp), 2:99), data=EmplUK, effect = "twoways", model = "twosteps")
summary(emp.gmm)
````

当然我们也可以用系统GMM来估计，只需要加上一个参数`` transformation = "ld" ``即可。最后可以在`summary()`中加入`robust = TRUE`来查看模型的稳健性。

``` {r label='system-gmm'}
z2 <- pgmm(log(emp)~lag(log(emp), 1) + lag(log(wage), 0:1) + lag(log(capital), 0:1)+lag(log(emp), 2:99) + lag(log(wage), 2:99) + lag(log(capital), 2:99), data = EmplUK, effect = "twoways", model = "onestep", transformation = "ld")
summary(z2, robust = TRUE)
````

面板数据自回归模型
------------------

一般广义最小二乘法（General FGLS models）
---------------------------------------

`pggls()`

面板单位根检验（第一代）
----------------------

### LLC 检验 

### IPS 检验 

### Breitung 检验

### Choi / ADF-Fisher / PP-Fisher检验

### Hadri 检验 

协方差矩阵的稳健估计
--------------------

面板数据协整
------------
