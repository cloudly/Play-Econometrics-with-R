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