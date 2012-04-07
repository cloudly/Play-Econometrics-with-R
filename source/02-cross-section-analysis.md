# 从截面数据分析说起
上面简单的说了一下多元回归，下面则是一些我们在回归分析中常用分析的实现。
## 参数检验
得到一个回归方程后，关心的第一件事就是系数和方程整体的显著性，分别由t检验和F检验实现。来看下面这个有关法学院的例子。
(@在LAWSCH85)
在LAWSCH85.DTA这个数据集中，法学院应届生薪水的中位数由下面的方程决定：
$log(salary)=\beta_{0}+\beta_{1}LAST+\beta_{2}GPA+\beta_{3}log(libvol)+\beta_{4}log(cost)+\beta_{5}rank+u $

其中LSAT 是班级里LSAT成绩中位数，GPA 是班级学习成绩的中位数，libvol 是法学院图书馆藏书卷数，cost 是在法学院的年消费额，rank 是法学院的排名（正序）。
接下来我们估计这个方程:
$LAW_Result <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank, data=LAW)$

很容易得到回归结果如下：
``` {r load-law-data}
LAW <- read.dta("data/LAWSCH85.DTA", convert.dates=TRUE, convert.factors=FALSE, missing.type=FALSE, convert.underscore=TRUE, warn.missing.labels=TRUE)
LAW_Result <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank, data=LAW)
summary(LAW_Result)
````
### t检验

在回归结果中已经报告了各变量的t统计值，从而可知：rank 的估计值很显著（通过0.1%显著性水平检验）。而GPA 和(log)libvol 则通过了1%显著性水平检验。

而变量LSAT 系数估计值不显著。
### F检验
考虑到新生入学的时候只有GPA 和LSAT 两个变量可以观测，所以接下来我们进行变量GPA 和LSAT 的联合检验即F检验。该检验属于线性假设检验，在*RCommander*下可以在`Models -> Hypothesis Tests ->Linear hypothesis`里面通过图形化界面完成。

![F检验图形化界面](2-2-1.jpg)
其中设置为“2”行，而后分别在LAST和GPA输入1，保持右侧为0。相当于检验假设
$H_{0}:\;\beta_{1}=\beta_{2}=0 $

可得到输出结果如下：
``` {r f-test}

library("car")

.Hypothesis <- matrix(c(0,1,0,0,0,0,0,0,1,0,0,0), 2, 6, byrow=TRUE) 

.RHS <- c(0,0) 

linear.hypothesis(LAW_Result, .Hypothesis, rhs=.RHS) 

remove(.Hypothesis, .RHS)
````


从上面结果可知，F=9.9517 且通过了0.1%显著性水平检验，即变量LSAT 和GPA 联合显著。

此外还可以分别加入clsize （班级容量）和faculty （教师规模）来进行回归，代码如下： [未完成]

由回归结果，这两个变量的系数均不显著，且方程F统计量有所下降（调整后的$R^{2}$ 变动不大），故不用加入到方程中关于模型变量选择的问题，将在后面另行论述，这里只做简单的分析。

## 置信区间

回归分析里还常用的一项分析就是得到某一显著性水平下的置信区间。[未完成]

## 虚拟变量
### 按性质分组

比较简单的例子就是已经含有分组变量的数据，比如变量gender 有两个值male, female, 那么我们只需把它们变成factor形式就可以了。如我们可以把法学院例子中的变量north进行变化 [footnote-factor][]：
[footnote-factor]:
其实这里不用这么麻烦也可以，因为north变量本身的赋值只有0和1，可以直接进行回归。在这里只是用这个例子来说明`factor()`函数的调用形式而已。      "footnote-factor"

``` {r factor-transform}

LAW$north_true <- factor(LAW$north, labels=c('others','north')) 

````

可以这样做的原因是：R在调用`lm()`函数的时候会自动把factor类型的变量作为虚拟变量进行回归。
### 按数量值分组

依旧采用法学院的例子。很明显在上面的分析中我们把各个学院排名直接当作一个可以“测距”的变量其实它只是一个排序而已，并不代表实质的差距。来使用了，这可能会引起一些争议。因此，我们可以采取另一种模式，即引入虚拟变量，把学校分为六组：top 10，11-25名，26-40名，41-60名，61-100名，100名开外。引入五个虚拟变量$top10$ , $r11\_25$ , $r26\_40$ , $r41\_60$ , $r61\_100$ 。

我想你不会手动的把所有的学校都赋一个虚拟变量值吧？在R里面，我们需要先通过`recode()`来依照分组创建一个新的factor形式的变量$rank\_f$，然后再进行回归。这样我们就不需要在原来的数据库里面新增加五个变量并赋逻辑值了。

``` {r group-by}

LAW$rank_f <- recode(LAW$rank, '1:10="top10"; 11:25="r11_25"; 26:40="r26_40";    41:60="r41_60";  61:100="r61_100"; else="r101_"; ', as.factor.result=TRUE)

LAW_Result2 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank_f, data=LAW)

summary(LAW_Result2)

````

此外，我们可以通过*RCommander*里面，在`Data->Recode Variables`的方框里逐行输入。
![Recode Varibles图形化界面](2-3-1.JPG)

### 交叉项

我不知道这样叫是不是足够确切，在微观计量里面我们会经常用到两个变量相乘的回归项，比如$female\cdot single $，即单身女士。相比而言这样的虚拟变量并不需要特别的处理，在回归方程里面直接写成相乘的形式即可。注意此时不需要再写female 和single 变量，`lm()`会默认加入这两个变量。例如，在法学院的例子中，我们可以对top10 和west 两个变量进行相乘回归（这里top10 变量来源于数据库本身自带的）。

``` {r intersections}

LAW_Result3 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + top10*west, data=LAW)

summary(LAW_Result3)

```` 

当然也可以使用factor变量和其他虚拟变量相乘进行回归，反馈的结果中包含所有的相乘项。
``` {r intersections-2}

LAW_Result4 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank_f*west, data=LAW)

LAW_Result4
````
### 指定参照组

当R处理factor形式的数据的时候，默认以数据中的第一个层次 (level) 作为参照组。比如上例中，我们想把top10 这一组作为参照组，那么则需要使用`relevel()`命令。

``` {r relevel}

attach(LAW)

rank_f2 <- relevel(rank_f, ref="top10")

LAW_Result5 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank_f2, data=LAW)

summary(LAW_Result5)
````
## 异方差检验

有件很没办法的事儿，那就是要想让OLS回归出来的结果最佳，必须要符合那五条经典假设（尤其是小样本下）。但是事实中的数据那里会那么完美呢？首当其冲的问题就是异方差。

异方差检验方法很多，这里给出两种常用的：BP检验 (Breusch-Pagan Test)、怀特检验 (White test for heteroskedasticity)。

下面给出一个关于房价的例子。
(@Hprice1)
在Hprice1.dta这个数据集中，有price （房价，按套计算）、lotsize （地皮面积要知道人家住的都是小别墅啊，自然要先有地、后建房，卖房子也都是一套一套的卖。）、sqrft （房屋面积）、bdrms （卧室数量）。接下来我们估计这个方程：
$\hat{price}=\hat{\beta_{0}}+\hat{\beta_{1}}lotsize+\hat{\beta_{2}}sqrft+\hat{\beta_{3}}bdrms $

使用OLS估计结果如下：

``` {r house-price-ols}

HPrice <- read.dta("data/hprice1.dta", convert.dates=TRUE, convert.factors=TRUE, missing.type=FALSE,    convert.underscore=TRUE, warn.missing.labels=TRUE)

Hprice_Result <- lm(price~bdrms+lotsize+sqrft, data=HPrice)

Hprice_Result
````
### BP检验 (Breusch-Pagan Test)
下面我们进行BP检验来测定是否有异方差。进行BP检验需要加载包*lmtest*，而后者需要加载包*zoo*。调用BP检验最简单的方法就是直接写回归结果变量。更多参数关于该命令各种参数设置请使用`?bptest`来查看帮助文档。可以通过*RCommander*里面的图形化界面设定，位于`Models > Numberical diagnostics > Breusch-Pagan Test for heteroskedasticity`。

``` {r bp-test}

library("lmtest")

bptest(Hprice_Result)

````
由结果来看，存在异方差。由于对数形式是消除异方差（尤其针对价格数据）的常用方法，因此我们再对对数形式进行回归:
$\hat{log(price)}=\hat{\beta_{0}}+\hat{\beta_{1}}log(lotsize)+\hat{\beta_{2}}log(sqrft)+\hat{\beta_{3}}bdrms$
得到回归结果如下：

``` {r log-regression}

Hprice_Result2 <- lm(log(price)~bdrms+log(lotsize)+log(sqrft), data=HPrice)

Hprice_Result2

````

此时再进行异方差检验。

``` {r log-regression-bp-test}

bptest(Hprice_Result2)

````
因此可以接受原假设，已经不存在异方差。

此外还有一个bptest()非常接近的ncv.test()，需加载car包。我们进行一下对比。

``` {r log-regression-bp-test-2}

ncv.test(Hprice_Result2)

bptest(Hprice_Result2,studentize=FALSE,varformula = ~fitted.values(Hprice_Result2), data=HPrice)
````

可以看到`ncv.test()`相当于把`bptest()`里面参数studentize设为FLASE，且进行固定值的检验。事实上，`bptest()`默认该项为TRUE，在TRUE时会采用Koenker (1981)的学生氏检验算法，也是目前最广为接受的算法。

### 怀特检验 (White test for heteroskedasticity)
还是上面这个例子，我们改用怀特检验。其实，我们可以把怀特检验看作广义上的BP检验的一种特殊形式，因此可以通过在`bptest()`里面赋予更多的参数来实现，即加入各个变量平方和交叉相乘的项。

比如回归为`fm <- lm(y ~ x + z, data = foo)`，那么则应写成`bptest(fm, ~ x * z + I(x^2) + I(z^2), data = foo)` 。因为这里写出来较麻烦，所以不再举例。

另，也可以通过*sandwich*这个专门对付“三明治”的包来实现怀特检验。
## 稳健标准差
当存在异方差的时候，我们可以采用稳健的标准差来替代原有的异方差矩阵。在R中，可以利用*sandwich*包的`vcovHC()`函数实现。依旧采用上面房价的例子。

``` {r robust-sd}

library("sandwich")

vcovHC(Hprice_Result)

````

`vcovHC()`函数可以选择各种形式，在后面附加type = 即可。可选形式有"HC3", "const", "HC", "HC0", "HC1", "HC2", "HC4"，分别对应不同的异方差假设形式。如该函数的文档中所述，const对应$\sigma^{2}(X'X)^{-1} $，HC（或HC0）对应$(X'X)^{-1}X'\Omega X(X'X)^{-1}$ ，更多解释请参照`?vcovHC`。

之后我们就可以采用该异方差矩阵进行参数检验，如t检验。这里调用*lmtest*包内另一个非常有用的函数`coeftest()`。

``` {r coef-test}

coeftest(Hprice_Result, vcov = vcovHC)

````

此外，对于含有自回归异方差的情形，可以采用`vcovHAC()`函数。更多相关用法后面章节中详述。这两个函数均可以附加到参数检验`coeftest()`或者`waldtest()`一起使用。

## 加权最小二乘估计 (WLS)
### 扰动项形式已知
有些情况下，我们可以写出加权的形式，比如扰动项服从$Var(u_{i}|inc)=\sigma^{2}inc$ ，那么可以直接在`lm()`函数里附加一项weight来实现。
(@smoke)
下面是一个烟草需求的例子。在SMOKE.rda中有如下几个变量：每天吸烟的数量 (cigs )、年收入 (income )、该州烟的价格 (cigpric )、受访者年龄 (age )、受教育程度 (educ )、该州有无饭店内吸烟禁令 (restaurn )。而后我们需要研究决定烟草需求的因素，即cigs 为被解释变量，其他为解释变量。

* 使用FGLS的第一步是进行OLS估计，得到残差项的估计值$\hat{u}$ 。对于价格数据，我们取其对数形式。
	
	``` {r fgls-step1}
	load("data/SMOKE.rda")
	SMOKE_OLS <- lm(cigs~log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE)
	````
	
* 第二步则是使用$log(\hat{u}^{2})$ 对其余变量进行回归。对于线性回归`lm()`所得结果，`residuals()`存储的是残差项。
	
	``` {r fgls-step2}
	SMOKE_auxreg <- lm(log(residuals(SMOKE_OLS)^2)~log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE)
	````
	
* 第三步则是进行最后的加权回归。
	
	``` {r fgls-step3}
	SMOKE_FGLS <- lm(cigs~log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE, weights=1/exp(fitted(SMOKE_auxreg))) 
	summary(SMOKE_FGLS)
	````
	
* 如果需要的话，可以进行多次的FGLS估计。这里可以使用R的循环方式while。
	
	``` {r fgls-loop}

	gamma2i <- coef(SMOKE_auxreg)[2]

	gamma2 <- 0

	while(abs((gamma2i - gamma2)/gamma2) > 1e-7){ 

	 gamma2 <- gamma2i

	 SMOKE_FGLSi<- lm(cigs~log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE, weights = 1/exp(fitted(SMOKE_auxreg))) 

	 SMOKE_auxreg <- lm(log(residuals(SMOKE_FGLSi)^2)~ log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE)

	 gamma2i <- coef(SMOKE_auxreg)[2]

	}

	SMOKE_FGLS2 <- lm(cigs~log(income)+log(cigpric)+educ+age+I(age^2)+restaurn, data=SMOKE, weights=1/exp(fitted(SMOKE_auxreg))) 

	summary(SMOKE_FGLS2)

	````
	
在其中我们使用当`log(income)`的系数估计值收敛$(<10^{-7} )$当作循环的条件。
## 广义线性估计 (GLM)
通常被解释变量并不一定服从正态分布，因而产生了Probit, Logit等模型。在R中，在采取广义线性估计法（Generalized Linear Models, GLM）来估计的时候，我们可以调用*glm*包。

(@MORZ)
这里我们看一个关于已婚妇女劳动参与率的例子（MROZ.dra）。当然，一个人工不工作是一个二值变量 (inlf )，我们设1为工作，0表示不工作。这里我们不妨认为其劳动参与行为主要取决于其他的收入来源——丈夫的工资 (nwifeinc )，受教育年限 (educ )，工作经验 (exper )，年龄 (age )，小于六岁的孩子数 (kidslt6 )，六到十八岁的孩子数 (kidsge6 )。
首先我们使用OLS来估计线性概率模型（Linear Probability Model，LPM）。

``` {r glm-morz}
load("data/MROZ.rda")
MROZ_LPM<- lm(inlf~nwifeinc+educ+exper+I(exper^2)+age+kidslt6+kidsge6,data=MROZ) 
MROZ_LPM
````

### 最大似然估计 (Maximum Likelihood Estimation, MLE)
对于非线性的估计最常用的方法就是最大似然估计法（MLE）。在stats4包中有对应的函数mle()可进行相应的估计。但是由于在计量中单独用到最大似然估计的时候很少，大多数情况下都是用于估计特定模型（如GLM），有着特定的函数，所以在这里不再作特别介绍。
### Probit和Logit模型
当然使用OLS来估计概率模型并不理想（线性模型需假设解释变量具有不变的边际效应），因此我们再分别使用非线性的Probit和Logit模型来估计上例。在使用`glm()`的时候，只需要指定回归的类型(family)，其他的用法和`lm()`类似。此外可以使用`logLik()`来获取Log-Likelihood统计量。

``` {r probit-morz}

MROZ_Probit <- glm(inlf ~ nwifeinc +educ +exper +I(exper ^2) +age +kidsge6 +kidslt6, family=binomial(probit), data=MROZ)

MROZ_Probit

logLik(MROZ_Probit)

MROZ_Logit <- glm(inlf ~ nwifeinc +educ +exper +I(exper ^2) +age +kidsge6 +kidslt6, family=binomial(probit), data=MROZ)

MROZ_Logit

logLik(MROZ_Logit)

````

### Tobit模型
依旧是上例，我们观察到每年的工作时间变化很大：对于不工作的来说，该值为0。此时如果画散点图那么必有近一半的点（325人）聚集在数轴上。因此，年工作时间 (hours )呈现很强烈的“边角解 (coner solution)”特性，对于这种情况我们可以采取Tobit模型。Tobit模型也是被审查的回归（Censored Regression）的一个特例。

其实Tobit很类似于生存分析里面的情况，因此可以调用*survival*包的`survreg()`函数。这里我们有个更简单的办法，*AER*包的作者进行了一个简单的转换，在包内自带了一个`tobit()`函数，调用更方便。这里我们将结果与OLS回归的进行对比。

``` {r tobit}

library("AER")

MROZ_Tobit <- tobit(hours~nwifeinc+educ+exper+I(exper^2)+age+kidslt6+kidsge6,data=MROZ)

MROZ_Tobit

MROZ_OLS<- lm(hours~nwifeinc+educ+exper+I(exper^2)+age+kidslt6+kidsge6,data=MROZ)

MROZ_OLS
````

<red>使用加权最小二乘法进行Probit估计

to be finished</red>
### 有序的probit/logit模型（Ordered Logit/Probit）
对于有序的Logit/Probit模型，可以调用*MASS*包中的`polr()`函数。比如研究数据集BankWages里面男性的有无工作（job ）和教育程度（education ）、少数民族（minority ）之间的关系。

``` {r ordered-probit}

library("MASS") 

data(BankWages) 

bank_polr <- polr(job ~ education + minority, data = BankWages, subset = gender == "male", Hess = TRUE) 

coeftest(bank_polr)
````

## 计数模型 (Count Model)
### 泊松回归 (Poisson Regression Model)

对于呈现$\{0,1,2,...\}$这样特性的数据，我们采取计数模型。而计数模型的实质是利用泊松回归。泊松回归也是上面所说的GLM的一种。下面我们给出一个关于犯罪率的例子。
(@CRIME1)
在CRIME1.rda这个数据集中，我们把每个人被逮捕的次数 (narr86)作为被解释变量。对于其中大多数人来说，该变量值为0；剩下的也大都在$1\sim5$ 之间，因此泊松回归会比较合适。
一般说来我们直接用泊松回归就可以，在不假设整体都服从泊松分布的时候，我们采用的实质是准最大似然估计（Quasi-maximum likelihood estimation, QMLE）。

``` {r Poisson-regression}

load("data/CRIME1.rda")

CRIME1_poisson<- glm(narr86 ~ pcnv+avgsen +tottime +ptime86 +qemp86 +inc86 +black +hispan +born60, family=poisson(log),    data=CRIME1)

CRIME1_poisson

CRIME1_quasipoisson <- glm(narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + inc86 + black + hispan + born60,    family=quasipoisson(log), data=CRIME1)

CRIME1_quasipoisson 
````

### 过度离散数据检验
当数据呈现过度离散特性的时候，就违背了泊松回归的假设（方差等于期望），所以在进行泊松回归前需要进行一下离散度检验。*AER*包中提供了一个函数`dispersiontest()`可以用来进行该检验。
(@RecreationDemand)
在RecreationDemand这个数据集中，涵盖了1980年德克萨斯州划船度假村的相关数据。我们希望用调查所得的（主观排名）设施质量（变量quality）、被调查者是否参加了滑水项目（变量ski）、家庭收入（income）、被调查者是否为游览该湖付费（userfee）、和三个表示机会成本的变量（costC , costS , costH）来解释trips 变量。
首先我们需要进行泊松回归。

``` {r over-dispersion-test1}

library(AER) 

data("RecreationDemand") 

rd_pois <- glm(trips ~ ., data = RecreationDemand, family = poisson) 
````

而后对回归模型rd_pois进行离散度检验。在调用`dispersiontest()`函数之时，可以指定参数trafo 的值，从而只对$\alpha$进行估计。具体解释请参见函数说明。

``` {r over-dispersion-test2}

dispersiontest(rd_pois) 

dispersiontest(rd_pois, trafo = 2)
````

### 负二项回归模型（negative binomial regression）
在数据呈现过度离散的情况下，我们可以采取负二项回归模型。*MASS*包中提供了相关函数`negative.binomial()`和`glm.nb()`。前者用于参数$\theta$已知，后者用于该参数未知。依旧采用上面的例子。这里参数$\theta$ 未知，所以调用`glm.nb()`，而后进行参数检验。

``` {r negative-bio-regression}

library("MASS")  

rd_nb <- glm.nb(trips ~ ., data = RecreationDemand)  

coeftest(rd_nb)
````

当然，我们还可以再调用logLik()来获取Log-Likelihood统计量。

``` {r likelihood-stat}
logLik(rd_nb)
````
### 零膨胀泊松模型 (Zero-inflated Poisson Model, ZIP)
对于计数模型来说，当数据集中的0观测值众多，所占比例超出泊松回归允许的范围时，回归结果就不是那么令人满意。此时需采用ZIP（Zero-inflated Poisson Model ）模型。在R中，*pscl*包提供了一个函数`zeroinfl()`，用来实现ZIP泊松回归。比如例2.6中，大多数人($>70\%$ )并未被逮捕过。

所以我们不妨采用ZIP模型（负二项回归形式，ZINB）。
``` {r zinb}

library("pscl")

CRIME1_zip <- zeroinfl(narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + inc86 + black + hispan + born60|inc86, data = CRIME1, dist = "negbin")

summary(CRIME1_zip)
````

## 选择性样本问题
### Heckit模型

当样本不能保证随机性的时候，即面对样本自选择问题（最常见的为偶然断尾）之时，我们一般采用Heckit模型。回到那个已婚妇女参加工作的例子（2.5）<red>如何cross-reference?</red>。现在我们研究影响参与工作的妇女的工资问题。这里需要加载*sampleSelection*包。

``` {r heckit}

library(sampleSelection)
MROZ_Heckit <- heckit( inlf ~ nwifeinc + educ + exper + I( exper^2 ) + age + kidslt6+kidsge6, log( wage ) ~ educ + exper + I( exper^2 ), data=MROZ, method = "2step" )
summary(MROZ_Heckit)

````

Heckit模型实际上就是先进行一个probit回归，而后再利用前面的得到的估计值加上解释变量对被解释变量回归。
## 联立方程模型（Simultaneous Equations）
由于经济系统内的各变量往往是相互联系的，所以在出现联立方程的情况下OLS估计会因为内生性的问题而产生偏差，此时需要借助两阶段最小二乘法（2SLS）来估计方程（组）。

### 两阶段最小二乘法(2SLS)和工具变量法

对于应用在结构单一的方程上的两阶段最小二乘法，我们只需要调用*sem*包中的`tsls()`函数。

回到例2.5，我们想研究教育的回报率。这个时候需要估计工资log(wage)和受教育程度（educ）、经验（exper）之间的关系。但是我们怀疑受教育程度educ 是内生变量，但他父母的受教育程度$motheduc,\;\; fatheduc$ 则为外生变量，所以可以作为educ 的工具变量。

``` {r 2sls}

library(sem)

MROZ_2SLS <- tsls(lwage~educ+exper+I(exper^2),~exper+I(exper^2)+motheduc+fatheduc, data=MROZ) 

summary(MROZ_2SLS)
````

### 联立方程模型估计：似不相关回归法（Seemingly Unrelated Regression）
对于联立方程模型，终极的解决方案莫过于*systemfit*包，它提供了似不相关回归及其变形、两阶段最小二乘法和工具变量等多种估计方法。这里我们看一个似不相关回归法来估计联立方程模型的例子。

(@Grunfeld)
我们现在来看投资和企业价值及资本存量之间的关系。在数据集Grunfeld之中，invest 代表总投资值，value 代表企业的价值，capital 代表企业的资本存量，以上数据都是剔除了通胀因素之后的真实值。
为了简单起见，我们只考虑两个厂商Chrysler和IBM，因此首先要使用`subset()`函数来从原数据集中找出一个子集。厂商之间可能是有联系的，所以需要分别设定变量，这里我们就可以用到factor类型的数据。这里最方便的就是利用面板数据的类型，调用*plm*包里面的`plm.data()`函数。

``` {r sur}

data(Grunfeld, package="AER") 

library("systemfit") 

library("plm") 

gr2 <- subset(Grunfeld, firm %in% c("Chrysler", "IBM")) 

pgr2 <- plm.data(gr2, c("firm", "year")) 

gr_sur <- systemfit(invest ~ value + capital, method = "SUR", data = pgr2) 

summary(gr_sur, residCov = FALSE, equations = FALSE)

````

从结果中我们可以得到似不相关回归的估计值。这里也可以调整一下`summary()`的参数来看更详细的回归结果。

此外，也可以加参数2SLS来调用`systemfit()`来进行两阶段最小二乘估计，具体方法不再赘述，请参见函数说明。

## 代理变量 (Proxy Variables)
其实代理变量并没有多少要特别说明的地方，只需要选择合适的变量代替不能观测的变量进行相应的回归分析就好。但有一种常用的而且很特别的代理变量，就是被解释变量的滞后项。这里简单的以一个例子说明。

(@CRIME)
这个例子是有关城市中犯罪率的。在CRIME.rda这个数据集中，含有1987年46个城市的犯罪率数据，可见是个标准的截面数据分析。只是除了犯罪率 (crmrte)，可用的变量只有失业率 (unem) 和人均用于维护法律权益的支出 (lawexpc) 。这样就有一些难以观测的变量导致回归的结果不甚理想。因此，我们可以采取1982年各个城市的犯罪率做一个代理变量，来但因那些难以观测的变量。方程如下：
$log(crmrte_{87})=\beta_{0}+\beta_{1}unem+\beta_{2}lawexpc+\beta_{3}log(crmrte_{82})$ 但是在这个数据集中，每个观测值均有犯罪率和年份两个属性，也就是为面板数据的形式。好在对于87年的数据，已经给出对应82年的犯罪率lcrmrte.1 ，故选取87年数据直接回归即可。

``` {r proxy}

load("data/CRIME2.rda")

OLS87<- lm(lcrmrte ~ lcrmrt.1 +llawexpc + unem, data=CRIME2,    subset=(year==87))

summary(OLS87)

````

对于更多时间序列问题和面板数据问题将在后面几章中详细阐述。