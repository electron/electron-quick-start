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

