### R code from vignette source 'Rcpp-sugar.Rnw'

###################################################
### code chunk number 1: Rcpp-sugar.Rnw:42-44
###################################################
prettyVersion <- packageDescription("Rcpp")$Version
prettyDate <- format(Sys.Date(), "%B %e, %Y")


###################################################
### code chunk number 3: Rcpp-sugar.Rnw:105-108 (eval = FALSE)
###################################################
## foo <- function(x, y){
##     ifelse( x < y, x*x, -(y*y) )
## }


