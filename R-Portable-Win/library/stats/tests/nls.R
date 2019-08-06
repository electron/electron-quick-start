#  File src/library/stats/tests/nls.R
#  Part of the R package, https://www.R-project.org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

## tests of nls, especially of weighted fits

library(stats)
options(digits = 5) # to avoid trivial printed differences
options(useFancyQuotes = FALSE) # avoid fancy quotes in o/p
options(show.nls.convergence = FALSE) # avoid non-diffable output
options(warn = 1)

have_MASS <- requireNamespace('MASS', quietly = TRUE)

pdf("nls-test.pdf")

## utility for comparing nls() results:  [TODO: use more often below]
.n <- function(r) r[names(r) != "call"]

## selfStart.default() w/ no parameters:
logist <- deriv( ~Asym/(1+exp(-(x-xmid)/scal)), c("Asym", "xmid", "scal"),
		function(x, Asym, xmid, scal){} )
logistInit <- function(mCall, LHS, data) {
    xy <- sortedXyData(mCall[["x"]], LHS, data)
    if(nrow(xy) < 3) stop("Too few distinct input values to fit a logistic")
    Asym <- max(abs(xy[,"y"]))
    if (Asym != max(xy[,"y"])) Asym <- -Asym  # negative asymptote
    xmid <- NLSstClosestX(xy, 0.5 * Asym)
    scal <- NLSstClosestX(xy, 0.75 * Asym) - xmid
    setNames(c(Asym, xmid, scal),
	     mCall[c("Asym", "xmid", "scal")])
}
logist <- selfStart(logist, initial = logistInit) ##-> Error in R 1.5.0
str(logist)

## lower and upper in algorithm="port"
set.seed(123)
x <- runif(200)
a <- b <- 1; c <- -0.1
y <- a+b*x+c*x^2+rnorm(200, sd=0.05)
plot(x,y)
curve(a+b*x+c*x^2, add = TRUE)
nls(y ~ a+b*x+c*I(x^2), start = c(a=1, b=1, c=0.1), algorithm = "port")
(fm <- nls(y ~ a+b*x+c*I(x^2), start = c(a=1, b=1, c=0.1),
           algorithm = "port", lower = c(0, 0, 0)))
if(have_MASS) print(confint(fm))

## weighted nls fit: unsupported < 2.3.0
set.seed(123)
y <- x <- 1:10
yeps <- y + rnorm(length(y), sd = 0.01)
wts <- rep(c(1, 2), length = 10); wts[5] <- 0
fit0 <- lm(yeps ~ x, weights = wts)
summary(fit0, cor = TRUE)
cf0 <- coef(summary(fit0))[, 1:2]
fit <- nls(yeps ~ a + b*x, start = list(a = 0.12345, b = 0.54321),
           weights = wts, trace = TRUE)
summary(fit, cor = TRUE)
stopifnot(all.equal(residuals(fit), residuals(fit0), tolerance = 1e-5,
                    check.attributes = FALSE))
stopifnot(df.residual(fit) == df.residual(fit0))
cf1 <- coef(summary(fit))[, 1:2]
fit2 <- nls(yeps ~ a + b*x, start = list(a = 0.12345, b = 0.54321),
            weights = wts, trace = TRUE, algorithm = "port")
summary(fit2, cor = TRUE)
cf2 <- coef(summary(fit2))[, 1:2]
rownames(cf0) <- c("a", "b")
# expect relative errors ca 2e-08
stopifnot(all.equal(cf1, cf0, tolerance = 1e-6),
          all.equal(cf1, cf0, tolerance = 1e-6))
stopifnot(all.equal(residuals(fit2), residuals(fit0), tolerance = 1e5,
                    check.attributes = FALSE))


DNase1 <- subset(DNase, Run == 1)
DNase1$wts <- rep(8:1, each = 2)
fm1 <- nls(density ~ SSlogis(log(conc), Asym, xmid, scal),
           data = DNase1, weights = wts)
summary(fm1)

## directly
fm2 <- nls(density ~ Asym/(1 + exp((xmid - log(conc))/scal)),
           data = DNase1, weights = wts,
           start = list(Asym = 3, xmid = 0, scal = 1))
summary(fm2)
stopifnot(all.equal(coef(summary(fm2)), coef(summary(fm1)), tolerance = 1e-6))
stopifnot(all.equal(residuals(fm2), residuals(fm1), tolerance = 1e-5))
stopifnot(all.equal(fitted(fm2), fitted(fm1), tolerance = 1e-6))
fm2a <- nls(density ~ Asym/(1 + exp((xmid - log(conc)))),
            data = DNase1, weights = wts,
            start = list(Asym = 3, xmid = 0))
anova(fm2a, fm2)

## and without using weights
fm3 <- nls(~ sqrt(wts) * (density - Asym/(1 + exp((xmid - log(conc))/scal))),
           data = DNase1, start = list(Asym = 3, xmid = 0, scal = 1))
summary(fm3)
stopifnot(all.equal(coef(summary(fm3)), coef(summary(fm1)), tolerance = 1e-6))
ft <- with(DNase1, density - fitted(fm3)/sqrt(wts))
stopifnot(all.equal(ft, fitted(fm1), tolerance = 1e-6))
# sign of residuals is reversed
r <- with(DNase1, -residuals(fm3)/sqrt(wts))
all.equal(r, residuals(fm1), tolerance = 1e-5)
fm3a <- nls(~ sqrt(wts) * (density - Asym/(1 + exp((xmid - log(conc))))),
            data = DNase1, start = list(Asym = 3, xmid = 0))
anova(fm3a, fm3)

## using conditional linearity
fm4 <- nls(density ~ 1/(1 + exp((xmid - log(conc))/scal)),
           data = DNase1, weights = wts,
           start = list(xmid = 0, scal = 1), algorithm = "plinear")
summary(fm4)
cf <- coef(summary(fm4))[c(3,1,2), ]
rownames(cf)[2] <- "Asym"
stopifnot(all.equal(cf, coef(summary(fm1)), tolerance = 1e-6,
                    check.attributes = FALSE))
stopifnot(all.equal(residuals(fm4), residuals(fm1), tolerance = 1e-5))
stopifnot(all.equal(fitted(fm4), fitted(fm1), tolerance = 1e-6))
fm4a <- nls(density ~ 1/(1 + exp((xmid - log(conc)))),
            data = DNase1, weights = wts,
            start = list(xmid = 0), algorithm = "plinear")
anova(fm4a, fm4)

## using 'port'
fm5 <- nls(density ~ Asym/(1 + exp((xmid - log(conc))/scal)),
           data = DNase1, weights = wts,
           start = list(Asym = 3, xmid = 0, scal = 1),
           algorithm = "port")
summary(fm5)
stopifnot(all.equal(coef(summary(fm5)), coef(summary(fm1)), tolerance = 1e-6))
stopifnot(all.equal(residuals(fm5), residuals(fm1), tolerance = 1e-5))
stopifnot(all.equal(fitted(fm5), fitted(fm1), tolerance = 1e-6))

## check profiling
pfm1 <- profile(fm1)
pfm3 <- profile(fm3)
for(m in names(pfm1))
    stopifnot(all.equal(pfm1[[m]], pfm3[[m]], tolerance = 1e-5))
pfm5 <- profile(fm5)
for(m in names(pfm1))
    stopifnot(all.equal(pfm1[[m]], pfm5[[m]], tolerance = 1e-5))
if(have_MASS) {
    print(c1 <- confint(fm1))
    print(c4 <- confint(fm4, 1:2))
    stopifnot(all.equal(c1[2:3, ], c4, tolerance = 1e-3))
}

## some low-dimensional examples
npts <- 1000
set.seed(1001)
x <- runif(npts)
b <- 0.7
y <- x^b+rnorm(npts, sd=0.05)
a <- 0.5
y2 <- a*x^b+rnorm(npts, sd=0.05)
c <- 1.0
y3 <- a*(x+c)^b+rnorm(npts, sd=0.05)
d <- 0.5
y4 <- a*(x^d+c)^b+rnorm(npts, sd=0.05)
m1 <- c(y ~ x^b, y2 ~ a*x^b, y3 ~ a*(x+exp(logc))^b)
s1 <- list(c(b=1), c(a=1,b=1), c(a=1,b=1,logc=0))
for(p in 1:3) {
    fm <- nls(m1[[p]], start = s1[[p]])
    print(fm)
    if(have_MASS) print(confint(fm))
    fm <- nls(m1[[p]], start = s1[[p]], algorithm = "port")
    print(fm)
    if(have_MASS) print(confint(fm))
}

if(have_MASS) {
    fm <- nls(y2~x^b, start=c(b=1), algorithm="plinear")
    print(confint(profile(fm)))
    fm <- nls(y3 ~ (x+exp(logc))^b, start=c(b=1, logc=0), algorithm="plinear")
    print(confint(profile(fm)))
}


## more profiling with bounds
op <- options(digits=3)
npts <- 10
set.seed(1001)
a <- 2
b <- 0.5
x <- runif(npts)
y <- a*x/(1+a*b*x) + rnorm(npts, sd=0.2)
gfun <- function(a,b,x) {
    if(a < 0 || b < 0) stop("bounds violated")
    a*x/(1+a*b*x)
}
m1 <- nls(y ~ gfun(a,b,x), algorithm = "port",
          lower = c(0,0), start = c(a=1, b=1))
(pr1 <- profile(m1))
if(have_MASS) print(confint(pr1))

gfun <- function(a,b,x) {
    if(a < 0 || b < 0 || a > 1.5 || b > 1) stop("bounds violated")
    a*x/(1+a*b*x)
}
m2 <- nls(y ~ gfun(a,b,x), algorithm = "port",
          lower = c(0, 0), upper=c(1.5, 1), start = c(a=1, b=1))
profile(m2)
if(have_MASS) print(confint(m2))
options(op)

## scoping problems
test <- function(trace=TRUE)
{
    x <- seq(0,5,len=20)
    n <- 1
    y <- 2*x^2 + n + rnorm(x)
    xy <- data.frame(x=x,y=y)
    myf <- function(x,a,b,c) a*x^b+c
    list(with.start=
         nls(y ~ myf(x,a,b,n), data=xy, start=c(a=1,b=1), trace=trace),
         no.start= ## cheap auto-init to 1
	 suppressWarnings(
	     nls(y ~ myf(x,A,B,n), data=xy)))
}
t1 <- test(); t1$with.start
##__with.start:
## failed to find n in 2.2.x
## found wrong n in 2.3.x
## finally worked in 2.4.0
##__no.start: failed in 3.0.2
## 2018-09 fails on macOS with Accelerate framework.
stopifnot(all.equal(.n(t1[[1]]), .n(t1[[2]])))
rm(a,b)
t2 <- test(FALSE)
stopifnot(all.equal(lapply(t1, .n),
		    lapply(t2, .n), tolerance = 0.16))# different random error


## list 'start'
set.seed(101)# (remain independent of above)
getExpmat <- function(theta, t)
{
        conc <- matrix(nrow = length(t), ncol = length(theta))
        for(i in 1:length(theta)) conc[, i] <- exp(-theta[i] * t)
        conc
}
expsum <- as.vector(getExpmat(c(.05,.005), 1:100) %*% c(1,1))
expsumNoisy <- expsum + max(expsum) *.001 * rnorm(100)
expsum.df <-data.frame(expsumNoisy)

## estimate decay rates, amplitudes with default Gauss-Newton
summary (nls(expsumNoisy ~ getExpmat(k, 1:100) %*% sp, expsum.df,
             start = list(k = c(.6,.02), sp = c(1,2))))

## didn't work with port in 2.4.1
summary (nls(expsumNoisy ~ getExpmat(k, 1:100) %*% sp, expsum.df,
             start = list(k = c(.6,.02), sp = c(1,2)),
             algorithm = "port"))


## PR13540

x <- runif(200)
b0 <- c(rep(0,100),runif(100))
b1 <- 1
fac <- as.factor(rep(c(0,1), each = 100))
y <- b0 + b1*x + rnorm(200, sd=0.05)
# next failed in 2.8.1
fit <- nls(y~b0[fac] + b1*x, start = list(b0=c(1,1), b1=1),
           algorithm ="port", upper = c(100, 100, 100))
# next did not "fail" in proposed fix:
fiB <- nls(y~b0[fac] + b1*x, start = list(b0=c(1,1), b1=101),
           algorithm ="port", upper = c(100, 100, 100),
           control = list(warnOnly=TRUE))# warning ..
with(fiB$convInfo, ## start par. violates constraints
     stopifnot(isConv == FALSE, stopCode == 300))


## PR#17367 -- nls() quoting non-syntactical variable names
##
op <- options(warn = 2)# no warnings allowed from here
##
dN <- data.frame('NO [µmol/l]' = c(1,3,8,17), t = 1:4, check.names=FALSE)
fnN <- `NO [µmol/l]` ~ a + k* exp(t)
## lm() works,  nls() should too
lm.N  <- lm(`NO [µmol/l]` ~ exp(t) ,                          data = dN)
summary(lm.N) -> slmN
nm. <- nls(`NO [µmol/l]` ~ a + k*exp(t), start=list(a=0,k=1), data = dN)
## In R <= 3.4.x : Error in eval(predvars, data, env) : object 'NO' not found
nmf <- nls(fnN,                          start=list(a=0,k=1), data = dN)
## (ditto; gave identical error)
noC  <- function(L) L[-match("call", names(L))]
stopifnot(all.equal(noC (nm.), noC (nmf)))
##
## with list for which  as.data.frame() does not work [-> different branch, not using model.frame!]
## list version (has been valid "forever", still doubtful, rather give error [FIXME] ?)
lsN <- c(as.list(dN), list(foo="bar")); lsN[["t"]] <- 1:8
nmL <- nls(`NO [µmol/l]` ~ a + k*exp(t), start=list(a=0,k=1), data = lsN)
stopifnot(all.equal(coef(nmL), c(a = 5.069866, k = 0.003699669), tol = 4e-7))# seen 4.2e-8

## trivial RHS -- should work even w/o 'start='
fi1 <- nls(y ~ a, start = list(a=1))
## -> 2 deprecation warnings "length 1 in vector-arithmetic" from nlsModel()  in R 3.4.x ..
options(op) # warnings about missing 'start' ok:
f.1 <- nls(y ~ a) # failed in R 3.4.x
stopifnot(all.equal(noC(f.1), noC(fi1)),
	  all.equal(coef(f.1), c(a = mean(y))))
