### R code from vignette source 'iterators.Rnw'

###################################################
### code chunk number 1: ex1
###################################################
library(iterators)
i1 <- iter(1:10)
nextElem(i1)
nextElem(i1)


###################################################
### code chunk number 2: ex2
###################################################
istate <- iter(state.x77, by='row')
nextElem(istate)
nextElem(istate)


###################################################
### code chunk number 3: ex3
###################################################
ifun <- iter(function() sample(0:9, 4, replace=TRUE))
nextElem(ifun)
nextElem(ifun)


###################################################
### code chunk number 4: ex5
###################################################
library(iterators)
itrn <- irnorm(10)
nextElem(itrn)
nextElem(itrn)


###################################################
### code chunk number 5: ex6
###################################################
itru <- irunif(10)
nextElem(itru)
nextElem(itru)


###################################################
### code chunk number 6: ex7
###################################################
it <- icount(3)
nextElem(it)
nextElem(it)
nextElem(it)


