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



```r
LAW <- read.dta("data/LAWSCH85.DTA")
```



```
## Warning message: cannot read factor labels from Stata 5 files
```



```r
LAW_Result <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
    rank, data = LAW)
summary(LAW_Result)
```



```
## 
## Call:
## lm(formula = log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
##     rank, data = LAW)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.30136 -0.08498 -0.00436  0.07794  0.28861 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  8.343226   0.532519   15.67   <2e-16 ***
## LSAT         0.004696   0.004010    1.17   0.2437    
## GPA          0.247524   0.090037    2.75   0.0068 ** 
## log(libvol)  0.094993   0.033254    2.86   0.0050 ** 
## log(cost)    0.037554   0.032106    1.17   0.2443    
## rank        -0.003325   0.000348   -9.54   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.112 on 130 degrees of freedom
##   (20 observations deleted due to missingness)
## Multiple R-squared: 0.842,	Adjusted R-squared: 0.836 
## F-statistic:  138 on 5 and 130 DF,  p-value: <2e-16 
## 
```




### t检验

在回归结果中已经报告了各变量的t统计值，从而可知：rank 的估计值很显著（通过0.1%显著性水平检验）。而GPA 和(log)libvol 则通过了1%显著性水平检验。
而变量LSAT 系数估计值不显著。

### F检验

考虑到新生入学的时候只有GPA 和LSAT 两个变量可以观测，所以接下来我们进行变量GPA 和LSAT 的联合检验即F检验。该检验属于线性假设检验，在*RCommander*下可以在`Models -> Hypothesis Tests ->Linear hypothesis`里面通过图形化界面完成。

![F检验图形化界面](imgs/f_test.JPG)
其中设置为“2”行，而后分别在LAST和GPA输入1，保持右侧为0。相当于检验假设

$H_{0}:\;\beta_{1}=\beta_{2}=0$

可得到输出结果如下：



```r
library("car")
.Hypothesis <- matrix(c(0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), 2, 6, 
    byrow = TRUE)
.RHS <- c(0, 0)
linearHypothesis(LAW_Result, .Hypothesis, rhs = .RHS)
```



```
## Linear hypothesis test
## 
## Hypothesis:
## LSAT = 0
## GPA = 0
## 
## Model 1: restricted model
## Model 2: log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + rank
## 
##   Res.Df  RSS Df Sum of Sq    F  Pr(>F)    
## 1    132 1.89                              
## 2    130 1.64  2     0.252 9.95 9.5e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
```



```r
remove(.Hypothesis, .RHS)
```




从上面结果可知，F=9.9517 且通过了0.1%显著性水平检验，即变量LSAT 和GPA 联合显著。
此外还可以分别加入clsize （班级容量）和faculty （教师规模）来进行回归，代码如下： [未完成]

由回归结果，这两个变量的系数均不显著，且方程F统计量有所下降（调整后的$R^{2}$ 变动不大），故不用加入到方程中关于模型变量选择的问题，将在后面另行论述，这里只做简单的分析。

## 置信区间

回归分析里还常用的一项分析就是得到某一显著性水平下的置信区间。[未完成]

## 虚拟变量

### 按性质分组

比较简单的例子就是已经含有分组变量的数据，比如变量gender 有两个值male, female, 那么我们只需把它们变成factor形式就可以了。如我们可以把法学院例子中的变量north进行变化 [footnote-factor][]：
[footnote-factor]: 其实这里不用这么麻烦也可以，因为north变量本身的赋值只有0和1，可以直接进行回归。在这里只是用这个例子来说明`factor()`函数的调用形式而已。      "footnote-factor"



```r
LAW$north_true <- factor(LAW$north, labels = c("others", "north"))
```




可以这样做的原因是：R在调用`lm()`函数的时候会自动把factor类型的变量作为虚拟变量进行回归。

### 按数量值分组

依旧采用法学院的例子。很明显在上面的分析中我们把各个学院排名直接当作一个可以“测距”的变量其实它只是一个排序而已，并不代表实质的差距。来使用了，这可能会引起一些争议。因此，我们可以采取另一种模式，即引入虚拟变量，把学校分为六组：top 10，11-25名，26-40名，41-60名，61-100名，100名开外。引入五个虚拟变量$top10$ , $r11\_25$ , $r26\_40$ , $r41\_60$ , $r61\_100$ 。
我想你不会手动的把所有的学校都赋一个虚拟变量值吧？在R里面，我们需要先通过`recode()`来依照分组创建一个新的factor形式的变量$rank\_f$，然后再进行回归。这样我们就不需要在原来的数据库里面新增加五个变量并赋逻辑值了。



```r
LAW$rank_f <- recode(LAW$rank, "1:10=\"top10\"; 11:25=\"r11_25\"; 26:40=\"r26_40\";    41:60=\"r41_60\";  61:100=\"r61_100\"; else=\"r101_\"; ", 
    as.factor.result = TRUE)
LAW_Result2 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
    rank_f, data = LAW)
summary(LAW_Result2)
```



```
## 
## Call:
## lm(formula = log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
##     rank_f, data = LAW)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.29489 -0.03969 -0.00168  0.04389  0.27750 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   9.165295   0.411424   22.28  < 2e-16 ***
## LSAT          0.005691   0.003063    1.86    0.066 .  
## GPA           0.013726   0.074192    0.19    0.854    
## log(libvol)   0.036362   0.026017    1.40    0.165    
## log(cost)     0.000841   0.025136    0.03    0.973    
## rank_fr11_25  0.593543   0.039440   15.05  < 2e-16 ***
## rank_fr26_40  0.375076   0.034081   11.01  < 2e-16 ***
## rank_fr41_60  0.262819   0.027962    9.40  3.2e-16 ***
## rank_fr61_100 0.131595   0.021042    6.25  5.7e-09 ***
## rank_ftop10   0.699566   0.053492   13.08  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.0856 on 126 degrees of freedom
##   (20 observations deleted due to missingness)
## Multiple R-squared: 0.911,	Adjusted R-squared: 0.905 
## F-statistic:  143 on 9 and 126 DF,  p-value: <2e-16 
## 
```




此外，我们可以通过*RCommander*里面，在`Data -> Recode Variables`的方框里逐行输入。
![Recode Varibles图形化界面](imgs/recode_variables.JPG)

### 交叉项

我不知道这样叫是不是足够确切，在微观计量里面我们会经常用到两个变量相乘的回归项，比如$female\cdot single $，即单身女士。相比而言这样的虚拟变量并不需要特别的处理，在回归方程里面直接写成相乘的形式即可。注意此时不需要再写female 和single 变量，`lm()`会默认加入这两个变量。例如，在法学院的例子中，我们可以对top10 和west 两个变量进行相乘回归（这里top10 变量来源于数据库本身自带的）。



```r
LAW_Result3 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
    top10 * west, data = LAW)
summary(LAW_Result3)
```



```
## 
## Call:
## lm(formula = log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
##     top10 * west, data = LAW)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.3723 -0.0997 -0.0219  0.0943  0.4159 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  5.22585    0.55409    9.43  2.3e-16 ***
## LSAT         0.00778    0.00521    1.49   0.1383    
## GPA          0.50411    0.11417    4.42  2.1e-05 ***
## log(libvol)  0.21985    0.04086    5.38  3.4e-07 ***
## log(cost)    0.12096    0.04036    3.00   0.0033 ** 
## top10        0.10506    0.06688    1.57   0.1187    
## west         0.01635    0.03052    0.54   0.5931    
## top10:west   0.01128    0.11961    0.09   0.9250    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.146 on 128 degrees of freedom
##   (20 observations deleted due to missingness)
## Multiple R-squared: 0.737,	Adjusted R-squared: 0.723 
## F-statistic: 51.4 on 7 and 128 DF,  p-value: <2e-16 
## 
```




当然也可以使用factor变量和其他虚拟变量相乘进行回归，反馈的结果中包含所有的相乘项。



```r
LAW_Result4 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
    rank_f * west, data = LAW)
LAW_Result4
```



```
## 
## Call:
## lm(formula = log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
##     rank_f * west, data = LAW)
## 
## Coefficients:
##        (Intercept)                LSAT                 GPA  
##           9.183816            0.005732            0.011030  
##        log(libvol)           log(cost)        rank_fr11_25  
##           0.035169           -0.000485            0.591775  
##       rank_fr26_40        rank_fr41_60       rank_fr61_100  
##           0.378440            0.260765            0.137090  
##        rank_ftop10                west   rank_fr11_25:west  
##           0.713412            0.012817            0.008311  
##  rank_fr26_40:west   rank_fr41_60:west  rank_fr61_100:west  
##          -0.011688            0.005488           -0.020113  
##   rank_ftop10:west  
##          -0.055886  
## 
```




### 指定参照组
当R处理factor形式的数据的时候，默认以数据中的第一个层次 (level) 作为参照组。比如上例中，我们想把top10 这一组作为参照组，那么则需要使用`relevel()`命令。



```r
attach(LAW)
rank_f2 <- relevel(rank_f, ref = "top10")
LAW_Result5 <- lm(log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
    rank_f2, data = LAW)
summary(LAW_Result5)
```



```
## 
## Call:
## lm(formula = log(salary) ~ LSAT + GPA + log(libvol) + log(cost) + 
##     rank_f2, data = LAW)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.29489 -0.03969 -0.00168  0.04389  0.27750 
## 
## Coefficients:
##                 Estimate Std. Error t value Pr(>|t|)    
## (Intercept)     9.864861   0.449840   21.93  < 2e-16 ***
## LSAT            0.005691   0.003063    1.86   0.0655 .  
## GPA             0.013726   0.074192    0.19   0.8535    
## log(libvol)     0.036362   0.026017    1.40   0.1647    
## log(cost)       0.000841   0.025136    0.03   0.9734    
## rank_f2r101_   -0.699566   0.053492  -13.08  < 2e-16 ***
## rank_f2r11_25  -0.106023   0.038716   -2.74   0.0071 ** 
## rank_f2r26_40  -0.324490   0.044339   -7.32  2.6e-11 ***
## rank_f2r41_60  -0.436747   0.045913   -9.51  < 2e-16 ***
## rank_f2r61_100 -0.567971   0.047180  -12.04  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.0856 on 126 degrees of freedom
##   (20 observations deleted due to missingness)
## Multiple R-squared: 0.911,	Adjusted R-squared: 0.905 
## F-statistic:  143 on 9 and 126 DF,  p-value: <2e-16 
## 
```




## 异方差检验

有件很没办法的事儿，那就是要想让OLS回归出来的结果最佳，必须要符合那五条经典假设（尤其是小样本下）。但是事实中的数据那里会那么完美呢？首当其冲的问题就是异方差。
异方差检验方法很多，这里给出两种常用的：BP检验 (Breusch-Pagan Test)、怀特检验 (White test for heteroskedasticity)。

下面给出一个关于房价的例子。

(@Hprice1)
在Hprice1.dta这个数据集中，有price （房价，按套计算）、lotsize （地皮面积要知道人家住的都是小别墅啊，自然要先有地、后建房，卖房子也都是一套一套的卖。）、sqrft （房屋面积）、bdrms （卧室数量）。接下来我们估计这个方程：

$\hat{price}=\hat{\beta_{0}}+\hat{\beta_{1}}lotsize+\hat{\beta_{2}}sqrft+\hat{\beta_{3}}bdrms$

使用OLS估计结果如下：



```r
HPrice <- read.dta("data/hprice1.dta")
Hprice_Result <- lm(price ~ bdrms + lotsize + sqrft, data = HPrice)
Hprice_Result
```



```
## 
## Call:
## lm(formula = price ~ bdrms + lotsize + sqrft, data = HPrice)
## 
## Coefficients:
## (Intercept)        bdrms      lotsize        sqrft  
##   -21.77031     13.85252      0.00207      0.12278  
## 
```




### BP检验 (Breusch-Pagan Test)
下面我们进行BP检验来测定是否有异方差。进行BP检验需要加载包*lmtest*，而后者需要加载包*zoo*。调用BP检验最简单的方法就是直接写回归结果变量。更多参数关于该命令各种参数设置请使用`?bptest`来查看帮助文档。可以通过*RCommander*里面的图形化界面设定，位于`Models > Numberical diagnostics > Breusch-Pagan Test for heteroskedasticity`。



```r
library("lmtest")
```



```
## Loading required package: zoo
```



```
## 
## Attaching package: 'zoo'
## 
```



```
## The following object(s) are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
```



```r
bptest(Hprice_Result)
```



```
## 
## 	studentized Breusch-Pagan test
## 
## data:  Hprice_Result 
## BP = 14.09, df = 3, p-value = 0.002782
## 
```




由结果来看，存在异方差。由于对数形式是消除异方差（尤其针对价格数据）的常用方法，因此我们再对对数形式进行回归:
$\hat{log(price)}=\hat{\beta_{0}}+\hat{\beta_{1}}log(lotsize)+\hat{\beta_{2}}log(sqrft)+\hat{\beta_{3}}bdrms$
得到回归结果如下：



```r
Hprice_Result2 <- lm(log(price) ~ bdrms + log(lotsize) + log(sqrft), 
    data = HPrice)
Hprice_Result2
```



```
## 
## Call:
## lm(formula = log(price) ~ bdrms + log(lotsize) + log(sqrft), 
##     data = HPrice)
## 
## Coefficients:
##  (Intercept)         bdrms  log(lotsize)    log(sqrft)  
##       -1.297         0.037         0.168         0.700  
## 
```




此时再进行异方差检验。



```r
bptest(Hprice_Result2)
```



```
## 
## 	studentized Breusch-Pagan test
## 
## data:  Hprice_Result2 
## BP = 4.223, df = 3, p-value = 0.2383
## 
```




因此可以接受原假设，已经不存在异方差。
此外还有一个`bptest()`非常接近的`ncv.test()`，需加载**car***包。我们进行一下对比。



```r
library(car)
ncvTest(Hprice_Result2)
```



```
## Non-constant Variance Score Test 
## Variance formula: ~ fitted.values 
## Chisquare = 3.525    Df = 1     p = 0.06044 
```



```r
bptest(Hprice_Result2, studentize = FALSE, varformula = ~fitted.values(Hprice_Result2), 
    data = HPrice)
```



```
## 
## 	Breusch-Pagan test
## 
## data:  Hprice_Result2 
## BP = 3.525, df = 1, p-value = 0.06044
## 
```




可以看到`ncvTest()`相当于把`bptest()`里面参数studentize设为FLASE，且进行固定值的检验。事实上，`bptest()`默认该项为TRUE，在TRUE时会采用Koenker (1981)的学生氏检验算法，也是目前最广为接受的算法。

### 怀特检验 (White test for heteroskedasticity)

还是上面这个例子，我们改用怀特检验。其实，我们可以把怀特检验看作广义上的BP检验的一种特殊形式，因此可以通过在`bptest()`里面赋予更多的参数来实现，即加入各个变量平方和交叉相乘的项。

比如回归为`fm <- lm(y ~ x + z, data = foo)`，那么则应写成`bptest(fm, ~ x * z + I(x^2) + I(z^2), data = foo)` 。因为这里写出来较麻烦，所以不再举例。

另，也可以通过**sandwich**这个专门对付“三明治”的包来实现怀特检验。

## 稳健标准差

当存在异方差的时候，我们可以采用稳健的标准差来替代原有的异方差矩阵。在R中，可以利用**sandwich**包的`vcovHC()`函数实现。依旧采用上面房价的例子。



```r
library("sandwich")
vcovHC(Hprice_Result)
```



```
##             (Intercept)      bdrms    lotsize      sqrft
## (Intercept)  1683.68200 -221.25362 -0.0616765 -0.2399245
## bdrms        -221.25362  133.67499  0.0475633 -0.3056587
## lotsize        -0.06168    0.04756  0.0000511 -0.0002524
## sqrft          -0.23992   -0.30566 -0.0002524  0.0016591
```




`vcovHC()`函数可以选择各种形式，在后面附加type = 即可。可选形式有"HC3", "const", "HC", "HC0", "HC1", "HC2", "HC4"，分别对应不同的异方差假设形式。如该函数的文档中所述，const对应 $\sigma^{2}(X'X)^{-1}$ ，HC（或HC0）对应 $(X'X)^{-1}X'\Omega X(X'X)^{-1}$ ，更多解释请参照`?vcovHC`。
之后我们就可以采用该异方差矩阵进行参数检验，如t检验。这里调用*lmtest*包内另一个非常有用的函数`coeftest()`。



```r
coeftest(Hprice_Result, vcov = vcovHC)
```



```
## 
## t test of coefficients:
## 
##              Estimate Std. Error t value Pr(>|t|)   
## (Intercept) -21.77031   41.03269   -0.53   0.5971   
## bdrms        13.85252   11.56179    1.20   0.2342   
## lotsize       0.00207    0.00715    0.29   0.7731   
## sqrft         0.12278    0.04073    3.01   0.0034 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
```




此外，对于含有自回归异方差的情形，可以采用`vcovHAC()`函数。更多相关用法后面章节中详述。这两个函数均可以附加到参数检验`coeftest()`或者`waldtest()`一起使用。

## 加权最小二乘估计 (WLS)

### 扰动项形式已知

有些情况下，我们可以写出加权的形式，比如扰动项服从$Var(u_{i}|inc)=\sigma^{2}inc$ ，那么可以直接在`lm()`函数里附加一项weight来实现。

(@smoke)
下面是一个烟草需求的例子。在SMOKE.rda中有如下几个变量：每天吸烟的数量 (cigs )、年收入 (income )、该州烟的价格 (cigpric )、受访者年龄 (age )、受教育程度 (educ )、该州有无饭店内吸烟禁令 (restaurn )。而后我们需要研究决定烟草需求的因素，即cigs 为被解释变量，其他为解释变量。

* 使用FGLS的第一步是进行OLS估计，得到残差项的估计值$\hat{u}$ 。对于价格数据，我们取其对数形式。
		


```r
load("data/SMOKE.rda")
SMOKE_OLS <- lm(cigs ~ log(income) + log(cigpric) + educ + age + 
    I(age^2) + restaurn, data = SMOKE)
```




* 第二步则是使用$log(\hat{u}^{2})$ 对其余变量进行回归。对于线性回归`lm()`所得结果，`residuals()`存储的是残差项。
		


```r
SMOKE_auxreg <- lm(log(residuals(SMOKE_OLS)^2) ~ log(income) + log(cigpric) + 
    educ + age + I(age^2) + restaurn, data = SMOKE)
```




* 第三步则是进行最后的加权回归。
		


```r
SMOKE_FGLS <- lm(cigs ~ log(income) + log(cigpric) + educ + age + 
    I(age^2) + restaurn, data = SMOKE, weights = 1/exp(fitted(SMOKE_auxreg)))
summary(SMOKE_FGLS)
```



```
## 
## Call:
## lm(formula = cigs ~ log(income) + log(cigpric) + educ + age + 
##     I(age^2) + restaurn, data = SMOKE, weights = 1/exp(fitted(SMOKE_auxreg)))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -1.904 -0.953 -0.810  0.842  9.856 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   5.635463  17.803139    0.32  0.75167    
## log(income)   1.295239   0.437012    2.96  0.00313 ** 
## log(cigpric) -2.940312   4.460145   -0.66  0.50993    
## educ         -0.463446   0.120159   -3.86  0.00012 ***
## age           0.481948   0.096808    4.98  7.9e-07 ***
## I(age^2)     -0.005627   0.000939   -5.99  3.2e-09 ***
## restaurn     -3.461064   0.795505   -4.35  1.5e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 1.58 on 800 degrees of freedom
## Multiple R-squared: 0.113,	Adjusted R-squared: 0.107 
## F-statistic: 17.1 on 6 and 800 DF,  p-value: <2e-16 
## 
```




* 如果需要的话，可以进行多次的FGLS估计。这里可以使用R的循环方式while。
		


```r
gamma2i <- coef(SMOKE_auxreg)[2]
gamma2 <- 0
while (abs((gamma2i - gamma2)/gamma2) > 1e-07) {
    gamma2 <- gamma2i
    SMOKE_FGLSi <- lm(cigs ~ log(income) + log(cigpric) + educ + age + I(age^2) + 
        restaurn, data = SMOKE, weights = 1/exp(fitted(SMOKE_auxreg)))
    SMOKE_auxreg <- lm(log(residuals(SMOKE_FGLSi)^2) ~ log(income) + log(cigpric) + 
        educ + age + I(age^2) + restaurn, data = SMOKE)
    gamma2i <- coef(SMOKE_auxreg)[2]
}
SMOKE_FGLS2 <- lm(cigs ~ log(income) + log(cigpric) + educ + age + 
    I(age^2) + restaurn, data = SMOKE, weights = 1/exp(fitted(SMOKE_auxreg)))
summary(SMOKE_FGLS2)
```



```
## 
## Call:
## lm(formula = cigs ~ log(income) + log(cigpric) + educ + age + 
##     I(age^2) + restaurn, data = SMOKE, weights = 1/exp(fitted(SMOKE_auxreg)))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -1.487 -0.977 -0.864  0.835  7.972 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   1.40314   19.54430    0.07  0.94278    
## log(income)   1.12124    0.42827    2.62  0.00901 ** 
## log(cigpric) -1.92067    4.87588   -0.39  0.69375    
## educ         -0.46133    0.12895   -3.58  0.00037 ***
## age           0.57558    0.10313    5.58  3.3e-08 ***
## I(age^2)     -0.00661    0.00102   -6.46  1.8e-10 ***
## restaurn     -3.31660    0.79246   -4.19  3.2e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 1.57 on 800 degrees of freedom
## Multiple R-squared: 0.107,	Adjusted R-squared: 0.0999 
## F-statistic: 15.9 on 6 and 800 DF,  p-value: <2e-16 
## 
```




在其中我们使用当`log(income)`的系数估计值收敛$(<10^{-7})$当作循环的条件。

## 广义线性估计 (GLM)

通常被解释变量并不一定服从正态分布，因而产生了Probit, Logit等模型。在R中，在采取广义线性估计法（Generalized Linear Models, GLM）来估计的时候，我们可以调用**glm**包。

(@MORZ)
这里我们看一个关于已婚妇女劳动参与率的例子（MROZ.dra）。当然，一个人工不工作是一个二值变量 (inlf )，我们设1为工作，0表示不工作。这里我们不妨认为其劳动参与行为主要取决于其他的收入来源——丈夫的工资 (nwifeinc )，受教育年限 (educ )，工作经验 (exper )，年龄 (age )，小于六岁的孩子数 (kidslt6 )，六到十八岁的孩子数 (kidsge6 )。
首先我们使用OLS来估计线性概率模型（Linear Probability Model，LPM）。



```r
load("data/MROZ.rda")
MROZ_LPM <- lm(inlf ~ nwifeinc + educ + exper + I(exper^2) + age + 
    kidslt6 + kidsge6, data = MROZ)
MROZ_LPM
```



```
## 
## Call:
## lm(formula = inlf ~ nwifeinc + educ + exper + I(exper^2) + age + 
##     kidslt6 + kidsge6, data = MROZ)
## 
## Coefficients:
## (Intercept)     nwifeinc         educ        exper   I(exper^2)  
##    0.585519    -0.003405     0.037995     0.039492    -0.000596  
##         age      kidslt6      kidsge6  
##   -0.016091    -0.261810     0.013012  
## 
```




### 最大似然估计 (Maximum Likelihood Estimation, MLE)

对于非线性的估计最常用的方法就是最大似然估计法（MLE）。在stats4包中有对应的函数mle()可进行相应的估计。但是由于在计量中单独用到最大似然估计的时候很少，大多数情况下都是用于估计特定模型（如GLM），有着特定的函数，所以在这里不再作特别介绍。

### Probit和Logit模型

当然使用OLS来估计概率模型并不理想（线性模型需假设解释变量具有不变的边际效应），因此我们再分别使用非线性的Probit和Logit模型来估计上例。在使用`glm()`的时候，只需要指定回归的类型(family)，其他的用法和`lm()`类似。此外可以使用`logLik()`来获取Log-Likelihood统计量。



```r
MROZ_Probit <- glm(inlf ~ nwifeinc + educ + exper + I(exper^2) + 
    age + kidsge6 + kidslt6, family = binomial(probit), data = MROZ)
MROZ_Probit
```



```
## 
## Call:  glm(formula = inlf ~ nwifeinc + educ + exper + I(exper^2) + age + 
##     kidsge6 + kidslt6, family = binomial(probit), data = MROZ)
## 
## Coefficients:
## (Intercept)     nwifeinc         educ        exper   I(exper^2)  
##     0.27007     -0.01202      0.13090      0.12335     -0.00189  
##         age      kidsge6      kidslt6  
##    -0.05285      0.03601     -0.86832  
## 
## Degrees of Freedom: 752 Total (i.e. Null);  745 Residual
## Null Deviance:	    1030 
## Residual Deviance: 803 	AIC: 819 
```



```r
logLik(MROZ_Probit)
```



```
## 'log Lik.' -401.3 (df=8)
```



```r
MROZ_Logit <- glm(inlf ~ nwifeinc + educ + exper + I(exper^2) + age + 
    kidsge6 + kidslt6, family = binomial(probit), data = MROZ)
MROZ_Logit
```



```
## 
## Call:  glm(formula = inlf ~ nwifeinc + educ + exper + I(exper^2) + age + 
##     kidsge6 + kidslt6, family = binomial(probit), data = MROZ)
## 
## Coefficients:
## (Intercept)     nwifeinc         educ        exper   I(exper^2)  
##     0.27007     -0.01202      0.13090      0.12335     -0.00189  
##         age      kidsge6      kidslt6  
##    -0.05285      0.03601     -0.86832  
## 
## Degrees of Freedom: 752 Total (i.e. Null);  745 Residual
## Null Deviance:	    1030 
## Residual Deviance: 803 	AIC: 819 
```



```r
logLik(MROZ_Logit)
```



```
## 'log Lik.' -401.3 (df=8)
```




### Tobit模型
依旧是上例，我们观察到每年的工作时间变化很大：对于不工作的来说，该值为0。此时如果画散点图那么必有近一半的点（325人）聚集在数轴上。因此，年工作时间 (hours )呈现很强烈的“边角解 (coner solution)”特性，对于这种情况我们可以采取Tobit模型。Tobit模型也是被审查的回归（Censored Regression）的一个特例。
其实Tobit很类似于生存分析里面的情况，因此可以调用*survival*包的`survreg()`函数。这里我们有个更简单的办法，*AER*包的作者进行了一个简单的转换，在包内自带了一个`tobit()`函数，调用更方便。这里我们将结果与OLS回归的进行对比。



```r
library("AER")
```



```
## Loading required package: Formula
```



```
## Loading required package: strucchange
```



```
## Loading required package: survival
```



```
## Loading required package: splines
```



```r
MROZ_Tobit <- tobit(hours ~ nwifeinc + educ + exper + I(exper^2) + 
    age + kidslt6 + kidsge6, data = MROZ)
MROZ_Tobit
```



```
## 
## Call:
## tobit(formula = hours ~ nwifeinc + educ + exper + I(exper^2) + 
##     age + kidslt6 + kidsge6, data = MROZ)
## 
## Coefficients:
## (Intercept)     nwifeinc         educ        exper   I(exper^2)  
##      965.31        -8.81        80.65       131.56        -1.86  
##         age      kidslt6      kidsge6  
##      -54.41      -894.02       -16.22  
## 
## Scale: 1122 
## 
```



```r
MROZ_OLS <- lm(hours ~ nwifeinc + educ + exper + I(exper^2) + age + 
    kidslt6 + kidsge6, data = MROZ)
MROZ_OLS
```



```
## 
## Call:
## lm(formula = hours ~ nwifeinc + educ + exper + I(exper^2) + age + 
##     kidslt6 + kidsge6, data = MROZ)
## 
## Coefficients:
## (Intercept)     nwifeinc         educ        exper   I(exper^2)  
##     1330.48        -3.45        28.76        65.67        -0.70  
##         age      kidslt6      kidsge6  
##      -30.51      -442.09       -32.78  
## 
```




<red>使用加权最小二乘法进行Probit估计
to be finished</red>

### 有序的probit/logit模型（Ordered Logit/Probit）

对于有序的Logit/Probit模型，可以调用*MASS*包中的`polr()`函数。比如研究数据集BankWages里面男性的有无工作（job）和教育程度（education）、少数民族（minority）之间的关系。



```r
library("MASS")
data(BankWages)
bank_polr <- polr(job ~ education + minority, data = BankWages, subset = gender == 
    "male", Hess = TRUE)
coeftest(bank_polr)
```



```
## 
## z test of coefficients:
## 
##                 Estimate Std. Error z value Pr(>|z|)    
## education         0.8700     0.0931    9.35  < 2e-16 ***
## minorityyes      -1.0564     0.4120   -2.56     0.01 *  
## custodial|admin   7.9514     1.0769    7.38  1.5e-13 ***
## admin|manage     14.1721     1.4744    9.61  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
```




## 计数模型 (Count Model)

### 泊松回归 (Poisson Regression Model)

对于呈现$\{0,1,2,...\}$这样特性的数据，我们采取计数模型。而计数模型的实质是利用泊松回归。泊松回归也是上面所说的GLM的一种。下面我们给出一个关于犯罪率的例子。

(@CRIME1)
在CRIME1.rda这个数据集中，我们把每个人被逮捕的次数 (narr86)作为被解释变量。对于其中大多数人来说，该变量值为0；剩下的也大都在$1\sim5$ 之间，因此泊松回归会比较合适。
一般说来我们直接用泊松回归就可以，在不假设整体都服从泊松分布的时候，我们采用的实质是准最大似然估计（Quasi-maximum likelihood estimation, QMLE）。



```r
load("data/CRIME1.rda")
CRIME1_poisson <- glm(narr86 ~ pcnv + avgsen + tottime + ptime86 + 
    qemp86 + inc86 + black + hispan + born60, family = poisson(log), data = CRIME1)
CRIME1_poisson
```



```
## 
## Call:  glm(formula = narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + 
##     inc86 + black + hispan + born60, family = poisson(log), data = CRIME1)
## 
## Coefficients:
## (Intercept)         pcnv       avgsen      tottime      ptime86  
##    -0.59959     -0.40157     -0.02377      0.02449     -0.09856  
##      qemp86        inc86        black       hispan       born60  
##    -0.03802     -0.00808      0.66084      0.49981     -0.05103  
## 
## Degrees of Freedom: 2724 Total (i.e. Null);  2715 Residual
## Null Deviance:	    3210 
## Residual Deviance: 2820 	AIC: 4520 
```



```r
CRIME1_quasipoisson <- glm(narr86 ~ pcnv + avgsen + tottime + ptime86 + 
    qemp86 + inc86 + black + hispan + born60, family = quasipoisson(log), data = CRIME1)
CRIME1_quasipoisson
```



```
## 
## Call:  glm(formula = narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + 
##     inc86 + black + hispan + born60, family = quasipoisson(log), 
##     data = CRIME1)
## 
## Coefficients:
## (Intercept)         pcnv       avgsen      tottime      ptime86  
##    -0.59959     -0.40157     -0.02377      0.02449     -0.09856  
##      qemp86        inc86        black       hispan       born60  
##    -0.03802     -0.00808      0.66084      0.49981     -0.05103  
## 
## Degrees of Freedom: 2724 Total (i.e. Null);  2715 Residual
## Null Deviance:	    3210 
## Residual Deviance: 2820 	AIC: NA 
```




### 过度离散数据检验

当数据呈现过度离散特性的时候，就违背了泊松回归的假设（方差等于期望），所以在进行泊松回归前需要进行一下离散度检验。**AER**包中提供了一个函数`dispersiontest()`可以用来进行该检验。

(@RecreationDemand)
在RecreationDemand这个数据集中，涵盖了1980年德克萨斯州划船度假村的相关数据。我们希望用调查所得的（主观排名）设施质量（变量quality）、被调查者是否参加了滑水项目（变量ski）、家庭收入（income）、被调查者是否为游览该湖付费（userfee）、和三个表示机会成本的变量（costC , costS , costH）来解释trips 变量。

首先我们需要进行泊松回归。



```r
library(AER)
data("RecreationDemand")
rd_pois <- glm(trips ~ ., data = RecreationDemand, family = poisson)
```




而后对回归模型rd_pois进行离散度检验。在调用`dispersiontest()`函数之时，可以指定参数trafo 的值，从而只对$\alpha$进行估计。具体解释请参见函数说明。



```r
dispersiontest(rd_pois)
```



```
## 
## 	Overdispersion test
## 
## data:  rd_pois 
## z = 2.412, p-value = 0.007941
## alternative hypothesis: true dispersion is greater than 1 
## sample estimates:
## dispersion 
##      6.566 
## 
```



```r
dispersiontest(rd_pois, trafo = 2)
```



```
## 
## 	Overdispersion test
## 
## data:  rd_pois 
## z = 2.938, p-value = 0.001651
## alternative hypothesis: true alpha is greater than 0 
## sample estimates:
## alpha 
## 1.316 
## 
```




### 负二项回归模型（negative binomial regression）

在数据呈现过度离散的情况下，我们可以采取负二项回归模型。*MASS*包中提供了相关函数`negative.binomial()`和`glm.nb()`。前者用于参数$\theta$已知，后者用于该参数未知。依旧采用上面的例子。这里参数$\theta$ 未知，所以调用`glm.nb()`，而后进行参数检验。



```r
library("MASS")
rd_nb <- glm.nb(trips ~ ., data = RecreationDemand)
coeftest(rd_nb)
```



```
## 
## z test of coefficients:
## 
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept) -1.12194    0.21430   -5.24  1.6e-07 ***
## quality      0.72200    0.04012   18.00  < 2e-16 ***
## skiyes       0.61214    0.15030    4.07  4.6e-05 ***
## income      -0.02606    0.04245   -0.61    0.539    
## userfeeyes   0.66917    0.35302    1.90    0.058 .  
## costC        0.04801    0.00918    5.23  1.7e-07 ***
## costS       -0.09269    0.00665  -13.93  < 2e-16 ***
## costH        0.03884    0.00775    5.01  5.4e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
```




当然，我们还可以再调用logLik()来获取Log-Likelihood统计量。



```r
logLik(rd_nb)
```



```
## 'log Lik.' -825.6 (df=9)
```




### 零膨胀泊松模型 (Zero-inflated Poisson Model, ZIP)

对于计数模型来说，当数据集中的0观测值众多，所占比例超出泊松回归允许的范围时，回归结果就不是那么令人满意。此时需采用ZIP（Zero-inflated Poisson Model）模型。在R中，*pscl*包提供了一个函数`zeroinfl()`，用来实现ZIP泊松回归。比如例2.6中，大多数人($>70\%$ )并未被逮捕过。所以我们不妨采用ZIP模型（负二项回归形式，ZINB）。



```r
library("pscl")
```



```
## Loading required package: mvtnorm
```



```
## Loading required package: coda
```



```
## Loading required package: lattice
```



```
## Loading required package: gam
```



```
## Loaded gam 1.06.2
## 
```



```
## Loading required package: vcd
```



```
## Loading required package: grid
```



```
## Loading required package: colorspace
```



```
## Classes and Methods for R developed in the
## 
```



```
## Political Science Computational Laboratory
## 
```



```
## Department of Political Science
## 
```



```
## Stanford University
## 
```



```
## Simon Jackman
## 
```



```
## hurdle and zeroinfl functions by Achim Zeileis
## 
```



```r
CRIME1_zip <- zeroinfl(narr86 ~ pcnv + avgsen + tottime + ptime86 + 
    qemp86 + inc86 + black + hispan + born60 | inc86, data = CRIME1, dist = "negbin")
summary(CRIME1_zip)
```



```
## 
## Call:
## zeroinfl(formula = narr86 ~ pcnv + avgsen + tottime + ptime86 + 
##     qemp86 + inc86 + black + hispan + born60 | inc86, data = CRIME1, 
##     dist = "negbin")
## 
## Pearson residuals:
##    Min     1Q Median     3Q    Max 
## -0.815 -0.543 -0.428  0.165 13.307 
## 
## Count model coefficients (negbin with log link):
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept) -0.28061    0.09839   -2.85  0.00434 ** 
## pcnv        -0.47205    0.10293   -4.59  4.5e-06 ***
## avgsen      -0.01989    0.02647   -0.75  0.45240    
## tottime      0.02255    0.01968    1.15  0.25188    
## ptime86     -0.09613    0.02710   -3.55  0.00039 ***
## qemp86      -0.15531    0.03995   -3.89  0.00010 ***
## inc86       -0.00685    0.00112   -6.11  9.8e-10 ***
## black        0.63444    0.09173    6.92  4.6e-12 ***
## hispan       0.49618    0.08845    5.61  2.0e-08 ***
## born60      -0.05239    0.07702   -0.68  0.49636    
## Log(theta)   0.40448    0.15207    2.66  0.00782 ** 
## 
## Zero-inflation model coefficients (binomial with logit link):
##             Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   -0.769      0.254   -3.03   0.0025 **
## inc86        -30.038     96.621   -0.31   0.7559   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Theta = 1.499 
## Number of iterations in BFGS optimization: 87 
## Log-likelihood: -2.15e+03 on 13 Df
```




## 选择性样本问题

### Heckit模型

当样本不能保证随机性的时候，即面对样本自选择问题（最常见的为偶然断尾）之时，我们一般采用Heckit模型。回到那个已婚妇女参加工作的例子（2.5）<red>如何cross-reference?</red>。现在我们研究影响参与工作的妇女的工资问题。这里需要加载**sampleSelection**包。



```r
library(sampleSelection)
```



```
## Loading required package: maxLik
```



```
## Loading required package: miscTools
```



```
## Loading required package: systemfit
```



```
## Loading required package: Matrix
```



```r
MROZ_Heckit <- heckit(inlf ~ nwifeinc + educ + exper + I(exper^2) + 
    age + kidslt6 + kidsge6, log(wage) ~ educ + exper + I(exper^2), data = MROZ, 
    method = "2step")
summary(MROZ_Heckit)
```



```
## --------------------------------------------
## Tobit 2 model (sample selection model)
## 2-step Heckman / heckit estimation
## 753 observations (325 censored and 428 observed)
## 15 free parameters (df = 739)
## Probit selection equation:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  0.27008    0.50859    0.53   0.5956    
## nwifeinc    -0.01202    0.00484   -2.48   0.0132 *  
## educ         0.13090    0.02525    5.18  2.8e-07 ***
## exper        0.12335    0.01872    6.59  8.3e-11 ***
## I(exper^2)  -0.00189    0.00060   -3.15   0.0017 ** 
## age         -0.05285    0.00848   -6.23  7.6e-10 ***
## kidslt6     -0.86833    0.11852   -7.33  6.2e-13 ***
## kidsge6      0.03601    0.04348    0.83   0.4079    
## Outcome equation:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -0.578103   0.305006   -1.90   0.0584 .  
## educ         0.109066   0.015523    7.03  4.8e-12 ***
## exper        0.043887   0.016261    2.70   0.0071 ** 
## I(exper^2)  -0.000859   0.000439   -1.96   0.0507 .  
## Multiple R-Squared:0.157,	Adjusted R-Squared:0.149
## Error terms:
##               Estimate Std. Error t value Pr(>|t|)
## invMillsRatio   0.0323     0.1336    0.24     0.81
## sigma           0.6636         NA      NA       NA
## rho             0.0486         NA      NA       NA
## --------------------------------------------
```




Heckit模型实际上就是先进行一个probit回归，而后再利用前面的得到的估计值加上解释变量对被解释变量回归。

## 联立方程模型（Simultaneous Equations）

由于经济系统内的各变量往往是相互联系的，所以在出现联立方程的情况下OLS估计会因为内生性的问题而产生偏差，此时需要借助两阶段最小二乘法（2SLS）来估计方程（组）。

### 两阶段最小二乘法(2SLS)和工具变量法

对于应用在结构单一的方程上的两阶段最小二乘法，我们只需要调用**sem**包中的`tsls()`函数。

回到例2.5，我们想研究教育的回报率。这个时候需要估计工资log(wage)和受教育程度（educ）、经验（exper）之间的关系。但是我们怀疑受教育程度educ 是内生变量，但他父母的受教育程度$motheduc,\;\; fatheduc$ 则为外生变量，所以可以作为educ 的工具变量。



```r
library(sem)
```



```
## Loading required package: matrixcalc
```



```r
MROZ_2SLS <- tsls(lwage ~ educ + exper + I(exper^2), ~exper + I(exper^2) + 
    motheduc + fatheduc, data = MROZ)
summary(MROZ_2SLS)
```



```
## 
##  2SLS Estimates
## 
## Model Formula: lwage ~ educ + exper + I(exper^2)
## <environment: 0x049689d0>
## 
## Instruments: ~exper + I(exper^2) + motheduc + fatheduc
## <environment: 0x049689d0>
## 
## Residuals:
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -3.1000 -0.3200  0.0551  0.0000  0.3690  2.3500 
## 
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept)  0.048100  0.4003281  0.1202 0.904419
## educ         0.061397  0.0314367  1.9530 0.051474
## exper        0.044170  0.0134325  3.2883 0.001092
## I(exper^2)  -0.000899  0.0004017 -2.2380 0.025740
## 
## Residual standard error: 0.6747 on 424 degrees of freedom
## 
```




### 联立方程模型估计：似不相关回归法（Seemingly Unrelated Regression）

对于联立方程模型，终极的解决方案莫过于**systemfit**包，它提供了似不相关回归及其变形、两阶段最小二乘法和工具变量等多种估计方法。这里我们看一个似不相关回归法来估计联立方程模型的例子。

(@Grunfeld)
我们现在来看投资和企业价值及资本存量之间的关系。在数据集Grunfeld之中，invest 代表总投资值，value 代表企业的价值，capital 代表企业的资本存量，以上数据都是剔除了通胀因素之后的真实值。
为了简单起见，我们只考虑两个厂商Chrysler和IBM，因此首先要使用`subset()`函数来从原数据集中找出一个子集。厂商之间可能是有联系的，所以需要分别设定变量，这里我们就可以用到factor类型的数据。这里最方便的就是利用面板数据的类型，调用*plm*包里面的`plm.data()`函数。



```r
data(Grunfeld, package = "AER")
library("systemfit")
library("plm")
```



```
## Loading required package: bdsmatrix
```



```
## 
## Attaching package: 'bdsmatrix'
## 
```



```
## The following object(s) are masked from 'package:base':
## 
##     backsolve
## 
```



```
## Loading required package: nlme
```



```
## 
## Attaching package: 'plm'
## 
```



```
## The following object(s) are masked from 'package:data.table':
## 
##     between
## 
```



```r
gr2 <- subset(Grunfeld, firm %in% c("Chrysler", "IBM"))
pgr2 <- plm.data(gr2, c("firm", "year"))
gr_sur <- systemfit(invest ~ value + capital, method = "SUR", data = pgr2)
summary(gr_sur, residCov = FALSE, equations = FALSE)
```



```
## 
## systemfit results 
## method: SUR 
## 
##         N DF  SSR detRCov OLS-R2 McElroy-R2
## system 40 34 4114   11022  0.929      0.927
## 
##           N DF  SSR   MSE  RMSE    R2 Adj R2
## Chrysler 20 17 3002 176.6 13.29 0.913  0.903
## IBM      20 17 1112  65.4  8.09 0.952  0.946
## 
## 
## Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
## Chrysler_(Intercept)  -5.7031    13.2774   -0.43  0.67293    
## Chrysler_value         0.0780     0.0196    3.98  0.00096 ***
## Chrysler_capital       0.3115     0.0287   10.85  4.6e-09 ***
## IBM_(Intercept)       -8.0908     4.5216   -1.79  0.09139 .  
## IBM_value              0.1272     0.0306    4.16  0.00066 ***
## IBM_capital            0.0966     0.0983    0.98  0.33951    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
```




从结果中我们可以得到似不相关回归的估计值。这里也可以调整一下`summary()`的参数来看更详细的回归结果。
此外，也可以加参数2SLS来调用`systemfit()`来进行两阶段最小二乘估计，具体方法不再赘述，请参见函数说明。

## 代理变量 (Proxy Variables)

其实代理变量并没有多少要特别说明的地方，只需要选择合适的变量代替不能观测的变量进行相应的回归分析就好。但有一种常用的而且很特别的代理变量，就是被解释变量的滞后项。这里简单的以一个例子说明。

(@CRIME)
这个例子是有关城市中犯罪率的。在CRIME.rda这个数据集中，含有1987年46个城市的犯罪率数据，可见是个标准的截面数据分析。只是除了犯罪率 (crmrte)，可用的变量只有失业率 (unem) 和人均用于维护法律权益的支出 (lawexpc) 。这样就有一些难以观测的变量导致回归的结果不甚理想。因此，我们可以采取1982年各个城市的犯罪率做一个代理变量，来但因那些难以观测的变量。方程如下：

$log(crmrte_{87})=\beta_{0}+\beta_{1}unem+\beta_{2}lawexpc+\beta_{3}log(crmrte_{82})$ 

但是在这个数据集中，每个观测值均有犯罪率和年份两个属性，也就是为面板数据的形式。好在对于87年的数据，已经给出对应82年的犯罪率lcrmrte.1 ，故选取87年数据直接回归即可。



```r
## need to correct data source
load("data/CRIME2.rda")
OLS87 <- lm(lcrmrte ~ lcrmrt.1 + llawexpc + unem, data = CRIME2, 
    subset = (year == 87))
summary(OLS87)
```




对于更多时间序列问题和面板数据问题将在后面几章中详细阐述。
