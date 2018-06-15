### R code from vignette source 'Rcpp-introduction.Rnw'

###################################################
### code chunk number 1: prelim
###################################################
library(Rcpp)
rcpp.version <- packageDescription("Rcpp")$Version
rcpp.date <- packageDescription("Rcpp")$Date
now.date <- strftime(Sys.Date(), "%B %d, %Y")


