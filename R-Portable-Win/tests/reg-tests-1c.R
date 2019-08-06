## Regression tests for R 3.[0-3].*

pdf("reg-tests-1c.pdf", encoding = "ISOLatin1.enc")
.pt <- proc.time()

## mapply with classed objects with length method
## was not documented to work in 2.x.y
setClass("A", representation(aa = "integer"))
a <- new("A", aa = 101:106)
setMethod("length", "A", function(x) length(x@aa))
setMethod("[[", "A", function(x, i, j, ...) x@aa[[i]])
(z <- mapply(function(x, y) {x * y}, a, rep(1:3, 2)))
stopifnot(z == c(101, 204, 309, 104, 210, 318))
## reported as a bug (which it was not) by H. Pages in
## https://stat.ethz.ch/pipermail/r-devel/2012-November/065229.html

## recyling in split()
## https://stat.ethz.ch/pipermail/r-devel/2013-January/065700.html
x <- 1:6
y <- split(x, 1:2)
class(x) <- "ABC" ## class(x) <- "A" creates an invalid object
yy <- split(x, 1:2)
stopifnot(identical(y, yy))
## were different in R < 3.0.0


## dates with fractional seconds after 2038 (PR#15200)
## Extremely speculative!
z <- as.POSIXct(2^31+c(0.4, 0.8), origin=ISOdatetime(1970,1,1,0,0,0,tz="GMT"))
zz <- format(z)
stopifnot(zz[1] == zz[2])
## printed form rounded not truncated in R < 3.0.0

## origin coerced in tz and not GMT by as.POSIXct.numeric()
x <- as.POSIXct(1262304000, origin="1970-01-01", tz="EST")
y <- as.POSIXct(1262304000, origin=.POSIXct(0, "GMT"), tz="EST")
stopifnot(identical(x, y))

## Handling records with quotes in names
x <- c("a b' c",
"'d e' f g",
"h i 'j",
"k l m'")
y <- data.frame(V1 = c("a", "d e", "h"), V2 = c("b'", "f", "i"), V3 = c("c", "g", "j\nk l m"))
f <- tempfile()
writeLines(x, f)
stopifnot(identical(count.fields(f), c(3L, 3L, NA_integer_, 3L)))
stopifnot(identical(read.table(f), y))
stopifnot(identical(scan(f, ""), as.character(t(as.matrix(y)))))

## docu always said  'length 1 is sorted':
stopifnot(!is.unsorted(NA))

## str(.) for large factors should be fast:
u <- as.character(runif(1e5))
dummy <- str(u); dummy <- str(u); # force compilation of str
t1 <- max(0.001, system.time(str(u))[[1]]) # get a baseline > 0
uf <- factor(u)
(t2 <- system.time(str(uf))[[1]]) / t1 # typically around 1--2
stopifnot(t2  / t1 < 30)
## was around 600--850 for R <= 3.0.1


## ftable(<array with unusual dimnames>)
(m <- matrix(1:12, 3,4, dimnames=list(ROWS=paste0("row",1:3), COLS=NULL)))
ftable(m)
## failed to format (and hence print) because of NULL 'COLS' dimnames

## regression test formerly in kmeans.Rd, but result differs by platform
## Artificial example [was "infinite loop" on x86_64; PR#15364]
rr <- c(rep(-0.4, 5), rep(-0.4- 1.11e-16, 14), -.5)
r. <- signif(rr, 12)
k3 <- kmeans(rr, 3, trace=2) ## Warning: Quick-Transfer.. steps exceed
try ( k. <- kmeans(r., 3) ) # after rounding, have only two distinct points
      k. <- kmeans(r., 2)   # fine


## PR#15376
stem(c(1, Inf))
## hung in 3.0.1


## PR#15377, very long variable names
x <- 1:10
y <- x + rnorm(10)
z <- y + rnorm(10)
yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy <- y
fit <- lm(cbind(yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy, z) ~ x)
## gave spurious error message in 3.0.1.

## PR#15341 singular complex matrix in rcond()
set.seed(11)
n <- 5
A <- matrix(runif(n*n),nrow=n)
B <- matrix(runif(n*n),nrow=n)
B[n,] <- (B[n-1,]+B[n-2,])/2
rcond(B)
B <- B + 0i
rcond(B)
## gave error message (OK) in R 3.0.1: now returns 0 as in real case.


## Misuse of formatC as in PR#15303
days <- as.Date(c("2012-02-02", "2012-03-03", "2012-05-05"))
(z <- formatC(days))
stopifnot(!is.object(z), is.null(oldClass(z)))
## used to copy over class in R < 3.0.2.


## PR15219
val <- sqrt(pi)
fun <- function(x) (-log(x))^(-1/2)
(res <- integrate(fun, 0, 1, rel.tol = 1e-4))
stopifnot(abs(res$value - val) < res$abs.error)
(res <- integrate(fun, 0, 1, rel.tol = 1e-6))
stopifnot(abs(res$value - val) < res$abs.error)
res <- integrate(fun, 0, 1, rel.tol = 1e-8)
stopifnot(abs(res$value - val) < res$abs.error)

fun <- function(x) x^(-1/2)*exp(-x)
(res <- integrate(fun, 0, Inf, rel.tol = 1e-4))
stopifnot(abs(res$value - val) < res$abs.error)
(res <- integrate(fun, 0, Inf, rel.tol = 1e-6))
stopifnot(abs(res$value - val) < res$abs.error)
(res <- integrate(fun, 0, Inf, rel.tol = 1e-8))
stopifnot(abs(res$value - val) < res$abs.error)
## sometimes exceeded reported error in 2.12.0 - 3.0.1


## Unary + should coerce
x <- c(TRUE, FALSE, NA, TRUE)
stopifnot(is.integer(+x))
## +x was logical in R <= 3.0.1


## Attritbutes of value of unary operators
# +x, -x were ts, !x was not in 3.0.2
x <- ts(c(a=TRUE, b=FALSE, c=NA, d=TRUE), frequency = 4, start = 2000)
x; +x; -x; !x
stopifnot(is.ts(!x), !is.ts(+x), !is.ts(-x))
# +x, -x were ts, !x was not in 3.0.2
x <- ts(c(a=1, b=2, c=0, d=4), frequency = 4, start = 2010)
x; +x; -x; !x
stopifnot(!is.ts(!x), is.ts(+x), is.ts(-x))
##


## regression test incorrectly in colorRamp.Rd
bb <- colorRampPalette(2)(4)
stopifnot(bb[1] == bb)
## special case, invalid in R <= 2.15.0:


## Setting NAMED on ... arguments
f <- function(...) { x <- (...); x[1] <- 7; (...) }
stopifnot(f(1+2) == 3)
## was 7 in 3.0.1


## copying attributes from only one arg of a binary operator.
A <- array(c(1), dim = c(1L,1L), dimnames = list("a", 1))
x <- c(a = 1)
B <- A/(pi*x)
stopifnot(is.null(names(B)))
## was wrong in R-devel in Aug 2013
## needed an un-NAMED rhs.


## lgamma(x) for very small negative x
X <- 3e-308; stopifnot(identical(lgamma(-X), lgamma(X)))
## lgamma(-X) was NaN in R <= 3.0.1


## PR#15413
z <- subset(data.frame(one = numeric()), select = one)
stopifnot(nrow(z) == 0L)
## created a row prior to 3.0.2


## https://stat.ethz.ch/pipermail/r-devel/2013-September/067524.html
dbeta(0.9, 9.9e307, 10)
dbeta(0.1, 9,  9.9e307)
dbeta(0.1, 9.9e307, 10)
## first two hung in R <= 3.0.2

## PR#15465 (0-extent matrix / data frame)
provideDimnames(matrix(nrow = 0, ncol = 1))
provideDimnames(table(character()))
as.data.frame(table(character()))
## all failed in 3.0.2

## PR#15004
n <- 10
s <- 3
l <- 10000
m <- 20
x <- data.frame(x1 = 1:n, x2 = 1:n)
by <- data.frame(V1 = factor(rep(1:3, n %/% s + 1)[1:n], levels = 1:s))
for(i in 1:m) {
    by[[i + 1]] <- factor(rep(l, n), levels = 1:l)
}
agg <- aggregate.data.frame(x, by, mean)
stopifnot(nrow(unique(by)) == nrow(agg))
## rounding caused groups to be falsely merged

## PR#15454
set.seed(357)
z <- matrix(c(runif(50, -1, 1), runif(50, -1e-190, 1e-190)), nrow = 10)
contour(z)
## failed because rounding made crossing tests inconsistent

## Various cases where zero length vectors were not handled properly
## by functions in base and utils, including PR#15499
y <- as.data.frame(list())
format(y)
format(I(integer()))
gl(0, 2)
z <- list(numeric(0), 1)
stopifnot(identical(relist(unlist(z), z), z))
summary(y)
## all failed in 3.0.2

## PR#15518 Parser catching errors in particular circumstance:
(ee <- tryCatch(parse(text = "_"), error= function(e)e))
stopifnot(inherits(ee, "error"))
## unexpected characters caused the parser to segfault in 3.0.2


## nonsense value of nmax
unique(1:3, nmax = 1)
## infinite-looped in 3.0.2, now ignored.


## besselI() (and others), now using sinpi() etc:
stopifnot(all.equal(besselI(2.125,-5+1/1024),
		    0.02679209380095711, tol= 8e-16),
	  all.equal(lgamma(-12+1/1024), -13.053274367453049, tol=8e-16))
## rel.error was 1.5e-13 / 7.5e-14 in R <= 3.0.x
ss <- sinpi(2*(-10:10)-2^-12)
tt <- tanpi(  (-10:10)-2^-12)
stopifnot(ss == ss[1], tt == tt[1], # as internal arithmetic must be exact here
	  all.equal(ss[1], -0.00076699031874270453, tol=8e-16),
	  all.equal(tt[1], -0.00076699054434309260, tol=8e-16))
## (checked via Rmpfr) The above failed during development


## PR#15535 c() "promoted" raw vectors to bad logical values
stopifnot( c(as.raw(11), TRUE) == TRUE )
## as.raw(11) became a logical value coded as 11,
## and did not test equal to TRUE.


## PR#15564
fit <- lm(rnorm(10) ~ I(1:10))
predict(fit, interval = "confidence", scale = 1)
## failed in <= 3.0.2 with object 'w' not found


## PR#15534 deparse() did not produce reparseable complex vectors
assert.reparsable <- function(sexp) {
  deparsed <- paste(deparse(sexp), collapse=" ")
  reparsed <- tryCatch(eval(parse(text=deparsed)[[1]]), error = function(e) NULL)
  if (is.null(reparsed))
    stop(sprintf("Deparsing produced invalid syntax: %s", deparsed))
  if(!identical(reparsed, sexp))
    stop(sprintf("Deparsing produced change: value is not %s", reparsed))
}

assert.reparsable(1)
assert.reparsable("string")
assert.reparsable(2+3i)
assert.reparsable(1:10)
assert.reparsable(c(NA, 12, NA, 14))
assert.reparsable(as.complex(NA))
assert.reparsable(complex(real=Inf, i=4))
assert.reparsable(complex(real=Inf, i=Inf))
assert.reparsable(complex(real=Inf, i=-Inf))
assert.reparsable(complex(real=3, i=-Inf))
assert.reparsable(complex(real=3, i=NaN))
assert.reparsable(complex(r=NaN, i=0))
assert.reparsable(complex(real=NA, i=1))
assert.reparsable(complex(real=1, i=NA))
## last 7 all failed


## PR#15621 backticks could not be escaped
stopifnot(deparse(as.name("`"), backtick=TRUE) == "`\\``")
assign("`", TRUE)
`\``
tools::assertError(parse("```"))
##


## We document tanpi(0.5) etc to be NaN
stopifnot(is.nan(tanpi(c(0.5, 1.5, -0.5, -1.5))))
## That is not required for system implementations, and some give +/-Inf


## PR#15642 segfault when parsing overflowing reals
as.double("1e1000")


ll <- ml <- list(1,2); dim(ml) <- 2:1
ali <- all.equal(list( ), identity)  # failed in R-devel for ~ 30 hours
al1 <- all.equal(list(1), identity)  # failed in R < 3.1.0
stopifnot(length(ali) == 3, grepl("list", ali[1]),
	  grepl("length", ali[2], ignore.case=TRUE),
	  is.character(al1), length(al1) >= 2,
	  all.equal(ml, ml),
	  all.equal(ll, ml, check.attributes=FALSE))


## PR#15699 aggregate failed when there were no grouping variables
dat <- data.frame(Y = runif(10), X = sample(LETTERS[1:3], 10, TRUE))
aggregate(Y ~ 1, FUN = mean, data = dat)


## merge() with duplicated column names, similar to PR#15618
X <- data.frame(Date = c("1967-02-01", "1967-02-02", "1967-02-03"),
                Settle.x = c(NA, NA, NA), Settle.y = c(NA, NA, NA),
                Settle = c(35.4, 35.15, 34.95))
Y <- data.frame(Date = c("2013-12-10", "2013-12-11", "2013-12-12"),
                Settle = c(16.44, 16.65, 16.77))
merge(X, Y, by = "Date", all = TRUE)
## failed in R < 3.1.0: now warns (correctly).


## PR#15679
badstructure <- function(depth, key)
{
    ch <- if (depth == 1L) list() else list(badstructure(depth-1,key))
    r <- list()
    r[[key]] <- ch
    r
}
badstructure(20, "children")
## overran, segfaulted for the original reporter.


## PR#15702 and PR#15703
d <- as.dendrogram(hclust(dist(sin(1:7))))
(dl <- d[[c(2,1,2)]]) # single-leaf dendrogram
stopifnot(inherits(dl, "dendrogram"), is.leaf(dl),
	  identical(attributes(reorder(dl, 1:7)), c(attributes(dl), value = 5L)),
	  identical(order.dendrogram(dl), as.vector(dl)),
	  identical(d, as.dendrogram(d)))
## as.dendrogram() was hidden;  order.*() failed for leaf


## using *named* method
hw <- hclust(dist(sqrt(1:5)), method=c(M = "ward"))
## failed for 2 days in R-devel/-alpha


## PR#15758
my_env <- new.env(); my_env$one <- 1L
save(one, file = tempfile(), envir = my_env)
## failed in R < 3.1.1.


## Conversion to numeric in boundary case
ch <- "0x1.ffa0000000001p-1"
rr <- type.convert(ch, numerals = "allow.loss")
rX <- type.convert(ch, numerals = "no.loss")
stopifnot(is.numeric(rr), identical(rr, rX),
          all.equal(rr, 0.999267578125),
	  all.equal(type.convert(ch,	      numerals = "warn"),
		    type.convert("0x1.ffap-1",numerals = "warn"), tol = 5e-15))
## type.convert(ch) was not numeric in R 3.1.0
##
ch <- "1234567890123456789"
rr <- type.convert(ch, numerals = "allow.loss")
rX <- type.convert(ch, numerals = "no.loss")
rx <- type.convert(ch, numerals = "no.loss", as.is = TRUE)
tools::assertWarning(r. <- type.convert(ch, numerals = "warn.loss"))
stopifnot(is.numeric(rr), identical(rr, r.), all.equal(rr, 1.234567890e18),
	  is.factor(rX),  identical(rx, ch))


## PR#15764: integer overflow could happen without a warning or giving NA
tools::assertWarning(ii <- 1980000020L + 222000000L)
stopifnot(is.na(ii))
tools::assertWarning(ii <- (-1980000020L) + (-222000000L))
stopifnot(is.na(ii))
tools::assertWarning(ii <- (-1980000020L) - 222000000L)
stopifnot(is.na(ii))
tools::assertWarning(ii <- 1980000020L - (-222000000L))
stopifnot(is.na(ii))
## first two failed for some version of clang in R < 3.1.1


## PR#15735: formulae with exactly 32 variables
myFormula <- as.formula(paste(c("y ~ x0", paste0("x", 1:30)), collapse = "+"))
ans <- update(myFormula, . ~ . - w1)
stopifnot(identical(ans, myFormula))

updateArgument <-
    as.formula(paste(c(". ~ . ", paste0("w", 1:30)), collapse = " - "))
ans2 <- update(myFormula, updateArgument)
stopifnot(identical(ans2, myFormula))


## PR#15753
0x110p-5L # (+ warning)
stopifnot(.Last.value == 8.5)
## was 272 with a garbled message in R 3.0.0 - 3.1.0.


## numericDeriv failed to duplicate variables in
## the expression before modifying them.  PR#15849
x <- 10; y <- 10
d1 <- numericDeriv(quote(x+y),c("x","y"))
x <- y <- 10
d2 <- numericDeriv(quote(x+y),c("x","y"))
stopifnot(identical(d1,d2))
## The second gave the wrong answer


## prettyNum(x, zero.print = .) failed when x had NAs
pp <- sapply(list(TRUE, FALSE, ".", " "), function(.)
	     prettyNum(c(0:1,NA), zero.print = . ))
stopifnot(identical(pp[1,], c("0", " ", ".", " ")),
	  pp[2:3,] == c("1","NA"))
## all 4 prettyNum() would error out


## checking all.equal() with externalptr
library(methods) # getClass()'s versionKey is an e.ptr
cA <- getClass("ANY")
stopifnot(all.equal(cA, cA),
          is.character(all.equal(cA, getClass("S4"))))
# both all.equal() failed in R <= 3.1.1


## as.hexmode(x), as.octmode(x)  when x is double
x <- c(NA, 1)
stopifnot(identical(x == x,
		    as.hexmode(x) == as.octmode(x)))
p <- c(1, pi)
tools::assertError(as.hexmode(p))
tools::assertError(as.octmode(p))
## where all "wrong" in R <= 3.1.1


## PR#15935
y <- 1:3
drop1(lm(y ~ 1))
drop1(glm(y ~ 1))
stats:::drop1.default(glm(y ~ 1))
## gave error in R < 3.1.2

## getAnywhere() wrongly dealing with namespace hidden list object
nm <- deparse(body(pbinom)[[2]])# == "C_pbinom" currently
gg <- getAnywhere(nm)
stopifnot(length(gg$objs) == 1)
## was 4 and printed "4 differing objects matching ‘C_pbinom’ ..." in R <= 3.1.1


## 0-length consistency of options(), PR#15979
stopifnot(identical(options(list()), options(NULL)))
## options(list()) failed in R <= 3.1.1


## merge.dendrogram(), PR#15648
mkDend <- function(n, lab, method = "complete",
                   ## gives *ties* often:
		   rGen = function(n) 1+round(16*abs(rnorm(n)))) {
    stopifnot(is.numeric(n), length(n) == 1, n >= 1, is.character(lab))
    a <- matrix(rGen(n*n), n, n)
    colnames(a) <- rownames(a) <- paste0(lab, 1:n)
    .HC. <<- hclust(as.dist(a + t(a)), method=method)
    as.dendrogram(.HC.)
}
set.seed(7)
da <- mkDend(4, "A")
db <- mkDend(3, "B")
d.ab <- merge(da, db)
hcab <- as.hclust(d.ab)
stopifnot(hcab$order == c(2, 4, 1, 3, 7, 5, 6),
	  hcab$labels == c(paste0("A", 1:4), paste0("B", 1:3)))
## was wrong in R <= 3.1.1
set.seed(1) ; h1 <- as.hclust(mkDend(5, "S", method="single")); hc1 <- .HC.
set.seed(5) ; h5 <- as.hclust(mkDend(5, "S", method="single")); hc5 <- .HC.
set.seed(42); h3 <- as.hclust(mkDend(5, "A", method="single")); hc3 <- .HC.
## all failed (differently!) because of ties in R <= 3.2.3
stopifnot(all.equal(h1[1:4], hc1[1:4], tol = 1e-12),
	  all.equal(h5[1:4], hc5[1:4], tol = 1e-12),
	  all.equal(h3[1:4], hc3[1:4], tol = 1e-12))


## bw.SJ() and similar with NA,Inf values, PR#16024
try(bw.SJ (c(NA,2,3)))
try(bw.bcv(c(-Inf,2,3)))
try(bw.ucv(c(1,NaN,3,4)))
## seg.faulted  in  3.0.0 <= R <= 3.1.1


## as.dendrogram() with wrong input
x <- rbind(c( -6, -9), c(  0, 13),
	   c(-15,  6), c(-14,  0), c(12,-10))
dx <- dist(x,"manhattan")
hx <- hclust(dx)
hx$merge <- matrix(c(-3, 1, -2, 3,
                     -4, -5, 2, 3), 4,2)
tools::assertError(as.dendrogram(hx))
## 8 member dendrogram and memory explosion for larger examples in R <= 3.1.2


## abs with named args failed, PR#16047
abs(x=1i)
## Complained that the arg should be named z


## Big exponents overflowed, PR#15976
x <- 0E4933
y <- 0x0p100000
stopifnot(x == 0, y == 0)
##


## drop.terms() dropped some attributes, PR#16029
test <- model.frame(Employed ~ Year + poly(GNP,3) + Population, data=longley)
mterm <- terms(test)
mterm2 <- drop.terms(mterm, 3)
predvars <- attr(mterm2, "predvars")
dataClasses <- attr(mterm2, "dataClasses")
factors <- attr(mterm2, "factors")
stopifnot(is.language(predvars), length(predvars) == length(dataClasses)+1,
          all(names(dataClasses) == rownames(factors)))
## Previously dropped predvars and dataClasses


## prompt() did not escape percent signs properly
fn <- function(fmt = "%s") {}
f <- tempfile(fileext = ".Rd")
prompt(fn, filename = f)
rd <- tools::parse_Rd(f)
## Gave syntax errors because the percent sign in Usage
## was taken as the start of a comment.

## pass no arguments to 0-parameter macro
cat("\\newcommand{\\mac0}{MAC0}\\mac0", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), "MAC0\n"))

## pass empty argument to a 1-parameter macro (failed in 3.5.0 and earlier)
cat("\\newcommand{\\mac1}{MAC1:#1}\\mac1{}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), "MAC1:\n"))

## pass empty argument to a 2-parameter macro (failed in 3.5.0 and earlier)
cat("\\newcommand{\\mac2}{MAC2:#2}\\mac2{}{XX}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), "MAC2:XX\n"))

cat("\\newcommand{\\mac2}{MAC2:#2#1}\\mac2{YY}{}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), "MAC2:YY\n"))

## pass multi-line argument to a user macro (failed in 3.5.0 and earlier)
cat("\\newcommand{\\mac1}{MAC1:#1}\\mac1{XXX\nYYY}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), c("MAC1:XXX\n","YYY\n")))

## comments are removed from macro arguments (not in 3.5.0 and earlier)
cat("\\newcommand{\\mac1}{MAC1:#1}\\mac1{XXX%com\n}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), c("MAC1:XXX\n","\n")))

cat("\\newcommand{\\mac1}{MAC1:#1}\\mac1{XXX%com\nYYY}", file=f)
rd <- tools::parse_Rd(f)
stopifnot(identical(as.character(rd), c("MAC1:XXX\n","YYY\n")))

## power.t.test() failure for very large n (etc): PR#15792
(ptt <- power.t.test(delta = 1e-4, sd = .35, power = .8))
(ppt <- power.prop.test(p1 = .5, p2 = .501, sig.level=.001, power=0.90, tol=1e-8))
stopifnot(all.equal(ptt$n, 192297000, tol = 1e-5),
          all.equal(ppt$n,  10451937, tol = 1e-7))
## call to uniroot() did not allow n > 1e7


## save(*, ascii=TRUE):  PR#16137
x0 <- x <- c(1, NA, NaN)
save(x, file=(sf <- tempfile()), ascii = TRUE)
load(sf)
stopifnot(identical(x0, x))
## x had 'NA' instead of 'NaN'


## PR#16205
stopifnot(length(glob2rx(character())) == 0L)
## was "^$" in R < 3.1.3


### Bugs fixed in R 3.2.0

## Bugs reported by Radford Neal
x <- pairlist(list(1, 2))
x[[c(1, 2)]] <- NULL   # wrongly gave an error, referring to misuse
                       # of the internal SET_VECTOR_ELT procedure
stopifnot(identical(x, pairlist(list(1))))

a <- pairlist(10, 20, 30, 40, 50, 60)
dim(a) <- c(2, 3)
dimnames(a) <- list(c("a", "b"), c("x", "y", "z"))
# print(a)              # doesn't print names, not fixed
a[["a", "x"]] <- 0
stopifnot(a[["a", "x"]] == 0)
## First gave a spurious error, second caused a seg.fault


## Radford (R-devel, June 24, 2014); M.Maechler
m <- matrix(1:2, 1,2); v <- 1:3
stopifnot(identical(crossprod(2, v), t(2) %*% v),
	  identical(crossprod(m, v), t(m) %*% v),
	  identical(5 %*% v, 5 %*% t(v)),
          identical(tcrossprod(m, 1:2), m %*% 1:2) )
## gave error "non-conformable arguments" in R <= 3.2.0
proc.time() - .pt; .pt <- proc.time()


## list <--> environment
L0 <- list()
stopifnot(identical(L0, as.list(as.environment(L0))))
## as.env..() did not work, and as.list(..) gave non-NULL names in R 3.1.x


### all.equal() refClass()es check moved to methods package


## missing() did not propagate through '...', PR#15707
check <- function(x,y,z) c(missing(x), missing(y), missing(z))
check1 <- function(...) check(...)
check2 <- function(...) check1(...)
stopifnot(identical(check2(one, , three), c(FALSE, TRUE, FALSE)))
## missing() was unable to handle recursive promises


### envRefClass check moved to methods package


## takes too long with JIT enabled:
.jit.lev <- compiler::enableJIT(0)
Sys.getenv("_R_CHECK_LENGTH_1_CONDITION_") -> oldV
Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = "false") # only *warn*
## while did not protect its argument, which caused an error
## under gctorture, PR#15990
gctorture()
suppressWarnings(while(c(FALSE, TRUE)) 1)
gctorture(FALSE)
## gave an error because the test got released when the warning was generated.
compiler::enableJIT(.jit.lev)# revert
Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = oldV)


## hist(x, breaks =) with too large bins, PR#15988
set.seed(5); x <- runif(99)
Hist <- function(x, b) hist(x, breaks = b, plot = FALSE)$counts
for(k in 1:5) {
    b0 <- seq_len(k-1)/k
    H.ok <- Hist(x, c(-10, b0, 10))
    for(In in c(1000, 1e9, Inf))
	stopifnot(identical(Hist(x, c(-In, b0, In)), H.ok),
		  identical(Hist(x, c( 0,  b0, In)), H.ok))
}
## "wrong" results for k in {2,3,4} in R 3.1.x


## eigen(*, symmetric = <default>) with asymmetric dimnames,  PR#16151
m <- matrix(c(83,41), 5, 4,
	    dimnames=list(paste0("R",1:5), paste0("C",1:4)))[-5,] + 3*diag(4)
stopifnot( all.equal(eigen(m, only.values=TRUE) $ values,
		     c(251, 87, 3, 3), tol=1e-14) )
## failed, using symmetric=FALSE and complex because of the asymmetric dimnames()


## match.call() re-matching '...'
test <- function(x, ...) test2(x, 2, ...)
test2 <- function(x, ...) match.call(test2, sys.call())
stopifnot(identical(test(1, 3), quote(test2(x=x, 2, 3))))
## wrongly gave test2(x=x, 2, 2, 3) in R <= 3.1.2


## callGeneric not forwarding dots in call (PR#16141)
setGeneric("foo", function(x, ...) standardGeneric("foo"))
setMethod("foo", "character",
          function(x, capitalize = FALSE) if (capitalize) toupper(x) else x)
setMethod("foo", "factor",
          function(x, capitalize = FALSE) { x <- as.character(x);  callGeneric() })
toto1 <- function(x, ...) foo(x, ...)
stopifnot(identical(toto1(factor("a"), capitalize = TRUE), "A"))
## wrongly did not capitalize in R <= 3.1.2


## Accessing non existing objects must be an error
tools::assertError(base :: foobar)
tools::assertError(base :::foobar)
tools::assertError(stats:::foobar)
tools::assertError(stats:: foobar)
## lazy data only via '::', not ':::' :
stopifnot(    nrow(datasets:: swiss) == 47)
tools::assertError(datasets:::swiss)
## The ::: versions gave NULL in certain development versions of R
stopifnot(identical(stats4::show -> s4s,
		    get("show", asNamespace("stats4") -> ns4)),
	  s4s@package == "methods",
	  is.null(ns4[["show"]]) # not directly in stats4 ns
	  )
## stats4::show was NULL for 4 hours in R-devel


## mode<- did too much evaluation (PR#16215)
x <- y <- quote(-2^2)
x <- as.list(x)
mode(y) <- "list"
stopifnot(identical(x, y))
## y ended up containing -4, not -2^2


## besselJ()/besselY() with too large order
besselJ(1, 2^64) ## NaN with a warning
besselY(1, c(2^(60:70), Inf))
## seg.faulted in R <= 3.1.2


## besselJ()/besselY() with  nu = k + 1/2; k in {-1,-2,..}
besselJ(1, -1750.5) ## Inf, with only one warning...
stopifnot(is.finite(besselY(1, .5 - (1500 + 0:10))))
## last gave NaNs; both: more warnings in R <= 3.1.x


## BIC() for arima(), also with NA's
lho <- lh; lho[c(3,7,13,17)] <- NA
alh300 <- arima(lh,  order = c(3,0,0))
alh311 <- arima(lh,  order = c(3,1,1))
ao300  <- arima(lho, order = c(3,0,0))
ao301  <- arima(lho, order = c(3,0,1))
## AIC/BIC for *different* data rarely makes sense ... want warning:
tools::assertWarning(AA <- AIC(alh300,alh311, ao300,ao301))
tools::assertWarning(BB <- BIC(alh300,alh311, ao300,ao301))
fmLst <- list(alh300,alh311, ao300,ao301)
## nobs() did not "work" in R < 3.2.0:
stopifnot(sapply(fmLst, nobs) == c(48,47, 44,44))
lls <- lapply(fmLst, logLik)
str(lapply(lls, unclass))# -> 'df' and 'nobs'
## 'manual BIC' via generalized AIC:
stopifnot(all.equal(BB[,"BIC"],
                    sapply(fmLst, function(fm) AIC(fm, k = log(nobs(fm))))))
## BIC() was NA unnecessarily in  R < 3.2.0; nobs() was not available eiher


## as.integer() close and beyond maximal integer
MI <- .Machine$integer.max
stopifnot(identical( MI, as.integer( MI + 0.99)),
	  identical(-MI, as.integer(-MI - 0.99)),
	  is.na(as.integer(as.character( 100*MI))),
	  is.na(as.integer(as.character(-100*MI))))
## The two cases with positive numbers  failed in R <= 3.2.0


## Ensure that sort() works with a numeric vector "which is an object":
stopifnot(is.object(y <- freeny$y))
stopifnot(diff(sort(y)) > 0)
## order() and hence sort() failed here badly for a while around 2015-04-16


## NAs in data frame names (but *not* in row.names; that's really wrong):
dn <- list(c("r1", "r2"), c("V", NA))
d11 <- as.data.frame(matrix(c(1, 1, 1, 1), ncol = 2, dimnames = dn))
stopifnot(identical(names(d11), dn[[2]]),
          identical(row.names(d11), dn[[1]]))
## as.data.frame() failed in R-devel for a couple of hours ..


## Ensure  R -e ..  works on Unix
if(.Platform$OS.type == "unix" &&
   file.exists(Rc <- file.path(R.home("bin"), "R")) &&
   file.access(Rc, mode = 1) == 0) { # 1: executable
    cmd <- paste(Rc, "-q --vanilla -e 1:3")
    ans <- system(cmd, intern=TRUE)
    stopifnot(length(ans) >= 3,
	      identical(ans[1:2], c("> 1:3",
				    "[1] 1 2 3")))
}
## (failed for < 1 hr, in R-devel only)
proc.time() - .pt; .pt <- proc.time()


## Parsing large exponents of floating point numbers, PR#16358
set.seed(12)
lrg <- sprintf("%.0f", round(exp(10*(2+abs(rnorm(2^10))))))
head(huge <- paste0("1e", lrg))
    micro <- paste0("1e-", lrg)
stopifnot(as.numeric(huge) == Inf,
          as.numeric(micro) == 0)
## Both failed in R <= 3.2.0


## vcov() failed on manova() results, PR#16380
tear <- c(6.5, 6.2, 5.8, 6.5, 6.5, 6.9, 7.2, 6.9, 6.1, 6.3, 6.7, 6.6, 7.2, 7.1, 6.8, 7.1, 7.0, 7.2, 7.5, 7.6)
gloss <- c(9.5, 9.9, 9.6, 9.6, 9.2, 9.1, 10.0, 9.9, 9.5, 9.4, 9.1, 9.3, 8.3, 8.4, 8.5, 9.2, 8.8, 9.7, 10.1, 9.2)
opacity <- c(4.4, 6.4, 3.0, 4.1, 0.8, 5.7, 2.0, 3.9, 1.9, 5.7, 2.8, 4.1, 3.8,1.6, 3.4, 8.4, 5.2, 6.9, 2.7, 1.9)
Y <- cbind(tear, gloss, opacity)
rate <- factor(gl(2,10), labels = c("Low", "High"))
fit <- manova(Y ~ rate)
vcov(fit)
## Gave error because coef.aov() turned matrix of coefficients into a vector


## Unary / Binary uses of logic operations, PR#16385
tools::assertError(`&`(FALSE))
tools::assertError(`|`(TRUE))
## Did not give errors in R <= 3.2.0
E <- tryCatch(`!`(), error = function(e)e)
stopifnot(grepl("0 argument.*\\<1", conditionMessage(E)))
##            PR#17456 :   ^^ a version that also matches in a --disable-nls configuration
## Gave wrong error message in R <= 3.2.0
stopifnot(identical(!matrix(TRUE), matrix(FALSE)),
	  identical(!matrix(FALSE), matrix(TRUE)))
## was wrong for while in R 3.2.0 patched


## cummax(<integer>)
iNA <- NA_integer_
x <- c(iNA, 1L)
stopifnot(identical(cummin(x), c(iNA, iNA)),
          identical(cummax(x), c(iNA, iNA)))
## an initial NA was not propagated in R <= 3.2.0


## summaryRprof failed for very short profile, PR#16395
profile <- tempfile()
writeLines(c(
'memory profiling: sample.interval=20000',
':145341:345360:13726384:0:"stdout"',
':208272:345360:19600000:0:"stdout"'), profile)
summaryRprof(filename = profile, memory = "both")
unlink(profile)
## failed when a matrix was downgraded to a vector


## option(OutDec = *)  -- now gives a warning when  not 1 character
op <- options(OutDec = ".", digits = 7, # <- default
              warn = 2)# <- (unexpected) warnings become errors
stopifnot(identical("3.141593", fpi <- format(pi)))
options(OutDec = ",")
stopifnot(identical("3,141593", cpi <- format(pi)))
## warnings, but it "works" (for now):
tools::assertWarning(options(OutDec = ".1."))
stopifnot(identical("3.1.141593", format(pi)))
tools::assertWarning(options(OutDec = ""))
tools::assertWarning(stopifnot(identical("3141593", format(pi))))
options(op)# back to sanity
## No warnings in R versions <= 3.2.1


## format(*, decimal.mark=".")  when   OutDec != "."  (PR#16411)
op <- options(OutDec = ",")
stopifnot(identical(fpi, format(pi, decimal.mark=".")))
options(op)
## failed in R <= 3.2.1


## model.frame() removed ts attributes on original data (PR#16436)
orig <- class(EuStockMarkets)
mf <- model.frame(EuStockMarkets ~ 1, na.action=na.fail)
stopifnot(identical(orig, class(EuStockMarkets)))
## ts class lost in R <= 3.2.1


##
foo <- as.expression(1:3)
matrix(foo, 3, 3) # always worked
matrix(foo, 3, 3, byrow = TRUE)
## failed in R <= 3.1.2


## labels.dendrogram(), dendrapply(), etc -- see comment #15 of PR#15215 :
(D <- as.dendrogram(hclust(dist(cbind(setNames(c(0,1,4), LETTERS[1:3]))))))
stopifnot(
    identical(labels(D), c("C", "A", "B")),
    ## has been used in "CRAN package space"
    identical(suppressWarnings(dendrapply(D, labels)),
              list("C", list("A", "B"), "C")))
## dendrapply(D, labels) failed in R-devel for a day or two


## poly() / polym() predict()ion
library(datasets)
alm <- lm(stack.loss ~ poly(Air.Flow, Water.Temp, degree=3), stackloss)
f20 <- fitted(alm)[1:20] # "correct" prediction values [1:20]
stopifnot(all.equal(unname(f20[1:4]), c(39.7703378, 39.7703378, 35.8251359, 21.5661761)),
	  all.equal(f20, predict(alm, stackloss) [1:20] , tolerance = 1e-14),
	  all.equal(f20, predict(alm, stackloss[1:20, ]), tolerance = 1e-14))
## the second prediction went off in  R <= 3.2.1


## PR#16478
kkk <- c("a\tb", "3.14\tx")
z1 <- read.table(textConnection(kkk), sep = "\t", header = TRUE,
                 colClasses = c("numeric", "character"))
z2 <- read.table(textConnection(kkk), sep = "\t", header = TRUE,
                 colClasses = c(b = "character", a = "numeric"))
stopifnot(identical(z1, z2))
z3 <- read.table(textConnection(kkk), sep = "\t", header = TRUE,
                 colClasses = c(b = "character"))
stopifnot(identical(z1, z3))
z4 <- read.table(textConnection(kkk), sep = "\t", header = TRUE,
                 colClasses = c(c = "integer", b = "character", a = "numeric"))
stopifnot(identical(z1, z4))
## z2 and z4 used positional matching (and failed) in R < 3.3.0.


## PR#16484
z <- regexpr("(.)", NA_character_, perl = TRUE)
stopifnot(is.na(attr(z, "capture.start")), is.na(attr(z, "capture.length")))
## Result was random integers in R <= 3.2.2.


## PR#14861
if(.Platform$OS.type == "unix") { # no 'ls /'  on Windows
    con <- pipe("ls /", open = "rt")
    data <- readLines(con)
    z <- close(con)
    print(z)
    stopifnot(identical(z, 0L))
}
## was NULL in R <= 3.2.2


## Sam Steingold:  compiler::enableJIT(3) not working in ~/.Rprofile anymore
stopifnot(identical(topenv(baseenv()),
                    baseenv()))
## accidentally globalenv in R 3.2.[12] only


## widths of unknown Unicode characters
stopifnot(nchar("\u200b", "w") == 0)
## was -1 in R 3.2.2


## abbreviate dropped names in some cases
x <- c("AA", "AB", "AA", "CBA") # also test handling of duplicates
for(m in 2:0) {
    print(y <- abbreviate(x, m))
    stopifnot(identical(names(y), x))
}
## dropped for 0 in R <= 3.2.2


## match(<NA>, <NA>)
stopifnot(
    isTRUE(NA          %in% c(NA, TRUE)),
    isTRUE(NA_integer_ %in% c(TRUE, NA)),
    isTRUE(NA_real_    %in% c(NA, FALSE)),# !
    isTRUE(!(NaN       %in% c(NA, FALSE))),
    isTRUE(NA          %in% c(3L, NA)),
    isTRUE(NA_integer_ %in% c(NA, 3L)),
    isTRUE(NA_real_    %in% c(3L, NA)),# !
    isTRUE(!(NaN       %in% c(3L, NA))),
    isTRUE(NA          %in% c(2., NA)),# !
    isTRUE(NA_integer_ %in% c(NA, 2.)),# !
    isTRUE(NA_real_    %in% c(2., NA)),# !
    isTRUE(!(NaN       %in% c(2., NA))))
## the "!" gave FALSE in R-devel (around 20.Sep.2015)


## oversight in  within.data.frame()  [R-help, Sep 20 2015 14:23 -04]
df <- data.frame(.id = 1:3 %% 3 == 2, a = 1:3)
d2 <- within(df, {d = a + 2})
stopifnot(identical(names(d2), c(".id", "a", "d")))
## lost the '.id' column in R <= 3.2.2
proc.time() - .pt; .pt <- proc.time()

## system() truncating and splitting long lines of output, PR#16544
## only works when platform has getline() in stdio.h, and Solaris does not.
known.POSIX_2008 <- .Platform$OS.type == "unix" &&
     (Sys.info()[["sysname"]] != "SunOS")
## ^^^ explicitly exclude *non*-working platforms above
if(known.POSIX_2008) {
    cat("testing system(\"echo\", <large>) : "); op <- options(warn = 2)# no warnings allowed
    cn <- paste(1:2222, collapse=" ")
    rs <- system(paste("echo", cn), intern=TRUE)
    stopifnot(identical(rs, cn))
    cat("[Ok]\n"); options(op)
}


## tail.matrix()
B <- 100001; op <- options(max.print = B + 99)
mat.l <- list(m0  = matrix(, 0,2),
              m0n = matrix(, 0,2, dimnames = list(NULL, paste0("c",1:2))),
              m2  = matrix(1:2,   2,1),
              m2n = matrix(1:2,   2,3, dimnames = list(NULL, paste0("c",1:3))),
              m9n = matrix(1:9,   9,1, dimnames = list(paste0("r",1:9),"CC")),
              m12 = matrix(1:12, 12,1),
              mBB = matrix(1:B, B, 1))
## tail() used to fail for 0-rows matrices m0*
n.s <- -3:3
hl <- lapply(mat.l, function(M) lapply(n.s, function(n) head(M, n)))
tl <- lapply(mat.l, function(M) lapply(n.s, function(n) tail(M, n)))
## Check dimensions of resulting matrices --------------
## ncol:
Mnc <- do.call(rbind, rep(list(vapply(mat.l, ncol, 1L)), length(n.s)))
stopifnot(identical(Mnc, sapply(hl, function(L) vapply(L, ncol, 1L))),
          identical(Mnc, sapply(tl, function(L) vapply(L, ncol, 1L))))
## nrow:
fNR <- function(L) vapply(L, nrow, 1L)
tR <- sapply(tl, fNR)
stopifnot(identical(tR, sapply(hl, fNR)), # head() & tail  both
          tR[match(0, n.s),] == 0, ## tail(*,0) has always 0 rows
          identical(tR, outer(n.s, fNR(mat.l), function(x,y)
              ifelse(x < 0, pmax(0L, y+x), pmin(y,x)))))
for(j in c("m0", "m0n")) { ## 0-row matrices: tail() and head() look like identity
    co <- capture.output(mat.l[[j]])
    stopifnot(vapply(hl[[j]], function(.) identical(co, capture.output(.)), NA),
              vapply(tl[[j]], function(.) identical(co, capture.output(.)), NA))
}

CO1 <- function(.) capture.output(.)[-1] # drop the printed column names
## checking tail(.) rownames formatting
nP <- n.s > 0
for(nm in c("m9n", "m12", "mBB")) { ## rownames: rather [100000,] than [1e5,]
    tf <- file(); capture.output(mat.l[[nm]], file=tf)
    co <- readLines(tf); close(tf)
    stopifnot(identical(# tail(.) of full output == output of tail(.) :
        lapply(n.s[nP], function(n) tail(co, n)),
        lapply(tl[[nm]][nP], CO1)))
}

identCO <- function(x,y, ...) identical(capture.output(x), capture.output(y), ...)
headI <- function(M, n) M[head(seq_len(nrow(M)), n), , drop=FALSE]
tailI <- function(M, n) M[tail(seq_len(nrow(M)), n), , drop=FALSE]
for(mat in mat.l) {
    ## do not capture.output for  tail(<large>, <small negative>)
    n.set <- if(nrow(mat) < 999) -3:3 else 0:3
    stopifnot(
        vapply(n.set, function(n) identCO (head(mat, n), headI(mat, n)), NA),
        vapply(n.set, function(n) identCO (tail (mat, n, addrownums=FALSE),
                                           tailI(mat, n)), NA),
        vapply(n.set, function(n) all.equal(tail(mat, n), tailI(mat, n),
                                            check.attributes=FALSE), NA))
}
options(op)
## end{tail.matrix check} ------------------

## format.data.frame() & as.data.frame.list() - PR#16580
myL <- list(x=1:20, y=rnorm(20), stringsAsFactors = gl(4,5))
names(myL)[1:2] <- lapply(1:2, function(i)
    paste(sample(letters, 300, replace=TRUE), collapse=""))
nD  <- names(myD  <- as.data.frame(myL))
nD2 <- names(myD2 <- as.data.frame(myL, cut.names = 280))
nD3 <- names(myD3 <- as.data.frame(myL, cut.names = TRUE))
stopifnot(nchar(nD) == c(300,300,16), is.data.frame(myD),  dim(myD)  == c(20,3),
	  nchar(nD2)== c(278,278,16), is.data.frame(myD2), dim(myD2) == c(20,3),
	  nchar(nD3)== c(254,254,16), is.data.frame(myD3), dim(myD3) == c(20,3),
	  identical(nD[3], "stringsAsFactors"),
	  identical(nD[3], nD2[3]), identical(nD[3], nD3[3]))

names(myD)[1:2] <- c("Variable.1", "")# 2nd col.name is "empty"
## A data frame with a column that is an empty data frame:
d20 <- structure(list(type = c("F", "G"), properties = data.frame(i=1:2)[,-1]),
                 class = "data.frame", row.names = c(NA, -2L))
stopifnot(is.data.frame(d20), dim(d20) == c(2,2),
	  identical(colnames(d20), c("type", "properties")),
	  identical(capture.output(d20), c("  type", "1    F", "2    G")))
## format(d20) failed in intermediate R versions
stopifnot(identical(names(myD), names(format(head(myD)))),
	  identical(names(myD), c("Variable.1", "", "stringsAsFactors")),
	  identical(rbind.data.frame(2:1, 1:2), ## was wrong for some days
		    data.frame(X2.1 = 2:1, X1.2 = 1:2)))
## format.data.frame() did not show "stringsAsFactors" in R <= 3.2.2
## Follow up: the new as.data.frame.list() must be careful with 'AsIs' columns:
desc <- structure( c("a", NA, "z"), .Names = c("A", NA, "Z"))
tools::assertError( data.frame(desc = desc, stringsAsFactors = FALSE) )
## however
dd <- data.frame(desc = structure(desc, class="AsIs"),
                 row.names = c("A","M","Z"), stringsAsFactors = FALSE)
## is "legal" (because "AsIs" can be 'almost anything')
dd ## <- did not format nor print correctly in R-devel early Nov.2015
fdesc <- structure(c("a", "NA", "z"), .Names=names(desc), class="AsIs")
stopifnot(identical(format(dd),
                    data.frame(desc = fdesc, row.names = c("A", "M", "Z"))),
          identical(capture.output(dd),
                    c("  desc", "A    a",
		      "M <NA>", "Z    z")),
	  identical(dd, data.frame(list(dd))))# lost row.names for a while


## var(x) and hence sd(x)  with factor x, PR#16564
tools::assertError(cov(1:6, f <- gl(2,3)))# was ok already
tools::assertError(var(f))# these two give an error now (R >= 3.6.0)
tools::assertError( sd(f))
## var() "worked" in R <= 3.2.2  using the underlying integer codes
proc.time() - .pt; .pt <- proc.time()


## loess(*, .. weights) - PR#16587
d.loess <-
    do.call(expand.grid,
            c(formals(loess.control)[1:3],
              list(iterations = c(1, 10),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)))
d.loess $ iterTrace <- (d.loess$ iterations > 1)
## apply(d.loes, 1L, ...) would coerce everything to atomic, i.e, "character":
loess.c.list <- lapply(1:nrow(d.loess), function(i)
    do.call(loess.control, as.list(d.loess[i,])))
set.seed(123)
for(n in 1:6) { if(n %% 10 == 0) cat(n,"\n")
    wt <- runif(nrow(cars))
    for(ctrl in loess.c.list) {
        cars.wt <- loess(dist ~ speed, data = cars, weights = wt,
                         family = if(ctrl$iterations > 1) "symmetric" else "gaussian",
                         control = ctrl)
        cPr  <- predict(cars.wt)
        cPrN <- predict(cars.wt, newdata=cars)
        stopifnot(all.equal(cPr, cPrN, check.attributes = FALSE, tol=1e-14))
    }
}
## gave (typically slightly) wrong predictions in R <= 3.2.2


## aperm() for named dim()s:
na <- list(A=LETTERS[1:2], B=letters[1:3], C=LETTERS[21:25], D=letters[11:17])
da <- lengths(na)
A <- array(1:210, dim=da, dimnames=na)
aA <- aperm(A)
a2 <- aperm(A, (pp <- c(3:1,4)))
stopifnot(identical(     dim(aA), rev(da)),# including names(.)
	  identical(dimnames(aA), rev(na)),
	  identical(     dim(a2), da[pp]), # including names(.)
	  identical(dimnames(a2), na[pp]))
## dim(aperm(..)) did lose names() in R <= 3.2.2


## poly() / predict(poly()) with NAs -- PR#16597
fm <- lm(y ~ poly(x, 3), data=data.frame(x=1:7, y=sin(1:7)))
x <- c(1,NA,3:7)
stopifnot(all.equal(c(predict(fm, newdata=list(x = 1:3)), `4`=NA),
		      predict(fm, newdata=list(x=c(1:3,NA))), tol=1e-15),
	  all.equal(unclass(poly(x, degree=2, raw=TRUE)),
		    cbind(x, x^2), check.attributes=FALSE))
## both gave error about NA in R <= 3.2.2


## data(package = *) on some platforms
dd <- data(package="datasets")[["results"]]
if(anyDuplicated(dd[,"Item"])) stop("data(package=*) has duplications")
## sometimes returned the data sets *twice* in R <= 3.2.2


## prettyNum(*, big.mark, decimal.mark)
b.m <- c(".", ",", "'", "")
d.m <- c(".", ",", ".,", "..")
pa <- expand.grid(big.mark = b.m, decimal.mark = d.m,
                  x = c(1005.24, 100.22, 1000000.33), scientific=FALSE, digits=9,
                  stringsAsFactors=FALSE, KEEP.OUT.ATTRS=FALSE)
r <- vapply(1:nrow(pa), function(i) do.call(prettyNum, pa[i,]), "")# with 6x2 warnings
r
b.m[b.m == ""] <- "0"
## big.mark: only >= 1000; *and* because particular chosen numbers:
r.2 <- substr(r[pa[,"x"] > 1000], 2, 2)
## compute location of decimal point (which maybe more than one char)
nd <- nchar(dm.s <- rep(d.m, each=length(b.m)))
nr <- nchar(r) - 3 + (nd == 1)
nr2 <- nr + (nd > 1)
stopifnot(identical(r.2,               rep_len(b.m, length(r.2))),
          identical(substr(r, nr,nr2), rep_len(dm.s, length(r))))
## several cases (1, 5, 9, 10,..) were wrong in R 3.2.2


## kmeans with just one center -- PR#16623
set.seed(23)
x <- rbind(matrix(rnorm(100,           sd = 0.3), ncol = 2),
           matrix(rnorm(100, mean = 1, sd = 0.3), ncol = 2))
k1 <- kmeans(x, 1)
k2 <- kmeans(x, centers = k1$centers)
stopifnot(all.equal(k1, k2), k1$cluster == 1)
## the kmeans(*, centers=.) called failed in R <= 3.2.3


## invalid dimnames for array()
tools::assertError(array(1, 2:3, dimnames="foo"))
## were silently disregarded in R <= 3.2.3


## addmargins() - dimnames with (by default) "Sum"
m <- rbind(1, 2:3)
m2 <- addmargins(m, 2)
am <- addmargins(m)
stopifnot(
    identical(dimnames(m2), list(NULL, c("", "", "Sum"))),
    identical(am[,"Sum"], setNames(c(2, 5, 7), c("", "", "Sum"))))
## the dimnames array() bug above hid the addmargins() not adding "Sum"


## dim( x[,] ) -- should keep names(dim(.)) --
## ---  ----
##_ 1 D _
A1 <- array(1:6, (d <- c(nam=6L)))
stopifnot(identical(dim(A1), d),
          identical(dim(A1), dim(A1[])))
##_ 2 D _
A2 <- A[1,2,,]
stopifnot(identical(names(dim(A2)), c("C", "D")),
          identical(dim(A2), dim(A)[-(1:2)]),
          identical(dim(A2[ ]), dim(A2)),
          identical(dim(A2[,]), dim(A2)),
          identical(dim(A2[1, , drop=FALSE]), c(C = 1L, D = 7L)),
          identical(dim(A2[, 1, drop=FALSE]), c(C = 5L, D = 1L)))
##_ higher D_
A3 <- A[1, ,,]
stopifnot(
    identical(dim(A ), dim(A [,,,])),# was already wrong: [,,,] losing names(dim(.))
    identical(dim(A[,-1,-1,-1]), dim(A) - c(0:1,1L,1L)),
    identical(dim(A3), dim(A)[-1]),
    identical(dim(A3), dim(A3[,, ])),
    identical(dim(A3[,1,]), c(B = 3L, D = 7L)))
## all subsetting of arrays lost names(dim(.)) in R < 3.3.0


## NextMethod() dispatch for  `$`  and  `$<-`
`$.foo` <- function(x, fun) paste("foo:", NextMethod())
x <- list(a = 1, b = 2)
class(x) <- "foo"
stopifnot(identical(x$b, "foo: 2"))  # 'x$b' failed prior to R 3.3.0

`$<-.foo` <- function(x, value, fun) {
    attr(x, "modified") <- "yes"
    NextMethod()
}
x$y <- 10 ## failed prior to R 3.3.0
stopifnot(identical(attr(x, "modified"), "yes"))


## illegal 'row.names' for as.data.frame():  -- for now just a warning --
tools::assertWarning(
    d3 <- as.data.frame(1:3, row.names = letters[1:2])
)
stopifnot(dim(d3) == c(3,1)) ## was (2, 1) in R <= 3.2.3
## 'row.names' were not checked and produced a "corrupted" data frame in R <= 3.2.3


## rbind.data.frame()'s  smart row names construction
mk1 <- function(x) data.frame(x=x)
d4 <- rbind(mk1(1:4)[3:4,,drop=FALSE], mk1(1:2))
stopifnot(identical(dimnames(d4),
                    list(c("3", "4", "1", "2"), "x")),
## the rownames were       "3"  "4"  "31" "41"  in R <= 3.3.0
          identical(attr(rbind(mk1(5:8), 7, mk1(6:3)), "row.names"), 1:9)
          )

## sort on integer() should drop NAs by default
stopifnot(identical(1L, sort(c(NA, 1L))))
## and other data types for method="radix"
stopifnot(identical("a", sort(c(NA, "a"), method="radix")))
stopifnot(identical(character(0L), sort(c(NA, NA_character_), method="radix")))
stopifnot(identical(1, sort(c(NA, 1), method="radix")))


## dummy.coef(.) in the case of "non-trivial terms" -- PR#16665
op <- options(contrasts = c("contr.treatment", "contr.poly"))
fm1 <- lm(Fertility ~ cut(Agriculture, breaks=4) + Infant.Mortality, data=swiss)
(dc1 <- dummy.coef(fm1)) ## failed in R <= 3.3.0
## (R-help, Alexandra Kuznetsova, 24 Oct 2013):
set.seed(56)
group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
weight <- c(rnorm(10, 4), rnorm(10, 5))
x <- rnorm(20)
lm9 <- lm(weight ~ group + x + I(x^2))
dc9 <- dummy.coef(lm9)
## failed in R <= 3.3.0
stopifnot( # depends on contrasts:
    all.equal(unname(coef(fm1)), unlist(dc1, use.names=FALSE)[-2], tol= 1e-14),
    all.equal(unname(coef(lm9)), unlist(dc9, use.names=FALSE)[-2], tol= 1e-14))
## a 'use.na=TRUE' example
dd <- data.frame(x1 = rep(letters[1:2], each=3),
                 x2 = rep(LETTERS[1:3], 2),
                 y = rnorm(6))
dd[6,2] <- "B" # => no (b,C) combination => that coef should be NA
fm3 <- lm(y ~ x1*x2, dd)
(d3F <- dummy.coef(fm3, use.na=FALSE))
(d3T <- dummy.coef(fm3, use.na=TRUE))
stopifnot(all.equal(d3F[-4], d3T[-4]),
	  all.equal(d3F[[4]][-6], d3T[[4]][-6]),
	  all.equal(drop(d3T$`x1:x2`),
		    c("a:A"= 0, "b:A"= 0, "a:B"= 0,
		      "b:B"= 0.4204843786, "a:C"=0, "b:C"=NA)))
## in R <= 3.2.3, d3T$`x1:x2` was *all* NA
##
## dummy.coef() for "manova"
## artificial data inspired by the  summary.manova  example
rate <- gl(2,10, labels=c("Lo", "Hi"))
additive <- gl(4, 1, length = 20, labels = paste("d", 1:4, sep="."))
additive <- C(additive, "contr.sum")# => less trivial dummy.coef
X <- model.matrix(~ rate*additive)
E <- matrix(round(rnorm(20*3), 2), 20,3) %*% cbind(1, c(.5,-1,.5), -1:1)
bet <- outer(1:8, c(tear = 2, gloss = 5, opacity = 20))
Y <- X %*% bet + E

fit <- manova(Y ~ rate * additive)
## For consistency checking, one of the univariate models:
flm <- lm(Y[,"tear"] ~ rate * additive)
dclm <- lapply(dummy.coef(flm), drop); names(dclm[[1]]) <- "tear"

op <- options(digits = 3, width = 88)
(cf <- coef(fit))
(dcf <- dummy.coef(fit))
options(op)
stopifnot(all.equal(coef(flm), cf[,"tear"]),
          all.equal(dclm,
                    lapply(dcf, function(cc)
                        if(is.matrix(cc)) cc["tear",] else cc["tear"])),
          identical(lengths(dcf),
                    c("(Intercept)" = 3L, "rate" = 6L,
                      "additive" = 12L, "rate:additive" = 24L)),
          identical(sapply(dcf[-1], dim),
                    cbind(rate = 3:2, additive = 3:4,
                          `rate:additive` = c(3L, 8L))))
## dummy.coef() were missing coefficients in R <= 3.2.3
proc.time() - .pt; .pt <- proc.time()


## format.POSIXlt() with modified 'zone' or length-2 format
f0 <- "2016-01-28 01:23:45"; tz0 <- "Europe/Stockholm"
d2 <- d1 <- rep(as.POSIXlt(f0, tz = tz0), 2)
(f1 <- format(d1, usetz=TRUE))
identical(f1, rep(paste(f0, "CET"), 2))# often TRUE (but too platform dependent)
d2$zone <- d1$zone[1] # length 1 instead of 2
f2 <- format(d2, usetz=TRUE)## -> segfault
f1.2 <- format(as.POSIXlt("2016-01-28 01:23:45"), format=c("%d", "%y"))# segfault
stopifnot(identical(f2, format(as.POSIXct(d2), usetz=TRUE)),# not yet in R <= 3.5.x
	  identical(f1.2, c("28", "16")))
tims <- seq.POSIXt(as.POSIXct("2016-01-01"),
		   as.POSIXct("2017-11-11"), by = as.difftime(pi, units="weeks"))
form <- c("%m/%d/%y %H:%M:%S", "", "%Y-%m-%d %H:%M:%S")
op <- options(warn = 2)# no warnings allowed
head(rf1 <- format(tims, form)) # recycling was wrong
head(rf2 <- format(tims, form[c(2,1,3)]))
stopifnot(identical(rf1[1:3], c("01/01/16 00:00:00", "2016-01-22 23:47:15",
				"2016-02-13 23:34:30")),
	  identical(rf2[1:3], c("2016-01-01 00:00:00", "01/22/16 23:47:15",
				rf1[3])),
	  nchar(rf1) == rep(c(17,19,19), length = length(rf1)),
	  nchar(rf2) == rep(c(19,17,19), length = length(rf2)))
options(op)
## Wrong-length 'zone' or short 'x' segfaulted -- PR#16685
## Default 'format' setting sometimes failed for length(format) > 1


## saveRDS(*, compress= .)
opts <- setNames(,c("bzip2", "xz", "gzip"))
fil <- tempfile(paste0("xx", 1:6, "_"), fileext = ".rds")
names(fil) <- c("default", opts, FALSE,TRUE)
xx <- 1:11
saveRDS(xx, fil["default"])
saveRDS(xx, fil[opts[1]], compress = opts[1])
saveRDS(xx, fil[opts[2]], compress = opts[2])
saveRDS(xx, fil[opts[3]], compress = opts[3])
saveRDS(xx, fil["FALSE"], compress = FALSE)
saveRDS(xx, fil["TRUE" ], compress = TRUE)
f.raw <- lapply(fil, readBin, what = "raw", n = 100)
lengths(f.raw) # 'gzip' is best in this case
for(i in 1:6) stopifnot(identical(xx, readRDS(fil[i])))
eMsg <- tryCatch(saveRDS(xx, tempfile(), compress = "Gzip"),
                 error = function(e) e$message)
stopifnot(
    grepl("'compress'.*Gzip", eMsg), # had ".. not interpretable as logical"
    identical(f.raw[["default"]], f.raw[["TRUE"]]),
    identical(f.raw[["default"]], f.raw[[opts["gzip"]]]))
## compress = "gzip" failed (PR#16653), but compress = c(a = "xz") did too


## recursive dendrogram methods and deeply nested dendrograms
op <- options(expressions = 999)# , verbose = 2) # -> max. depth= 961
set.seed(11); d <- mkDend(1500, "A", method="single")
rd <- reorder(d, nobs(d):1)
## Error: evaluation nested too deeply: infinite recursion .. in R <= 3.2.3
stopifnot(is.leaf(r1 <- rd[[1]]),    is.leaf(r2 <- rd[[2:1]]),
	  attr(r1, "label") == "A1458", attr(r2, "label") == "A1317")
options(op)# revert


## cor.test() with extremely small p values
b <- 1:10; set.seed(1)
for(n in 1:256) {
    a <- round(jitter(b, f = 1/8), 3)
    p1 <- cor.test(a, b)$ p.value
    p2 <- cor.test(a,-b)$ p.value
    stopifnot(abs(p1 - p2) < 8e-16 * (p1+p2))
    ## on two different Linuxen, they actually are always equal
}
## were slightly off in R <= 3.2.3. PR#16704


## smooth(*, do.ends=TRUE)
y <- c(4,2,2,3,10,5:7,7:6)
stopifnot(
    identical(c(smooth(y, "3RSR" , do.ends=TRUE, endrule="copy")),
              c(4, 2, 2, 3, 5, 6, 6, 7, 7, 6) -> sy.c),
    identical(c(smooth(y, "3RSS" , do.ends=TRUE, endrule="copy")), sy.c),
    identical(c(smooth(y, "3RS3R", do.ends=TRUE, endrule="copy")), sy.c),
    identical(c(smooth(y, "3RSR" , do.ends=FALSE, endrule="copy")),
              c(4, 4, 4, 4, 5, 6, 6, 6, 6, 6)),
    identical(c(smooth(y, "3RSS" , do.ends=FALSE, endrule="copy")),
              c(4, 4, 2, 3, 5, 6, 6, 6, 6, 6)),
    identical(c(smooth(y, "3RS3R", do.ends=FALSE, endrule="copy")),
              c(4, 4, 3, 3, 5, 6, 6, 6, 6, 6)))
## do.ends=TRUE was not obeyed for the "3RS*" kinds, for 3.0.0 <= R <= 3.2.3
proc.time() - .pt; .pt <- proc.time()


## prettyDate() for subsecond ranges
##' checking pretty():
chkPretty <- function(x, n = 5, min.n = NULL, ..., max.D = 1) {
    if(is.null(min.n)) {
	## work with both pretty.default() and greDevices::prettyDate()
	## *AND* these have a different default for 'min.n' we must be "extra smart":
	min.n <-
	    if(inherits(x, "Date") || inherits(x, "POSIXt"))
		n %/% 2 # grDevices:::prettyDate
	    else
		n %/% 3 # pretty.default
    }
    pr <- pretty(x, n=n, min.n=min.n, ...)
    ## if debugging: pr <- grDevices:::prettyDate(x, n=n, min.n=min.n, ...)
    stopifnot(length(pr) >= (min.n+1),
	      ## pretty(x, *) must cover range of x:
	      min(pr) <= min(x), max(x) <= max(pr))
    if((D <- abs(length(pr) - (n+1))) > max.D)
	stop("| |pretty(.)| - (n+1) | = ", D, " > max.D = ", max.D)
    ## is it equidistant [may need fuzz, i.e., signif(.) ?]:
    eqD <- length(pr) == 1 || length(udp <- unique(dp <- diff(pr))) == 1
    ## may well FALSE (differing number days in months; leap years, leap seconds)
    if(!eqD) {
        if(inherits(dp, "difftime") && units(dp) %in% c("days")# <- more ??
           )
            attr(pr, "chkPr") <- "not equidistant"
        else
            stop("non equidistant: has ", length(udp)," unique differences")
    }
    invisible(pr)
}
sTime <- structure(1455056860.75, class = c("POSIXct", "POSIXt"))
for(n in c(1:16, 30:32, 41, 50, 60)) # (not for much larger n, (TODO ?))
    chkPretty(sTime, n=n)
set.seed(7)
for(n in c(1:7, 12)) replicate(32, chkPretty(sTime + .001*rlnorm(1) * 0:9, n = n))
## failed in R <= 3.2.3
seqD  <- function(d1,d2) seq.Date(as.Date(d1), as.Date(d2), by = "1 day")
seqDp <- function(d1,d2) { s <- seqD(d1,d2); structure(s, labels=format(s,"%b %d")) }
time2d <- function(i) sprintf("%02d", i %% 60)
MTbd <- as.Date("1960-02-10")
(p1   <- chkPretty(MTbd))
stopifnot(
    identical(p1, seqDp("1960-02-08", "1960-02-13")) ,
    identical(attr(p1, "labels"), paste("Feb", time2d(8:13))),
    identical(chkPretty(MTbd + rep(0,2)), p1) ,
    identical(chkPretty(MTbd +  0:1), p1) ,
    identical(chkPretty(MTbd + -1:1), p1) ,
    identical(chkPretty(MTbd +  0:3), seqDp("1960-02-09", "1960-02-14")) )
## all pretty() above gave length >= 5 answer (with duplicated values!) in R <= 3.2.3!
## and length 1 or 2 instead of about 6 in R 3.2.4
(p2 <- chkPretty(as.POSIXct("2002-02-02 02:02", tz = "GMT-1"), n = 5, min.n = 5))
stopifnot(length(p2) >= 5+1,
	  identical(p2, structure(1012611717 + (0:5), class = c("POSIXct", "POSIXt"),
				  tzone = "GMT-1", labels = time2d(57 + (0:5)))))
## failed in R 3.2.4
(T3 <- structure(1460019857.25, class = c("POSIXct", "POSIXt")))# typical Sys.date()
chkPretty(T3, 1) # error in svn 70438
## "Data" from  example(pretty.Date) :
steps <- setNames(,
    c("10 secs", "1 min", "5 mins", "30 mins", "6 hours", "12 hours",
      "1 DSTday", "2 weeks", "1 month", "6 months", "1 year",
      "10 years", "50 years", "1000 years"))
t02 <- as.POSIXct("2002-02-02 02:02")
(at <- chkPretty(t02 + 0:1, n = 5, min.n = 3, max.D=2))
xU <- as.POSIXct("2002-02-02 02:02", tz = "UTC")
x5 <- as.POSIXct("2002-02-02 02:02", tz = "EST5EDT")
atU <- chkPretty(seq(xU, by = "30 mins", length = 2), n = 5)
at5 <- chkPretty(seq(x5, by = "30 mins", length = 2), n = 5)
stopifnot(length(at) >= 4,
	  identical(sort(names(aat <- attributes(at))), c("class", "labels", "tzone")),
	  identical(aat$labels, time2d(59+ 0:3)),
          identical(x5 - xU, structure(5, units = "hours", class = "difftime")),
          identical(attr(at5, "labels"), attr(atU, "labels") -> lat),
          identical(lat, paste("02", time2d(10* 0:4), sep=":"))
)
nns <- c(1:9, 15:17); names(nns) <- paste0("n=",nns)
prSeq <- function(x, n, st, ...) pretty(seq(x, by = st, length = 2), n = n, ...)
pps <- lapply(nns, function(n)
	      lapply(steps, function(st) prSeq(x=t02, n=n, st=st)))
Ls.ok <- list(
    `10 secs`  = c("00", "02", "04", "06", "08", "10"),
    `1 min`    = sprintf("%02d", 10*((0:6) %% 6)),
    `5 mins`   = sprintf("02:%02d", 2:7),
    `30 mins`  = sprintf("02:%02d", (0:4)*10),
    `6 hours`  = sprintf("%02d:00", 2:9),
    `12 hours` = sprintf("%02d:00", (0:5)*3),
    `1 DSTday` = c("Feb 02 00:00", "Feb 02 06:00", "Feb 02 12:00",
		   "Feb 02 18:00", "Feb 03 00:00", "Feb 03 06:00"),
    `2 weeks`  = c("Jan 28", "Feb 04", "Feb 11", "Feb 18"),
    `1 month`  = c("Jan 28", "Feb 04", "Feb 11", "Feb 18", "Feb 25", "Mar 04"),
    `6 months` = c("Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep"),
    `1 year`   = c("Jan", "Apr", "Jul", "Oct", "Jan", "Apr"),
    `10 years` = as.character(2000 +   2*(1:7)),
    `50 years` = as.character(2000 +  10*(0:6)),
    `1000 years`= as.character(2000 + 200*(0:6)))
stopifnot(identical(Ls.ok,
		    lapply(pps[["n=5"]], attr, "label")))
##
chkSeq <- function(st, x, n, max.D = if(n <= 4) 1 else if(n <= 10) 2 else 3, ...)
    tryCatch(chkPretty(seq(x, by = st, length = 2), n = n, max.D=max.D, ...),
             error = conditionMessage)
prSeq.errs <- function(tt, nset, tSteps) {
    stopifnot(length(tt) == 1)
    c.ps <- lapply(nset, function(n) lapply(tSteps, chkSeq, x = tt, n = n))
    ## ensure that all are ok *but* some which did not match 'n' well enough:
    cc.ps <- unlist(c.ps, recursive=FALSE)
    ok <- vapply(cc.ps, inherits, NA, what = "POSIXt")
    errs <- unlist(cc.ps[!ok])
    stopifnot(startsWith(errs, prefix = "| |pretty(.)| - (n+1) |"))
    list(ok = ok,
	 Ds = as.numeric(sub(".*\\| = ([0-9]+) > max.*", "\\1", errs)))
}
r.t02 <- prSeq.errs(t02, nset = nns, tSteps = steps)
table(r.t02 $ ok)
table(r.t02 $ Ds -> Ds)
## Currently   [may improve]
##  3  4  5  6  7  8
##  4 14  6  3  2  1
## ... and ensure we only improve:
stopifnot(length(Ds) <= 30, max(Ds) <= 8, sum(Ds) <= 138)
## A Daylight saving time -- halfmonth combo:
(tOz <- structure(c(1456837200, 1460728800), class = c("POSIXct", "POSIXt"),
		tzone = "Australia/Sydney"))
(pz <- pretty(tOz)) # failed in R 3.3.0, PR#16923
stopifnot(length(pz) <= 6, # is 5
          attr(dpz <- diff(pz), "units") == "days", sd(dpz) < 1.6)
if(FALSE) { # save 0.4 sec
    print(system.time(
        r.tOz <- prSeq.errs(tOz[1], nset = nns, tSteps = steps)
    ))
    stopifnot(sum(r.tOz $ ok) >= 132,
              max(r.tOz $ Ds -> DOz) <= 8, mean(DOz) < 4.5)
}
nn <- c(1:33,10*(4:9),100*(1+unique(sort(rpois(20,4)))))
pzn <- lengths(lapply(nn, pretty, x=tOz))
stopifnot(0.5 <= min(pzn/(nn+1)), max(pzn/(nn+1)) <= 1.5)
proc.time() - .pt; .pt <- proc.time()



stopifnot(c("round.Date", "round.POSIXt") %in% as.character(methods(round)))
## round.POSIXt suppressed in R <= 3.2.x


## approxfun(*, method="constant")
Fn <- ecdf(1:5)
t <- c(NaN, NA, 1:5)
stopifnot(all.equal(Fn(t), t/5))
## In R <= 3.2.3,  NaN values resulted in something like (n-1)/n.


## tar() default (i.e. "no files") behaviour:
doit <- function(...) {
    dir.create(td <- tempfile("tar-experi"))
    setwd(td)
    dfil <- "base_Desc"
    file.copy(system.file("DESCRIPTION"), dfil)
    ## tar w/o specified files
    tar("ex.tar", ... ) # all files, i.e. 'dfil'
    unlink(dfil)
    stopifnot(grepl(dfil, untar("ex.tar", list = TRUE)))
    untar("ex.tar")
    myF2 <- c(dfil, "ex.tar")
    stopifnot(identical(list.files(), myF2))
    unlink(myF2)
}
doit() # produced an empty tar file in R < 3.3.0, PR#16716
if(nzchar(Sys.which("tar"))) doit(tar = "tar")


## format.POSIXlt() of Jan.1 if  1941 or '42 is involved:
tJan1 <- function(n1, n2)
    strptime(paste0(n1:n2,"/01/01"), "%Y/%m/%d", tz="CET")
wDSTJan1 <- function(n1, n2)
    which("CEST" == sub(".* ", '', format(tJan1(n1,n2), usetz=TRUE)))
(w8 <- wDSTJan1(1801, 2300))
(w9 <- wDSTJan1(1901, 2300))
stopifnot(identical(w8, 141:142),# exactly 1941:1942 had CEST on Jan.1
          identical(w9,  41: 42))
## for R-devel Jan.2016 to Mar.14 -- *AND* for R 3.2.4 -- the above gave
## integer(0)  and  c(41:42, 99:100, ..., 389:390)  respectively


## tsp<- did not remove mts class
z <- ts(cbind(1:5,1:5))
tsp(z) <- NULL
stopifnot(identical(class(z), "matrix"))
## kept "mts" in 3.2.4, PR#16769


## as.hclust() and str() for deeply nested dendrograms
op <- options(expressions = 300) # so problem triggers early
d500 <- mkDend(500, 'x', 'single')
sink(tempfile()); str(d500) ; sink()
hc2 <- as.hclust(d500)
options(op)
## gave .. nested too deeply / node stack overflow / "C stack usage ..."
## for R <= 3.3.z



## keep at end
rbind(last =  proc.time() - .pt,
      total = proc.time())
