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



```r
load("data/WAGEPAN.rdata")
library("plm")
WAGE_data <- plm.data(WAGEPAN, index = c("nr", "year"))
# 混合OLS
WAGE_PLM_Pooled <- plm(lwage ~ educ + black + hisp + exper + I(exper^2) + 
    married + union, data = WAGE_data, model = "pooling")
summary(WAGE_PLM_Pooled)
```



```
## Oneway (individual) effect Pooling Model
## 
## Call:
## plm(formula = lwage ~ educ + black + hisp + exper + I(exper^2) + 
##     married + union, data = WAGE_data, model = "pooling")
## 
## Balanced Panel: n=545, T=8, N=4360
## 
## Residuals :
##    Min. 1st Qu.  Median 3rd Qu.    Max. 
## -5.2700 -0.2490  0.0332  0.2960  2.5600 
## 
## Coefficients :
##              Estimate Std. Error t-value Pr(>|t|)    
## (Intercept) -0.034706   0.064569   -0.54     0.59    
## educ         0.099388   0.004678   21.25  < 2e-16 ***
## black       -0.143842   0.023560   -6.11  1.1e-09 ***
## hisp         0.015698   0.020811    0.75     0.45    
## exper        0.089179   0.010111    8.82  < 2e-16 ***
## I(exper^2)  -0.002849   0.000707   -4.03  5.7e-05 ***
## married      0.107666   0.015696    6.86  7.9e-12 ***
## union        0.180073   0.017121   10.52  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    1240
## Residual Sum of Squares: 1010
## R-Squared      :  0.187 
##       Adj. R-Squared :  0.186 
## F-statistic: 142.613 on 7 and 4352 DF, p-value: <2e-16
```



```r
# 一阶差分
WAGE_PLM_FD <- plm(lwage ~ educ + black + hisp + exper + I(exper^2) + 
    married + union, data = WAGE_data, model = "fd")
summary(WAGE_PLM_FD)
```



```
## Oneway (individual) effect First-Difference Model
## 
## Call:
## plm(formula = lwage ~ educ + black + hisp + exper + I(exper^2) + 
##     married + union, data = WAGE_data, model = "fd")
## 
## Balanced Panel: n=545, T=8, N=4360
## 
## Residuals :
##    Min. 1st Qu.  Median 3rd Qu.    Max. 
## -4.5800 -0.1460 -0.0127  0.1330  4.8400 
## 
## Coefficients :
##             Estimate Std. Error t-value Pr(>|t|)    
## (intercept)  0.11575    0.01959    5.91  3.7e-09 ***
## I(exper^2)  -0.00388    0.00139   -2.80   0.0051 ** 
## married      0.03814    0.02293    1.66   0.0963 .  
## union        0.04279    0.01966    2.18   0.0296 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    751
## Residual Sum of Squares: 748
## R-Squared      :  0.0042 
##       Adj. R-Squared :  0.0042 
## F-statistic: 5.36242 on 3 and 3811 DF, p-value: 0.0011
```



```r
# 固定效应模型
WAGE_PLM_fixed <- plm(lwage ~ educ + black + hisp + exper + I(exper^2) + 
    married + union, data = WAGE_data, model = "within")
summary(WAGE_PLM_fixed)
```



```
## Oneway (individual) effect Within Model
## 
## Call:
## plm(formula = lwage ~ educ + black + hisp + exper + I(exper^2) + 
##     married + union, data = WAGE_data, model = "within")
## 
## Balanced Panel: n=545, T=8, N=4360
## 
## Residuals :
##     Min.  1st Qu.   Median  3rd Qu.     Max. 
## -4.17000 -0.12600  0.00925  0.16000  1.47000 
## 
## Coefficients :
##             Estimate Std. Error t-value Pr(>|t|)    
## exper       0.116847   0.008420   13.88  < 2e-16 ***
## I(exper^2) -0.004301   0.000605   -7.11  1.4e-12 ***
## married     0.045303   0.018310    2.47    0.013 *  
## union       0.082087   0.019291    4.26  2.1e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    572
## Residual Sum of Squares: 470
## R-Squared      :  0.178 
##       Adj. R-Squared :  0.156 
## F-statistic: 206.375 on 4 and 3811 DF, p-value: <2e-16
```



```r
# 随机效应模型
WAGE_PLM_random <- plm(lwage ~ educ + black + hisp + exper + I(exper^2) + 
    married + union, data = WAGE_data, model = "random")
summary(WAGE_PLM_random)
```



```
## Oneway (individual) effect Random Effect Model 
##    (Swamy-Arora's transformation)
## 
## Call:
## plm(formula = lwage ~ educ + black + hisp + exper + I(exper^2) + 
##     married + union, data = WAGE_data, model = "random")
## 
## Balanced Panel: n=545, T=8, N=4360
## 
## Effects:
##                 var std.dev share
## idiosyncratic 0.123   0.351  0.54
## individual    0.105   0.325  0.46
## theta:  0.643  
## 
## Residuals :
##    Min. 1st Qu.  Median 3rd Qu.    Max. 
## -4.5800 -0.1450  0.0235  0.1860  1.5400 
## 
## Coefficients :
##              Estimate Std. Error t-value Pr(>|t|)    
## (Intercept) -0.107464   0.110706   -0.97  0.33174    
## educ         0.101225   0.008913   11.36  < 2e-16 ***
## black       -0.144131   0.047615   -3.03  0.00248 ** 
## hisp         0.020151   0.042601    0.47  0.63622    
## exper        0.112119   0.008261   13.57  < 2e-16 ***
## I(exper^2)  -0.004069   0.000592   -6.88  7.1e-12 ***
## married      0.062795   0.016773    3.74  0.00018 ***
## union        0.107379   0.017830    6.02  1.9e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    657
## Residual Sum of Squares: 540
## R-Squared      :  0.178 
##       Adj. R-Squared :  0.178 
## F-statistic: 134.85 on 7 and 4352 DF, p-value: <2e-16
```



```r
# 组内模型
WAGE_PLM_between <- plm(lwage ~ educ + black + hisp + exper + I(exper^2) + 
    married + union, data = WAGE_data, model = "between")
summary(WAGE_PLM_between)
```



```
## Oneway (individual) effect Between Model
## 
## Call:
## plm(formula = lwage ~ educ + black + hisp + exper + I(exper^2) + 
##     married + union, data = WAGE_data, model = "between")
## 
## Balanced Panel: n=545, T=8, N=4360
## 
## Residuals :
##    Min. 1st Qu.  Median 3rd Qu.    Max. 
## -1.1200 -0.2390  0.0246  0.2300  1.7400 
## 
## Coefficients :
##             Estimate Std. Error t-value Pr(>|t|)    
## (Intercept)  0.49231    0.22101    2.23  0.02632 *  
## educ         0.09460    0.01090    8.68  < 2e-16 ***
## black       -0.13881    0.04887   -2.84  0.00468 ** 
## hisp         0.00478    0.04269    0.11  0.91097    
## exper       -0.05044    0.05033   -1.00  0.31676    
## I(exper^2)   0.00512    0.00321    1.60  0.11119    
## married      0.14366    0.04120    3.49  0.00053 ***
## union        0.27068    0.04656    5.81  1.1e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    83.1
## Residual Sum of Squares: 64.9
## R-Squared      :  0.219 
##       Adj. R-Squared :  0.216 
## F-statistic: 21.5386 on 7 and 537 DF, p-value: <2e-16
```




一般说来，OLS估计（混合回归）不如其他方法有效。而在上例中我们可以看出，为了估计不随时间变化的量（种族、受教育程度），我们必须用到随机效应模型。然而对于随时间变化的量（经验等），固定效应模型或一阶差分法显然更为有效。此外，对于随机效应模型，还可以使用`fixef()`函数来提取其中的固定效应。

实际上，`plm()`函数不仅仅支持这些基本的模型，而且对于每种模型还提供了不同参数以调整具体方法，如双向模型（two-way model）和时间效应等。例如，在使用双向模型的时候，只需在调用函数`plm()`中加一个参数`effect = "twoways"`即可，但此时如果使用`fixef()`函数来提取其中的固定效应则需写成`` fixef(YOUR_MODLE, effect = "time") ``。具体说来，随机效应模型支持增加参数`random.method`，可选择 `amemiya、swar、walhus、nerlove`，而对应的误差分量的变化可以直接调用`ercomp()`函数指定`method`和`effect`来估计。

非平衡面板（Unbalanced panels）
-----------------------------

如果在不同时期的个体是不同的（增加或减少），那么该面板数据就成为了非平衡面板。目前**plm**包中对于非平衡面板还不能进行双向效应估计，能提供的误差分量估计法也只有一种。Baltagi(2001)重新估计了房地产市场的特徽价格方程（hedonic housing prices function），代码如下：



```r
data("Hedonic", package = "plm")
Hed <- plm(mv ~ crim + zn + indus + chas + nox + rm + age + dis + 
    rad + tax + ptratio + blacks + lstat, Hedonic, model = "random", index = "townid")
summary(Hed)
```



```
## Oneway (individual) effect Random Effect Model 
##    (Swamy-Arora's transformation)
## 
## Call:
## plm(formula = mv ~ crim + zn + indus + chas + nox + rm + age + 
##     dis + rad + tax + ptratio + blacks + lstat, data = Hedonic, 
##     model = "random", index = "townid")
## 
## Unbalanced Panel: n=92, T=1-30, N=506
## 
## Effects:
##                  var std.dev share
## idiosyncratic 0.0170  0.1302   0.5
## individual    0.0168  0.1297   0.5
## theta  : 
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   0.292   0.590   0.666   0.650   0.745   0.820 
## 
## Residuals :
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  -0.641  -0.066  -0.001  -0.002   0.070   0.527 
## 
## Coefficients :
##              Estimate Std. Error t-value Pr(>|t|)    
## (Intercept)  9.68e+00   2.07e-01   46.72  < 2e-16 ***
## crim        -7.23e-03   1.03e-03   -6.99  8.9e-12 ***
## zn           3.96e-05   6.88e-04    0.06  0.95414    
## indus        2.08e-03   4.34e-03    0.48  0.63208    
## chasyes     -1.06e-02   2.90e-02   -0.37  0.71473    
## nox         -5.86e-03   1.25e-03   -4.71  3.3e-06 ***
## rm           9.18e-03   1.18e-03    7.78  4.2e-14 ***
## age         -9.27e-04   4.65e-04   -2.00  0.04657 *  
## dis         -1.33e-01   4.57e-02   -2.91  0.00379 ** 
## rad          9.69e-02   2.83e-02    3.42  0.00069 ***
## tax         -3.75e-04   1.89e-04   -1.98  0.04799 *  
## ptratio     -2.97e-02   9.75e-03   -3.05  0.00243 ** 
## blacks       5.75e-01   1.01e-01    5.69  2.2e-08 ***
## lstat       -2.85e-01   2.39e-02  -11.95  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    893
## Residual Sum of Squares: 8.68
## R-Squared      :  0.99 
##       Adj. R-Squared :  0.963 
## F-statistic: 3854.18 on 13 and 492 DF, p-value: <2e-16
```




面板数据相关检验
----------------

### 可混合性检验（Tests of poolability）

在进行面板数据分析前，一般会考虑到一个问题：对于每个个体，解释变量系数都是一样的吗？换言之，个体效应是否存在？当然，一般说来个体效应都会存在的，否则后面的分析就没有意义了，直接采用混合模型就好。可混合性检验就是用来检验个体效应的。我们这里需要调用`pooltest()`函数进行检验。回到例2.8，继续看公司的投资与真实价值和资本存量的关系。最简单的调用方法如下：



```r
data(Grunfeld, package = "plm")
pooltest(inv ~ value + capital, data = Grunfeld, model = "within")
```



```
## 
## 	F statistic
## 
## data:  inv ~ value + capital 
## F = 5.78, df1 = 18, df2 = 170, p-value = 1.219e-10
## alternative hypothesis: unstability 
## 
```




其实，该函数需要的由两部分组成，一为通过`plm()`得到的模型，二为通过`pvcm()`得到的固定效应模型。因此，上面的代码实则等价于：
```
znp <- pvcm(inv~value + capital, data = Grunfeld, model = "within") 
zplm <- plm(inv~value + capital, data = Grunfeld)
pooltest(zplm, znp) 
```

实际上，这里的`pvcm()`函数进行的正是变系数回归，而可混合性检验的实质也就是对这两种模型进行比较的F检验。

### 个体效应或时间效应检验（Tests for individual and time effects）

用拉格朗格乘子法可以检验相对于混合模型的个体或时间效应。这里可以调用`plmtest()`函数。调用方式有两种，其一可以先做一个混合回归再进行检验（如双向效应）：



```r
g_pooled <- plm(inv ~ value + capital, data = Grunfeld, model = "pooling")
plmtest(g_pooled, effect = "twoways", type = "ghm")
```



```
## 
## 	Lagrange Multiplier Test - two-ways effects (Gourieroux, Holly
## 	and Monfort)
## 
## data:  inv ~ value + capital 
## chisq = 798.2, df = 2, p-value < 2.2e-16
## alternative hypothesis: significant effects 
## 
```




此外也可以直接在调用检验函数的同时指定回归模型，如：



```r
plmtest(inv ~ value + capital, data = Grunfeld, effect = "twoways", 
    type = "ghm")
```



```
## 
## 	Lagrange Multiplier Test - two-ways effects (Gourieroux, Holly
## 	and Monfort)
## 
## data:  inv ~ value + capital 
## chisq = 798.2, df = 2, p-value < 2.2e-16
## alternative hypothesis: significant effects 
## 
```




对于该函数来说，还可以附加参数`type`，可选`bp, honda, kw, ghm`之一。至于必须指明的`effect`参数，可选`individual, time, twoways`之一。

此外，还可以做各种效应的F检验（基于混合模型与固定效应模型之间的比较）。依旧用例2.8：



```r
g_fixed_twoways <- plm(inv ~ value + capital, data = Grunfeld, effect = "twoways", 
    model = "within")
```



```
## Error: object 'inv' not found
```



```r
pFtest(g_fixed_twoways, g_pooled)
```



```
## Error: object 'g_fixed_twoways' not found
```




当然，`pFtest()`函数也提供了另外一种直接的调用形式，如`` pFtest(inv value + capital, data = Grunfeld, effect = "twoways") ``。

### Hausman检验

为了判断到底是采用固定效应还是随机效应模型，我们一般采取经典的Hausman检验，这可以通过调用`phtest()`函数实现。注：这里我们只展示Hausman检验的用法，至于实际应用中该检验结果是否足以支撑模型选择，则需另作学术讨论。



```r
gw <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
gr <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
phtest(gw, gr)
```



```
## 
## 	Hausman Test
## 
## data:  inv ~ value + capital 
## chisq = 2.33, df = 2, p-value = 0.3119
## alternative hypothesis: one model is inconsistent 
## 
```




同理，对于例4.1，我们也可以采用该检验来判断应该使用哪个模型。因为我们上面已经分别作了固定效应和随机效应的回归，所以此时直接调用两个回归模型结果就可以。



```r
phtest(WAGE_PLM_fixed, WAGE_PLM_random)
```



```
## 
## 	Hausman Test
## 
## data:  lwage ~ educ + black + hisp + exper + I(exper^2) + married +      union 
## chisq = 31.45, df = 4, p-value = 2.476e-06
## alternative hypothesis: one model is inconsistent 
## 
```




注意Hasuman检验的原假设是“随机效应模型优于固定效应模型”，所以对于例2.8，我们可以接受原假设，采用随机效应模型；对于例4.1，则应考虑固定效应模型。

变系数模型（Variable coeffcients model）
--------------------------------------

一般说来在固定或随机效应模型中，系数都被假设为不变的而截距项是变化的。下面我们可以考虑系数也变化的情形。依旧以2.8（Grunfeld）为例，欲使用变系数模型我们只需要调用`pvcm()`函数即可。



```r
g_varw <- pvcm(inv ~ value + capital, data = Grunfeld, model = "within")
g_varr <- pvcm(inv ~ value + capital, data = Grunfeld, model = "random")
summary(g_varr)
```



```
## Oneway (individual) effect Random coefficients model
## 
## Call:
## pvcm(formula = inv ~ value + capital, data = Grunfeld, model = "random")
## 
## Balanced Panel: n=10, T=20, N=200
## 
## Residuals:
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  -211.0   -32.3    -4.3     9.1    12.7   579.0 
## 
## Estimated mean of the coefficients:
##             Estimate Std. Error z-value Pr(>|z|)    
## (Intercept)  -9.6293    17.0350   -0.57  0.57189    
## value         0.0846     0.0200    4.24  2.2e-05 ***
## capital       0.1994     0.0527    3.79  0.00015 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Estimated variance of the coefficients:
##             (Intercept)    value  capital
## (Intercept)    2344.244 -0.68523 -4.02766
## value            -0.685  0.00312 -0.00118
## capital          -4.028 -0.00118  0.02448
## 
## Total Sum of Squares: 4.74e+08
## Residual Sum of Squares: 2190000
## Multiple R-Squared: 0.995
```




面板工具变量法
--------------

### Hausman-Taylor估计法

前面说到，使用固定效应模型的时候无法估计不随时间变化的量的影响。在没有理想的外部工具变量的情况下，我们可以采用Hausman-Taylor估计法来进行工具变量的运用。但是该方法有一个前提假设，就是有部分变量为外生，和残差项不相关；另一部分变量为内生，和残差项相关，在具体研究中需要证明这一点才能保证估计的一致性。

调用该方法的函数为`pht()`。我们下面再来看一个工资的问题，这个时候使用Wages数据集，其包含了1976到1982年美国595个个体的数据。



```r
data("Wages", package = "plm")
ht <- plm(lwage ~ wks + south + smsa + married + exp + I(exp^2) + 
    bluecol + ind + union + sex + black + ed | sex + black + bluecol + south + 
    smsa + ind, data = Wages, model = "ht", index = 595)
summary(ht)
```



```
## Oneway (individual) effect Hausman-Taylor Model
## Call:
## pht(formula = lwage ~ wks + south + smsa + married + exp + I(exp^2) + 
##     bluecol + ind + union + sex + black + ed | sex + black + 
##     bluecol + south + smsa + ind, data = Wages, index = 595)
## 
## T.V. exo  : bluecol,south,smsa,ind
## T.V. endo : wks,married,exp,I(exp^2),union
## T.I. exo  : sex,black
## T.I. endo : ed
## 
## Balanced Panel: n=595, T=7, N=4165
## 
## Effects:
##                 var std.dev share
## idiosyncratic 0.023   0.152  0.03
## individual    0.887   0.942  0.97
## theta:  0.939  
## 
## Residuals :
##     Min.  1st Qu.   Median  3rd Qu.     Max. 
## -1.92000 -0.07070  0.00657  0.07970  2.03000 
## 
## Coefficients :
##              Estimate Std. Error t-value Pr(>|t|)    
## (Intercept)  2.78e+00   3.08e-01    9.04  < 2e-16 ***
## wks          8.37e-04   6.00e-04    1.40    0.163    
## southyes     7.44e-03   3.20e-02    0.23    0.816    
## smsayes     -4.18e-02   1.90e-02   -2.21    0.027 *  
## marriedyes  -2.99e-02   1.90e-02   -1.57    0.116    
## exp          1.13e-01   2.47e-03   45.79  < 2e-16 ***
## I(exp^2)    -4.19e-04   5.46e-05   -7.67  1.7e-14 ***
## bluecolyes  -2.07e-02   1.38e-02   -1.50    0.133    
## ind          1.36e-02   1.52e-02    0.89    0.372    
## unionyes     3.28e-02   1.49e-02    2.20    0.028 *  
## sexmale      1.31e-01   1.27e-01    1.03    0.301    
## blackyes    -2.86e-01   1.56e-01   -1.84    0.066 .  
## ed           1.38e-01   2.12e-02    6.49  8.5e-11 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    887
## Residual Sum of Squares: 95.9
## F-statistic: 2852.33 on 12 and 4152 DF, p-value: <2e-16
```




### 外部工具变量

当存在一些外部的工具变量满足工具变量的要求的时候，我们可以直接使用它们代替原有变量进行回归，只是需要在调用`plm()`函数的时候用
符号指定就好。

我们依旧来看那个犯罪率的问题。这里我们扩展到整个面板数据，调用**plm**包中的Crime数据集，里面包含了1981-1987年间美国90个郡的数据。我们这里依旧想研究影响犯罪率的因素。

因为变量比较多，所以不一一解释其含义，可以直接参照包中的说明。下面我们希望以$log(taxpc)$和$log(mix)$作为工具变量，分别代替$log(prbarr)$和$log(polpc)$，故只需要在原始回归方程中加入` . - log(prbarr) - log(polpc) + log(taxpc) + log(mix)`即可。



```r
data("Crime", package = "plm")
cr <- plm(log(crmrte) ~ log(prbarr) + log(polpc) + log(prbconv) + 
    log(prbpris) + log(avgsen) + log(density) + log(wcon) + log(wtuc) + log(wtrd) + 
    log(wfir) + log(wser) + log(wmfg) + log(wfed) + log(wsta) + log(wloc) + 
    log(pctymle) + log(pctmin) + region + smsa + factor(year) | . - log(prbarr) - 
    log(polpc) + log(taxpc) + log(mix), data = Crime, model = "random")
summary(cr)
```



```
## Oneway (individual) effect Random Effect Model 
##    (Swamy-Arora's transformation)
## Instrumental variable estimation
##    (Balestra-Varadharajan-Krishnakumar's transformation)
## 
## Call:
## plm(formula = log(crmrte) ~ log(prbarr) + log(polpc) + log(prbconv) + 
##     log(prbpris) + log(avgsen) + log(density) + log(wcon) + log(wtuc) + 
##     log(wtrd) + log(wfir) + log(wser) + log(wmfg) + log(wfed) + 
##     log(wsta) + log(wloc) + log(pctymle) + log(pctmin) + region + 
##     smsa + factor(year) | . - log(prbarr) - log(polpc) + log(taxpc) + 
##     log(mix), data = Crime, model = "random")
## 
## Balanced Panel: n=90, T=7, N=630
## 
## Effects:
##                  var std.dev share
## idiosyncratic 0.0223  0.1492  0.33
## individual    0.0460  0.2146  0.67
## theta:  0.746  
## 
## Residuals :
##    Min. 1st Qu.  Median 3rd Qu.    Max. 
## -5.0200 -0.4760  0.0273  0.5260  3.1900 
## 
## Coefficients :
##                Estimate Std. Error t-value Pr(>|t|)    
## (Intercept)    -0.45382    1.70298   -0.27   0.7900    
## log(prbarr)    -0.41412    0.22105   -1.87   0.0615 .  
## log(polpc)      0.50493    0.22778    2.22   0.0270 *  
## log(prbconv)   -0.34324    0.13247   -2.59   0.0098 ** 
## log(prbpris)   -0.19004    0.07334   -2.59   0.0098 ** 
## log(avgsen)    -0.00644    0.02894   -0.22   0.8241    
## log(density)    0.43435    0.07115    6.10  1.8e-09 ***
## log(wcon)      -0.00430    0.04142   -0.10   0.9174    
## log(wtuc)       0.04446    0.02154    2.06   0.0395 *  
## log(wtrd)      -0.00856    0.04198   -0.20   0.8385    
## log(wfir)      -0.00403    0.02946   -0.14   0.8912    
## log(wser)       0.01056    0.02158    0.49   0.6248    
## log(wmfg)      -0.20179    0.08394   -2.40   0.0165 *  
## log(wfed)      -0.21346    0.21511   -0.99   0.3214    
## log(wsta)      -0.06011    0.12031   -0.50   0.6175    
## log(wloc)       0.18351    0.13967    1.31   0.1894    
## log(pctymle)   -0.14584    0.22681   -0.64   0.5205    
## log(pctmin)     0.19488    0.04594    4.24  2.6e-05 ***
## regionwest     -0.22818    0.10103   -2.26   0.0243 *  
## regioncentral  -0.19877    0.06075   -3.27   0.0011 ** 
## smsayes        -0.25954    0.14998   -1.73   0.0840 .  
## factor(year)82  0.01321    0.02999    0.44   0.6597    
## factor(year)83 -0.08477    0.03200   -2.65   0.0083 ** 
## factor(year)84 -0.10620    0.03879   -2.74   0.0064 ** 
## factor(year)85 -0.09774    0.05117   -1.91   0.0566 .  
## factor(year)86 -0.07194    0.06058   -1.19   0.2355    
## factor(year)87 -0.03965    0.07585   -0.52   0.6013    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Total Sum of Squares:    30.2
## Residual Sum of Squares: 558
## R-Squared      :  0.592 
##       Adj. R-Squared :  0.567 
## F-statistic: -21.9376 on 26 and 603 DF, p-value: 1
```




序列相关性检验（Tests of serial correlation）
-------------------------------------------

横截面的依赖性检验（Tests for cross-sectional dependence）
--------------------------------------------------------

动态面板分析：广义矩估计（GMM）
----------------------------

当回归方程中有被解释变量的滞后值作为解释变量的时候，便形成了动态面板数据。由于滞后项的存在，原来的估计成为了不一致的估计，即“动态面板偏差”。对于此种情况的出现，分别有差分GMM（difference GMM）和系统GMM（system GMM）可以用来解决。R中对应的函数为`pgmm()`。

在EmplUK数据集中，涵盖了1976到1984年间英国工厂的就业和工资情况的数据，且该面板为非平衡面板。我们这里关系就业情况。由于上一期的就业会很直接的影响当期就业水平，所以回归方程中包含了就业作为解释变量，该问题成为了动态面板分析。

在这里我们首先用差分GMM来估计，选择双向效应和两步法。



```r
data("EmplUK", package = "plm")
emp.gmm <- pgmm(log(emp) ~ lag(log(emp), 1:2) + lag(log(wage), 0:1) + 
    log(capital) + lag(log(output), 0:1) | lag(log(emp), 2:99), data = EmplUK, 
    effect = "twoways", model = "twosteps")
summary(emp.gmm)
```



```
## Twoways effects Two steps model
## 
## Call:
## pgmm(formula = log(emp) ~ lag(log(emp), 1:2) + lag(log(wage), 
##     0:1) + log(capital) + lag(log(output), 0:1) | lag(log(emp), 
##     2:99), data = EmplUK, effect = "twoways", model = "twosteps")
## 
## Unbalanced Panel: n=140, T=7-9, N=1031
## 
## Number of Observations Used:  611 
## 
## Residuals
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.6190 -0.0256  0.0000 -0.0001  0.0332  0.6410 
## 
## Coefficients
##                        Estimate Std. Error z-value Pr(>|z|)    
## lag(log(emp), 1:2)1      0.4742     0.0853    5.56  2.7e-08 ***
## lag(log(emp), 1:2)2     -0.0530     0.0273   -1.94  0.05222 .  
## lag(log(wage), 0:1)0    -0.5132     0.0493  -10.40  < 2e-16 ***
## lag(log(wage), 0:1)1     0.2246     0.0801    2.81  0.00502 ** 
## log(capital)             0.2927     0.0395    7.42  1.2e-13 ***
## lag(log(output), 0:1)0   0.6098     0.1085    5.62  1.9e-08 ***
## lag(log(output), 0:1)1  -0.4464     0.1248   -3.58  0.00035 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Sargan Test: chisq(25) = 30.11 (p.value=0.22)
## Autocorrelation test (1): normal = -2.428 (p.value=0.00759)
## Autocorrelation test (2): normal = -0.3325 (p.value=0.37)
## Wald test for coefficients: chisq(7) = 372 (p.value=<2e-16)
## Wald test for time dummies: chisq(6) = 26.9 (p.value=0.000151)
```




当然我们也可以用系统GMM来估计，只需要加上一个参数`` transformation = "ld" ``即可。最后可以在`summary()`中加入`robust = TRUE`来查看模型的稳健性。



```r
z2 <- pgmm(log(emp) ~ lag(log(emp), 1) + lag(log(wage), 0:1) + lag(log(capital), 
    0:1) | lag(log(emp), 2:99) + lag(log(wage), 2:99) + lag(log(capital), 2:99), 
    data = EmplUK, effect = "twoways", model = "onestep", transformation = "ld")
summary(z2, robust = TRUE)
```



```
## Twoways effects One step model
## 
## Call:
## pgmm(formula = log(emp) ~ lag(log(emp), 1) + lag(log(wage), 0:1) + 
##     lag(log(capital), 0:1) | lag(log(emp), 2:99) + lag(log(wage), 
##     2:99) + lag(log(capital), 2:99), data = EmplUK, effect = "twoways", 
##     model = "onestep", transformation = "ld")
## 
## Unbalanced Panel: n=140, T=7-9, N=1031
## 
## Number of Observations Used:  1642 
## 
## Residuals
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.7530 -0.0369  0.0000  0.0003  0.0466  0.6000 
## 
## Coefficients
##                         Estimate Std. Error z-value Pr(>|z|)    
## lag(log(emp), 1)          0.9356     0.0263   35.58  < 2e-16 ***
## lag(log(wage), 0:1)0     -0.6310     0.1181   -5.34  9.1e-08 ***
## lag(log(wage), 0:1)1      0.4826     0.1369    3.53  0.00042 ***
## lag(log(capital), 0:1)0   0.4839     0.0539    8.98  < 2e-16 ***
## lag(log(capital), 0:1)1  -0.4244     0.0585   -7.26  4.0e-13 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Sargan Test: chisq(100) = 236 (p.value=5.21e-13)
## Autocorrelation test (1): normal = -4.808 (p.value=7.61e-07)
## Autocorrelation test (2): normal = -0.28 (p.value=0.39)
## Wald test for coefficients: chisq(5) = 11175 (p.value=<2e-16)
## Wald test for time dummies: chisq(7) = 14.71 (p.value=0.0399)
```




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
