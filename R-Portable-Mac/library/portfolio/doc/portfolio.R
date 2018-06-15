### R code from vignette source 'portfolio.Rnw'

###################################################
### code chunk number 1: portfolio.Rnw:25-26
###################################################
op <- options(width = 50, digits = 4, scipen = 5)


###################################################
### code chunk number 2: portfolio.Rnw:52-56
###################################################
library(portfolio)
data(dow.jan.2005)
summary(dow.jan.2005)
head(dow.jan.2005)


###################################################
### code chunk number 3: portfolio.Rnw:70-71
###################################################
options(digits = 3)


###################################################
### code chunk number 4: portfolio.Rnw:74-82
###################################################
p <- new("portfolioBasic", 
         instant = as.Date("2004-12-31"),
         id.var  = "symbol",
         in.var  = "price",
         sides   = "long", 
         ret.var = "month.ret", 
         data    = dow.jan.2005)
summary(p)


###################################################
### code chunk number 5: portfolio.Rnw:110-111
###################################################
exposure(p, exp.var = c("price", "sector"))


###################################################
### code chunk number 6: portfolio.Rnw:145-146
###################################################
performance(p)


###################################################
### code chunk number 7: portfolio.Rnw:164-165
###################################################
contribution(p, contrib.var = c("sector"))


###################################################
### code chunk number 8: portfolio.Rnw:208-209
###################################################
contribution(p, contrib.var = c("cap.bil"))


###################################################
### code chunk number 9: portfolio.Rnw:237-246
###################################################
p <- new("portfolioBasic",
         instant = as.Date("2004-12-31"),
         id.var  = "symbol",
         in.var  = "price",
         type    = "linear",
         sides   = c("long", "short"),
         ret.var = "month.ret",
         data    = dow.jan.2005)
summary(p)


###################################################
### code chunk number 10: portfolio.Rnw:268-269
###################################################
plot(p)


###################################################
### code chunk number 11: portfolio.Rnw:278-279
###################################################
exposure(p, exp.var = c("price", "sector"))


###################################################
### code chunk number 12: portfolio.Rnw:324-325
###################################################
plot(exposure(p, exp.var = c("price", "sector")))


###################################################
### code chunk number 13: portfolio.Rnw:333-334
###################################################
performance(p)


###################################################
### code chunk number 14: portfolio.Rnw:349-350
###################################################
contribution(p, contrib.var = c("cap.bil", "sector"))


###################################################
### code chunk number 15: portfolio.Rnw:371-372
###################################################
plot(contribution(p, contrib.var = c("cap.bil", "sector")))


###################################################
### code chunk number 16: portfolio.Rnw:393-394
###################################################
options(op)


