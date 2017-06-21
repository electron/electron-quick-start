###----------------- sparse / dense   interpSpline() ---------------------------

## This requires recommended package Matrix.

if(!requireNamespace("Matrix", quietly = TRUE)) q()

require("splines")

## from  help(interpSpline) -- ../man/interpSpline.Rd
ispl <- interpSpline( women$height, women$weight)
isp. <- interpSpline( women$height, women$weight, sparse=TRUE)
stopifnot(all.equal(ispl, isp., tol = 1e-12)) # seen 1.65e-14

##' @title Interpolate size-n version of the 'women' data sparsely and densely
##' @param n size of "women-like" data to interpolate
##' @return list with dense and sparse \code{\link{system.time}()}s
##' @author Martin Maechler
ipStime <- function(n) { # and using 'ispl'
    h <- seq(55, 75, length.out = n)
    w <- predict(ispl, h)$y
    c.d <- system.time(is.d <- interpSpline(h, w, sparse=FALSE))
    c.s <- system.time(is.s <- interpSpline(h, w, sparse=TRUE ))
    stopifnot(all.equal(is.d, is.s, tol = 1e-7)) # seen 9.4e-10 (n=1000), 1.3e-7 (n=5000)
    list(d.time = c.d, s.time = c.s)
}

n.s <- 25 * round(2^seq(1,6, by=.5))
if(!interactive())# save 'check time'
    n.s <- n.s[100 <= n.s & n.s <= 800]
(ipL <- lapply(setNames(n.s, paste0("n=",n.s)), ipStime))
## sparse is *an order of magnitude* faster for n ~= 1000 but somewhat slower for n ~< 200:
sapply(ipL, function(ip) round(ip$d.time / ip$s.time, 1)[c(1,3)])
##           n=50 n=75 n=100 n=150 n=200 n=275 n=400 n=575 n=800 n=1125 n=1600 -- nb-mm4, i7-5600U
## user.self  0.5  0.5   0.5   0.5   0.7   2.5   4.3  12.3  33.7   70.5  116.1
## elapsed    0.5  0.3   0.5   0.7   1.0   2.5   4.3  13.0  26.2   57.4  117.3
