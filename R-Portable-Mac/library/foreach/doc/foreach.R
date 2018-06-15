### R code from vignette source 'foreach.Rnw'

###################################################
### code chunk number 1: loadLibs
###################################################
library(foreach)


###################################################
### code chunk number 2: ex1
###################################################
x <- foreach(i=1:3) %do% sqrt(i)
x


###################################################
### code chunk number 3: ex2
###################################################
x <- foreach(a=1:3, b=rep(10, 3)) %do% (a + b)
x


###################################################
### code chunk number 4: ex3
###################################################
x <- foreach(a=1:3, b=rep(10, 3)) %do% {
  a + b
}
x


###################################################
### code chunk number 5: ex4
###################################################
x <- foreach(a=1:1000, b=rep(10, 2)) %do% {
  a + b
}
x


###################################################
### code chunk number 6: ex5
###################################################
x <- foreach(i=1:3, .combine='c') %do% exp(i)
x


###################################################
### code chunk number 7: ex6
###################################################
x <- foreach(i=1:4, .combine='cbind') %do% rnorm(4)
x


###################################################
### code chunk number 8: ex7
###################################################
x <- foreach(i=1:4, .combine='+') %do% rnorm(4)
x


###################################################
### code chunk number 9: ex7.1
###################################################
cfun <- function(a, b) NULL
x <- foreach(i=1:4, .combine='cfun') %do% rnorm(4)
x


###################################################
### code chunk number 10: ex7.2
###################################################
cfun <- function(...) NULL
x <- foreach(i=1:4, .combine='cfun', .multicombine=TRUE) %do% rnorm(4)
x


###################################################
### code chunk number 11: ex7.2
###################################################
cfun <- function(...) NULL
x <- foreach(i=1:4, .combine='cfun', .multicombine=TRUE, .maxcombine=10) %do% rnorm(4)
x


###################################################
### code chunk number 12: ex7.3
###################################################
foreach(i=4:1, .combine='c') %dopar% {
  Sys.sleep(3 * i)
  i
}
foreach(i=4:1, .combine='c', .inorder=FALSE) %dopar% {
  Sys.sleep(3 * i)
  i
}


###################################################
### code chunk number 13: ex8
###################################################
library(iterators)
x <- foreach(a=irnorm(4, count=4), .combine='cbind') %do% a
x


###################################################
### code chunk number 14: ex9
###################################################
set.seed(123)
x <- foreach(a=irnorm(4, count=1000), .combine='+') %do% a
x


###################################################
### code chunk number 15: ex10
###################################################
set.seed(123)
x <- numeric(4)
i <- 0
while (i < 1000) {
  x <- x + rnorm(4)
  i <- i + 1
}
x


###################################################
### code chunk number 16: ex11
###################################################
set.seed(123)
x <- foreach(icount(1000), .combine='+') %do% rnorm(4)
x


###################################################
### code chunk number 17: ex12.data
###################################################
x <- matrix(runif(500), 100)
y <- gl(2, 50)


###################################################
### code chunk number 18: ex12.load
###################################################
library(randomForest)


###################################################
### code chunk number 19: ex12.seq
###################################################
rf <- foreach(ntree=rep(250, 4), .combine=combine) %do%
  randomForest(x, y, ntree=ntree)
rf


###################################################
### code chunk number 20: ex12.par
###################################################
rf <- foreach(ntree=rep(250, 4), .combine=combine, .packages='randomForest') %dopar%
  randomForest(x, y, ntree=ntree)
rf


###################################################
### code chunk number 21: ex13.orig
###################################################
applyKernel <- function(newX, FUN, d2, d.call, dn.call=NULL, ...) {
  ans <- vector("list", d2)
  for(i in 1:d2) {
    tmp <- FUN(array(newX[,i], d.call, dn.call), ...)
    if(!is.null(tmp)) ans[[i]] <- tmp
  }
  ans
}
applyKernel(matrix(1:16, 4), mean, 4, 4)


###################################################
### code chunk number 22: ex13.first
###################################################
applyKernel <- function(newX, FUN, d2, d.call, dn.call=NULL, ...) {
  foreach(i=1:d2) %dopar%
    FUN(array(newX[,i], d.call, dn.call), ...)
}
applyKernel(matrix(1:16, 4), mean, 4, 4)


###################################################
### code chunk number 23: ex13.second
###################################################
applyKernel <- function(newX, FUN, d2, d.call, dn.call=NULL, ...) {
  foreach(x=iter(newX, by='col')) %dopar%
    FUN(array(x, d.call, dn.call), ...)
}
applyKernel(matrix(1:16, 4), mean, 4, 4)


###################################################
### code chunk number 24: ex13.iter
###################################################
iblkcol <- function(a, chunks) {
  n <- ncol(a)
  i <- 1

  nextElem <- function() {
    if (chunks <= 0 || n <= 0) stop('StopIteration')
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    chunks <<- chunks - 1
    a[,r, drop=FALSE]
  }

  structure(list(nextElem=nextElem), class=c('iblkcol', 'iter'))
}
nextElem.iblkcol <- function(obj) obj$nextElem()


###################################################
### code chunk number 25: ex13.third
###################################################
applyKernel <- function(newX, FUN, d2, d.call, dn.call=NULL, ...) {
  foreach(x=iblkcol(newX, 3), .combine='c', .packages='foreach') %dopar% {
    foreach(i=1:ncol(x)) %do% FUN(array(x[,i], d.call, dn.call), ...)
  }
}
applyKernel(matrix(1:16, 4), mean, 4, 4)


###################################################
### code chunk number 26: when
###################################################
x <- foreach(a=irnorm(1, count=10), .combine='c') %:% when(a >= 0) %do% sqrt(a)
x


###################################################
### code chunk number 27: qsort
###################################################
qsort <- function(x) {
  n <- length(x)
  if (n == 0) {
    x
  } else {
    p <- sample(n, 1)
    smaller <- foreach(y=x[-p], .combine=c) %:% when(y <= x[p]) %do% y
    larger  <- foreach(y=x[-p], .combine=c) %:% when(y >  x[p]) %do% y
    c(qsort(smaller), x[p], qsort(larger))
  }
}

qsort(runif(12))


