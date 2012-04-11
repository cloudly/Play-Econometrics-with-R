load("data/reshape_sample.rdata")
reshape_sample$CUSTOMER_ID <- as.factor(reshape_sample$CUSTOMER_ID)
reshape_sample$MONTH <- as.factor(reshape_sample$MONTH)
save(reshape_sample, file="data/reshape_sample.rdata")
summary(reshape_sample)
head(reshape_sample)

summary(reshape_sample_wide)
head(reshape_sample_wide)

reshape_sample_long <- melt(reshape_sample_wide, id=c("CUSTOMER_ID"))
head(reshape_sample_long[order(reshape_sample_long$CUSTOMER_ID),])
library(reshape2)
data(airquality)
names(airquality) <- tolower(names(airquality))
airquality
melt(airquality, id=c("month", "day"))
names(ChickWeight) <- tolower(names(ChickWeight))
melt(ChickWeight, id=2:4)

names(airquality) <- tolower(names(airquality))
aqm <- melt(airquality, id=c("month", "day"), na.rm=TRUE)
summary(aqm)
acast(aqm, day ~ month ~ variable)

#foreign

library(foreign)
WAGEPAN = read.dta("data/WAGEPAN.DTA")
summary(Papke_1995)

save(WAGEPAN, file="WAGEPAN.rdata")

save(Papke_1995,file="Papke_1995.rdata")
plot(Papke_1995$mrate,Papke_1995$prate) 

RegModel<- lm(prate~mrate, data=Papke_1995)
abline(RegModel,col="red")
mrate_new <- data.frame(mrate = 3.5)
mrate_new <- data.frame(mrate = 3.5)
predict(RegModel,mrate_new)

library(foreign)
Attend <- read.dta("data/attend.dta")
Reg2<-lm(atndrte~priGPA+ACT, data=Attend) 
summary(Reg2)

library(knitr)
pat_gfm()



HPrice <- read.dta("data/hprice1.dta")
Hprice_Result <- lm(price~bdrms+lotsize+sqrft, data=HPrice)
library("lmtest")
bptest(Hprice_Result)
Hprice_Result2 <- lm(log(price)~bdrms+log(lotsize)+log(sqrft), data=HPrice)
Hprice_Result2
bptest(Hprice_Result2)
library(car)
ncvTest(Hprice_Result2)
bptest(Hprice_Result2,studentize=FALSE,varformula = ~fitted.values(Hprice_Result2), data=HPrice)

library("sandwich")
vcovHC(Hprice_Result)
coeftest(Hprice_Result, vcov = vcovHC)

library(AER) 
data("RecreationDemand") 
rd_pois <- glm(trips ~ ., data = RecreationDemand, family = poisson) 
dispersiontest(rd_pois) 
dispersiontest(rd_pois, trafo = 2)
library("MASS")  
rd_nb <- glm.nb(trips ~ ., data = RecreationDemand)  
coeftest(rd_nb)
logLik(rd_nb)

load("data/CRIME1.rda")
CRIME1_poisson<- glm(narr86 ~ pcnv+avgsen +tottime +ptime86 +qemp86 +inc86 +black +hispan +born60, family=poisson(log),    data=CRIME1)
CRIME1_poisson
CRIME1_quasipoisson <- glm(narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + inc86 + black + hispan + born60,    family=quasipoisson(log), data=CRIME1)
CRIME1_quasipoisson 
library("pscl")
CRIME1_zip <- zeroinfl(narr86 ~ pcnv + avgsen + tottime + ptime86 + qemp86 + inc86 + black + hispan + born60|inc86, data = CRIME1, dist = "negbin")
summary(CRIME1_zip)

data(Grunfeld, package="AER") 
library("systemfit") 
library("plm") 
gr2 <- subset(Grunfeld, firm %in% c("Chrysler", "IBM")) 
pgr2 <- plm.data(gr2, c("firm", "year")) 
gr_sur <- systemfit(invest ~ value + capital, method = "SUR", data = pgr2) 
summary(gr_sur, residCov = FALSE, equations = FALSE)

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