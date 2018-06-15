### R code from vignette source 'fastMcd-kmini.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: init
###################################################
# set margins for plots
options(SweaveHooks=list(fig=function() par(mar=c(3,3,1.4,0.7),
                         mgp=c(1.5, 0.5, 0))),
        width = 75)


###################################################
### code chunk number 2: h.alpha.ex
###################################################
require(robustbase)
n <- c(5, 10, 20, 30, 50, 100, 200, 500)
hmat <- function(alpha, p) cbind(n, h.alpha = h.alpha.n (alpha, n,p),
        h. = floor(alpha * (n + p + 1)), alpha.n = round(alpha * n))
hmat(alpha = 1/2, p = 3)
hmat(alpha = 3/4, p = 4)


