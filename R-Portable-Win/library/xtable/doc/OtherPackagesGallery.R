## ----set, include=FALSE--------------------------------------------------
library(knitr)
opts_chunk$set(fig.path = 'Figures/other', debug = TRUE, echo = TRUE)
opts_chunk$set(out.width = '0.9\\textwidth')

## ----package, results='asis'------------------------------
library(xtable)
options(xtable.floating = FALSE)
options(xtable.timestamp = "")
options(width = 60)
set.seed(1234)

## ----dataspdep--------------------------------------------
library(spdep)
data("oldcol", package = "spdep")
COL.lag.eig <- lagsarlm(CRIME ~ INC + HOVAL, data = COL.OLD[],
                        nb2listw(COL.nb))
class(COL.lag.eig)
COL.errW.GM <- GMerrorsar(CRIME ~ INC + HOVAL, data = COL.OLD,
                          nb2listw(COL.nb, style = "W"),
                          returnHcov = TRUE)
class(COL.errW.GM)
COL.lag.stsls <- stsls(CRIME ~ INC + HOVAL, data = COL.OLD,
                       nb2listw(COL.nb))
class(COL.lag.stsls)

p1 <- predict(COL.lag.eig, newdata = COL.OLD[45:49,],
              listw = nb2listw(COL.nb))
class(p1)
p2 <- predict(COL.lag.eig, newdata = COL.OLD[45:49,],
              pred.type = "trend", type = "trend")
#type option for retrocompatibility with spdep 0.5-92
class(p2)

imp.exact <- impacts(COL.lag.eig, listw = nb2listw(COL.nb))
class(imp.exact)
imp.sim <- impacts(COL.lag.eig, listw = nb2listw(COL.nb), R = 200)
class(imp.sim)

## ----xtablesarlm, results = 'asis'------------------------
xtable(COL.lag.eig)

## ----xtablesarlmsumm, results = 'asis'--------------------
xtable(summary(COL.lag.eig, correlation = TRUE))

## ----xtablesarlmbooktabs, results = 'asis'----------------
print(xtable(COL.lag.eig), booktabs = TRUE)

## ----xtablegmsar, results = 'asis'------------------------
xtable(COL.errW.GM)

## ----xtablestsls, results = 'asis'------------------------
xtable(COL.lag.stsls)

## ----xtablesarlmpred, results = 'asis'--------------------
xtable(p1)

## ----xtablesarlmpred2, results = 'asis'-------------------
xtable(p2)

## ----xtablelagimpactexact, results = 'asis'---------------
xtable(imp.exact)

## ----xtablelagimpactmcmc, results = 'asis'----------------
xtable(imp.sim)

## ----minimalexample, results = 'hide'---------------------
library(spdep)
example(NY_data)
spautolmOBJECT <- spautolm(Z ~ PEXPOSURE + PCTAGE65P,data = nydata,
                           listw = listw_NY, family = "SAR",
                           method = "eigen", verbose = TRUE)
summary(spautolmOBJECT, Nagelkerke = TRUE)

## ----spautolmclass----------------------------------------
class(spautolmOBJECT)

## ----xtablespautolm, results = 'asis'---------------------
xtable(spautolmOBJECT,
       display = c("s",rep("f", 3), "e"), digits = 4)

## ----datasplm---------------------------------------------
library(splm)
data("Produc", package = "plm")
data("usaww",  package = "splm")
fm <- log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp
respatlag <- spml(fm, data = Produc, listw = mat2listw(usaww),
                   model="random", spatial.error="none", lag=TRUE)
class(respatlag)
GM <- spgm(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc,
           listw = usaww, moments = "fullweights", spatial.error = TRUE)
class(GM)

imp.spml <- impacts(respatlag, listw = mat2listw(usaww, style = "W"), time = 17)
class(imp.spml)

## ----xtablesplm, results = 'asis'-------------------------
xtable(respatlag)

## ----xtablesplm1, results = 'asis'------------------------
xtable(GM)

## ----xtablesplmimpacts, results = 'asis'------------------
xtable(imp.spml)

## ----datasphet--------------------------------------------
library(sphet)
data("columbus", package = "spdep")
listw <- nb2listw(col.gal.nb)
data("coldis", package = "sphet")
res.stsls <- stslshac(CRIME ~ HOVAL + INC, data = columbus, listw = listw,
                      distance = coldis, type = 'Triangular')
class(res.stsls)

res.gstsls <- gstslshet(CRIME ~ HOVAL + INC, data = columbus, listw = listw)
class(res.gstsls)

imp.gstsls <- impacts(res.gstsls, listw = listw)
class(imp.gstsls)

## ----xtablesphet, results = 'asis'------------------------
xtable(res.stsls)

## ----xtablesphet1, results = 'asis'-----------------------
xtable(res.gstsls)

## ----xtablesphetimpacts, results = 'asis'-----------------
xtable(imp.gstsls)

## ----zoo, results = 'asis'--------------------------------
library(zoo)
xDate <- as.Date("2003-02-01") + c(1, 3, 7, 9, 14) - 1
as.ts(xDate)
x <- zoo(rnorm(5), xDate)
xtable(x)

## ----zoots, results = 'asis'------------------------------
tempTs <- ts(cumsum(1 + round(rnorm(100), 0)),
              start = c(1954, 7), frequency = 12)
tempTable <- xtable(tempTs, digits = 0)
tempTable
tempZoo <- as.zoo(tempTs)
xtable(tempZoo, digits = 0)

## ----survival, results = 'asis'---------------------------
library(survival)
test1 <- list(time=c(4,3,1,1,2,2,3),
              status=c(1,1,1,0,1,1,0),
              x=c(0,2,1,1,1,0,0),
              sex=c(0,0,0,0,1,1,1))
coxFit <- coxph(Surv(time, status) ~ x + strata(sex), test1)
xtable(coxFit)

