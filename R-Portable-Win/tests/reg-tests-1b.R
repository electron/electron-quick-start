## From PR#10000 on, for R < 3.0.0

pdf("reg-tests-1b.pdf", encoding = "ISOLatin1.enc")

## force standard handling for data frames
options(stringsAsFactors = TRUE)
## .Machine
(Meps <- .Machine$double.eps)# and use it in this file

assertWarning <- tools::assertWarning
assertError <- tools::assertError

## str() for list-alikes :
"[[.foo" <- function(x,i) x
x <- structure(list(2), class="foo")
str(x)
## gave infinite recursion < 2.6.0


curve(sin, -2*pi, 3*pi); pu1 <- par("usr")[1:2]
curve(cos, add = NA) # add = NA new in 2.14.0
stopifnot(all.equal(par("usr")[1:2], pu1))
## failed in R <= 2.6.0


## tests of side-effects with CHARSXP caching
x <- y <- "abc"
Encoding(x) <- "UTF-8"
stopifnot(Encoding(y) == "unknown") # was UTF-8 in 2.6.0
x <- unserialize(serialize(x, NULL))
stopifnot(Encoding(y) == "unknown") # was UTF-8 in 2.6.0
##  problems in earlier versions of cache


## regression test for adding functions to deriv()
deriv3(~  gamma(y), namevec="y")
deriv3(~  lgamma(y), namevec="y")
# failed in R < 2.7.0
D(quote(digamma(sin(x))),"x")
D(quote(trigamma(sin(x))),"x")
D(quote(psigamma(sin(x))),"x")
D(quote(psigamma(sin(x), 3)),"x")
n <- 2L; D(quote(psigamma(sin(x), n)),"x")
## rest are new


## .subset2 quirk
iris[1, c(TRUE, FALSE, FALSE, FALSE, FALSE)]
iris[1, c(FALSE, FALSE, FALSE, FALSE, TRUE)]
## failed in 2.6.0


## indexing by "": documented as 'no name' and no match
x <- structure(1:4, names=c(letters[1:3], ""))
stopifnot(is.na(x[""])) # always so
stopifnot(is.na(x[NA_character_]))
z <- tryCatch(x[[NA_character_]], error=function(...) {})
stopifnot(is.null(z))
z <- tryCatch(x[[""]], error=function(...) {})
stopifnot(is.null(z)) # x[[""]] == 4 < 2.7.0
x[[""]] <- 5  # no match, so should add an element, but replaced.
stopifnot(length(x) == 5)
x[""] <- 6    # also add
stopifnot(length(x) == 6)
xx <- list(a=1, 2)
stopifnot(is.null(xx[[""]])) # 2 < 2.7.0
##


## negative n gave choose(n, k) == 0
stopifnot(isTRUE(all.equal(choose(-1,3),-1)))
##


## by() on 1-column data frame (PR#10506)
X <- data.frame(a=1:10)
g <- gl(2,5)
by(X, g, colMeans)
## failed in 2.6.1


## range.default omitted na.rm on non-numeric objects
(z <- range(as.Date(c("2007-11-06", NA)), na.rm = TRUE))
stopifnot(!is.na(z))
## NAs in 2.6.1


## cut() on constant values used the min, not abs(min)
z <- cut(rep(-1,5), 2)
stopifnot(!is.na(z))
##


## extreme example of two-sample wilcox.test
## reported by Wolfgang Huber to R-devel, 2008-01-01
## normal approximation is way off here.
wilcox.test(1, 2:60, conf.int=TRUE, exact=FALSE)
## failed in R < 2.7.0


## more corner cases for cor()
z <- cor(c(1,2,3),c(3,4,6),use="pairwise.complete.obs",method="kendall")
stopifnot(!is.matrix(x)) # was 1x1 in R < 2.7.0
Z <- cbind(c(1,2,3),c(3,4,6))
# next gave 0x0 matrix < 2.7.0
z <- try(cor(Z[, FALSE], use="pairwise.complete.obs",method="kendall"))
stopifnot(inherits(z, "try-error"))
# next gave NA < 2.7.0
z <- try(cor(numeric(0), numeric(0), use="pairwise.complete.obs",
             method="kendall"))
stopifnot(inherits(z, "try-error"))
##


## infinite loop in format.AsIs reported on R-help by Bert Gunter
## https://stat.ethz.ch/pipermail/r-help/2008-January/149504.html
z <- rep(Sys.time(),5)
data.frame(I(z))
##


## drop with length-one result
x <- matrix(1:4, 4,1, dimnames=list(letters[1:4], NULL))
stopifnot(identical(names(drop(x)), letters[1:4])) # was OK
stopifnot(identical(names(drop(x[1,,drop=FALSE])), "a")) # was no names
stopifnot(identical(names(x[1,]), "a")) # ditto
# now consistency tests.
x <- matrix(1, 1, 1, dimnames=list("a", NULL))
stopifnot(identical(names(x[,]), "a"))
x <- matrix(1, 1, 1, dimnames=list(NULL, "a"))
stopifnot(identical(names(x[,]), "a"))
x <- matrix(1, 1, 1, dimnames=list("a", "b"))
stopifnot(is.null(names(x[,])))
## names were dropped in R < 2.7.0 in all cases except the first.


## fisher.test with extreme degeneracy PR#10558
a <- diag(1:3)
p <- fisher.test(a, simulate.p.value=TRUE)$p.value
# true value is 1/60, but should not be small
stopifnot(p > 0.001)
## was about 0.0005 in 2.6.1 patched


## tests of problems fixed by Marc Schwartz's patch for
## cut/hist for Dates and POSIXt
Dates <- seq(as.Date("2005/01/01"), as.Date("2009/01/01"), "day")
months <- format(Dates, format = "%m")
years <- format(Dates, format = "%Y")
mn <- unlist(lapply(unname(split(months, years)), table), use.names=FALSE)
ty <- as.vector(table(years))
# Test hist.Date() for months
stopifnot(identical(hist(Dates, "month", plot = FALSE)$counts, mn))
# Test cut.Date() for months
stopifnot(identical(as.vector(table(cut(Dates, "month"))), mn))
# Test cut.Date() for 3 months
stopifnot(identical(as.vector(table(cut(Dates, "3 months"))),
                    as.integer(colSums(matrix(c(mn, 0, 0), nrow = 3)))))
# Test hist.Date() for years
stopifnot(identical(hist(Dates, "year", plot = FALSE)$counts, ty))
# Test cut.Date() for years
stopifnot(identical(as.vector(table(cut(Dates, "years"))),ty))
# Test cut.Date() for 3 years
stopifnot(identical(as.vector(table(cut(Dates, "3 years"))),
                    as.integer(colSums(matrix(c(ty, 0), nrow = 3)))))

Dtimes <- as.POSIXlt(Dates)
# Test hist.POSIXt() for months
stopifnot(identical(hist(Dtimes, "month", plot = FALSE)$counts, mn))
# Test cut.POSIXt() for months
stopifnot(identical(as.vector(table(cut(Dtimes, "month"))), mn))
# Test cut.POSIXt() for 3 months
stopifnot(identical(as.vector(table(cut(Dtimes, "3 months"))),
                    as.integer(colSums(matrix(c(mn, 0, 0), nrow = 3)))))
# Test hist.POSIXt() for years
stopifnot(identical(hist(Dtimes, "year", plot = FALSE)$counts, ty))
# Test cut.POSIXt() for years
stopifnot(identical(as.vector(table(cut(Dtimes, "years"))), ty))
# Test cut.POSIXt() for 3 years
stopifnot(identical(as.vector(table(cut(Dtimes, "3 years"))),
                    as.integer(colSums(matrix(c(ty, 0), nrow = 3)))))
## changed in 2.6.2


## zero-length args in tapply (PR#10644)
tapply(character(0), factor(letters)[FALSE], length)
## failed < 2.6.2


## zero-length patterns in gregexpr
expect <- structure(1:3, match.length=rep(0L, 3), useBytes = TRUE)
stopifnot(identical(expect, gregexpr("", "abc")[[1]]))
stopifnot(identical(expect, gregexpr("", "abc", fixed=TRUE)[[1]]))
stopifnot(identical(expect, gregexpr("", "abc", perl=TRUE)[[1]]))
## segfaulted < 2.6.2


## test of internal argument matching
stopifnot(all.equal(round(d=2, x=pi), 3.14))
## used positional matching in 2.6.x


## kappa.tri(x, exact=TRUE) wrongly ended using exact=FALSE:
data(longley)
fm1 <- lm(Employed ~ ., data = longley)
stopifnot(all.equal(23845862, kappa(fm1, exact=TRUE)))


## names from pairlists (PR#10807, esoteric)
m <- c("a", "b", "c")
mp <- pairlist("a", "b", "c")
x <- 1:3
names(x) <- mp
stopifnot(identical(names(x), m)) # OK before
x <- 1:3
attr(x, "names") <- mp
stopifnot(identical(names(x), m)) # rep("a", 3) in 2.6.x
##


## preserving attributes in [<-.data.frame (PR#10873)
df <- data.frame(a=1:3, b=letters[1:3])
attr(df,"foo") <- 10
df[, "b"] <- 10:12
stopifnot(identical(attr(df, "foo"), 10))
## dropped attributes < 2.7.0


## r<foo> NA warnings, and rnorm(*, mu = +- Inf) consistency
op <- options(warn=2)
m <- c(-Inf,Inf)
stopifnot(rnorm(2, mean = m) == m,
          rexp (2, Inf) == 0)
set.seed(11)
rt(1, Inf)
R <- list(try(rnorm(2, numeric())),
          try(rexp (2, numeric())),
          try(rnorm(2, c(1,NA))),
          try(rnorm(1, sd = Inf)) )
options(op)
stopifnot(sapply(R, function(ch) sub(".* : ", '', ch) ==
                 "(converted from warning) NAs produced\n"))
## was inconsistent in R < 2.7.0


## predict.loess with transformed variables
set.seed(11)
y <- 1:100 + rnorm(100)
od <- data.frame(x=1:100, z=1:100 + rnorm(100, 10))
nd <- data.frame(x=1:100, z=11:110)
fit <- loess(y ~ log(x) + log(z), od)
p1 <- predict(fit, nd) # failed in 2.6.x
fit.log <- loess(y ~ x + z, log(od))
p2 <- predict(fit.log, log(nd))
stopifnot(all.equal(p1, p2))


## wishlist PR#11192
plot(1:10)
segments(1, 1, 10, 10, col='green')
segments(numeric(0), numeric(0), numeric(0), numeric(0), col='green')
## last was error in R < 2.8.0


## merging with a zero-row data frame
merge(NULL, women)
merge(women, NULL)
merge(women[FALSE, ], women)
merge(women, women[FALSE, ])
## first two failed in 2.7.0


## influence.measures() for lm and glm, and its constituents
if(require(MASS)) {
    fit <- lm(formula = 1000/MPG.city ~ Weight + Cylinders + Type + EngineSize + DriveTrain, data = Cars93)
    gf <- glm(formula(fit), data=Cars93) # should be "identical"
    im1 <- influence.measures(fit)
    im2 <- influence.measures(gf)
    stopifnot(all.equal(im1[1:2], im2[1:2]),
	      all.equal(unname(im1$infmat[,1:15]), unname(dfbetas(fit))),
	      all.equal(im1$infmat[,"dffit"], dffits(fit)),
	      all.equal(im1$infmat[,"cov.r"], covratio(fit)),
	      all.equal(im1$infmat[,"cook.d"], cooks.distance(fit)),
	      all.equal(im2$infmat[,"cook.d"], cooks.distance(gf)),
	      all.equal(im1$infmat[,"hat"],  hatvalues(fit)))
}
## "cook.d" part of influence.measures(<glm>) differed in R <= 2.7.0


## short list value for dimnames
n <- matrix(c(1259, 845, 719,390,1360,1053,774,413), nrow = 2, byrow = TRUE)
dimnames(n)[[1]] <- c("a", "b")
## was (correctly) an error in R < 2.8.0


## glob2rx(pattern, .) with "(", "[" or "{" in pattern :
nm <- "my(ugly[file{name"
stopifnot(identical(regexpr(glob2rx("*[*"), nm),
		    structure(1L, match.length = 8L, useBytes = TRUE)),
	  identical(regexpr(glob2rx("*{n*"), nm),
		    structure(1L, match.length = 14L, useBytes = TRUE)),
	  identical(regexpr(glob2rx("*y(*{*"), nm),
		    structure(1L, match.length = 13L, useBytes = TRUE))
	  )
## gave 'Invalid regular expression' in R <= 2.7.0


## showDefault() problem with "unregistered" S3 classes:
show(structure(1:3, class = "myClass"))
## failed in R <= 2.7.0


## formatC(.., format="fg", flag="#"):
x <- 0.599 * c(.1, .01, .001, 1e-4,1e-5,1e-6)
(fCx <- formatC(x, digits=2, format="fg", flag="#"))
stopifnot(sub(".*(..)$", "\\1", fCx) == "60")
## dropped the trailing "0" in the last 3 cases, in R <= 2.7.0


## c.noquote bug, posted to R-devel by Ray Brownrigg, 2008-06-16
z <- c(noquote('z'), 'y', 'x', 'w')
stopifnot(identical(unclass(z), c('z', 'y', 'x', 'w')))
## repeated third and later args in R < 2.7.1.

## PD found that f==f contains NA when f has NA levels (but no missing value)
f1 <- factor(c(1, 2, NA), levels = 1:2)
f2 <- factor(c(1, 2, NA), exclude = NULL)
stopifnot(identical(f1, factor(c(1,2,NA))),
          nlevels(f1) == 2, nlevels(f2) == 3,
          all(f2 == f2), !any(f2 != f2),
          identical(f1 == f1, c(TRUE,TRUE,NA)))

f. <- f <- factor(c(letters[c(1:3,3:1)],"NA", "d","d", NA), exclude=NULL)
is.na(f.)[2:3] <- TRUE
f.
stopifnot(all(f == f), identical(f == f., f. == f.),
          identical(2:3, which(is.na(f. == f.))))
## f == f was wrong in R 1.5.0 -- 2.7.1


## data.frame[, <char>] must match exactly
dd <- data.frame(ii = 1:10, xx = pi * -3:6)
t1 <- try(dd[,"x"])# partial match
t2 <- try(dd[,"C"])# no match
stopifnot(inherits(t1, "try-error"),
	  inherits(t2, "try-error"),
	  ## partial matching is "ok" for '$' {hence don't use for dataframes!}
	  identical(dd$x, dd[,"xx"]))
## From 2.5.0 to 2.7.1, the non-match indexing gave NULL instead of error


## data.frame[ (<NA>), ] when row.names had  "NA"
x <- data.frame(x=1:3, y=2:4, row.names=c("a","b","NA"))
y  <- x [c(2:3, NA),]
y.ok <- data.frame(x=c(2:3,NA), y=c(3:4,NA), row.names=c("b", "NA", "NA.1"))
stopifnot(identical(y, y.ok))
## From 2.5.0 to 2.7.1,  y had row name "NA" twice


stopifnot(shapiro.test(c(0,0,1))$p.value >= 0)
## was wrong up to 2.7.1, because of rounding errors (in single precision).


stopifnot(rcond(cbind(1, c(3,3))) == 0)
## gave an error (because Lapack's LU detects exact singularity)


## dispatch when primitives are called from lapply.
x <- data.frame(d=Sys.Date())
stopifnot(sapply(x, is.numeric) == FALSE)
# TRUE in 2.7.1, tried to dispatch on "FUN"
(ds <- seq(from=Sys.Date(), by=1, length=4))
lapply(list(d=ds), round)
# failed in 2.7.1 with 'dispatch error' since call had '...' arg
## related to calls being passed unevaluated by lapply.


## subsetting data frames with NA cols
## Dieter Menne: https://stat.ethz.ch/pipermail/r-help/2008-January/151266.html
df3 <- data.frame(a=0:10,b=10:20,c=20:30)
names(df3) <- c("A","B", NA)
df3[-2]
df3[, -2]
df3[1:4, -2]
df3[c(TRUE,FALSE,TRUE)]
df3[, c(TRUE,FALSE,TRUE)]
df3[1:4, c(TRUE,FALSE,TRUE)]
## all gave 'undefined columns selected', 2.6.1 to 2.7.x
## note that you can only select columns by number, not by name


## nls with weights in an unusual model
Data <- data.frame(x=c(1,1,1,1,1,2,2,3,3,3,3,3,3,4,4,4,5,5,5,5,6,6,6,6,6,6,
                   7,7,7,7,7,7,7,7,7,8,8,8, 8,8,8,8,8,8,8,9,9,9,9,9,11,12),
                   y=c(73,73,70,74,75,115,105,107,124,107,116,125,102,144,178,
                   149,177,124,157,128, 169,165,186,152,181,139,173,151,138,
                   181,152,188,173,196,180,171,188,174,198, 172, 176,162,188,
                   182,182,141,191,190,159,170,163,197),
                   weight=c(1, rep(0.1, 51)))
G.st <- c(k=0.005, g1=50, g2=550)
# model has length-1 (and 52) variables
Ta <- min(Data$x)
Tb <- max(Data$x)

#no weights
nls(y~((g1)*exp((log(g2/g1))*(1-exp(-k*(x-Ta)))
                /(1-exp(-k*(Tb-Ta))))), data=Data, start=G.st, trace=TRUE)

#with weights
nls(y ~ ((g1)*exp((log(g2/g1))*(1-exp(-k*(x-Ta)))/(1-exp(-k*(Tb-Ta))))),
    data = Data, start = G.st, trace = TRUE, weights = weight)
## failed for find weights in R <= 2.7.1


## barplot(log = "y") with NAs (PR#11585)
dat <- matrix(1:25, 5)
dat[2,3] <- NA
barplot(dat, beside = TRUE, log = "y")
## failed in 2.7.1


## related to PR#12551
unique("a", c("a", "b"))
unique(1, 1:2)
# could seqfault in 2.7.1 on some platforms
stopifnot(!duplicated(rep("a", 3), "a"))
## wrong answer in 2.7.1


## drop1.lm() bug
dd <- stackloss ; dd[1,3] <- NA
rr <- lm(stack.loss ~ ., data=dd, na.action=na.exclude)
drop1(rr)
## failed in 2.7.x


## explicit row.names=NULL in data.frame()
stopifnot(identical(row.names(data.frame(x=c(a=1,b=2), row.names=NULL)),
                    c("1", "2")))
stopifnot(identical(row.names(data.frame(x=c(a=1,b=2))), c("a", "b")))
## same as default in 2.5.0 <= R < 2.7.2

stopifnot(all.equal(chol2inv(2), matrix(0.25, 1), tolerance = 4*Meps),
	  all.equal(solve(chol2inv(chol(4))), matrix(4, 1), tolerance = 10*Meps))
## chol2inv() did not accept non-matrices up to 2.7.*


## seek should discard pushback. (PR#12640)
cat(c("1\t2\t3", "4\t5\t6"), file="foo.txt", sep="\n")
fd <- file("foo.txt",open="rt")
scan(file=fd,what=double(),n=2)
seek(con=fd,where=0,origin="start")
z <- scan(file=fd,what=double(),n=2)
close(fd)
unlink("foo.txt")
stopifnot(identical(z, c(1,2)))
## changed in 2.7.2 patched


## cov / cor / var etc with NAs :
stopifnot(inherits(try(var(NULL)), "try-error"))## gave NA in 1.2.2
v0 <- var(0[FALSE]) # gave "'x' is empty" in the past;  NA in 1.2.2
x <- c(1:2,NA)
v1 <- var(c(1,NA))
v2 <- var(c(NA,0/0, Inf-Inf))
sx <- sd(x)# sd() -> var()
## all three gave "missing observations in cov/cor"  for a long time in the past
is.NA <- function(x) is.na(x) & !is.nan(x)
stopifnot(is.NA(v1), is.NA(v2), is.NA(sx),
	  all.equal(0.5, var(x, na.rm=TRUE), tol=8*Meps)# should even be exact
	  )


## write.dcf() indenting for ".<foo>" (PR#12816)
zz <- textConnection("foo", "w")
write.dcf(list(Description = 'what a fat goat .haha'),
          file = zz, indent=1, width=10)
stopifnot(substring(foo[-1], 1,1) == " ", length(foo) == 4,
          foo[4] == "  .haha")
close(zz)
## was " .haha" (not according to DCF standard)


## pdf() with CIDfonts active -- they need MBCS to be supported
pdf(file = "testCID.pdf", family="Japan1") # << for CIDfonts, pd->fonts is NULL
try({
    plot(1,1,pch="", axes=FALSE)
    text(1,1,"F.1", family="Helvetica")
})
dev.off()
unlink("testCID.pdf")
## text() seg.faulted up to 2.7.2 (and early 2.8.0-alpha)


## PS mixing CIDfonts and Type1 - reverse case
postscript(file = "testCID.ps", family="Helvetica")
plot(1,1,pch="", axes=FALSE)
try(text(1,1,"A",family="Japan1"))
unlink("testCID.ps")
## error instead of seg.fault


## splinefun with derivatives evaluated to the left of first knot
x <- 1:10; y <- sin(x)
splfun <- splinefun(x,y, method='natural')
x1 <- splfun( seq(0,1, 0.1), deriv=1 )
x2 <- splfun( seq(0,1, 0.1), deriv=2 )
x3 <- splfun( seq(0,1, 0.1), deriv=3 )
stopifnot(x1 == x1[1], x2 == 0, x3 == 0)
##


## glm(y = FALSE), in part PR#1398
fit <- glm(1:10 ~ I(1:10) + I((1:10)^2), y = FALSE)
anova(fit)
## obscure errors < 2.8.0


## boundary case in cut.Date (PR#13159)
d <- as.Date("2008-07-07")
cut(d, "weeks")
d <- as.POSIXct("2008-07-07", tz="UTC")
cut(d, "weeks")
## failed < 2.8.0


### end of tests added for 2.8.x


## (Deliberate) overshot in seq(from, to, by) because of fuzz
stopifnot(seq(0, 1, 0.00025+5e-16) <= 1, seq.int(0, 1, 0.00025+5e-16) <= 1)
## overshot by about 2e-12 in 2.8.x
## no longer reaches 1 in 2.11.0 (needed a fuzz of 8e-9)


## str() with an "invalid object"
ob <- structure(1, class = "test") # this is fine
is.object(ob)# TRUE
ob <- 1 + ob # << this is "broken"
is.object(ob)# FALSE - hmm..
identical(ob, unclass(ob)) # TRUE !
stopifnot(grep("num 2", capture.output(str(ob))) == 1)
## str(ob) lead to infinite recursion in R <= 2.8.0


## row.names(data.frame(matrixWithDimnames)) (PR#13230)
rn0 <- c("","Row 2","Row 3")
A <- matrix(1:6, nrow=3, ncol=2, dimnames=list(rn0, paste("Col",1:2)))
rn <- row.names(data.frame(A))
stopifnot(identical(rn, rn0))
# was 1:3 in R 2.8.0, whereas
rn0 <- c("Row 1","","Row 3")
A <- matrix(1:6, nrow=3, ncol=2, dimnames=list(rn0, paste("Col",1:2)))
rn <- row.names(data.frame(A))
stopifnot(identical(rn, rn0))
## used the names.


## rounding error in windowing a time series (PR#13272)
x <- ts(1:290, start=c(1984,10), freq=12)
window(x, start=c(2008,9), end=c(2008,9), extend=FALSE)
window(x, start=c(2008,9), end=c(2008,9), extend=TRUE)
## second failed in 2.8.0


## deparse(nlines=) should shrink the result (PR#13299)
stopifnot(length(deparse(quote(foo(1,2,3)), width.cutoff = 20, nlines=7)) ==1)
## was 7.


## legend did not reset xpd correctly (PR#12756)
par(xpd = FALSE)
plot(1)
legend("top", legend="Tops", xpd=NA, inset=-0.1)
stopifnot(identical(par("xpd"), FALSE))
## left xpd as NA


## lines.formula with 'subset' and no 'data' needed a tweak
## (R-help, John Field, 20008-11-14)
x <- 1:5
y <- c(1,3,NA,2,5)
plot(y ~ x, type="n")
lines(y ~ x, subset = !is.na(y), col="red")
## error in 2.8.0


## prettyNum(*, drop0trailing) erronously dropped 0 in '1e10':
cn <- c("1.107", "2.3120", "3.14e+0", "4.2305400", "120.0",
        "5.31e-01", "6.3333e-20", "8.1e100", "9.9e+00", "10.1e-0")
d <- cn != (pcn <- prettyNum(cn, drop0trailing=TRUE))
stopifnot(identical(pcn[d],
		    c("2.312", "3.14", "4.23054","120","9.9","10.1")),
	  identical("-3", prettyNum("-3.0",drop0trailing=TRUE)) )
## first failed, e.g. for 8.1e100


## (R-help, 2008-12-01)
transform(mtcars, t1=3, t2=4)
## failed in 2.8.0 since extra columns were passed as a list.


## deparsing transform failed
parse(text = deparse(transform))
## failed in 2.8.0


## crashed on some systems (PR#13361)
matrix(1:4, nrow=2, dimnames=list())
##


## col(as.factor=TRUE) failed
col(matrix(0, 5, 5), as.factor=TRUE)
## failed in 2.8.0


## qt failure in R-devel in early Dec 2008
stopifnot(!is.nan(qt(0.1, 0.1)))
##


## formals<- gave wrong result for list body
f <- f0 <- function(x) list(pi)
formals(f) <- formals(f)
stopifnot(identical(body(f), body(f)))
## had body 'pi' < 2.8.1


## body<- failed on a function with no arguments.
f <- function() {pi}
body(f) <- 2
f
## Failed < 2.8.1


## body<- with value a list
f <- function(x) NULL
body(f) <- list(pi)
stopifnot(is.list(body(f))) # was 'pi'
body(f) <- b0 <- list(a=1, b=2)
stopifnot(identical(body(f), b0)) # 'a' became an argument
f <- function(x) NULL
body(f) <- list(1, 2, 3) # was error
## pre-2.9.0 behaviour was erratic.


## PR#13305
qr.solve(cbind(as.complex(1:11), as.complex(1)),
         as.complex(2*(20:30)))
## failed in 2.8.1


## PR#13433: is ....\nEOF an empty last line?
aa <- "field1\tfield2\n 1\ta\n 2\tb"
zz <- textConnection(aa)
res <- read.table(zz, blank.lines.skip = FALSE)
close(zz)
stopifnot(nrow(res) == 3)
## was 4 in 2.8.1


## segfault from cbind() reported by Hadley Wickham
## https://stat.ethz.ch/pipermail/r-devel/2009-January/051853.html
e <- environment()
a <- matrix(list(e), ncol = 1, nrow = 2)
b <- matrix(ncol = 0, nrow = 2) # zero-length
cbind(a, b)
cbind(a, b)
## crashed in 2.9.0


## besselI(x, -n) == besselI(x, +n)  when n is an integer
set.seed(7) ; x <- rlnorm(216) ; nu <- c(1,44,111)
## precision lost warnings {may be gone in the future}:
suppressWarnings(r <- outer(x, c(-nu, nu), besselI))
stopifnot(identical(r[,1:3], r[,4:6]))
## suffered from sin(n * pi) imprecision in R <= 2.8.1


## Large sanples in mood.test
## https://stat.ethz.ch/pipermail/r-help/2009-March/190479.html
set.seed(123)
x <- rnorm(50, 10, 5)
y <- rnorm(50, 2 ,5)
(z <- mood.test(x, y))
stopifnot(!is.na(z$p.value))
## gave warning and incorrect result in 2.8.x


## heatmap without dendrogram (PR#13512)
X <- matrix(rnorm(200),20,10)
XX <- crossprod(X)
heatmap(XX, Rowv =  NA, revC = TRUE)
heatmap(XX, Rowv = NA, symm = TRUE)
## both failed in 2.8.1


## sprintf with 0-length args
stopifnot(identical(sprintf("%d", integer(0L)), character(0L)))
stopifnot(identical(sprintf(character(0L), pi), character(0L)))
## new feature in 2.9.0


## C-level asLogical(x) or c(<raw>, <number>) did not work
r <- as.raw(1)
stopifnot(if(r) TRUE)
for (type in c("null", "logical", "integer", "double", "complex",
               "character", "list", "expression"))
    c(r, r, get(sprintf('as.%s', type))(1))
## failed  before 2.9.0


### Non-unique levels in factor should be forbidden from R 2.10.0 on
c1 <- c("a.b","a"); c2 <- c("c","b.c")
fi <- interaction(c1, c2)
stopifnot(length(lf <- levels(fi)) == 3, lf[1] == "a.b.c",
	  identical(as.integer(fi), rep.int(1L, 2)))
## interaction() failed to produce unique levels before 2.9.1

levs <- c("A","A")
## warnings since 2009; errors since R 3.4.0 (R-devel, June 2016):
local({
    assertError(gl(2,3, labels = levs))
    assertError(factor(levs, levels=levs))
    assertError(factor(1:2,  labels=levs))
    })
## failed in R < 2.10.0
L <- c("no", "yes")
x <- (5:1)/10; lx <- paste("0.", 1:5, sep="")
y <- pi + (-9:9)*2^-53
z <- c(1:2,2:1) ; names(z) <- nz <- letters[seq_along(z)]
of <- ordered(4:1)
stopifnot(identical(factor(c(2, 1:2), labels = L),
		    structure(c(2L, 1:2), .Label = L, class="factor")),
	  identical(factor(x),
		    structure(5:1, .Label = lx, class="factor")),
	  length(levels(factor(y))) == 1, length(unique(y)) == 5,
	  identical(factor(z),
		    structure(z, .Names = nz, .Label = c("1","2"),
			      class="factor")),
	  identical(of, factor(of)))
## partly failed in R <= 2.9.0, partly in R-devel(2.10.0)


## "misuses" of sprintf()
assertError(sprintf("%S%"))
assertError(sprintf("%n %g", 1))
## seg.faulted in R <= 2.9.0


## sprintf(., e)  where length(as.character(e)) < length(e):
e <- tryCatch(stop(), error=identity)
stopifnot(identical(sprintf("%s", e),
		    sprintf("%s", as.character(e))))
## seg.faulted in R <= 2.9.0
e <- tryCatch(sprintf("%q %d",1), error=function(e)e)
e2 <- tryCatch(sprintf("%s", quote(list())), error=function(e)e)
e3 <- tryCatch(sprintf("%s", quote(blabla)), error=function(e)e)
stopifnot(inherits(e, "error"), inherits(e2, "error"),inherits(e3, "error"),
	  grep("invalid", c(msg	 <- conditionMessage(e),
			    msg2 <- conditionMessage(e2),
			    msg3 <- conditionMessage(e3))) == 1:3,
	  1 == c(grep("%q", msg), grep("language", msg2), grep("symbol", msg3))
          )
## less helpful error messages previously


## bw.SJ on extreme example
ep <- 1e-3
stopifnot(all.equal(bw.SJ(c(1:99, 1e6), tol = ep), 0.725, tolerance = ep))
## bw.SJ(x) failed for R <= 2.9.0 (in two ways!), when x had extreme outlier


## anyDuplicated() with 'incomp' ...
oo <- options(warn=2) # no warnings allowed
stopifnot(identical(0L, anyDuplicated(c(1,NA,3,NA,5), incomp=NA)),
	  identical(5L, anyDuplicated(c(1,NA,3,NA,3), incomp=NA)),
	  identical(4L, anyDuplicated(c(1,NA,3,NA,3), incomp= 3)),
	  identical(0L, anyDuplicated(c(1,NA,3,NA,3), incomp=c(3,NA))))
options(oo)
## missing UNPROTECT and partly wrong in development versions of R


## test of 'stringsAsFactors' argument to expand.grid()
z <- expand.grid(letters[1:3], letters[1:4], stringsAsFactors = TRUE)
stopifnot(sapply(z, class) == "factor")
z <- expand.grid(letters[1:3], letters[1:4], stringsAsFactors = FALSE)
stopifnot(sapply(z, class) == "character")
## did not work in 2.9.0, fixed in 2.9.1 patched


## print.srcref should not fail; a bad encoding should fail; neither should
## leave an open connection
nopen <- nrow(showConnections())
tmp <- tempfile()
cat( c( "1", "a+b", "2"), file=tmp, sep="\n")
p <- parse(tmp)
print(p)
con <- try(file(tmp, open="r", encoding="unknown"))
unlink(tmp)
stopifnot(inherits(con, "try-error") && nopen == nrow(showConnections()))
##


## PR#13574
x <- 1:11; y <- c(6:1, 7, 11:8)
stopifnot(all.equal(cor.test(x, y, method="spearman", alternative="greater")$p.value,
                    cor.test(x, -y, method="spearman", alternative="less")$p.value))
## marginally different < 2.9.0 patched


## median should work on POSIXt objects (it did in 2.8.0)
median(rep(Sys.time(), 2))
## failed in 2.8.1, 2.9.0


## repeated NA in dim() (PR#13729)
L0 <- logical(0)
try(dim(L0) <- c(1,NA,NA))
stopifnot(is.null(dim(L0)))
L1 <- logical(1)
try(dim(L1) <- c(-1,-1))
stopifnot(is.null(dim(L)))
## dim was set in 2.9.0


## as.character(<numeric>)
nx <- 0.3 + 2e-16 * -2:2
stopifnot(identical("0.3", unique(as.character(nx))),
          identical("0.3+0.3i", unique(as.character(nx*(1+1i)))))
## the first gave ("0.300000000000000" "0.3") in R < 2.10.0


## aov evaluated a test in the wrong place ((PR#13733)
DF <- data.frame(y = c(rnorm(10), rnorm(10, mean=3), rnorm(10, mean=6)),
                 x = factor(rep(c("A", "B", "C"), c(10, 10, 10))),
                 sub = factor(rep(1:10, 3)))
## In 2.9.0, the following line raised an error because "x" cannot be found
junk <- summary(aov(y ~ x + Error(sub/x), data=DF, subset=(x!="C")))
## safety check added in 2.9.0 evaluated the call.


## for(var in seq) .. when seq is modified  "inside" :
x <- c(1,2); s <- 0; for (i in x) { x[i+1] <- i + 42.5; s <- s + i }
stopifnot(s == 3)
## s was  44.5  in R <= 2.9.0


## ":" at the boundary
M <- .Machine$integer.max
s <- (M-2):(M+.1)
stopifnot(is.integer(s), s-M == -2:0)
## was "double" in R <= 2.9.1


## too many columns model.matrix()
dd <- as.data.frame(sapply(1:40, function(i) gl(2, 100)))
(f <- as.formula(paste("~ - 1 + ", paste(names(dd), collapse = ":"), sep = "")))
e <- tryCatch(X <- model.matrix(f, data = dd), error=function(e)e)
stopifnot(inherits(e, "error"))
## seg.faulted in R <= 2.9.1


## seq_along( <obj> )
x <- structure(list(a = 1, value = 1:7), class = "FOO")
length.FOO <- function(x) length(x$value)
stopifnot(identical(seq_len(length(x)),
		    seq_along(x)))
## used C-internal non-dispatching length() in R <= 2.9.1


## factor(NULL)
stopifnot(identical(factor(), factor(NULL)))
## gave an error from R ~1.3.0 to 2.9.1


## methods() gave two wrong warnings in some cases:
op <- options(warn = 2)# no warning, please!
m1 <- methods(na.omit) ## should give (no warning):
##
setClass("bla")
setMethod("na.omit", "bla", function(object, ...) "na.omit(<bla>)")
(m2 <- methods(na.omit)) ## should give (no warning):
stopifnot(identical(m1, .S3methods("na.omit")))
options(op)
## gave two warnings, when an S3 generic had turned into an S4 one


## raw vector assignment with NA index
x <- charToRaw("abc")
y <- charToRaw("bbb")
x[c(1, NA, 3)] <- x[2]
stopifnot(identical(x, y))
## used to segfault


## Logic operations with complex
stopifnot(TRUE & -3i, FALSE | 0+1i,
	  TRUE && 1i, 0+0i || 1+0i)
## was error-caught explicitly in spite of contrary documentation


## Tests of save/load with different types of compression
x <- xx <- 1:1000
test1 <- function(ascii, compress)
{
    tf <- tempfile()
    save(x, ascii = ascii, compress = compress, file = tf)
    load(tf)
    stopifnot(identical(x, xx))
    unlink(tf)
}
for(compress in c(FALSE, TRUE))
    for(ascii in c(TRUE, FALSE)) test1(ascii, compress)
for(compress in c("bzip2", "xz"))
    for(ascii in c(TRUE, FALSE)) test1(ascii, compress)


## tests of read.table with different types of compressed input
mor <- system.file("data/morley.tab", package="datasets")
ll <- readLines(mor)
tf <- tempfile()
## gzip copression
writeLines(ll, con <- gzfile(tf)); close(con)
file.info(tf)$size
stopifnot(identical(read.table(tf), morley))
## bzip2 copression
writeLines(ll, con <- bzfile(tf)); close(con)
file.info(tf)$size
stopifnot(identical(read.table(tf), morley))
## xz copression
writeLines(ll, con <- xzfile(tf, compression = -9)); close(con)
file.info(tf)$size
stopifnot(identical(read.table(tf), morley))
unlink(tf)


## weighted.mean with NAs (PR#14032)
x <- c(101, 102, NA)
stopifnot(all.equal(mean(x, na.rm = TRUE), weighted.mean(x, na.rm = TRUE)))
## divided by 3 in 2.10.0 (only)
## but *should* give NaN for empty:
stopifnot(identical(NaN, weighted.mean(0[0])),
	  identical(NaN, weighted.mean(NA,		na.rm=TRUE)),
	  identical(NaN, weighted.mean(rep(NA_real_,2), na.rm=TRUE)))
## all three gave 0  in 2.10.x and 2.11.x (but not previously)


## unname() on 0-length vector
stopifnot(identical(1[FALSE], unname(c(a=1)[FALSE])))
## failed to drop names in 2.10.0


## complete.cases on 0-column data frame
complete.cases(data.frame(1:10)[-1])
## failed in 2.10.0


## PR#14035, converting (partially) unnamed lists to environments.
(qq <- with(list(2), ls()))
nchar(qq)
with(list(a=1, 2), ls())
## failed in R < 2.11.0


## chisq.test with over-long 'x' or 'y' arg
# https://stat.ethz.ch/pipermail/r-devel/2009-November/055700.html
x <- y <- rep(c(1000, 1001, 1002), each=5)
z <- eval(substitute(chisq.test(x,y), list(x=x)))
z
z$observed
## failed in 2.10.0


## unsplit(drop = TRUE) on a data frame failed (PR#14084)
dff <- data.frame(gr1 = factor(c(1,1,1,1,1,2,2,2,2,2,2), levels=1:4),
                  gr2 = factor(c(1,2,1,2,1,2,1,2,1,2,3), levels=1:4),
                  yy = rnorm(11), row.names = as.character(1:11))
dff2 <- split(dff, list(dff$gr1, dff$gr2), drop=TRUE)
dff3 <- unsplit(dff2, list(dff$gr1, dff$gr2), drop=TRUE)
stopifnot(identical(dff, dff3))
## failed in 2.10.0


## mean.difftime ignored its na.rm argument
z <- as.POSIXct(c("1980-01-01", "1980-02-01", NA, "1980-03-01", "1980-04-01"))
zz <- diff(z)
stopifnot(is.finite(mean(zz, na.rm=TRUE)))
## was NA in 2.10.0


## weighted means with zero weights and infinite values
x <- c(0, 1, 2, Inf)
w <- c(1, 1, 1, 0)
z <- weighted.mean(x, w)
stopifnot(is.finite(z))
## was NaN in 2.10.x


## Arithmetic operations involving "difftime"
z <- as.POSIXct(c("2009-12-01", "2009-12-02"), tz="UTC")
(zz <- z[2] - z[1])
(zzz <- z[1] + zz)
stopifnot(identical(zzz, z[2]),
          identical(zz + z[1], z[2]),
          identical(z[2] - zz, z[1]))
z <- as.Date(c("2009-12-01", "2009-12-02"))
(zz <- z[2] - z[1])
(zzz <- z[1] + zz)
stopifnot(identical(zzz, z[2]),
          identical(zz + z[1], z[2]),
          identical(z[2] - zz, z[1]))
## failed/gave wrong answers when Ops.difftime was introduced.


## quantiles, new possibilities in 2.11.0
x <- ordered(1:11, labels=letters[1:11])
quantile(x, type = 1)
quantile(x, type = 3)
st <- as.Date("1998-12-17")
en <- as.Date("2000-1-7")
ll <- seq(as.Date("2000-1-7"), as.Date("1997-12-17"), by="-1 month")
quantile(ll, type = 1)
quantile(ll, type = 3)
## failed prior to 2.11.0


## (asymptotic) point estimate in wilcox.test(*, conf.int=TRUE)
alt <- eval(formals(stats:::wilcox.test.default)$alternative)
Z <- c(-2, 0, 1, 1, 2, 2, 3, 5, 5, 5, 7)
E1 <- sapply(alt, function(a.)
	     wilcox.test(Z, conf.int = TRUE,
			 alternative = a., exact = FALSE)$estimate)
X <- c(6.5, 6.8, 7.1, 7.3, 10.2)
Y <- c(5.8, 5.8, 5.9, 6, 6, 6, 6.3, 6.3, 6.4, 6.5, 6.5)
E2 <- sapply(alt, function(a.)
	     wilcox.test(X,Y, conf.int = TRUE,
			 alternative = a., exact = FALSE)$estimate)
stopifnot(E1[-1] == E1[1],
	  E2[-1] == E2[1])
## was continiuity corrected, dependent on 'alternative', prior to 2.10.1


## read.table with embedded newlines in header (PR#14103)
writeLines(c('"B1', 'B2"', 'B3'), "test.dat")
z <- read.table("test.dat", header = TRUE)
unlink("test.dat")
stopifnot(identical(z, data.frame("B1.B2"="B3")))
## Left part of header to be read as data in R < 2.11.0


## switch() with  empty  '...'
stopifnot(is.null(switch("A")),
	  is.null(switch(1)), is.null(switch(3L)))
## the first one hung, 2nd gave error, in R <= 2.10.1


## factors with NA levels
V <- addNA(c(0,0,NA,0,1,1,0,NA,1,1))
stopifnot(identical(V, V[, drop = TRUE]))
stopifnot(identical(model.frame(~V), model.frame(~V, xlev = list(V=levels(V)))))
# dropped NA levels (in two places) in 2.10.1
V <- c(0,0,NA,0,1,1,0,NA,1,1)
stopifnot(identical(V, V[, drop = TRUE]))
stopifnot(identical(model.frame(~V), model.frame(~V, xlev = list(V=levels(V)))))
## check other cases have not been changed


## ks.test gave p=1 rather than p=0.9524 because abs(1/2-4/5)>3/10 was TRUE
stopifnot(all.equal(ks.test(1:5, c(2.5,4.5))$p.value, 20/21))


## NAs in utf8ToInt and v.v.
stopifnot(identical(utf8ToInt(NA_character_), NA_integer_),
          identical(intToUtf8(NA_integer_), NA_character_),
          identical(intToUtf8(NA_integer_, multiple = TRUE), NA_character_))
## no NA-handling prior to 2.11.0


## tcrossprod() for  matrix - vector combination
u <- 1:3 ; v <- 1:5
## would not work identically: names(u) <- LETTERS[seq_along(u)]
U <- as.matrix(u)
stopifnot(identical(tcrossprod(u,v), tcrossprod(U,v)),
	  identical(tcrossprod(u,v), u %*% t(v)),
	  identical(tcrossprod(v,u), tcrossprod(v,U)),
	  identical(tcrossprod(v,u), v %*% t(u)))
## tcrossprod(v,U) and (U,v) wrongly failed in R <= 2.10.1


## det() and determinant() in NA cases
m <- matrix(c(0, NA, 0, NA, NA, 0, 0, 0, 1), 3,3)
m0 <- rbind(0, cbind(0, m))
if(FALSE) { ## ideally, we'd want -- FIXME --
stopifnot(is.na(det(m)), 0 == det(m0))
} else print(c(det.m = det(m), det.m0 = det(m0)))
## the first wrongly gave 0  (still gives .. FIXME)


## c/rbind(deparse.level=2)
attach(mtcars)
(cn <- colnames(cbind(qsec, hp, disp)))
stopifnot(identical(cn, c("qsec", "hp", "disp")))
(cn <- colnames(cbind(qsec, hp, disp, deparse.level = 2)))
stopifnot(identical(cn, c("qsec", "hp", "disp")))
(cn <- colnames(cbind(qsec, log(hp), sqrt(disp))))
stopifnot(identical(cn, c("qsec", "", "")))
(cn <- colnames(cbind(qsec, log(hp), sqrt(disp), deparse.level = 2)))
stopifnot(identical(cn, c("qsec", "log(hp)", "sqrt(disp)")))
detach()
## 2.10.1 gave no column names for deparse.level=2


## Infinite-loops with match(incomparables=)
match(c("A", "B", "C"), "A", incomparables=NA)
match(c("A", "B", "C"), c("A", "B"), incomparables="A")
## infinite-looped in 2.10.1


## path.expand did not propagate NA
stopifnot(identical(c("foo", NA), path.expand(c("foo", NA))))
## 2.10.1 gave "NA"


## prettyNum(drop0trailing=TRUE) mangled complex values (PR#14201)
z <- c(1+2i, 1-3i)
str(z) # a user
stopifnot(identical(format(z, drop0trailing=TRUE), as.character(z)))
## 2.10.1 gave 'cplx [1:2] 1+2i 1+3i'


## "exact" fisher.test
dd <- data.frame(group=1, score=c(rep(0,14), rep(1,29), rep(2, 16)))[rep(1:59, 2),]
dd[,"group"] <- c(rep("DOG", 59), rep("kitty", 59))
Pv <- with(dd, fisher.test(score, group)$p.value)
stopifnot(0 <= Pv, Pv <= 1)
## gave P-value 1 + 1.17e-13  in R < 2.11.0


## Use of switch inside lapply (from BioC package ChromHeatMap)
lapply("forward", switch, forward = "posS", reverse = "negS")
## failed  when first converted to primitive.


## evaluation of arguments of log2
assertError(tryCatch(log2(quote(1:10))))
## 'worked' in 2.10.x by evaluting the arg twice.


## mean with NAs and trim (Bill Dunlap,
## https://stat.ethz.ch/pipermail/r-devel/2010-March/056982.html)
stopifnot(is.na(mean(c(1,10,100,NA), trim=0.1)),
          is.na(mean(c(1,10,100,NA), trim=0.26)))
## gave error, real value respectively in R <= 2.10.1


## all.equal(*, tol) for objects with numeric attributes
a <- structure(1:17, xtras = c(pi, exp(1)))
b <- a * (II <- (1 + 1e-7))
attr(b,"xtras") <- attr(a,"xtras") * II
stopifnot(all.equal(a,b, tolerance = 2e-7))
## gave  "Attributes: .... relative difference: 1e-07"  in R <= 2.10.x


## Misuse of gzcon() [PR# 14237]
(ac <- getAllConnections())
tc <- textConnection("x", "w")
try(f <- gzcon(tc)) # -> error.. but did *damage* tc
newConn <- function(){ A <- getAllConnections(); A[is.na(match(A,ac))] }
(newC <- newConn())
gg <- tryCatch(getConnection(newC), error=identity)
stopifnot(identical(gg, tc))
close(tc)
stopifnot(length(newConn()) == 0)
## getConn..(*) seg.faulted in R <= 2.10.x


## splinefun(., method = "monoH.FC")
x <- 1:7 ; xx <- seq(0.9, 7.1, length=2^12)
y <- c(-12, -10, 3.5, 4.45, 4.5, 140, 142)
Smon <- splinefun(x, y, method = "monoH.FC")
stopifnot(0 <= min(Smon(xx, deriv=1)))
## slopes in [4.4, 4.66] were slightly negative, because m[] adjustments
## could be sightly off in cases of adjacency, for  R <= 2.11.0


## prettyDate( <Date> )
x <- as.Date("2008-04-22 09:45") + 0:5
px <- pretty(x, n = 5)
stopifnot(px[1] == "2008-04-22", length(px) == 6)
## did depend on the local timezone  at first


## cut( d, breaks = n) - for d of class  'Date' or 'POSIXt'
x <- seq(as.POSIXct("2000-01-01"), by = "days", length = 20)
stopifnot(nlevels(c1 <- cut(x, breaks = 3)) == 3,
	  nlevels(c2 <- cut(as.POSIXlt(x), breaks = 3)) == 3,
	  nlevels(c3 <- cut(as.Date(x), breaks = 3)) == 3,
	  identical(c1, c2))
## failed in R <= 2.11.0


## memDecompress (https://stat.ethz.ch/pipermail/r-devel/2010-May/057419.html)
char <- paste(replicate(200, "1234567890"), collapse="")
char.comp <- memCompress(char, type="xz")
char.dec <- memDecompress(char.comp, type="xz", asChar=TRUE)
stopifnot(nchar(char.dec) == nchar(char))
## short in R <= 2.11.0


## rbeta() with mass very close to 1 -- bug PR#14291
set.seed(1)
if(any(ii <- is.na(rbeta(5000, 100, 0.001))))
    stop("rbeta() gave NAs at ", paste(which(ii), collapse=", "),
         "\n")
## did give several, but platform dependently, in R <= 2.11.0


## print.ls_str() should not eval() some objects
E <- environment((function(miss)function(){})())
E$i <- 2:4
E$o <- as.name("foobar")
E$cl <- expression(sin(x))[[1]]
ls.str(E)
## 'o' failed in R <= 2.11.0 (others in earlier versions of R)


## print() {& str()} should distinguish named empty lists
stopifnot(identical("named list()",
		    capture.output(list(.=2)[0])))
## was just "list()" up to R <= 2.11.x


## stripchart with empty first level (PR#14317)
stripchart(decrease ~ treatment, data = OrchardSprays,
           subset = treatment != "A")
## failed in 2.11.1


## versions of pre-2.12.0 using zlib 1.2.[45] failed
zz <- gzfile("ex.gz", "w")  # compressed file
cat("TITLE extra line", "2 3 5 7", "", "11 13 17", file = zz, sep ="\n")
close(zz)
blah <- file("ex.gz", "r")
stopifnot(seek(blah) == 0)
## gave random large multiple of 2^32 on Linux systems attempting to
## use LFS support.


## pre-2.12.0 wrongly accessed 0-length entries
o0 <- as.octmode(integer(0))
stopifnot(identical(o0, o0 & "400"))
## gave a seg.fault at some point


## as.logical on factors
x <- factor(c("FALSE", "TRUE"))
stopifnot(identical(as.logical(x), c(FALSE, TRUE)))
# Lost documented behaviour when taken primitive in R 2.6.0
stopifnot(identical(as.vector(x, "logical"), c(FALSE, TRUE)))
# continued to work
## Reverted in 2.12.0.


## missing backquoting of default arguments in in prompt()
f <- function (FUN = `*`) {}
pr <- prompt(f, NA)$usage
stopifnot(identical(pr[2], "f(FUN = `*`)"))
## see https://stat.ethz.ch/pipermail/r-devel/2010-August/058126.html


## cut.POSIXt very near boundaries (PR#14351)
x <- as.POSIXlt("2010-08-10 00:00:01")
stopifnot(!is.na(cut(x, "5 hours")))
## was NA in 2.11.x


## summary() on data frames with invalid names -- in UTF-8 locale
DF <- data.frame(a = 1:3, b = 4:6)
nm <- names(DF) <- c("\xca", "\xcb")
cn <- gsub(" ", "", colnames(summary(DF)), useBytes = TRUE)
stopifnot(identical(cn, nm))
m <- as.matrix(DF)
DF <- data.frame(a = 1:3, m=I(m))
cn <- gsub(" ", "", colnames(summary(DF)), useBytes = TRUE)
stopifnot(identical(cn, c("a", paste("m.", nm, sep="", collapse=""))))
##  Had NAs in < 2.12.0


## [[<- could create invalid objects,
## https://stat.ethz.ch/pipermail/r-devel/2010-August/058312.html
z0 <- z <- factor(c("Two","Two","Three"), levels=c("One","Two","Three"))
z[[2]] <- "One"
stopifnot(typeof(z) == "integer")
z[[2]] <- "Two"
stopifnot(identical(z, z0))
## failed < 2.12.0


## predict.loess with NAs
cars.lo <- loess(dist ~ speed, cars)
res <- predict(cars.lo, data.frame(speed = c(5, NA, 25)))
stopifnot(length(res) == 3L, is.na(res[2]))
res <- predict(cars.lo, data.frame(speed = c(5, NA, 25)), se = TRUE)
stopifnot(length(res$fit) == 3L, is.na(res$fit[2]),
          length(res$se.fit) == 3L, is.na(res$se.fit[2]))
cars.lo2 <- loess(dist ~ speed, cars, control = loess.control(surface = "direct"))
res <- predict(cars.lo2, data.frame(speed = c(5, NA, 25)))
stopifnot(length(res) == 3L, is.na(res[2]))
res <- predict(cars.lo2, data.frame(speed = c(5, NA, 25)), se = TRUE)
stopifnot(length(res$fit) == 3L, is.na(res$fit[2]),
          length(res$se.fit) == 3L, is.na(res$se.fit[2]))
## Used na.omit prior to 2.12.0


## student typo
try( ksmooth(cars$speed, cars$dists) )
## now error about y (== NULL);  segfaulted <= 2.11.1


## do.call()ing NextMethod and empty args:
try( do.call(function(x) NextMethod('foo'),list()) )
## segfaulted <= 2.11.1


## identical() returned FALSE on external ptr with
## identical addresses <= 2.11.1
## Example with getNativeSymbolInfo no longer relevant


## getNamespaceVersion() etc
stopifnot(getNamespaceVersion("stats") == getRversion())
## failed in R 2.11.x


## PR#14383
x <- rnorm(100)
z1 <- quantile(x, type = 6, probs = c(0, .5))
z2 <- quantile(x, type = 6, probs = c(.5, 0))
stopifnot(z1 == rev(z2))
## differed in 2.11.x


## backSpline() with decreasing knot locations
require(splines)
d1 <- c(616.1, 570.1, 523.7, 477.3, 431.3, 386.2, 342.4, 300.4, 260.4,
        222.7, 187.8, 155.7, 126.7, 100.8,  78.1,  58.6,  42.2,  28.7,
         18.1,  10.2)
r1 <- c(104.4, 110  , 115.5, 121,   126.6, 132.1, 137.7, 143.2, 148.8,
        154.3, 159.9, 165.4, 170.9, 176.5, 182,   187.6, 193.1, 198.7,
        204.2, 209.8)
sp1 <- interpSpline(r1,d1)# 'x' as function of 'y' (!)
psp1 <- predict(sp1)
bsp1 <- backSpline(sp1)
dy <- diff(predict(bsp1, .5 + 18:30)$y)
stopifnot(-.9 < dy, dy < -.35)
## failed in R <= 2.11.x: "bizarre jumps"
detach("package:splines")


## PR#14393
f <- factor(c(NA, 1, 2), levels = 1:3, labels = 1:3)
mf <- model.frame(~ f, na.action = na.pass, drop.unused.levels = TRUE)
stopifnot(identical(mf$f, f[,drop=TRUE]))
## failed to drop < 2.12.0


## problem with deparsing variable names of > 500 bytes in model.frame
## reported by Terry Therneau to R-devel, 2010-10-07
tname <- paste('var', 1:50, sep='')
tmat <- matrix(rnorm(500), ncol=50, dimnames=list(NULL, tname))
tdata <- data.frame(tmat)
temp1 <- paste( paste(tname, tname, sep='='), collapse=', ')
temp2 <- paste("~1 + cbind(", temp1, ")")
foo <- model.frame(as.formula(temp2), tdata)
## gave invalid variable name.


## subassignment to expressions sometimes coerced them to lists.
x1 <- x2 <- x3 <- expression(a = pi, b = pi^2)
x1["b"] <- expression(pi^3)
stopifnot(is.expression(x1)) # OK
x1["a"] <- NULL
stopifnot(is.expression(x1))
x2[["b"]] <- quote(pi^3)
stopifnot(is.expression(x2)) # OK
x2[["a"]] <- NULL
stopifnot(is.expression(x2))
x3$a <- NULL
stopifnot(is.expression(x3))
## coerced to lists


## predict on an lm object with type = "terms" and 'terms' specified
dat <- data.frame(y=log(1:10), x=1:10, fac=rep(LETTERS[11:13],c(3,3,4)))
fit <- lm(y~fac*x, data=dat)
pfit <- predict(fit, type="terms", interval="confidence", newdata=dat[7:5,])
pfit2 <- predict(fit, type="terms", terms=c("x","fac"),
                 interval="confidence", newdata=dat[7:5,])
pfit2Expected <- lapply(pfit,
                        function(x)if(is.matrix(x))
                        structure(x[, c("x","fac")], constant=attr(x, "constant"))
                        else x)
stopifnot(identical(pfit2, pfit2Expected))
## pfit2 failed, and without 'interval' gave se's for all terms.


## TRE called assert() on an invalid regexp (PR#14398)
try(regexpr("a{2-}", ""))
## terminated R <= 2.12.0


## ! on zero-length objects (PR#14244)
M <- matrix(FALSE, 0, 2)
stopifnot(identical(attributes(!M), attributes(M)))
# and for back compatibiility
!list() # logical(0)
## dropped all attributes in 2.12.0


## Preserve intercepts in drop.terms
tt <- terms(~ a + b - 1)
tt2 <- terms(~ b - 1)
stopifnot(identical(drop.terms(tt, 1), tt2))
stopifnot(identical(tt[2], tt2))
stopifnot(identical(tt[1:2], tt))
## reset intercept term < R 2.13.0


## Test new defn of cmdscale()
mds <- cmdscale(eurodist, eig = TRUE, k = 14)
stopifnot(ncol(mds$points) < 14L) # usually 11.
## Used negative eigenvalues in 2.12.0


## Sweave regression test moved to utils/tests.


## mapply() & sapply() should not simplify e.g. for "call":
f2 <- function(i,j) call(':',i,j)
stopifnot(identical(2:3,
		    dim(sapply(1:3, function(i) list(0, 1:i)))),
	  length(r <- mapply(1:2, c(3,7), FUN= f2)) == 2,
	  length(s <- sapply(1:3, f2, j=7)) == 3)
## length wrongly were 6 and 9, in R <= 2.12.0


## 'sep' in reshape() (PR#14335)
test <- data.frame(x = rnorm(100), y = rnorm(100), famid = rep(1:50, each=2),
                   time = rep(1:2, 50))

wide <- reshape(data = test, v.names = c("x", "y"), idvar = "famid",
                timevar = "time", sep = "", direction = "wide")
stopifnot(identical(names(wide), c("famid", "x1", "y1", "x2", "y2")))
## was c("famid", "x.1", "y.1", "x.2", "y.2") in R <= 2.12.0


## PR#14438
X <- matrix(0+1:10, ncol = 2)[, c(1,1,2,2)]
colnames(X) <- c("X1","Dup1", "X2", "Dup2")
X2 <- qr.X(qr(X))
X2
identical(colnames(X), colnames(X2))
## failed to pivot colnames in R <= 2.12.0


## improvements to aggregate.data.frame in 2.13.0
a <- data.frame(nm = c("a", "b", "a", "b"), time = rep(Sys.time(), 4))
b <- with(a, aggregate(time, list(nm=nm), max))
stopifnot(inherits(b$x, "POSIXt"))
##


## pretty(<only non-finite>)  PR#14468
stopifnot(length(pretty(-2:1 / 0)) == 0)
## gave an error in R <= 2.12.1


## revised behaviour of as.POSIXlt in R 2.13.0
x <- c("2001-02-03", "2001-02-03 04:05")
stopifnot(identical(as.POSIXlt(x), rev(as.POSIXlt(rev(x)))))
## used different formats earlier


## seq.Date could overshoot
x <- seq(as.Date("2011-01-07"), as.Date("2011-03-01"), by = "month")
stopifnot(length(x) == 2)
x <- seq(as.POSIXct("2011-01-07"), as.POSIXct("2011-03-01"), by = "month")
stopifnot(length(x) == 2)
## was 3 in R < 2.13.0


## mostattributes<- now sometimes works for data frames (PR#14469)
x <- women
mostattributes(x) <- attributes(women) # did not set names in R < 2.13.0
## but there are still problems with row.names (see the help)


## naresid.exclude when all cases have been omitted
## (reported by Simon Wood to R-help, 2011-01-14)
x <- NA_real_
na.act <- na.action(na.exclude(x))
z <- naresid(na.act, rep(0, 0))
stopifnot(identical(z, x))
## gave length-0 result


## weighted.residuals did not work correctly with mlm fits
## see https://stat.ethz.ch/pipermail/r-devel/2011-January/059642.html
d4 <- data.frame(y1=1:4, y2=2^(0:3), wt=log(1:4), fac=LETTERS[c(1,1,2,2)])
fit <- lm(data=d4, cbind(y1,y2)~fac, weights=wt)
wtr <- weighted.residuals(fit)
stopifnot(identical(dim(wtr), 3:2))
## dropped dims in 2.12.1


## ccf did not work with na.action=na.pass
## https://stat.ethz.ch/pipermail/r-help/2011-January/265992.html
z <- matrix(rnorm(50),,2); z[6,] <- NA; z <- ts(z)
acf(z, na.action=na.pass, plot = FALSE)
ccf(z[,1], z[,2], na.action=na.pass, plot=FALSE)
## failed in 2.12.1


## tests of append mode on compressed connections.
tf <- tempfile(); con <- gzfile(tf, "w")
writeLines(as.character(1:50), con)
close(con); con <- gzfile(tf, "a")
writeLines(as.character(51:70), con)
close(con)
stopifnot(length(readLines(tf)) == 70)
unlink(tf)

con <- bzfile(tf, "w")
writeLines(as.character(1:50), con)
close(con); con <- bzfile(tf, "a")
writeLines(as.character(51:70), con)
close(con)
stopifnot(length(readLines(tf)) == 70)
unlink(tf)

con <- xzfile(tf, "w")
writeLines(as.character(1:50), con)
close(con); con <- xzfile(tf, "a")
writeLines(as.character(51:70), con)
close(con)
stopifnot(length(readLines(tf)) == 70)
unlink(tf)
## bzfile warned and did not work R < 2.13.0


## NA_complex_ in prettyNum()
format(c(pi+0i, NA),   drop0 = TRUE)
prettyNum(NA_complex_, drop0 = TRUE)
## gave errors in R < 2.12.2


## Map() needed to call match.fun() itself (PR#14495)
local({a <- sum; Map("a", list(1:5))})
## failed R < 2.13.0


## correct format() / rounding, print()ing -- (PR#14491)
stopifnot(format.info(7.921,     digits=2) == c(3,1,0),
          format.info(5.9994001, digits=4) == c(5,3,0))
## gave (1, 0, 0) in all R versions < 2.13.0
stopifnot(identical(format(0.2204, digits=3), "0.22"))
## gave "0.220" previously


## regression test for PR#14517
try(unzip('non-existing_file.zip', list=TRUE, unzip="internal"))
## crashed on some platforms in pre-2.13.0


## plot.formula(*, data=<matrix>) etc
A <- data.matrix(anscombe)
plot  (y1 ~ x1, data = A, main = "Anscombe's first two sets")
points(y2 ~ x2, data = A, col=2, pch=2)
lines (y2 ~ x2, data = A, lwd=2, col="gray")
## using a matrix failed in R < 2.13.0  *when* there was an extra argument


## PR#14530
dfA <- data.frame(A=1:2, B=3:4, row.names=letters[1:2])
dfB <- dfA[2:1,]
res <- try(data.frame(dfA, dfA[2:1,], check.rows=TRUE))
stopifnot(inherits(res, "try-error"))
## 'worked' in 2.12.2.


## uniroot(f,..) when f(.) == -Inf :
## now play with different  g(.)'s ..
g <- function(x) exp( 5*sign(x)*abs(x)^2.1 )
if(FALSE) { ## if you want to see how it *did* go wrong:
    ff1 <- function(x) {r <- log(g(x)); print(c(x,r)); r}
    str(ur <- uniroot(ff1, c(-90,100)))
}
assertWarning(uniroot(function(x) log(g(x)), c(-90,100)))
str(ur <- uniroot(function(x) log(g(x)), c(-90,100)))# -> 2 warnings .. -Inf replaced ..
stopifnot(abs(ur$root) < 0.001)
## failed badly in R < 2.13.0, as -Inf was replaced by +1e308


## as.matrix.dist
x <- matrix(,0,0)
d <- dist(x)
as.matrix(d)
## Threw an error < 2.13.0


## smooth.spline with data with a very small range.  (PR#14552)
dt <- seq(as.POSIXct("2011-01-01"), as.POSIXct("2011-01-01 10:00:00"), by="min")
x <- as.double(dt)
y <- sin(seq_along(x) * 3 * pi/180)
s <- smooth.spline(x, y)
stopifnot(length(s$x) == length(x))
## Chose 5 distinct values of x in 2.13.0


## readBin on a raw connection
rawcon <- rawConnection(as.raw(101:110))
res <- readBin(rawcon, what="integer", size=1, n=4)
close(rawcon)
stopifnot(identical(res, 101:104))
## read the same value repeatedly in 2.13.0


## Types of closure bodies
fun <- eval(substitute(function() x, list(x = environment())))
body(fun)
# an external pointer
y <- file(""); z <- attr(y, "conn_id"); close(y)
fun <- eval(substitute(function() x, list(x = z)))
body(fun)
## not allowed in R < 2.14.0.


## Corner cases for signif() and round()
x <- pi^(-6:6)
stopifnot(identical(signif(x, -Inf), signif(x, 1L))) # zero in R < 2.14.0
stopifnot(identical(round(x, -Inf), rep(0, length(x)))) # NAs in R < 2.14.0
##


## (un)stack with character columns
DF <- data.frame(a = letters[1:3], b = letters[4:6], stringsAsFactors = FALSE)
DF2 <- stack(DF)
stopifnot(class(DF2$values) == "character") # was factor
DF3 <- unstack(DF2) # contained factors
stopifnot(all(sapply(DF3, class) == "character"))
DF4 <- stack(DF[1])
stopifnot(identical(unstack(DF4), DF[1])) # was a list
## issues in R < 2.14.0


## PR#14710 (an instance of PR#8528)
stopifnot(!is.na(qchisq(p=0.025, df=0.00991)))
## NaN in 2.13.2


## nobs() for zero-weight glm fits:
DF <- data.frame(x1=log(1:10), x2=c(1/(1:9), NA), y=1:10,
                 wt=c(0,2,0,4,0,6,7,8,9,10))
stopifnot(nobs(lm(y ~ x1 + x2, weights = wt, data=DF)) ==
          nobs(glm(y ~ x1 + x2, weights = wt, data = DF)))
## was 6 and 9 in R < 2.14.1.


## anyDuplicated(*, MARGIN=0)
m. <- m <- cbind(M = c(3,2,7,2),
                 F = c(6,2,7,2))
rownames(m.) <- LETTERS[1:4]; m.
stopifnot(identical(attributes(dm <- duplicated(m., MARGIN=0)),
		    attributes(m.)),
	  (dvm <- duplicated(as.vector(m.))) == dm, # all TRUE
	  identical(anyDuplicated(	    m.,	 MARGIN=0),
		    anyDuplicated(as.vector(m.), MARGIN=0)))
## gave error in R < 2.14.1


## PR#14739
stopifnot(!is.nan(pbinom(10, 1e6, 0.01, log.p=TRUE)))
## was NaN thanks to Maechler's misuse of toms708 in 2.11.0.


## PR14742
stopifnot(identical(duplicated(data.frame(c(1, 1)), fromLast = TRUE),
                    duplicated(c(1, 1), fromLast = TRUE)))
## first ignored fromLast in 2.14.0.

## str(*, list.len, strict.width=.):
dm <- as.data.frame(matrix( rnorm(10000), nrow=50, ncol=200))
calls <- list(quote( str(dm, list.len= 7)),
	      quote( str(dm, list.len= 7, digits=10, width=88, strict.width='no')),
	      quote( str(dm, list.len= 7, digits=10, width=88, strict.width='cut')))
ee <- lapply(calls, function(cl) capture.output(eval(cl)))
stopifnot(sapply(ee, length) == 1 + 7 + 1)
## with 'list.len' was not used with 'strict.width="cut"' in  R <= 2.14.1

## Tests of serialization (new internal code in 2.15.0)
input <- pi^(1:10)
stopifnot(identical(input, unserialize(serialize(input, NULL))))
stopifnot(identical(input, unserialize(serialize(input, NULL, xdr = FALSE))))
z <- pi+ 3*1i
input <- z^(1:10)
stopifnot(identical(input, unserialize(serialize(input, NULL))))
stopifnot(identical(input, unserialize(serialize(input, NULL, xdr = FALSE))))
input <- matrix(1:1000000, 1000, 1000)
stopifnot(identical(input, unserialize(serialize(input, NULL))))
stopifnot(identical(input, unserialize(serialize(input, NULL, xdr = FALSE))))
z <- paste(readLines(file.path(R.home("doc"), "COPYING")), collapse="\n")
input <- charToRaw(z)
stopifnot(identical(input, unserialize(serialize(input, NULL))))
serialize(input, con <- file("serial", "wb")); close(con)
res <- unserialize(con <- file("serial", "rb")); close(con)
stopifnot(identical(input, res))
unlink("serial")
## Just a test for possible regressions.


## mis-PROTECT()ion in printarray C code:
df <- data.frame(a=1:2080, b=1001:2040, c=letters, d=LETTERS, e=1:1040)
stopifnot(length(df.ch <- capture.output(df)) == 1+nrow(df))
## "cannot allocate memory block of size 17179869183.6 Gb" in R <= 2.14.1


## logic in one of the many combinations of predict.lm() computations
fit <- lm(mpg ~ disp+hp, data=mtcars)
r <- predict(fit, type="terms", terms = 2, se.fit=TRUE)
stopifnot(dim(r$se.fit) == c(nrow(mtcars), 1))
## failed in  R <= 2.14.1


## format.POSIXlt(x) for wrong x
d0 <- strptime(as.Date(logical(0)), format="%Y-%m-%d", tz = "GMT")
d0$mday <- 1
try(format(d0))
## crashed (Arithmetic exception) for  R <= 2.14.1


## options("max.print") :
tools::assertCondition(options(max.print = Inf), "warning") # and then error
assertError(options(max.print = -2))
tools::assertCondition(options(max.print = 1e100), "warning")
## gave only warnings (every print() time, ...)  in R <= 2.14.2


## attributes with units<-  (PR#14839)
tt <- structure(500, units = "secs", class = "difftime", names = "a")
tt
units(tt) <- "mins"
tt
stopifnot(identical(names(tt), "a"))
## R < 2.15.0 changed the name, but then it was not documented to be kept.


## predict( VAR(p >= 2) )
set.seed(42)
u <- matrix(rnorm(200), 100, 2)
y <- filter(u, filter=0.8, "recursive")
est <- ar(y, aic = FALSE, order.max = 2) ## Estimate VAR(2)
xpred <- predict(object = est, n.ahead = 100, se.fit = FALSE)
stopifnot(dim(xpred) == c(100, 2), abs(range(xpred)) < 1)
## values went to +- 1e23 in R <= 2.14.2


## regression tests for merge
d1 <- data.frame(a = 1:10, b = 1:10, b.x = 10:1)
d2 <- data.frame(a = 1:10, b = 101:110)
op <- options(warn = 2)
z <- try(merge(d1, d2, by = 'a'))
stopifnot(inherits(z, "try-error"))
merge(d1, d2, by = 'a', suffixes = c("", ".y"))
z <- try(merge(d1, d2, by = 'a', suffixes = c(".z", ".z")))
stopifnot(inherits(z, "try-error"))
options(op)
# First 'worked' in R < 2.15.0, second was disallowed in early 2012,
# third 'worked' in R < 2.15.1.
# example based on package SDMTools::compare.matrix
# where 'by' is ambiguous.
x <- expand.grid(x = 1:2, y = 1:2)
y <- data.frame(x = c(1,2,1,2), y = c(1,1,2,2), z = c(5040,128,1123,3709))
merge(x, y, all = TRUE)
names(y)[3] <- "x"
stopifnot(inherits(try(merge(x, y, all = TRUE)), "try-error"))
## 'worked' in R < 2.15.1.


## misuse of seq() by package 'plotrix'
stopifnot(inherits(try(seq(1:50, by = 5)), "try-error"))
## gave 1:50 in R < 2.15.1, with warnings from seq().


## regression test for PR#14850 (misuse of dim<-)
b <- a <- matrix(1:2, ncol = 2)
`dim<-`(b, c(2, 1))
stopifnot(ncol(a) == 2)
## did not duplicate.


## deparsing needs escape characters in names (PR#14846)
f <- function(x) switch(x,"\\dbc"=2,3)
parse(text=deparse(f))
## Gave error about unrecognized escape


## hclust()'s original algo was not ok for "median" (nor "centroid") -- PR#4195
n <- 12; p <- 3
set.seed(46)
d <- dist(matrix(round(rnorm(n*p), digits = 2), n,p), "manhattan")
d[] <- d[] * sample(1 + (-4:4)/100, length(d), replace=TRUE)
hc <- hclust(d, method = "median")
stopifnot(all.equal(hc$height[5:11],
                    c(1.69805, 1.75134375, 1.34036875, 1.47646406,
                      3.21380039, 2.9653438476, 6.1418258), tolerance = 1e-9))
## Also ensure that hclust() remains fast:
set.seed(1); nn <- 2000
tm0 <- system.time(dst <- as.dist(matrix(runif(n = nn^2, min = 0, max = 1)^1.1, nn, nn)))
(tm <- system.time(hc <- hclust(dst, method="average")))
stopifnot(tm[1] <= tm0[1])
## was slow  from R 1.9.0 up to R 2.15.0


## 'infinity' partially matched 'inf'
stopifnot(as.numeric("infinity") == Inf)
## was NA in R < 2.15.1


## by() failed for a 0-row data frame
b <- data.frame(ppg.id=1, predvol=2)
a <- b[b$ppg.id == 2, ]
by(a, a["ppg.id"], function(x){
    vol.sum = numeric()
    id = integer();
    if(dim(x)[1] > 0) {id = x$ppg.id[1]; vol.sum = sum(x$predvol)}
    data.frame(ppg.id=id, predVolSum=vol.sum)
})
## failed in 2.15.0


## model.frame.lm could be fooled if factor levels were re-ordered
A <- warpbreaks
fm1 <- lm(breaks ~ wool*tension, data = A, model = TRUE)
fm2 <- lm(breaks ~ wool*tension, data = A, model = FALSE)
A$tension <- factor(warpbreaks$tension, levels = c("H", "M", "L"))
stopifnot(identical(model.frame(fm1), model.frame(fm2)))
stopifnot(identical(model.frame(fm1), model.frame(fm1, data = A)))
stopifnot(identical(model.matrix(fm1), model.matrix(fm2)))
## not true before 2.15.2


## model.frame.lm did not make use of predvars
library(splines)
fm <- lm(weight ~ ns(height, 3), data = women)
m1 <- model.frame(fm)[1:3, ]
m2 <- model.frame(fm, data = women[1:3, ])
# attributes will differ
stopifnot(identical(as.vector(m1[,2]), as.vector(m2[,2])))
## differed in R < 2.15.2


## JMC's version of class<- did not work as documented. (PR#14942)
x <- 1:10
class(x) <- character()
class(x) <- "foo"
class(x) <- character()
oldClass(x) <- "foo"
oldClass(x) <- character()
## class<- version failed: required NULL


## anova.lmlist could fail (PR#14960)
set.seed(1)
y <- rnorm(20)
x <- rnorm(20)
f <- factor(rep(letters[1:2], each = 10))
model1 <- lm(y ~ x)
model2 <- lm(y ~ x + f)
anova(model1, model2, test = "F")
##


## regression test for sunflowerplot's formula method
sunflowerplot( Sepal.Length ~ Sepal.Width, data = iris, xlab = "A")
## failed in 2.15.1


## misuse of alloca
for(n in c(200, 722, 1000)) x <- rWishart(1, n, diag(n))
## failed in various ways in R <= 2.15.1


## undocumented used of rep(NULL), from matplot()
stopifnot(identical(rep(NULL, length.out = 4), NULL))
## now gives a warning.


## PR14974
a.factor <- as.factor(rep(letters[1:2], 2))
b.factor <- as.factor(rep(c(1:2), each = 2))
y <- cbind(aa = as.character(a.factor), bb = b.factor)
data1 <- data.frame(a.factor, b.factor, y = NA)
data1$y <- y # inserts a matric
data1 <- subset(data1, !((a.factor == "b") & (b.factor == 2))) # Delete row
factorial.data <- data.frame(a.factor, b.factor, row = 1:length(b.factor))
ans <- merge(factorial.data, data1, by = c("a.factor", "b.factor"),
             all.x = TRUE)
stopifnot(is.na(ans[["y"]][4,]))
## only set the first column of ans[["y"]] to NA.


## PR14967
stopifnot(qgeom(1e-20, prob = 0.1) >= 0)
## was -1 in R 2.15.1


## Regression test for r60116:7
(p1 <- parse(text="exp(-0.5*u**2)", srcfile=NULL))
(p2 <- parse(text="exp(-0.5*u^2)",  srcfile=NULL))
stopifnot(identical(p1, p2))
## p1 was expression(exp((-0.5 * u)^2))


## backsolve with k < nrows(rhs)
r <- rbind(c(1,2,3),c(0,1,1),c(0,0,2))
b <- c(8,4,2,1)
x <- backsolve(r, cbind(b,b))
stopifnot(identical(x[,1], x[,2]))
## 2.15.1 used elements (4,1), (2,1), (2,2) for second column.


## Matrix oddly assumes that solve() drops NULL dimanmes
A <- diag(3)
dimnames(A) <- list(NULL, NULL)
sA <- solve(A)
stopifnot(is.null(dimnames(sA)))
# and expm inverts a logical matrix, even though this is not as documented.
Q <- matrix(c(FALSE, TRUE, TRUE, FALSE), 2, 2)
is.numeric(Q) # FALSE
solve(Q)
## failed in R-devel, which interpreted 'numeric' correctly.


## tests of rowsum() with names and for factor groups
set.seed(123)
x <- matrix(runif(100), ncol=5)
group <- sample(1:8, 20, TRUE)
(xsum <- rowsum(x, group))
colnames(x) <- letters[16:20]
(xsum <- rowsum(x, group))
rowsum(as.data.frame(x), group)
group <- factor(group)
(xsum <- rowsum(x, group))
stopifnot(sapply(dimnames(xsum), is.character))
rowsum(as.data.frame(x), group)
## one version had factor row names.


## Rather pointless usage in PR#15044
set.seed(42)
n <- 10
y <- rnorm(n)
x <- rnorm(n)
w <- rep(0, n)
lm.wfit(cbind(1, x), y, w)
## segfaulted in 2.15.1, only


## as.data.frame() methods should preferably not barf on an 'nm' arg
## reported by Bill Dunlap
## (https://stat.ethz.ch/pipermail/r-devel/2012-September/064848.html)
as.data.frame(1:10, nm = "OneToTen")
as.data.frame(LETTERS[1:10], nm = "FirstTenLetters")
as.data.frame(LETTERS[1:10])
## second failed in 2.15.1.


## Test of stack direction (related to PR#15011)
f <- function(depth) if(depth < 20) f(depth+1) else Cstack_info()
(z <- f(0))
z10 <- f(10)
if(is.na(z[2]) || is.na(z10[2])) {
    message("current stack size is not available")
} else stopifnot(z[2] > z10[2])
## Previous test ould be defeated by compiler optimization.


##
options(max.print = .Machine$integer.max)
1 ## segfaulted because of integer overflow
stopifnot(identical(.Machine$integer.max, getOption("max.print")))
##


## corner cases for arima.sim(), in part PR#15068
stopifnot(length(arima.sim(list(order = c(0,0,0)), n = 10)) == 10)
stopifnot(inherits(try(arima.sim(list(order = c(1,0,0), ar = 0.7), n = 0)),
                   "try-error"))
## one too long in R < 2.15.2


## maintainer()
maintainer('stats')
maintainer("impossible_package_name")
## gave an error in R < 2.15.2


## PR#15075 and more
stopifnot(is.finite(c(beta(0.01, 171), beta(171, 0.01), beta(1e-200, 1e-200))))
## each overflowed to +Inf during calculations in R <= 2.15.2


## PR#15077
default <- 1; z <- eval(bquote(function(y = .(default)) y))
zz <- function(y = 1) y
stopifnot(identical(args(z), args(zz))) # zz has attributes
## was not substituted in R <= 2.15.2


## PR#15098
x <- list()
x[1:2] <- list(1)
x[[1]][] <- 2  # change part of first component of x
x   # second component of x should not be affected
stopifnot(identical(x[[2]], 1))# was 2
##
## 2nd example from Comment #5
x <- list()
list(1) -> x[1] -> x[2]
x[[1]][] <- 2
stopifnot(x[[2]] == 1)## was 2, wrongly, as well ..
##
## 3rd example from Comment #5
y <- list(1)
x <- list()
x[1] <- y
x[[1]][] <- 2
stopifnot(y[[1]] == 1)## was 2
## "NAMED": all three were wrong in    2.4.0 <= R <= 2.15.2


## PR#15115
a <- as.name("abc")
f <- call("==", a, 1L)
for (i in 2:5)
   f <- call("+", f, call("==", a, i))
abc <- 2
stopifnot(eval(f) == 1)
## Was 0 in 2.15.2 because the i was not duplicated


## Complex subassignment  return value
## From: Justin Talbot to R-devel, 8 Jan 2013
a <- list( 1 ); b <- (a[[1]] <- a); stopifnot(identical(b, list( 1 )))
a <- list(x=1); b <- ( a$x  <-  a); stopifnot(identical(b, list(x=1)))
## both failed in 2.15.2


## TukeyHSD with na.omit = na.exclude, see
## https://stat.ethz.ch/pipermail/r-help/2012-October/327119.html
br <- warpbreaks
br[br$tension == "M", "breaks"] <- NA
fit1 <- aov(breaks ~ wool + tension, data = br)
TukeyHSD(fit1, "tension", ordered = TRUE)
fit2 <- aov(breaks ~ wool + tension, data = br, na.action = na.exclude)
(z <- TukeyHSD(fit2, "tension", ordered = TRUE))
stopifnot(!is.na(z$tension))
## results were NA in R <= 2.15.2


## recursive listing of directories
p <- file.path(R.home("share"),"texmf") # always exists, readable
lfri <- list.files(p, recursive=TRUE, include.dirs=TRUE)
subdirs <- c("bibtex", "tex")
lfnd <- setdiff(list.files(p, all.files=TRUE, no..=TRUE), ".svn")
stopifnot(!is.na(match(subdirs, lfri)), identical(subdirs, lfnd))
## the first failed for a few days, unnoticed, in the development version of R


## [sd]Quote on 0-length inputs.
x <- character(0)
stopifnot(identical(sQuote(x), x), identical(dQuote(x), x))
## was length one in 2.15.2

## aperm(a, <char>)  when a has named dimnames:
a <- matrix(1:6, 2, dimnames=list(A=NULL, B=NULL))
stopifnot(identical(unname(aperm(a, c("B","A"))),
		    matrix(1:6, 3, byrow=TRUE)))# worked
assertError(aperm(a, c("C","A")))# fine, but
## forgetting one had been detrimental:
assertError( aperm(a, "A"))
## seg.faulted in 2.15.2 and earlier

## enc2utf8 failed on NA in non-UTF-8 locales PR#15201
stopifnot(identical(NA_character_, enc2utf8(NA_character_)))
## gave "NA" instead of NA_character_

## End of regression tests for R < 3.0.0
## -------------------------------------

proc.time()
