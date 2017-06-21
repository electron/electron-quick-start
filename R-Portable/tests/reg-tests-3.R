### Regression tests for which the printed output is the issue
### May fail.
### Skipped on a Unix-alike without Recommended packages

pdf("reg-tests-3.pdf", encoding = "ISOLatin1.enc")

## str() for character & factors with NA (levels), and for Surv objects:
ff <- factor(c(2:1,  NA),  exclude = NULL)
str(levels(ff))
str(ff)
str(ordered(ff, exclude=NULL))
if(require(survival)) {
    (sa <- Surv(aml$time, aml$status))
    str(sa)
    detach("package:survival", unload = TRUE)
}
## were different, the last one failed in 1.6.2 (at least)


## lm.influence where hat[1] == 1
if(require(MASS)) {
    fit <- lm(formula = 1000/MPG.city ~ Weight + Cylinders + Type + EngineSize + DriveTrain, data = Cars93)
    print(lm.influence(fit))
    ## row 57 should have hat = 1 and resid=0.
    summary(influence.measures(fit))
}
## only last two cols in row 57 should be influential


## PR#6640  Zero weights in plot.lm
if(require(MASS)) {
    fm1 <- lm(time~dist, data=hills, weights=c(0,0,rep(1,33)))
    plot(fm1)
}
## gave warnings in 1.8.1


## PR#7829 model.tables & replications
if(require(MASS)) {
    oats.aov <- aov(Y ~ B + V + N + V:N, data=oats[-1,])
    model.tables(oats.aov, "means", cterms=c("N", "V:N"))
}
## wrong printed output in 2.1.0


## drop1 on weighted lm() fits
if(require(MASS)) {
    hills.lm <- lm(time ~ 0 + dist + climb, data=hills, weights=1/dist^2)
    print(drop1(hills.lm))
    print(stats:::drop1.default(hills.lm))
    hills.lm2 <- lm(time/dist ~ 1 + I(climb/dist), data=hills)
    drop1(hills.lm2)
}
## quoted unweighted RSS etc in 2.2.1


## tests of ISO C99 compliance (Windows fails without a workaround)
sprintf("%g", 123456789)
sprintf("%8g", 123456789)
sprintf("%9.7g", 123456789)
sprintf("%10.9g", 123456789)
sprintf("%g", 12345.6789)
sprintf("%10.9g", 12345.6789)
sprintf("%10.7g", 12345.6789)
sprintf("%.7g", 12345.6789)
sprintf("%.5g", 12345.6789)
sprintf("%.4g", 12345.6789)
sprintf("%9.4g", 12345.6789)
sprintf("%10.4g", 12345.6789)
## Windows used e+008 etc prior to 2.3.0


## weighted glm() fits
if(require(MASS)) {
    hills.glm <- glm(time ~ 0 + dist + climb, data=hills, weights=1/dist^2)
    print(AIC(hills.glm))
    print(extractAIC(hills.glm))
    print(drop1(hills.glm))
    stats:::drop1.default(hills.glm)
}
## wrong AIC() and drop1 prior to 2.3.0.

## calculating no of signif digits
print(1.001, digits=16)
## 2.4.1 gave  1.001000000000000
## 2.5.0 errs on the side of caution.


## as.matrix.data.frame with coercion
if(require("survival")) {
    soa <- Surv(1:5, c(0, 0, 1, 0, 1))
    df.soa <- data.frame(soa)
    print(as.matrix(df.soa)) # numeric result
    df.soac <- data.frame(soa, letters[1:5])
    print(as.matrix(df.soac)) # character result
    detach("package:survival", unload = TRUE)
}
## failed in 2.8.1

## wish of PR#13505
npk.aov <- aov(yield ~ block + N * P + K, npk)
foo <- proj(npk.aov)
cbind(npk, foo)
## failed in R < 2.10.0


if(suppressMessages(require("Matrix"))) {
  print(cS. <- contr.SAS(5, sparse = TRUE))
  stopifnot(all(contr.SAS(5) == cS.),
	    all(contr.helmert(5, sparse = TRUE) == contr.helmert(5)))

  x1 <- x2 <- c('a','b','a','b','c')
  x3 <- x2; x3[4:5] <- x2[5:4]
  print(xtabs(~ x1 + x2, sparse= TRUE, exclude = 'c'))
  print(xtabs(~ x1 + x3, sparse= TRUE, exclude = 'c'))
  detach("package:Matrix")
  ## failed in R <= 2.13.1
}

## regression tests for dimnames (broken on 2009-07-31)
contr.sum(4)
contr.helmert(4)
contr.sum(2) # needed drop=FALSE at one point.

## xtabs did not exclude levels from factors
x1 <- c('a','b','a','b','c', NA)
x2 <- factor(x1, exclude=NULL)
print(xtabs(~ x1 + x2, na.action = na.pass))
print(xtabs(~ x1 + x2, exclude = 'c', na.action = na.pass))


## median should work by default for a suitable S4 class.
## adapted from adaptsmoFMRI
if(suppressMessages(require("Matrix"))) {
    x <- matrix(c(1,2,3,4))
    print(median(x))
    print(median(as(x, "dgeMatrix")))
    detach("package:Matrix")
}

## Various arguments were not duplicated:  PR#15352 to 15354
x <- 5
y <- 2
f <- function (y) x
numericDeriv(f(y),"y")
x

a<-list(1,2)
b<-rep.int(a,c(2,2))
b[[1]][1]<-9
a[[1]]

a <- numeric(1)
x <- mget("a",as.environment(1))
x
a[1] <- 9
x


## needs MASS installed
## PR#2586 labelling in alias()
if(require("MASS")) {
    Y <- c(0,1,2)
    X1 <- c(0,1,0)
    X2 <- c(0,1,0)
    X3 <- c(0,0,1)
    print(res <- alias(lm(Y ~ X1 + X2 + X3)))
    stopifnot(identical(rownames(res[[2]]), "X2"))
}
## the error was in lm.(w)fit

if(require("Matrix")) {
 m1 <- m2 <- m <- matrix(1:12, 3,4)
 dimnames(m2) <- list(LETTERS[1:3],
                      letters[1:4])
 dimnames(m1) <- list(NULL,letters[1:4])
 M  <- Matrix(m)
 M1 <- Matrix(m1)
 M2 <- Matrix(m2)
 ## Now, with a new ideal cbind(), rbind():
 print(cbind(M, M1))
 stopifnot(identical(cbind (M, M1),
                     cbind2(M, M1)))
 rm(M,M1,M2)
 detach("package:Matrix", unload=TRUE)
}##{Matrix}


## Invalid UTF-8 strings
x <- c("Jetz", "no", "chli", "z\xc3\xbcrit\xc3\xbc\xc3\xbctsch:",
       "(noch", "ein", "bi\xc3\x9fchen", "Z\xc3\xbc", "deutsch)",
       "\xfa\xb4\xbf\xbf\x9f")
lapply(x, utf8ToInt)
Encoding(x) <- "UTF-8"
nchar(x, "b")
try(nchar(x, "c"))
try(nchar(x, "w"))
nchar(x, "c", allowNA = TRUE)
nchar(x, "w", allowNA = TRUE)
## Results differed by platform, but some gave incorrect results on string 10.


## str() on large strings (in multibyte locales; changing locale may not work everywhere
oloc <- Sys.getlocale("LC_CTYPE")
mbyte.lc <- if(.Platform$OS.type == "windows")
 "English_United States.28605" else "en_GB.UTF-8"
stopifnot(identical(Sys.setlocale("LC_CTYPE", mbyte.lc), mbyte.lc))
cc <- "J\xf6reskog" # valid in "latin-1"; invalid multibyte string in UTF-8
.tmp <- capture.output(
str(cc) # failed in some R-devel versions
)
stopifnot(grepl("chr \"J.*reskog\"", .tmp))
nchar(L <- strrep(paste(LETTERS, collapse="."), 100000), type="b")# 5.1 M
stopifnot(system.time( str(L) )[[1L]] < 0.10) # Sparc Solaris needed 0.052
Sys.setlocale("LC_CTYPE", oloc)
## needed 1.6 sec in (some) R <= 3.3.0 in a multibyte locale

if(require("Matrix", .Library)) {
    M <- Matrix(diag(1:10), sparse=TRUE) # a "dsCMatrix"
    setClass("TestM", slots = c(M='numeric'))
    setMethod("+", c("TestM","TestM"), function(e1,e2) {
        e1@M + e2@M
    })
    M+M # works the first time
    M+M # was error   "object '.Generic' not found"
    ##
    stopifnot(
        identical(pmin(2,M), pmin(2, as.matrix(M))),
        identical(as.matrix(pmax(M, 7)), pmax(as.matrix(M), 7))
    )
    rm(M)
    detach("package:Matrix", unload=TRUE)
}##{Matrix}
