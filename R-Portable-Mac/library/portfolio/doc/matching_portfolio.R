### R code from vignette source 'matching_portfolio.Rnw'

###################################################
### code chunk number 1: matching_portfolio.Rnw:53-54
###################################################
op <- options(width = 80, digits = 2, scipen = 5)


###################################################
### code chunk number 2: matching_portfolio.Rnw:72-73
###################################################
library(portfolio)


###################################################
### code chunk number 3: matching_portfolio.Rnw:76-79
###################################################
data(assay)
assay[c(1407, 1873, 1058, 2453, 1833, 1390), c("id", "symbol", "name", "country", 
  "currency", "price", "sector", "liq", "on.fl", "ret.0.3.m", "ret.0.6.m")]


###################################################
### code chunk number 4: creating assay portfolio
###################################################
assay$assay.wt <- ifelse(assay$on.fl, -1, NA)
p <- new("portfolioBasic",
         name    = "AFL Portfolio",
         instant = as.Date("2004-12-31"),
         data    = assay,
         id.var  = "symbol",
         in.var  = "assay.wt",
         type    = "relative",
         size    = "all",
         ret.var = "ret.0.3.m")
summary(p)
summary(performance(p))


###################################################
### code chunk number 5: measuring sector exposure
###################################################
exposure(p, exp.var = 'sector')


###################################################
### code chunk number 6: matching_portfolio.Rnw:318-319
###################################################
p.m <- matching(p, covariates = c("country", "sector", "liq"))


###################################################
### code chunk number 7: matching_portfolio.Rnw:321-322
###################################################
summary(p.m)


###################################################
### code chunk number 8: test all
###################################################
all(!p.m@matches[,1] %in% p@weights$id)


###################################################
### code chunk number 9: matching_portfolio.Rnw:340-342
###################################################
exposure(p, exp.var = "sector")
exposure(p.m, exp.var = "sector")


###################################################
### code chunk number 10: matching_portfolio.Rnw:350-351
###################################################
exposure(p, exp.var = "liq")


###################################################
### code chunk number 11: matching_portfolio.Rnw:356-357
###################################################
exposure(p.m, exp.var = "liq")


###################################################
### code chunk number 12: matching_portfolio.Rnw:378-379
###################################################
summary(performance(p.m))


###################################################
### code chunk number 13: matching_portfolio.Rnw:411-412
###################################################
options(op)


