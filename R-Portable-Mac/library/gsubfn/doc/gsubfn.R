### R code from vignette source 'gsubfn.Rnw'

###################################################
### code chunk number 1: preliminaries
###################################################
library("gsubfn")
library("proto")


###################################################
### code chunk number 2: gsubfn-xypair
###################################################
   s <- 'abc 10:20 def 30:40 50'
   gsubfn('([0-9]+):([0-9]+)', ~ as.numeric(x) + as.numeric(y), s)


###################################################
### code chunk number 3: gsubfn-si
###################################################
   dat <- c('3.5G', '88P', '19') # test data
   gsubfn('[MGP]$', list(M = 'e6', G = 'e9', P = 'e12'), dat) 


###################################################
### code chunk number 4: gsubfn-proto-intro
###################################################
   p <- proto(fun = function(this, x) paste0(x, "{", count, "}"))
   class(p)
   ls(p)
   with(p, fun)
   s <- c("the dog and the cat are in the house", "x y x")
   gsubfn("\\w+", p, s)
   ls(p)
   p$count


###################################################
### code chunk number 5: gsubfn-words
###################################################
pwords <- proto(
	pre = function(this) { this$words <- list() },
	fun = function(this, x) {
		if (is.null(words[[x]])) this$words[[x]] <- 0
		this$words[[x]] <- words[[x]] + 1
		paste0(x, "{", words[[x]], "}")
	}
)
gsubfn("\\w+", pwords, "the dog and the cat are in the house")
ls(pwords)
dput(pwords$words)


###################################################
### code chunk number 6: gsubfn-strapply-initdigits
###################################################
   s <- c('123abc', '12cd34', '1e23')
   strapply(s, '^([[:digit:]]+)(.*)', c, simplify = rbind)


###################################################
### code chunk number 7: gsubfn-strapply-midpoint
###################################################
as.num <- function(x) if (x == "NA") NA else as.numeric(x)
rn <- c("[-11.9,-10.6]", "(NA,9.3]", "(9.3,8e01]", "(8.01,Inf]")
colMeans(strapply(rn, "[^][(),]+", as.num, simplify = TRUE))


###################################################
### code chunk number 8: gsubfn-strapply-combine
###################################################

s <- c('a:b c:d', 'e:f')

dput(strapply(s, '(.):(.)', c))

dput(strapply(s, '(.):(.)', c, combine = list))



###################################################
### code chunk number 9: gsubfn-strapply-words
###################################################
pwords2 <- proto(
	pre = function(this) { this$words <- list() },
	fun = function(this, x) {
		if (is.null(words[[x]])) this$words[[x]] <- 0
		this$words[[x]] <- words[[x]] + 1
		list(x, words[[x]])
	}
)
strapply("the dog and the cat are in the house", "\\w+", pwords2, 
	combine = list, simplify = x ~ do.call(rbind, x) )
ls(pwords2)
dput(pwords2$words)


###################################################
### code chunk number 10: gsubfn-paste0
###################################################
strapply(' a b c d e f ', ' [a-z](?=( [a-z] ))', paste0)[[1]]


###################################################
### code chunk number 11: gsubfn-fn
###################################################

fn$integrate(~ sin(x) + sin(x), 0, pi/2)

fn$lapply(list(1:4, 1:5), ~ LETTERS[x])

fn$mapply(~ seq_len(x) + y * z, 1:3, 4:6, 2) # list(9, 11:12, 13:15)

fn$by(CO2[4:5], CO2[2], x ~ coef(lm(uptake ~ ., x)), simplify = rbind)



###################################################
### code chunk number 12: gsubfn-fn-lattice (eval = FALSE)
###################################################
## library(lattice)
## library(grid)
## print(fn$xyplot(uptake ~ conc | Plant, CO2,
##       panel = ~~ { panel.xyplot(...); grid.text(panel.number(), .1, .85) }))


###################################################
### code chunk number 13: gsubfn-fn-lattice-repeat
###################################################
library(lattice)
library(grid)
print(fn$xyplot(uptake ~ conc | Plant, CO2,
      panel = ~~ { panel.xyplot(...); grid.text(panel.number(), .1, .85) }))


###################################################
### code chunk number 14: gsubfn-fn-simplify
###################################################
fn$by(CO2, CO2$Treatment, d ~ coef(lm(uptake ~ conc, d)), simplify = rbind)


###################################################
### code chunk number 15: gsubfn-fn-letters
###################################################
fn$lapply(list(1:4, 1:3), ~ LETTERS[x])


###################################################
### code chunk number 16: gsubfn-fn-aggregate2
###################################################
set.seed(1)
X <- data.frame(X = rnorm(24), W = runif(24), A = gl(2, 1, 24), B = gl(2, 2, 24))
fn$aggregate(1:nrow(X), X[3:4], i ~ weighted.mean(X[i,1], X[i,2]))



###################################################
### code chunk number 17: gsubfn-fn-math
###################################################
fn$integrate(~1/((x+1)*sqrt(x)), lower = 0, upper = Inf)

fn$optimize(~ x^2, c(-1,1))


###################################################
### code chunk number 18: gsubfn-fn-S4
###################################################
setClass('ooc', representation(a = 'numeric'))
fn$setGeneric('incr', x + value ~ standardGeneric('incr'))
fn$setMethod('incr', 'ooc', x + value ~ {x@a <- x@a+value; x})
oo <- new('ooc', a = 1)
oo <- incr(oo,1)
oo


###################################################
### code chunk number 19: gsubfn-fn-quantreg-load
###################################################
library(quantreg)
data(engel)
plot(engel$income, engel$foodexp, xlab = 'income', ylab = 'food expenditure')
junk <- fn$lapply(1:9/10, tau ~ abline(coef(rq(foodexp ~ income, tau, engel))))


###################################################
### code chunk number 20: gsubfn-fn-quantreg (eval = FALSE)
###################################################
## plot(engel$income, engel$foodexp, xlab = 'income', ylab = 'food expenditure')
## junk <- fn$lapply(1:9/10, tau ~ abline(coef(rq(foodexp ~ income, tau, engel))))


###################################################
### code chunk number 21: gsubfn-fn-quantreg-repeat
###################################################
plot(engel$income, engel$foodexp, xlab = 'income', ylab = 'food expenditure')
junk <- fn$lapply(1:9/10, tau ~ abline(coef(rq(foodexp ~ income, tau, engel))))


###################################################
### code chunk number 22: gsubfn-fn-zoo
###################################################
library(zoo)
fn$rollapply(LakeHuron, 12, ~ mean(range(x)))


###################################################
### code chunk number 23: gsubfn-fn-zoo
###################################################
library(boot)
set.seed(1)
fn$boot(rivers, ~ median(x[d]), R = 2000)


###################################################
### code chunk number 24: gsubfn-fn-pi (eval = FALSE)
###################################################
## x <- 0:50/50
## matplot(x, fn$outer(x, 1:8, ~ sin(x * k*pi)), type = 'blobcsSh')


###################################################
### code chunk number 25: gsubfn-fn-pi-repeat
###################################################
x <- 0:50/50
matplot(x, fn$outer(x, 1:8, ~ sin(x * k*pi)), type = 'blobcsSh')


###################################################
### code chunk number 26: gsubfn-fn-matmult
###################################################
a <- matrix(4:1, 2); b <- matrix(1:4, 2) # test matrices
fn$apply(b, 2, x ~ fn$apply(a, 1, y ~ sum(x*y)))
a %*% b 


###################################################
### code chunk number 27: gsubfn-fn-subseq
###################################################
L <- fn$apply(fn$sapply(1:4, ~ rbind(i,i:4), simplify = cbind), 2, ~ x[1]:x[2])
dput(L)


###################################################
### code chunk number 28: gsubfn-fn-python
###################################################
fn$sapply( 1:10, ~ if (x%%2==0) x^2, simplify = c)


###################################################
### code chunk number 29: gsubfn-fn-cat
###################################################
fn$cat("pi = $pi, exp = `exp(1)`\n")


###################################################
### code chunk number 30: gsubfn-fn-sq
###################################################
sq <- function(f, x) { f <- match.funfn(f); f(x^2) }

sq(~ exp(x)/x, pi)

f <- function(x) exp(x)/x
sq('f', pi) # character string

f <- function(x) exp(x)/x
sq(f, pi)
 
sq(function(x) exp(x)/x, pi)


