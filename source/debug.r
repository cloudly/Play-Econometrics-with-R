
load("data/Papke_1995.rdata")
names(Papke_1995)

summary(Papke_1995)
RegModel<- lm(prate~mrate, data=Papke_1995)
summary(RegModel)

plot(Papke_1995$mrate,Papke_1995$prate) 
load("data/CRIME2.rda")

library(foreign)
CRIME2 = read.dta("CRIME2.dta")
save(CRIME2, file="data/CRIME2.rda")
OLS87<- lm(lcrmrte ~ lcrmrt.1 +llawexpc + unem, data=CRIME2,    subset=(year==87))
names(CRIME2)

data("Wages", package = "plm")
names(Wages)
library("plm")
ht <- plm(lwage~wks+south+smsa+married+exp+I(exp^2)+
  bluecol+ind+union+sex+black+ed | 
  sex+black+bluecol+south+smsa+ind,
          data=Wages,model="ht",index=595)

data("Crime", package = "plm")
cr <- plm(log(crmrte) ~ log(prbarr) + log(polpc) + log(prbconv) +
  log(prbpris) + log(avgsen) + log(density) + log(wcon) +
  log(wtuc) + log(wtrd) + log(wfir) + log(wser) + log(wmfg) +
  log(wfed) + log(wsta) + log(wloc) + log(pctymle) + log(pctmin) +
  region + smsa + factor(year) | . - log(prbarr) -log(polpc) +
  log(taxpc) + log(mix), data = Crime,
          model = "random")
summary(cr)

data("EmplUK", package = "plm")
emp.gmm <- pgmm(log(emp)~lag(log(emp), 1:2) +
  lag(log(wage), 0:1) + log(capital) 
  + lag(log(output), 0:1)|lag(log(emp), 2:99), data=EmplUK, 
  effect = "twoways", model = "twosteps")

sample <- read.table("data/sample.txt",header=TRUE, sep="\t")
write.table(book_map, file="data/book_map_new.txt", row.names=F, col.names=T, sep="\t", quote=F)

data(Grunfeld, package = "plm")
g_fixed_twoways <- plm(inv~value + capital, data = Grunfeld, effect = "twoways", model = "within")