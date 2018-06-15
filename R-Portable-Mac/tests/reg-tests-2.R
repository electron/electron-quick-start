## Regression tests for which the printed output is the issue
### _and_ must work (no Recommended packages, please)

pdf("reg-tests-2.pdf", encoding = "ISOLatin1.enc")

## force standard handling for data frames
options(stringsAsFactors=TRUE)
options(useFancyQuotes=FALSE)

### moved from various .Rd files
## abbreviate
for(m in 1:5) {
  cat("\n",m,":\n")
  print(as.vector(abbreviate(state.name, minl=m)))
}

## apply
x <- cbind(x1 = 3, x2 = c(4:1, 2:5))
dimnames(x)[[1]] <- letters[1:8]
apply(x,  2, summary) # 6 x n matrix
apply(x,  1, quantile)# 5 x n matrix

d.arr <- 2:5
arr <- array(1:prod(d.arr), d.arr,
         list(NULL,letters[1:d.arr[2]],NULL,paste("V",4+1:d.arr[4],sep="")))
aa <- array(1:20,c(2,2,5))
str(apply(aa[FALSE,,,drop=FALSE], 1, dim))# empty integer, `incorrect' dim.
stopifnot(
       apply(arr, 1:2, sum) == t(apply(arr, 2:1, sum)),
       aa == apply(aa,2:3,function(x) x),
       all.equal(apply(apply(aa,2:3, sum),2,sum),
                 10+16*0:4, tolerance = 4*.Machine$double.eps)
)
marg <- list(1:2, 2:3, c(2,4), c(1,3), 2:4, 1:3, 1:4)
for(m in marg) print(apply(arr, print(m), sum))
for(m in marg) ## 75% of the time here was spent on the names
  print(dim(apply(arr, print(m), quantile, names=FALSE)) == c(5,d.arr[m]))

## Bessel
nus <- c(0:5,10,20)

x0 <- 2^(-20:10)
plot(x0,x0, log='xy', ylab="", ylim=c(.1,1e60),type='n',
     main = "Bessel Functions -Y_nu(x)  near 0\n log - log  scale")
for(nu in sort(c(nus,nus+.5))) lines(x0, -besselY(x0,nu=nu), col = nu+2)
legend(3,1e50, leg=paste("nu=", paste(nus,nus+.5, sep=",")), col=nus+2, lwd=1)

x <- seq(3,500);yl <- c(-.3, .2)
plot(x,x, ylim = yl, ylab="",type='n', main = "Bessel Functions  Y_nu(x)")
for(nu in nus){xx <- x[x > .6*nu]; lines(xx,besselY(xx,nu=nu), col = nu+2)}
legend(300,-.08, leg=paste("nu=",nus), col = nus+2, lwd=1)

x <- seq(10,50000,by=10);yl <- c(-.1, .1)
plot(x,x, ylim = yl, ylab="",type='n', main = "Bessel Functions  Y_nu(x)")
for(nu in nus){xx <- x[x > .6*nu]; lines(xx,besselY(xx,nu=nu), col = nu+2)}
summary(bY <- besselY(2,nu = nu <- seq(0,100,len=501)))
which(bY >= 0)
summary(bY <- besselY(2,nu = nu <- seq(3,300,len=51)))
summary(bI <- besselI(x = x <- 10:700, 1))
## end of moved from Bessel.Rd

## data.frame
set.seed(123)
L3 <- LETTERS[1:3]
d <- data.frame(cbind(x=1, y=1:10), fac = sample(L3, 10, replace=TRUE))
str(d)
(d0  <- d[, FALSE]) # NULL dataframe with 10 rows
(d.0 <- d[FALSE, ]) # <0 rows> dataframe  (3 cols)
(d00 <- d0[FALSE,]) # NULL dataframe with 0 rows
stopifnot(identical(d, cbind(d, d0)),
          identical(d, cbind(d0, d)))
stopifnot(identical(d, rbind(d,d.0)),
          identical(d, rbind(d.0,d)),
          identical(d, rbind(d00,d)),
          identical(d, rbind(d,d00)))
## Comments: failed before ver. 1.4.0

## diag
diag(array(1:4, dim=5))
## test behaviour with 0 rows or columns
diag(0)
z <- matrix(0, 0, 4)
diag(z)
diag(z) <- numeric(0)
z
## end of moved from diag.Rd

## format
## handling of quotes
zz <- data.frame(a=I("abc"), b=I("def\"gh"))
format(zz)
## " (E fontification)

## printing more than 16 is platform-dependent
for(i in c(1:5,10,15,16)) cat(i,":\t",format(pi,digits=i),"\n")

p <- c(47,13,2,.1,.023,.0045, 1e-100)/1000
format.pval(p)
format.pval(p / 0.9)
format.pval(p / 0.9, dig=3)
## end of moved from format.Rd


## is.finite
x <- c(100,-1e-13,Inf,-Inf, NaN, pi, NA)
x #  1.000000 -3.000000       Inf      -Inf        NA  3.141593        NA
names(x) <- formatC(x, dig=3)
is.finite(x)
##-   100 -1e-13 Inf -Inf NaN 3.14 NA
##-     T      T   .    .   .    T  .
is.na(x)
##-   100 -1e-13 Inf -Inf NaN 3.14 NA
##-     .      .   .    .   T    .  T
which(is.na(x) & !is.nan(x))# only 'NA': 7

is.na(x) | is.finite(x)
##-   100 -1e-13 Inf -Inf NaN 3.14 NA
##-     T      T   .    .   T    T  T
is.infinite(x)
##-   100 -1e-13 Inf -Inf NaN 3.14 NA
##-     .      .   T    T   .    .  .

##-- either  finite or infinite  or  NA:
all(is.na(x) != is.finite(x) | is.infinite(x)) # TRUE
all(is.nan(x) != is.finite(x) | is.infinite(x)) # FALSE: have 'real' NA

##--- Integer
(ix <- structure(as.integer(x),names= names(x)))
##-   100 -1e-13    Inf   -Inf    NaN   3.14     NA
##-   100      0     NA     NA     NA      3     NA
all(is.na(ix) != is.finite(ix) | is.infinite(ix)) # TRUE (still)

storage.mode(ii <- -3:5)
storage.mode(zm <- outer(ii,ii, FUN="*"))# integer
storage.mode(zd <- outer(ii,ii, FUN="/"))# double
range(zd, na.rm=TRUE)# -Inf  Inf
zd[,ii==0]

(storage.mode(print(1:1 / 0:0)))# Inf "double"
(storage.mode(print(1:1 / 1:1)))# 1 "double"
(storage.mode(print(1:1 + 1:1)))# 2 "integer"
(storage.mode(print(2:2 * 2:2)))# 4 "integer"
## end of moved from is.finite.Rd


## kronecker
fred <- matrix(1:12, 3, 4, dimnames=list(LETTERS[1:3], LETTERS[4:7]))
bill <- c("happy" = 100, "sad" = 1000)
kronecker(fred, bill, make.dimnames = TRUE)

bill <- outer(bill, c("cat"=3, "dog"=4))
kronecker(fred, bill, make.dimnames = TRUE)

# dimnames are hard work: let's test them thoroughly

dimnames(bill) <- NULL
kronecker(fred, bill, make=TRUE)
kronecker(bill, fred, make=TRUE)

dim(bill) <- c(2, 2, 1)
dimnames(bill) <- list(c("happy", "sad"), NULL, "")
kronecker(fred, bill, make=TRUE)

bill <- array(1:24, c(3, 4, 2))
dimnames(bill) <- list(NULL, NULL, c("happy", "sad"))
kronecker(bill, fred, make=TRUE)
kronecker(fred, bill, make=TRUE)

fred <- outer(fred, c("frequentist"=4, "bayesian"=4000))
kronecker(fred, bill, make=TRUE)
## end of moved from kronecker.Rd

## merge
authors <- data.frame(
    surname = c("Tukey", "Venables", "Tierney", "Ripley", "McNeil"),
    nationality = c("US", "Australia", "US", "UK", "Australia"),
    deceased = c("yes", rep("no", 4)))
books <- data.frame(
    name = c("Tukey", "Venables", "Tierney",
             "Ripley", "Ripley", "McNeil", "R Core"),
    title = c("Exploratory Data Analysis",
              "Modern Applied Statistics ...",
              "LISP-STAT",
              "Spatial Statistics", "Stochastic Simulation",
              "Interactive Data Analysis",
              "An Introduction to R"),
    other.author = c(NA, "Ripley", NA, NA, NA, NA,
                     "Venables & Smith"))
b2 <- books; names(b2)[1] <- names(authors)[1]

merge(authors, b2, all.x = TRUE)
merge(authors, b2, all.y = TRUE)

## empty d.f. :
merge(authors, b2[7,])

merge(authors, b2[7,], all.y = TRUE)
merge(authors, b2[7,], all.x = TRUE)
## end of moved from merge.Rd

## NA
is.na(c(1,NA))
is.na(paste(c(1,NA)))
is.na(list())# logical(0)
ll <- list(pi,"C",NaN,Inf, 1:3, c(0,NA), NA)
is.na (ll)
lapply(ll, is.nan)  # is.nan no longer works on lists
## end of moved from NA.Rd

## is.na was returning unset values on nested lists
ll <- list(list(1))
for (i in 1:5) print(as.integer(is.na(ll)))

## scale
## test out NA handling
tm <- matrix(c(2,1,0,1,0,NA,NA,NA,0), nrow=3)
scale(tm, , FALSE)
scale(tm)
## end of moved from scale.Rd

## tabulate
tabulate(numeric(0))
## end of moved from tabulate.Rd

## ts
# Ensure working arithmetic for `ts' objects :
stopifnot(z == z)
stopifnot(z-z == 0)

ts(1:5, start=2, end=4) # truncate
ts(1:5, start=3, end=17)# repeat
## end of moved from ts.Rd

### end of moved


## PR 715 (Printing list elements w/attributes)
##
l <- list(a=10)
attr(l$a, "xx") <- 23
l
## Comments:
## should print as
# $a:
# [1] 10
# attr($a, "xx"):
# [1] 23

## On the other hand
m <- matrix(c(1, 2, 3, 0, 10, NA), 3, 2)
na.omit(m)
## should print as
#      [,1] [,2]
# [1,]    1    0
# [2,]    2   10
# attr(,"na.action")
# [1] 3
# attr(,"na.action")
# [1] "omit"

## and
x <- 1
attr(x, "foo") <- list(a="a")
x
## should print as
# [1] 1
# attr(,"foo")
# attr(,"foo")$a
# [1] "a"


## PR 746 (printing of lists)
##
test.list <- list(A = list(formula=Y~X, subset=TRUE),
                  B = list(formula=Y~X, subset=TRUE))

test.list
## Comments:
## should print as
# $A
# $A$formula
# Y ~ X
#
# $A$subset
# [1] TRUE
#
#
# $B
# $B$formula
# Y ~ X
#
# $B$subset
# [1] TRUE

## Marc Feldesman 2001-Feb-01.  Precision in summary.data.frame & *.matrix
summary(attenu)
summary(attenu, digits = 5)
summary(data.matrix(attenu), digits = 5)# the same for matrix
## Comments:
## No difference between these in 1.2.1 and earlier
set.seed(1)
x <- c(round(runif(10), 2), 10000)
summary(x)
summary(data.frame(x))
## Comments:
## All entries show all 3 digits after the decimal point now.

## Chong Gu 2001-Feb-16.  step on binomials
detg1 <-
structure(list(Temp = structure(c(2L, 1L, 2L, 1L, 2L, 1L, 2L,
    1L, 2L, 1L, 2L, 1L), .Label = c("High", "Low"), class = "factor"),
    M.user = structure(c(1L, 1L, 2L, 2L, 1L, 1L, 2L, 2L, 1L,
    1L, 2L, 2L), .Label = c("N", "Y"), class = "factor"),
    Soft = structure(c(1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L),
    .Label = c("Hard", "Medium", "Soft"), class = "factor"),
    M = c(42, 30, 52, 43,
    50, 23, 55, 47, 53, 27, 49, 29), X = c(68, 42, 37, 24, 66,
    33, 47, 23, 63, 29, 57, 19)), .Names = c("Temp", "M.user",
"Soft", "M", "X"), class = "data.frame", row.names = c("1", "3",
"5", "7", "9", "11", "13", "15", "17", "19", "21", "23"))
detg1.m0 <- glm(cbind(X,M)~1,binomial,detg1)
detg1.m0
step(detg1.m0,scope=list(upper=~M.user*Temp*Soft))

## PR 829 (empty values in all.vars)
## This example by Uwe Ligges <ligges@statistik.uni-dortmund.de>

temp <- matrix(1:4, 2)
all.vars(temp ~ 3) # OK
all.vars(temp[1, ] ~ 3) # wrong in 1.2.1

## 2001-Feb-22 from David Scott.
## rank-deficient residuals in a manova model.
gofX.df<-
  structure(list(A = c(0.696706709347165, 0.362357754476673,
-0.0291995223012888,
0.696706709347165, 0.696706709347165, -0.0291995223012888, 0.696706709347165,
-0.0291995223012888, 0.362357754476673, 0.696706709347165, -0.0291995223012888,
0.362357754476673, -0.416146836547142, 0.362357754476673, 0.696706709347165,
0.696706709347165, 0.362357754476673, -0.416146836547142, -0.0291995223012888,
-0.416146836547142, 0.696706709347165, -0.416146836547142, 0.362357754476673,
-0.0291995223012888), B = c(0.717356090899523, 0.932039085967226,
0.999573603041505, 0.717356090899523, 0.717356090899523, 0.999573603041505,
0.717356090899523, 0.999573603041505, 0.932039085967226, 0.717356090899523,
0.999573603041505, 0.932039085967226, 0.909297426825682, 0.932039085967226,
0.717356090899523, 0.717356090899523, 0.932039085967226, 0.909297426825682,
0.999573603041505, 0.909297426825682, 0.717356090899523, 0.909297426825682,
0.932039085967226, 0.999573603041505), C = c(-0.0291995223012888,
-0.737393715541246, -0.998294775794753, -0.0291995223012888,
-0.0291995223012888, -0.998294775794753, -0.0291995223012888,
-0.998294775794753, -0.737393715541246, -0.0291995223012888,
-0.998294775794753, -0.737393715541246, -0.653643620863612, -0.737393715541246,
-0.0291995223012888, -0.0291995223012888, -0.737393715541246,
-0.653643620863612, -0.998294775794753, -0.653643620863612,
-0.0291995223012888,
-0.653643620863612, -0.737393715541246, -0.998294775794753),
    D = c(0.999573603041505, 0.67546318055115, -0.0583741434275801,
    0.999573603041505, 0.999573603041505, -0.0583741434275801,
    0.999573603041505, -0.0583741434275801, 0.67546318055115,
    0.999573603041505, -0.0583741434275801, 0.67546318055115,
    -0.756802495307928, 0.67546318055115, 0.999573603041505,
    0.999573603041505, 0.67546318055115, -0.756802495307928,
    -0.0583741434275801, -0.756802495307928, 0.999573603041505,
    -0.756802495307928, 0.67546318055115, -0.0583741434275801
    ), groups = structure(c(1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2,
    2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3), class = "factor", .Label = c("1",
    "2", "3"))), .Names = c("A", "B", "C", "D", "groups"), row.names = 1:24,
            class = "data.frame")

gofX.manova <- manova(formula = cbind(A, B, C, D) ~ groups, data = gofX.df)
try(summary(gofX.manova))
## should fail with an error message `residuals have rank 3 < 4'

## Prior to 1.3.0 dist did not handle missing values, and the
## internal C code was incorrectly scaling for missing values.
z <- as.matrix(t(trees))
z[1,1] <- z[2,2] <- z[3,3] <- z[2,4] <- NA
dist(z, method="euclidean")
dist(z, method="maximum")
dist(z, method="manhattan")
dist(z, method="canberra")

## F. Tusell 2001-03-07.  printing kernels.
kernel("daniell", m=5)
kernel("modified.daniell", m=5)
kernel("daniell", m=c(3,5,7))
## fixed by patch from Adrian Trapletti 2001-03-08

## Start new year (i.e. line) at Jan:
(tt <- ts(1:10, start = c(1920,7), end = c(1921,4), freq = 12))
cbind(tt, tt + 1)


## PR 883 (cor(x,y) when is.null(y))
try(cov(rnorm(10), NULL))
try(cor(rnorm(10), NULL))
## gave the variance and 1 respectively in 1.2.2.


## PR 960 (format() of a character matrix converts to vector)
## example from <John.Peters@tip.csiro.au>
a <- matrix(c("axx","b","c","d","e","f","g","h"), nrow=2)
format(a)
format(a, justify="right")
## lost dimensions in 1.2.3


## PR 963
res <- svd(rbind(1:7))## $v lost dimensions in 1.2.3
if(res$u[1,1] < 0) {res$u <- -res$u; res$v <- -res$v}
res


## Make sure  on.exit() keeps being evaluated in the proper env [from PD]:
## A more complete example:
g1 <- function(fitted) { on.exit(remove(fitted)); return(function(foo) foo) }
g2 <- function(fitted) { on.exit(remove(fitted));        function(foo) foo }
f <- function(g) { fitted <- 1; h <- g(fitted); print(fitted)
                   ls(envir=environment(h)) }
f(g1)
f(g2)

f2 <- function()
{
  g.foo <- g1
  g.bar <- g2
  g <- function(x,...) UseMethod("g")
  fitted <- 1; class(fitted) <- "foo"
  h <- g(fitted); print(fitted); print(ls(envir=environment(h)))
  fitted <- 1; class(fitted) <- "bar"
  h <- g(fitted); print(fitted); print(ls(envir=environment(h)))
  invisible(NULL)
}
f2()
## The first case in f2() is broken in 1.3.0(-patched).

## on.exit() consistency check from Luke:
g <- function() as.environment(-1)
f <- function(x) UseMethod("f")
f.foo <- function(x) { on.exit(e <<- g()); NULL }
f.bar <- function(x) { on.exit(e <<- g()); return(NULL) }
f(structure(1,class = "foo"))
ls(env = e)# only "x", i.e. *not* the GlobalEnv
f(structure(1,class = "bar"))
stopifnot("x" == ls(env = e))# as above; wrongly was .GlobalEnv in R 1.3.x


## some tests that R supports logical variables in formulae
## it coerced them to numeric prior to 1.4.0
## they should appear like 2-level factors, following S

oldCon <- options("contrasts")
y <- rnorm(10)
x <- rep(c(TRUE, FALSE), 5)
model.matrix(y ~ x)
lm(y ~ x)
DF <- data.frame(x, y)
lm(y ~ x, data=DF)
options(contrasts=c("contr.helmert", "contr.poly"))
model.matrix(y ~ x)
lm(y ~ x, data=DF)
z <- 1:10
lm(y ~ x*z)
lm(y ~ x*z - 1)
options(oldCon)

## diffinv, Adrian Trapletti, 2001-08-27
x <- ts(1:10)
diffinv(diff(x),xi=x[1])
diffinv(diff(x,lag=1,differences=2),lag=1,differences=2,xi=x[1:2])
## last had wrong start and end

## PR#1072  (Reading Inf and NaN values)
as.numeric(as.character(NaN))
as.numeric(as.character(Inf))
## were NA on Windows at least under 1.3.0.

## PR#1092 (rowsum dimnames)
rowsum(matrix(1:12, 3,4), c("Y","X","Y"))
## rownames were 1,2 in <= 1.3.1.

## PR#1115 (saving strings with ascii=TRUE)
x <- y <- unlist(as.list(
    parse(text=paste("\"\\", as.character(as.octmode(1:255)), "\"",sep=""))))
save(x, ascii=TRUE, file=(fn <- tempfile()))
load(fn)
all(x==y)
unlink(fn)
## 1.3.1 had trouble with \


## Some tests of sink() and connections()
## capture all the output to a file.
zz <- file("all.Rout", open="wt")
sink(zz)
sink(zz, type="message")
try(log("a"))
## back to the console
sink(type="message")
sink()
try(log("a"))

## capture all the output to a file.
zz <- file("all.Rout", open="wt")
sink(zz)
sink(zz, type="message")
try(log("a"))

## bail out
closeAllConnections()
(foo <- showConnections())
stopifnot(nrow(foo) == 0)
try(log("a"))
unlink("all.Rout")
## many of these were untested before 1.4.0.


## test mean() works on logical but not factor
x <- c(TRUE, FALSE, TRUE, TRUE)
mean(x)
mean(as.factor(x))
## last had confusing error message in 1.3.1.


## Kurt Hornik 2001-Nov-13
z <- table(x = 1:2, y = 1:2)
z - 1
unclass(z - 1)
## lost object bit prior to 1.4.0, so printed class attribute.


## PR#1226  (predict.mlm ignored newdata)
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2,10,20, labels = c("Ctl","Trt"))
weight <- c(ctl, trt)
data <- data.frame(weight, group)
fit <- lm(cbind(w=weight, w2=weight^2) ~ group, data=data)
predict(fit, newdata=data[1:2, ])
## was 20 rows in R <= 1.4.0


## Chong Gu 2002-Feb-8: `.' not expanded in drop1
lab <- dimnames(HairEyeColor)
HairEye <- cbind(expand.grid(Hair=lab$Hair, Eye=lab$Eye, Sex=lab$Sex,
			     stringsAsFactors = TRUE),
		 Fr = as.vector(HairEyeColor))
HairEye.fit <- glm(Fr ~ . ^2, poisson, HairEye)
drop1(HairEye.fit)
## broken around 1.2.1 it seems.


## PR#1329  (subscripting matrix lists)
m <- list(a1=1:3, a2=4:6, a3=pi, a4=c("a","b","c"))
dim(m) <- c(2,2)
m
m[,2]
m[2,2]
## 1.4.1 returned null components: the case was missing from a switch.

m <- list(a1=1:3, a2=4:6, a3=pi, a4=c("a","b","c"))
matrix(m, 2, 2)
## 1.4.1 gave `Unimplemented feature in copyVector'

x <- vector("list",6)
dim(x) <- c(2,3)
x[1,2] <- list(letters[10:11])
x
## 1.4.1 gave `incompatible types in subset assignment'


## printing of matrix lists
m <- list(as.integer(1), pi, 3+5i, "testit", TRUE, factor("foo"))
dim(m) <- c(1, 6)
m
## prior to 1.5.0 had quotes for 2D case (but not kD, k > 2),
## gave "numeric,1" etc, (even "numeric,1" for integers and factors)


## ensure RNG is unaltered.
for(type in c("Wichmann-Hill", "Marsaglia-Multicarry", "Super-Duper",
              "Mersenne-Twister", "Knuth-TAOCP", "Knuth-TAOCP-2002"))
{
    set.seed(123, type)
    print(RNGkind())
    runif(100); print(runif(4))
    set.seed(1000, type)
    runif(100); print(runif(4))
    set.seed(77, type)
    runif(100); print(runif(4))
}
RNGkind(normal.kind = "Kinderman-Ramage")
set.seed(123)
RNGkind()
rnorm(4)
RNGkind(normal.kind = "Ahrens-Dieter")
set.seed(123)
RNGkind()
rnorm(4)
RNGkind(normal.kind = "Box-Muller")
set.seed(123)
RNGkind()
rnorm(4)
set.seed(123)
runif(4)
set.seed(123, "default")
set.seed(123, "Marsaglia-Multicarry") ## Careful, not the default anymore
runif(4)
## last set.seed failed < 1.5.0.


## merging, ggrothendieck@yifan.net, 2002-03-16
d.df <- data.frame(x = 1:3, y = c("A","D","E"), z = c(6,9,10))
merge(d.df[1,], d.df)
## 1.4.1 got confused by inconsistencies in as.character


## PR#1394 (levels<-.factor)
f <- factor(c("a","b"))
levels(f) <- list(C="C", A="a", B="b")
f
## was  [1] C A; Levels:  C A  in 1.4.1


## NA levels in factors
(x <- factor(c("a", "NA", "b"), exclude=NULL))
## 1.4.1 had wrong order for levels
is.na(x)[3] <- TRUE
x
## missing entry prints as <NA>


## printing/formatting NA strings
(x <- c("a", "NA", NA, "b"))
print(x, quote = FALSE)
paste(x)
format(x)
format(x, justify = "right")
format(x, justify = "none")
## not ideal.


## print.ts problems  ggrothendieck@yifan.net on R-help, 2002-04-01
x <- 1:20
tt1 <- ts(x,start=c(1960,2), freq=12)
tt2 <- ts(10+x,start=c(1960,2), freq=12)
cbind(tt1, tt2)
## 1.4.1 had `Jan 1961' as `NA 1961'
## ...and 1.9.1 had it as `Jan 1960'!!

## glm boundary bugs (related to PR#1331)
x <- c(0.35, 0.64, 0.12, 1.66, 1.52, 0.23, -1.99, 0.42, 1.86, -0.02,
       -1.64, -0.46, -0.1, 1.25, 0.37, 0.31, 1.11, 1.65, 0.33, 0.89,
       -0.25, -0.87, -0.22, 0.71, -2.26, 0.77, -0.05, 0.32, -0.64, 0.39,
       0.19, -1.62, 0.37, 0.02, 0.97, -2.62, 0.15, 1.55, -1.41, -2.35,
       -0.43, 0.57, -0.66, -0.08, 0.02, 0.24, -0.33, -0.03, -1.13, 0.32,
       1.55, 2.13, -0.1, -0.32, -0.67, 1.44, 0.04, -1.1, -0.95, -0.19,
       -0.68, -0.43, -0.84, 0.69, -0.65, 0.71, 0.19, 0.45, 0.45, -1.19,
       1.3, 0.14, -0.36, -0.5, -0.47, -1.31, -1.02, 1.17, 1.51, -0.33,
       -0.01, -0.59, -0.28, -0.18, -1.07, 0.66, -0.71, 1.88, -0.14,
       -0.19, 0.84, 0.44, 1.33, -0.2, -0.45, 1.46, 1, -1.02, 0.68, 0.84)
y <- c(1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0,
       0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1,
       1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1,
       0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1,
       1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0)
try(glm(y ~ x, family = poisson(identity)))
## failed because start = NULL in 1.4.1
## now gives useful error message
glm(y ~ x, family = poisson(identity), start = c(1,0))
## step reduction failed in 1.4.1
set.seed(123)
y <- rpois(100, pmax(3*x, 0))
glm(y ~ x, family = poisson(identity), start = c(1,0))
warnings()


## extending char arrrays
x <- y <- LETTERS[1:2]
x[5] <- "C"
length(y) <- 5
x
y
## x was filled with "", y with NA in 1.5.0


## formula with no intercept, 2002-07-22
oldcon <- options(contrasts = c("contr.helmert", "contr.poly"))
U <- gl(3, 6, 18, labels=letters[1:3])
V <- gl(3, 2, 18, labels=letters[1:3])
A <- rep(c(0, 1), 9)
B <- rep(c(1, 0), 9)
set.seed(1); y <- rnorm(18)
terms(y ~ A:U + A:V - 1)
lm(y ~ A:U + A:V - 1)$coefficients  # 1.5.1 used dummies coding for V
lm(y ~ (A + B) : (U + V) - 1) # 1.5.1 used dummies coding for A:V but not B:V
options(oldcon)
## 1.5.1 miscomputed the first factor in the formula.


## quantile extremes, MM 13 Apr 2000 and PR#1852
(qq <- sapply(0:5, function(k) {
    x <- c(rep(-Inf,k+1), 0:k, rep(Inf, k))
    sapply(1:9, function(typ)
           quantile(x, pr=(2:10)/10, type=typ))
}, simplify="array"))
x <- c(-Inf, -Inf, Inf, Inf)
median(x)
quantile(x)
## 1.5.1 had -Inf not NaN in several places


## NAs in matrix dimnames
z <- matrix(1:9, 3, 3)
dimnames(z) <- list(c("x", "y", NA), c(1, NA, 3))
z
## NAs in dimnames misaligned when printing in 1.5.1


## weighted aov (PR#1930)
r <- c(10,23,23,26,17,5,53,55,32,46,10,8,10,8,23,0,3,22,15,32,3)
n <- c(39,62,81,51,39,6,74,72,51,79,13,16,30,28,45,4,12,41,30,51,7)
trt <- factor(rep(1:4,c(5,6,5,5)))
Y <- r/n
z <- aov(Y ~ trt, weights=n)
## 1.5.1 gave unweighted RSS


## rbind (PR#2266)
test <- as.data.frame(matrix(1:25, 5, 5))
test1 <- matrix(-(1:10), 2, 5)
rbind(test, test1)
rbind(test1, test)
## 1.6.1 treated matrix as a vector.


## escapes in non-quoted printing
x <- "\\abc\\"
names(x) <- 1
x
print(x, quote=FALSE)
## 1.6.2 had label misaligned


## summary on data frames containing data frames (PR#1891)
x <- data.frame(1:10)
x$z <- data.frame(x=1:10,yyy=11:20)
summary(x)
## 1.6.2 had NULL labels on output with z columns stacked.


## re-orderings in terms.formula (PR#2206)
form <- formula(y ~ a + b:c + d + e + e:d)
(tt <- terms(form))
(tt2 <- terms(formula(tt)))
stopifnot(identical(tt, tt2))
terms(delete.response(tt))
## both tt and tt2 re-ordered the formula < 1.7.0
## now try with a dot
terms(breaks ~ ., data = warpbreaks)
terms(breaks ~ . - tension, data = warpbreaks)
terms(breaks ~ . - tension, data = warpbreaks, simplify = TRUE)
terms(breaks ~ . ^2, data = warpbreaks)
terms(breaks ~ . ^2, data = warpbreaks, simplify = TRUE)
## 1.6.2 expanded these formulae out as in simplify = TRUE


## printing attributes (PR#2506)
(x <- structure(1:4, other=as.factor(LETTERS[1:3])))
## < 1.7.0 printed the codes of the factor attribute


## add logical matrix replacement indexing for data frames
TEMP <- data.frame(VAR1=c(1,2,3,4,5), VAR2=c(5,4,3,2,1), VAR3=c(1,1,1,1,NA))
TEMP[,c(1,3)][TEMP[,c(1,3)]==1 & !is.na(TEMP[,c(1,3)])] < -10
TEMP
##

## moved from reg-plot.R as exact output depends on rounding error
## PR 390 (axis for small ranges)

relrange <- function(x) {
    ## The relative range in EPS units
    r <- range(x)
    diff(r)/max(abs(r))/.Machine$double.eps
}

x <- c(0.12345678912345678,
       0.12345678912345679,
       0.12345678912345676)
# relrange(x) ## 1.0125, but depends on strtod
plot(x) # `extra horizontal' ;  +- ok on Solaris; label off on Linux

y <- c(0.9999563255363383973418,
       0.9999563255363389524533,
       0.9999563255363382863194)
## The relative range number:
# relrange(y) ## 3.000131, but depends on strtod
plot(y)# once gave infinite loop on Solaris [TL];  y-axis too long

## Comments: The whole issue was finally deferred to main/graphics.c l.1944
##    error("relative range of values is too small to compute accurately");
## which is not okay.

set.seed(101)
par(mfrow = c(3,3))
for(j.fac in 1e-12* c(10, 1, .7, .3, .2, .1, .05, .03, .01)) {
##           ====
    #set.seed(101) # or don't
    x <- pi + jitter(numeric(101), f = j.fac)
    rrtxt <- paste("rel.range =", formatC(relrange(x), dig = 4),"* EPS")
    cat("j.f = ", format(j.fac)," ;  ", rrtxt,"\n",sep="")
    plot(x, type = "l", main = rrtxt)
    cat("par(\"usr\")[3:4]:", formatC(par("usr")[3:4], wid = 10),"\n",
        "par(\"yaxp\") :   ", formatC(par("yaxp"), wid = 10),"\n\n", sep="")
}
par(mfrow = c(1,1))
## The warnings from inside GScale() will differ in their  relrange() ...
## >> do sloppy testing
## 2003-02-03 hopefully no more.  BDR
## end of PR 390


## scoping rules calling step inside a function
"cement" <-
    structure(list(x1 = c(7, 1, 11, 11, 7, 11, 3, 1, 2, 21, 1, 11, 10),
                   x2 = c(26, 29, 56, 31, 52, 55, 71, 31, 54, 47, 40, 66, 68),
                   x3 = c(6, 15, 8, 8, 6, 9, 17, 22, 18, 4, 23, 9, 8),
                   x4 = c(60, 52, 20, 47, 33, 22, 6, 44, 22, 26, 34, 12, 12),
                   y = c(78.5, 74.3, 104.3, 87.6, 95.9, 109.2, 102.7, 72.5,
                   93.1, 115.9, 83.8, 113.3, 109.4)),
              .Names = c("x1", "x2", "x3", "x4", "y"), class = "data.frame",
              row.names = 1:13)
teststep <- function(formula, data)
{
    d2 <- data
    fit <- lm(formula, data=d2)
    step(fit)
}
teststep(formula(y ~ .), cement)
## failed in 1.6.2

str(array(1))# not a scalar


## na.print="" shouldn't apply to (dim)names!
(tf <- table(ff <- factor(c(1:2,NA,2), exclude=NULL)))
identical(levels(ff), dimnames(tf)[[1]])
str(levels(ff))
## not quite ok previous to 1.7.0


## PR#3058  printing with na.print and right=TRUE
a <- matrix( c(NA, "a", "b", "10",
               NA, NA,  "d", "12",
               NA, NA,  NA,  "14"),
            byrow=T, ncol=4 )
print(a, right=TRUE, na.print=" ")
print(a, right=TRUE, na.print="----")
## misaligned in 1.7.0


## assigning factors to dimnames
A <- matrix(1:4, 2)
aa <- factor(letters[1:2])
dimnames(A) <- list(aa, NULL)
A
dimnames(A)
## 1.7.0 gave internal codes as display and dimnames()
## 1.7.1beta gave NAs via dimnames()
## 1.8.0 converts factors to character


## wishlist PR#2776: aliased coefs in lm/glm
set.seed(123)
x2 <- x1 <- 1:10
x3 <- 0.1*(1:10)^2
y <- x1 + rnorm(10)
(fit <- lm(y ~ x1 + x2 + x3))
summary(fit, cor = TRUE)
(fit <- glm(y ~ x1 + x2 + x3))
summary(fit, cor = TRUE)
## omitted silently in summary.glm < 1.8.0


## list-like indexing of data frames with drop specified
women["height"]
women["height", drop = FALSE]  # same with a warning
women["height", drop = TRUE]   # ditto
women[,"height", drop = FALSE] # no warning
women[,"height", drop = TRUE]  # a vector
## second and third were interpreted as women["height", , drop] in 1.7.x


## make.names
make.names("")
make.names(".aa")
## was "X.aa" in 1.7.1
make.names(".2")
make.names(".2a") # not valid in R
make.names(as.character(NA))
##


## strange names in data frames
as.data.frame(list(row.names=17))  # 0 rows in 1.7.1
aa <- data.frame(aa=1:3)
aa[["row.names"]] <- 4:6
aa # fine in 1.7.1
A <- matrix(4:9, 3, 2)
colnames(A) <- letters[1:2]
aa[["row.names"]] <- A
aa
## wrong printed names in 1.7.1

## assigning to NULL
a <- NULL
a[["a"]] <- 1
a
a <- NULL
a[["a"]] <- "something"
a
a <- NULL
a[["a"]] <- 1:3
a
## Last was an error in 1.7.1


## examples of 0-rank models, some empty, some rank-deficient
y <- rnorm(10)
x <- rep(0, 10)
(fit <- lm(y ~ 0))
summary(fit)
anova(fit)
predict(fit)
predict(fit, data.frame(x=x), se=TRUE)
predict(fit, type="terms", se=TRUE)
variable.names(fit) #should be empty
model.matrix(fit)

(fit <- lm(y ~ x + 0))
summary(fit)
anova(fit)
predict(fit)
predict(fit, data.frame(x=x), se=TRUE)
predict(fit, type="terms", se=TRUE)
variable.names(fit) #should be empty
model.matrix(fit)

(fit <- glm(y ~ 0))
summary(fit)
anova(fit)
predict(fit)
predict(fit, data.frame(x=x), se=TRUE)
predict(fit, type="terms", se=TRUE)

(fit <- glm(y ~ x + 0))
summary(fit)
anova(fit)
predict(fit)
predict(fit, data.frame(x=x), se=TRUE)
predict(fit, type="terms", se=TRUE)
## Lots of problems in 1.7.x


## lm.influence on deficient lm models
dat <- data.frame(y=rnorm(10), x1=1:10, x2=1:10, x3 = 0, wt=c(0,rep(1, 9)),
                  row.names=letters[1:10])
dat[3, 1] <- dat[4, 2] <- NA
lm.influence(lm(y ~ x1 + x2, data=dat, weights=wt, na.action=na.omit))
lm.influence(lm(y ~ x1 + x2, data=dat, weights=wt, na.action=na.exclude))
lm.influence(lm(y ~ 0, data=dat, weights=wt, na.action=na.omit))
lm.influence(lm(y ~ 0, data=dat, weights=wt, na.action=na.exclude))
lm.influence(lm(y ~ 0 + x3, data=dat, weights=wt, na.action=na.omit))
lm.influence(lm(y ~ 0 + x3, data=dat, weights=wt, na.action=na.exclude))
lm.influence(lm(y ~ 0, data=dat, na.action=na.exclude))
## last three misbehaved in 1.7.x, none had proper names.


## length of results in ARMAacf when lag.max is used
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=1) # was 4 in 1.7.1
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=2)
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=3)
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=4)
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=5) # failed in 1.7.1
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=6)
ARMAacf(ar=c(1.3,-0.6, -0.2, 0.1),lag.max=10)
##


## Indexing non-existent columns in a data frame
x <- data.frame(a = 1, b = 2)
try(x[c("a", "c")])
try(x[, c("a", "c")])
try(x[1, c("a", "c")])
## Second succeeded, third gave uniformative error message in 1.7.x.


## methods(class = ) with namespaces, .Primitives etc (many missing in 1.7.x):
meth2gen <- function(cl)
    noquote(sub(paste("\\.",cl,"$",sep=""),"", c(.S3methods(class = cl))))
meth2gen("data.frame")
meth2gen("dendrogram")
## --> the output may need somewhat frequent updating..


## subsetting a 1D array lost the dimensions
x <- array(1:5, dim=c(5))
dim(x)
dim(x[, drop=TRUE])
dim(x[2:3])
dim(x[2])
dim(x[2, drop=FALSE])
dimnames(x) <- list(some=letters[1:5])
x[]
x[2:3]
x[2]
x[2, drop=FALSE]
## both dim and dimnames lost in 1.8.0


## print.dist() didn't show NA's prior to 1.8.1
x <- cbind(c(1,NA,2,3), c(NA,2,NA,1))
(d <- dist(x))
print(d, diag = TRUE)
##


## offsets in model terms where sometimes not deleted correctly
attributes(terms(~ a + b + a:b + offset(c)))[c("offset", "term.labels")]
attributes(terms(y ~ a + b + a:b + offset(c)))[c("offset", "term.labels")]
attributes(terms(~ offset(c) + a + b + a:b))[c("offset", "term.labels")]
attributes(terms(y ~ offset(c) + a + b + a:b))[c("offset", "term.labels")]
## errors prior to 1.8.1


## 0-level factors gave nonsensical answers in model.matrix
m <- model.frame(~x, data.frame(x=NA), na.action=na.pass)
model.matrix(~x, m)
lm.fit <- lm(y ~ x, data.frame(x=1:10, y=1:10))
try(predict(lm.fit, data.frame(x=NA)))
## wrong answers in 1.8.0, refused to run in 1.8.1



## failure to print data frame containing arrays
## raised by John Fox on R-devel on 2004-01-08
y1 <- array(1:10, dim=10)
y2 <- array(1:30, dim=c(10,3), dimnames=list(NULL, letters[1:3]))
y3 <- array(1:40, dim=c(10,2,2),
            dimnames=list(NULL, letters[1:2], NULL))
data.frame(y=y1)
data.frame(y=y2)
data.frame(y=y3)

as.data.frame(y1)
as.data.frame(y2)
as.data.frame(y3)

X <- data.frame(x=1:10)
X$y <- y1
X
sapply(X, dim)

X$y <- y2
X
sapply(X, dim)

X$y <- y3
X
sapply(X, dim)
## The last one fails in S.

## test of user hooks
for(id in c("A", "B")) {
    eval(substitute(
    {
setHook(packageEvent("stats4", "onLoad"),
        function(pkgname, ...) cat("onLoad", sQuote(pkgname), id, "\n"));
setHook(packageEvent("stats4", "attach"),
        function(pkgname, ...) cat("attach", sQuote(pkgname), id, "\n"));
setHook(packageEvent("stats4", "detach"),
        function(pkgname, ...) cat("detach", sQuote(pkgname), id, "\n"));
setHook(packageEvent("stats4", "onUnload"),
        function(pkgname, ...) cat("onUnload", sQuote(pkgname), id, "\n"))
    },
                    list(id=id)))
}
loadNamespace("stats4")
library("stats4")
detach("package:stats4")
unloadNamespace("stats4")
## Just tests


## rep(0-length-vector, length.out > 0)
rep(integer(0), length.out=0)
rep(integer(0), length.out=10)
typeof(.Last.value)
rep(logical(0), length.out=0)
rep(logical(0), length.out=10)
typeof(.Last.value)
rep(numeric(0), length.out=0)
rep(numeric(0), length.out=10)
typeof(.Last.value)
rep(character(0), length.out=0)
rep(character(0), length.out=10)
typeof(.Last.value)
rep(complex(0), length.out=0)
rep(complex(0), length.out=10)
typeof(.Last.value)
rep(list(), length.out=0)
rep(list(), length.out=10)
## always 0-length before 1.9.0


## supplying 0-length data to array and matrix
array(numeric(0), c(2, 2))
array(list(), c(2,2))
# worked < 1.8.0, error in 1.8.x
matrix(character(0), 1, 2)
matrix(integer(0), 1, 2)
matrix(logical(0), 1, 2)
matrix(numeric(0), 1, 2)
matrix(complex(0), 1, 2)
matrix(list(), 1, 2)
## did not work < 1.9.0


## S compatibility change in 1.9.0
rep(1:2, each=3, length=12)
## used to pad with NAs.


## PR#6510: aov() with error and -1
set.seed(1)
test.df <- data.frame (y=rnorm(8), a=gl(2,1,8), b=gl(2,3,8),c=gl(2,4,8))
aov(y ~ a + b + Error(c), data=test.df)
aov(y ~ a + b - 1 + Error(c), data=test.df)
## wrong assignment to strata labels < 1.9.0
## Note this is unbalanced and not a good example

binom.test(c(800,10))# p-value < epsilon


## aov with a singular error model
rd <- c(16.53, 12.12, 10.04, 15.32, 12.33, 10.1, 17.09, 11.69, 11.81, 14.75,
        10.72, 8.79, 13.14, 9.79, 8.36, 15.62, 9.64, 8.72, 15.32,
        11.35, 8.52, 13.27, 9.74, 8.78, 13.16, 10.16, 8.4, 13.08, 9.66,
        8.16, 12.17, 9.13, 7.43, 13.28, 9.16, 7.92, 118.77, 78.83, 62.2,
        107.29, 73.79, 58.59, 118.9, 66.35, 53.12, 372.62, 245.39, 223.72,
        326.03, 232.67, 209.44, 297.55, 239.71, 223.8)
sample.df <- data.frame(dep.variable=rd,
                        subject=factor(rep(paste("subj",1:6, sep=""),each=9)),
                        f1=factor(rep(rep(c("f1","f2","f3"),each=6),3)),
                        f2=factor(rep(c("g1","g2","g3"),each=18))
)
sample.aov <- aov(dep.variable ~ f1 * f2 + Error(subject/(f1+f2)), data=sample.df)
sample.aov
summary(sample.aov)
sample.aov <- aov(dep.variable ~ f1 * f2 + Error(subject/(f2+f1)), data=sample.df)
sample.aov
summary(sample.aov)
## failed in 1.8.1


## PR#6645  stem() with near-constant values
stem(rep(1, 100))
stem(rep(0.1, 10))
stem(c(rep(1, 10), 1+1.e-8))
stem(c(rep(1, 10), 1+1.e-9))
stem(c(rep(1, 10), 1+1.e-10), atom=0) # integer-overflow is avoided.
##  had integer overflows in 1.8.1, and silly shifts of decimal point


## PR#6633 warnings with vector op matrix, and more
set.seed(1)
x1 <- rnorm(3)
y1 <- rnorm(4)
x1 * y1
x1 * as.matrix(y1) # no warning in 1.8.1
x1 * matrix(y1,2,2)# ditto
z1 <- x1 > 0
z2 <- y1 > 0
z1 & z2
z1 & as.matrix(z2) # no warning in 1.8.1
x1 < y1            # no warning in 1.8.1
x1 < as.matrix(y1) # ditto
##


## summary method for mle
library(stats4)
N <- c(rep(3:6, 3), 7,7, rep(8,6), 9,9, 10,12)# sample from Pois(lam = 7)
summary(mle(function(Lam = 1) -sum(dpois(N, Lam))))
## "Coefficients" was "NULL" in 1.9.0's "devel"


## PR#6656 terms.formula(simplify = TRUE) was losing offset terms
## successive offsets caused problems
df <- data.frame(x=1:4, y=sqrt( 1:4), z=c(2:4,1))
fit1 <- glm(y ~ offset(x) + z, data=df)
update(fit1, ". ~.")$call
## lost offset in 1.7.0 to 1.8.1
terms(y ~ offset(x) + offset(log(x)) + z, data=df)
## failed to remove second offset from formula in 1.8.1
terms(y ~ offset(x) + z - z, data=df, simplify = TRUE)
## first fix failed for models with no non-offset terms.


## only the first two were wrong up to 1.8.1:
3:4 * 1e-100
8:11* 1e-100
1:2 * 1e-99
1:2 * 1e+99
8:11* 1e+99
3:4 * 1e+100
##


## negative subscripts could be mixed with NAs
x <- 1:3
try(x[-c(1, NA)])
## worked on some platforms, segfaulted on others in 1.8.1


## vector 'border' (and no 'pch', 'cex' nor 'bg'):
boxplot(count ~ spray, data = InsectSprays, border=2:7)
## gave warnings in 1.9.0

summary(as.Date(paste("2002-12", 26:31, sep="-")))
## printed all "2002.-12-29" in 1.9.1 {because digits was too small}
as.matrix(data.frame(d = as.POSIXct("2004-07-20")))
## gave a warning in 1.9.1


## Dump should quote when necessary (PR#6857)
x <- quote(b)
dump("x", "")
## doesn't quote b in 1.9.0


## some checks of indexing by character, used to test hashing code
x <- 1:26
names(x) <- letters
x[c("a", "aa", "aa")] <- 100:102
x

x <- 1:26
names(x) <- rep("", 26)
x[c("a", "aa", "aa")] <- 100:102
x
##


## tests of raw type
# tests of logic operators
x <- "A test string"
(y <- charToRaw(x))
(xx <- c(y, as.raw(0), charToRaw("more")))

!y
y & as.raw(15)
y | as.raw(128)

# tests of binary read/write
zz <- file("testbin", "wb")
writeBin(xx, zz)
close(zz)
zz <- file("testbin", "rb")
(yy <- readBin(zz, "raw", 100))
seek(zz, 0, "start")
readBin(zz, "integer", n=100, size = 1) # read as small integers
seek(zz, 0, "start")
readBin(zz, "character", 100)  # is confused by embedded nul.
seek(zz, 0, "start")
readChar(zz, length(xx)) # truncates at embedded nul
seek(zz) # make sure current position is reported properly
close(zz)
unlink("testbin")

# tests of ASCII read/write.
cat(xx, file="testascii")
scan("testascii", what=raw(0))
unlink("testascii")
##


## Example of prediction not from newdata as intended.
set.seed(1)
y <- rnorm(10)
x  <- cbind(1:10, sample(1:10)) # matrix
xt <- cbind(1:2,  3:4)
(lm1 <- lm(y ~ x))
predict(lm1, newdata = data.frame(x= xt))
## warns as from 2.0.0


## eval could alter a data.frame/list second argument
data(trees)
a <- trees
eval(quote({Girth[1]<-NA;Girth}),a)
a[1, ]
trees[1, ]
## both a and trees got altered in 1.9.1


## write.table did not apply qmethod to col.names (PR#7171)
x <- data.frame("test string with \"" = c("a \" and a '"), check.names=FALSE)
write.table(x)
write.table(x, qmethod = "double")
## Quote in col name was unescaped in 1.9.1.


## extensions to read.table
Mat <- matrix(c(1:3, letters[1:3], 1:3, LETTERS[1:3],
                c("2004-01-01", "2004-02-01", "2004-03-01"),
                c("2004-01-01 12:00", "2004-02-01 12:00", "2004-03-01 12:00")),
              3, 6)
foo <- tempfile()
write.table(Mat, foo, col.names = FALSE, row.names = FALSE)
read.table(foo, colClasses = c(NA, NA, "NULL", "character", "Date", "POSIXct"))
unlist(sapply(.Last.value, class))
read.table(foo, colClasses = c("factor",NA,"NULL","factor","Date","POSIXct"))
unlist(sapply(.Last.value, class))
read.table(foo, colClasses = c(V4="character"))
unlist(sapply(.Last.value, class))
unlink(foo)
## added in 2.0.0


## write.table with complex columns (PR#7260, in part)
write.table(data.frame(x = 0.5+1:4, y = 1:4 + 1.5i), file = "")
# printed all as complex in 2.0.0.
write.table(data.frame(x = 0.5+1:4, y = 1:4 + 1.5i), file = "", dec=",")
## used '.' not ',' in 2.0.0

## splinefun() value test
(x <- seq(0,6, length=25))
mx <- sapply(c("fmm", "nat", "per"),
             function(m) splinefun(1:5, c(1,2,4,3,1), method = m)(x))
cbind(x,mx)


## infinite loop in read.fwf (PR#7350)
cat(file="test.txt", sep = "\n", "# comment 1", "1234567   # comment 2",
    "1 234567  # comment 3", "12345  67 # comment 4", "# comment 5")
read.fwf("test.txt", width=c(2,2,3), skip=1, n=4) # looped
read.fwf("test.txt", width=c(2,2,3), skip=1)      # 1 line short
read.fwf("test.txt", width=c(2,2,3), skip=0)
unlink("test.txt")
##


## split was not handling lists and raws
split(as.list(1:3), c(1,1,2))
(y <- charToRaw("A test string"))
(z <- split(y, rep(1:5, times=c(1,1,4,1,6))))
sapply(z, rawToChar)
## wrong results in 2.0.0


## tests of changed S3 implicit classes in 2.1.0
foo <- function(x, ...) UseMethod("foo")
foo.numeric <- function(x) cat("numeric arg\n")
foo(1:10)
foo(pi)
foo(matrix(1:10, 2, 5))
foo.integer <- function(x) cat("integer arg\n")
foo.double <- function(x) cat("double arg\n")
foo(1:10)
foo(pi)
foo(matrix(1:10, 2, 5))
##


## str() interpreted escape sequences prior to 2.1.0
x <- "ab\bc\ndef"
str(x)
str(x, vec.len=0)# failed in rev 32244
str(factor(x))

x <- c("a", NA, "b")
factor(x)
factor(x, exclude="")
str(x)
str(factor(x))
str(factor(x, exclude=""))
##


## print.factor(quote=TRUE) was not quoting levels
x <- c("a", NA, "b", 'a " test') #" (comment for fontification)
factor(x)
factor(x, exclude="")
print(factor(x), quote=TRUE)
print(factor(x, exclude=""), quote=TRUE)
## last two printed levels differently from values in 2.0.1


## write.table in marginal cases
x <- matrix(, 3, 0)
write.table(x) # 3 rows
write.table(x, row.names=FALSE)
# note: scan and read.table won't read this as they take empty fields as NA
## was 1 row in 2.0.1


## More tests of write.table
x <- list(a=1, b=1:2, c=3:4, d=5)
dim(x) <- c(2,2)
x
write.table(x)

x1 <- data.frame(a=1:2, b=I(matrix(LETTERS[1:4], 2, 2)), c = c("(i)", "(ii)"))
x1
write.table(x1) # In 2.0.1 had 3 headers, 4 cols
write.table(x1, quote=c(2,3,4))

x2 <- data.frame(a=1:2, b=I(list(a=1, b=2)))
x2
write.table(x2)

x3 <- seq(as.Date("2005-01-01"), len=6, by="day")
x4 <- data.frame(x=1:6, y=x3)
dim(x3) <- c(2,3)
x3
write.table(x3) # matrix, so loses class
x4
write.table(x4) # preserves class, does not quote
##


## Problem with earlier regexp code spotted by KH
grep("(.*s){2}", "Arkansas", v = TRUE)
grep("(.*s){3}", "Arkansas", v = TRUE)
grep("(.*s){3}", state.name, v = TRUE)
## Thought Arkansas had 3 s's.


## Replacing part of a non-existent column could create a short column.
xx<- data.frame(a=1:4, b=letters[1:4])
xx[2:3, "c"] <- 2:3
## gave short column in R < 2.1.0.


## add1/drop1 could give misleading results if missing values were involved
y <- rnorm(1:20)
x <- 1:20; x[10] <- NA
x2 <- runif(20); x2[20] <- NA
fit <- lm(y ~ x)
drop1(fit)
res <-  try(stats:::drop1.default(fit))
stopifnot(inherits(res, "try-error"))
add1(fit, ~ . +x2)
res <-  try(stats:::add1.default(fit, ~ . +x2))
stopifnot(inherits(res, "try-error"))
## 2.0.1 ran and gave incorrect answers.


## (PR#7789) escaped quotes in the first five lines for read.table
tf <- tempfile()
x <- c("6 'TV2  Shortland Street'",
       "2 'I don\\\'t watch TV at 7'",
       "1 'I\\\'m not bothered, whatever that looks good'",
       "2 'I channel surf'")
writeLines(x, tf)
read.table(tf)
x <- c("6 'TV2  Shortland Street'",
       "2 'I don''t watch TV at 7'",
       "1 'I''m not bothered, whatever that looks good'",
       "2 'I channel surf'")
writeLines(x, tf)
read.table(tf, sep=" ")
unlink(tf)
## mangled in 2.0.1


## (PR#7802) printCoefmat(signif.legend =FALSE) failed
set.seed(123)
cmat <- cbind(rnorm(3, 10), sqrt(rchisq(3, 12)))
cmat <- cbind(cmat, cmat[,1]/cmat[,2])
cmat <- cbind(cmat, 2*pnorm(-cmat[,3]))
colnames(cmat) <- c("Estimate", "Std.Err", "Z value", "Pr(>z)")
printCoefmat(cmat, signif.stars = TRUE)
printCoefmat(cmat, signif.stars = TRUE, signif.legend = FALSE)
# no stars, so no legend
printCoefmat(cmat, signif.stars = FALSE)
printCoefmat(cmat, signif.stars = TRUE, signif.legend = TRUE)
## did not work in 2.1.0


## PR#7824 subscripting an array by a matrix
x <- matrix(1:6, ncol=2)
x[rbind(c(1,1), c(2,2))]
x[rbind(c(1,1), c(2,2), c(0,1))]
x[rbind(c(1,1), c(2,2), c(0,0))]
x[rbind(c(1,1), c(2,2), c(0,2))]
x[rbind(c(1,1), c(2,2), c(0,3))]
x[rbind(c(1,1), c(2,2), c(1,0))]
x[rbind(c(1,1), c(2,2), c(2,0))]
x[rbind(c(1,1), c(2,2), c(3,0))]
x[rbind(c(1,0), c(0,2), c(3,0))]
x[rbind(c(1,0), c(0,0), c(3,0))]
x[rbind(c(1,1), c(2,2), c(1,2))]
x[rbind(c(1,1), c(2,NA), c(1,2))]
x[rbind(c(1,0), c(2,NA), c(1,2))]
try(x[rbind(c(1,1), c(2,2), c(-1,2))])
try(x[rbind(c(1,1), c(2,2), c(-2,2))])
try(x[rbind(c(1,1), c(2,2), c(-3,2))])
try(x[rbind(c(1,1), c(2,2), c(-4,2))])
try(x[rbind(c(1,1), c(2,2), c(-1,-1))])
try(x[rbind(c(1,1,1), c(2,2,2))])

# verify that range checks are applied to negative indices
x <- matrix(1:6, ncol=3)
try(x[rbind(c(1,1), c(2,2), c(-3,3))])
try(x[rbind(c(1,1), c(2,2), c(-4,3))])
## generally allowed in 2.1.0.


## printing RAW matrices/arrays was not implemented
s <- sapply(0:7, function(i) rawShift(charToRaw("my text"),i))
s
dim(s) <- c(7,4,2)
s
## empty < 2.1.1


## interpretation of '.' directly by model.matrix
dd <- data.frame(a = gl(3,4), b = gl(4,1,12))
model.matrix(~ .^2, data = dd)
## lost ^2 in 2.1.1


## add1.lm and drop.lm did not know about offsets (PR#8049)
set.seed(2)
y <- rnorm(10)
z <- 1:10
lm0 <- lm(y ~ 1)
lm1 <- lm(y ~ 1, offset = 1:10)
lm2 <- lm(y ~ z, offset = 1:10)

add1(lm0, scope = ~ z)
anova(lm1, lm2)
add1(lm1, scope = ~ z)
drop1(lm2)
## Last two ignored the offset in 2.1.1


## tests of raw conversion
as.raw(1234)
as.raw(list(a=1234))
## 2.1.1: spurious and missing messages, wrong result for second.


### end of tests added in 2.1.1 patched ###


## Tests of logical matrix indexing with NAs
df1 <- data.frame(a = c(NA, 0, 3, 4)); m1 <- as.matrix(df1)
df2 <- data.frame(a = c(NA, 0, 0, 4)); m2 <- as.matrix(df2)
df1[df1 == 0] <- 2; df1
m1[m1 == 0] <- 2;   m1
df2[df2 == 0] <- 2; df2  # not allowed in 2.{0,1}.z
m2[m2 == 0] <- 2;   m2
df1[df1 == 2] # this is first coerced to a matrix, and drops to a vector
df3 <- data.frame(a=1:2, b=2:3)
df3[df3 == 2]            # had spurious names
# but not allowed
## (modified to make printed result the same whether numeric() is
##  compiled or interpreted)
## try(df2[df2 == 2] <- 1:2)
## try(m2[m2 == 2] <- 1:2)
tryCatch(df2[df2 == 2] <- 1:2,
         error = function(e) paste("Error:", conditionMessage(e)))
tryCatch(m2[m2 == 2] <- 1:2,
         error = function(e) paste("Error:", conditionMessage(e)))
##


## vector indexing of matrices: issue is when rownames are used
# 1D array
m1 <- c(0,1,2,0)
dim(m1) <- 4
dimnames(m1) <- list(1:4)
m1[m1 == 0]                        # has rownames
m1[which(m1 == 0)]                 # has rownames
m1[which(m1 == 0, arr.ind = TRUE)] # no names < 2.2.0 (side effect of PR#937)

# 2D array with 2 cols
m2 <- as.matrix(data.frame(a=c(0,1,2,0), b=0:3))
m2[m2 == 0]                        # a vector, had names < 2.2.0
m2[which(m2 == 0)]                 # a vector, had names < 2.2.0
m2[which(m2 == 0, arr.ind = TRUE)] # no names (PR#937)

# 2D array with one col: could use rownames but do not.
m21 <- m2[, 1, drop = FALSE]
m21[m21 == 0]
m21[which(m21 == 0)]
m21[which(m21 == 0, arr.ind = TRUE)]
## not consistent < 2.2.0: S never gives names


## tests of indexing as quoted in Extract.Rd
x <- NULL
x$foo <- 2
x # length-1 vector
x <- NULL
x[[2]] <- pi
x # numeric vector
x <- NULL
x[[1]] <- 1:3
x # list
##


## printing of a kernel:
kernel(1)
## printed wrongly in R <= 2.1.1


## using NULL as a replacement value
DF <- data.frame(A=1:2, B=3:4)
try(DF[2, 1:3] <- NULL)
## wrong error message in R < 2.2.0


## tests of signif
ob <- 0:9 * 2000
print(signif(ob, 3), digits=17) # had rounding error in 2.1.1
signif(1.2347e-305, 4)
signif(1.2347e-306, 4)  # only 3 digits in 2.1.1
signif(1.2347e-307, 4)
##

### end of tests added in 2.2.0 patched ###


## printing lists with NA names
A <- list(1, 2)
names(A) <- c("NA", NA)
A
## both printed as "NA" in 2.2.0


## subscripting with both NA and "NA" names
x <- 1:4
names(x) <- c(NA, "NA", "a", "")
x[names(x)]
## 2.2.0 had the second matching the first.
lx <- as.list(x)
lx[[as.character(NA)]]
lx[as.character(NA)]
## 2.2.0 had both matching element 1


## data frame replacement subscripting
# Charles C. Berry, R-devel, 2005-10-26
a.frame <- data.frame( x=letters[1:5] )
a.frame[ 2:5, "y" ] <- letters[2:5]
a.frame  # added rows 1:4
# and adding and replacing matrices failed
a.frame[ ,"y" ] <- matrix(1:10, 5, 2)
a.frame
a.frame[3:5 ,"y" ] <- matrix(1:6, 3, 2)
a.frame
a.frame <- data.frame( x=letters[1:5] )
a.frame[3:5 ,"y" ] <- matrix(1:6, 3, 2)
a.frame
## failed/wrong ans in 2.2.0


### end of tests added in 2.2.0 patched ###


## test of fix of trivial warning PR#8252
pairs(iris[1:4], oma=rep(3,4))
## warned in 2.2.0 only


## str(<dendrogram>)
dend <- as.dendrogram(hclust(dist(USArrests), "ave")) # "print()" method
dend2 <- cut(dend, h=70)
str(dend2$upper)
## {{for Emacs: `}}  gave much too many spaces in 2.2.[01]


## formatC on Windows (PR#8337)
xx  <- pi * 10^(-5:4)
cbind(formatC(xx, wid = 9))
cbind(formatC(xx, wid = 9, flag = "-"))
cbind(formatC(xx, wid = 9, flag = "0"))
## extra space on 2.2.1


## an impossible glm fit
success <- c(13,12,11,14,14,11,13,11,12)
failure <- c(0,0,0,0,0,0,0,2,2)
predictor <- c(0, 5^(0:7))
try(glm(cbind(success,failure) ~ 0+predictor, family = binomial(link="log")))
# no coefficient is possible as the first case will have mu = 1
## 2.2.1 gave a subscript out of range warning instead.


## error message from solve (PR#8494)
temp <- diag(1, 5)[, 1:4]
rownames(temp) <- as.character(1:5)
colnames(temp) <- as.character(1:4)
try(solve(temp))
# also complex
try(solve(temp+0i))
# and non-comformant systems
try(solve(temp, diag(3)))
## gave errors from rownames<- in 2.2.1


## PR#8462 terms.formula(simplify = TRUE) needs parentheses.
update.formula (Reaction ~ Days + (Days | Subject), . ~ . + I(Days^2))
## < 2.3.0 dropped parens on second term.


## PR#8528: errors in the post-2.1.0 pgamma
pgamma(seq(0.75, 1.25, by=0.05)*1e100, shape = 1e100, log=TRUE)
pgamma(seq(0.75, 1.25, by=0.05)*1e100, shape = 1e100, log=TRUE, lower=FALSE)
pgamma(c(1-1e-10, 1+1e-10)*1e100, shape = 1e100)
pgamma(0.9*1e25, 1e25, log=TRUE)
## were NaN, -Inf etc in 2.2.1.


## + for POSIXt objects was non-commutative
# SPSS-style dates
c(10485849600,10477641600,10561104000,10562745600)+ISOdate(1582,10,14)
## was in the local time zone in 2.2.1.


## Limiting lines on deparse (wishlist PR#8638)
op <- options(deparse.max.lines = 3)
f <- function(...) browser()
do.call(f, mtcars)
c

options(error = expression(NULL))
f <- function(...) stop()
do.call(f, mtcars)
traceback()

## Debugger can handle a function that has a single function call as its body
g <- function(fun) fun(1)
debug(g)
g(function(x) x+1)

options(op)
## unlimited < 2.3.0


## row names in as.table (PR#8652)
as.table(matrix(1:60, ncol=2))
## rows past 26 had NA row names


## summary on a glm with zero weights and estimated dispersion (PR#8720)
y <- rnorm(10)
x <- 1:10
w <- c(rep(1,9), 0)
summary(glm(y ~ x, weights = w))
summary(glm(y ~ x, subset = w > 0))
## has NA dispersion in 2.2.1


## substitute was losing "..." after r37269
yaa <- function(...) substitute(list(...))
yaa(foo(...))
## and wasn't substituting after "..."
substitute(list(..., x), list(x=1))
## fixed for 2.3.0


## uniroot never warned (PR#8750)
ff <- function(x) (x-pi)^3
uniroot(ff, c(-10,10), maxiter=10)
## should warn, did not < 2.3.0


### end of tests added in 2.3.0 ###


## prod etc on empty lists and raw vectors
try(min(list()))
try(max(list()))
try(sum(list()))
try(prod(list()))
try(min(raw()))
try(max(raw()))
try(sum(raw()))
try(prod(raw()))
## Inf, -Inf, list(NULL) etc in 2.2.1

r <- hist(rnorm(100), plot = FALSE, breaks = 12,
          ## arguments which don't make sense for plot=FALSE - give a warning:
          xlab = "N(0,1)", col = "blue")
## gave no warning in 2.3.0 and earlier


## rbind.data.frame on permuted cols (PR#8868)
d1 <- data.frame(x=1:10, y=letters[1:10], z=1:10)
d2 <- data.frame(y=LETTERS[1:5], z=5:1, x=7:11)
rbind(d1, d2)
# got factor y  wrong in 2.3.0
# and failed with duplicated col names.
d1 <- data.frame(x=1:2, y=5:6, x=8:9, check.names=FALSE)
d2 <- data.frame(x=3:4, x=-(1:2), y=8:9, check.names=FALSE)
rbind(d1, d2)
## corrupt in 2.3.0


## sort.list on complex vectors was unimplemented prior to 2.4.0
x <- rep(2:1, c(2, 2)) + 1i*c(4, 1, 2, 3)
(o <- sort.list(x))
x[o]
sort(x)  # for a cross-check
##


## PR#9044 write.table(quote=TRUE, row.names=FALSE) did not quote column names
m <- matrix(1:9, nrow=3, dimnames=list(c("A","B","C"),  c("I","II","III")))
write.table(m)
write.table(m, col.names=FALSE)
write.table(m, row.names=FALSE)
# wrong < 2.3.1 patched.
write.table(m, quote=FALSE)
write.table(m, col.names=FALSE, quote=FALSE)
write.table(m, row.names=FALSE, quote=FALSE)
d <- as.data.frame(m)
write.table(d)
write.table(d, col.names=FALSE)
write.table(d, row.names=FALSE)
write.table(d, quote=FALSE)
write.table(d, col.names=FALSE, quote=FALSE)
write.table(d, row.names=FALSE, quote=FALSE)
write.table(m, quote=numeric(0)) # not the same as FALSE
##


## removing variable from baseenv
try(remove("ls", envir=baseenv()))
try(remove("ls", envir=asNamespace("base")))
## no message in 2.3.1


## tests of behaviour of factors
(x <- factor(LETTERS[1:5])[2:4])
x[2]
x[[2]]
stopifnot(identical(x[2], x[[2]]))
as.list(x)
(xx <- unlist(as.list(x)))
stopifnot(identical(x, xx))
as.vector(x, "list")
(sx <- sapply(x, function(.).))
stopifnot(identical(x, sx))
## changed in 2.4.0


## as.character on a factor with "NA" level
as.character(as.factor(c("AB", "CD", NA)))
as.character(as.factor(c("NA", "CD", NA)))  # use <NA> is 2.3.x
as.vector(as.factor(c("NA", "CD", NA)))     # but this did not
## used <NA> before


## [ on a zero-column data frame, names of such
data.frame()[FALSE]
names(data.frame())
# gave NULL names and hence spurious warning.


## residuals from zero-weight glm fits
d.AD <- data.frame(treatment = gl(3,3), outcome = gl(3,1,9),
                   counts = c(18,17,15,20,10,20,25,13,12))
fit <- glm(counts ~ outcome + treatment, family = poisson,
           data = d.AD, weights = c(0, rep(1,8)))
residuals(fit, type="working") # first was NA < 2.4.0
## working residuals were NA for zero-weight cases.
fit2 <- glm(counts ~ outcome + treatment, family = poisson,
           data = d.AD, weights = c(0, rep(1,8)), y = FALSE)
for(z in c("response", "working", "deviance", "pearson"))
    stopifnot(all.equal(residuals(fit, type=z), residuals(fit2, type=z),
                        scale = 1, tolerance = 1e-10))

## apply on arrays with zero extents
## Robin Hankin, R-help, 2006-02-13
A <- array(0, c(3, 0, 4))
dimnames(A) <- list(D1 = letters[1:3], D2 = NULL, D3 = LETTERS[1:4])
f <- function(x) 5
apply(A, 1:2, f)
apply(A, 1, f)
apply(A, 2, f)
## dropped dims in 2.3.1


## print a factor with names
structure(factor(1:4), names = letters[1:4])
## dropped names < 2.4.0


## some tests of factor matrices
A <- factor(7:12)
dim(A) <- c(2, 3)
A
str(A)
A[, 1:2]
A[, 1:2, drop=TRUE]
A[1,1] <- "9"
A
## misbehaved < 2.4.0


## [dpqr]t with vector ncp
nc <- c(0, 0.0001, 1)
dt(1.8, 10, nc)
pt(1.8, 10, nc)
qt(0.95, 10, nc)
## gave warnings in 2.3.1, short answer for qt.
dt(1.8, 10, -nc[-1])
pt(1.8, 10, -nc[-1])
qt(0.95, 10, -nc[-1])
## qt in 2.3.1 did not allow negative ncp.


## merge() used to insert row names as factor, not character, so
## sorting was unexpected.
A <- data.frame(a = 1:4)
row.names(A) <- c("2002-11-15", "2002-12-15", "2003-01-15", "2003-02-15")
B <- data.frame(b = 1:4)
row.names(B) <- c("2002-09-15", "2002-10-15", "2002-11-15", "2002-12-15")
merge(A, B, by=0, all=TRUE)


## assigning to a list loop index could alter the index (PR#9216)
L <- list(a = list(txt = "original value"))
f <- function(LL) {
    for (ll in LL) ll$txt <- "changed in f"
    LL
}
f(L)
L
## both were changed < 2.4.0


## summary.mlm misbehaved with na.action = na.exclude
n <- 50
x <- runif(n=n)
y1 <- 2 * x + rnorm(n=n)
y2 <- 5 * x + rnorm(n=n)
y2[sample(1:n, size=5)] <- NA
y <- cbind(y1, y2)
fit <- lm(y ~ 1, na.action="na.exclude")
summary(fit)
## failed < 2.4.0

RNGkind("default","default")## reset to default - ease  R core

## prettyNum lost attributes (PR#8695)
format(matrix(1:16, 4), big.mark = ",")
## was a vector < 2.4.0


## printing of complex numbers of very different magnitudes
1e100  + 1e44i
1e100 + pi*1i*10^(c(-100,0,1,40,100))
## first was silly, second not rounded correctly in 2.2.0 - 2.3.1
## We don't get them lining up, but that is a printf issue
## that only happens for very large complex nos.


### end of tests added in 2.4.0 ###


## Platform-specific behaviour in lowess reported to R-help
## 2006-10-12 by Frank Harrell
x <- c(0,7,8,14,15,120,242)
y <- c(122,128,130,158,110,110,92)
lowess(x, y, iter=0)
lowess(x, y)
## MAD of iterated residuals was zero, and result depended on the platform.


## PR#9263: problems with R_Visible
a <- list(b=5)
a[[(t<-'b')]]
x <- matrix(5:-6, 3)
x[2, invisible(3)]
## both invisible in 2.4.0


### end of tests added in 2.4.1 ###


## tests of deparsing
x <-list(a = NA, b = as.integer(NA), c=0+NA, d=0i+NA,
         e = 1, f = 1:1, g = 1:3, h = c(NA, 1:3),
         i = as.character(NA), j = c("foo", NA, "bar")
         )
dput(x, control=NULL)
dput(x, control="keepInteger")
dput(x, control="keepNA")
dput(x)
dput(x, control="all")
dput(x, control=c("all", "S_compatible"))
tmp <- tempfile()
dput(x, tmp, control="all")
stopifnot(identical(dget(tmp), x))
dput(x, tmp, control=c("all", "S_compatible"))
stopifnot(identical(dget(tmp), x))
unlink(tmp)
## changes in 2.5.0


## give better error message for nls with no parameters
## Ivo Welch, R-help, 2006-12-23.
d <- data.frame(y= runif(10), x=runif(10))
try(nls(y ~ 1/(1+x), data = d, start=list(x=0.5,y=0.5), trace=TRUE))
## changed in 2.4.1 patched


## cut(breaks="years"), in part PR#9433
cut(as.Date(c("2000-01-17","2001-01-13","2001-01-20")), breaks="years")
cut(as.POSIXct(c("2000-01-17","2001-01-13","2001-01-20")), breaks="years")
## did not get day 01 < 2.4.1 patched


## manipulating rownames: problems in pre-2.5.0
A <- data.frame(a=character(0))
try(row.names(A) <- 1:10) # succeeded in Dec 2006
A <- list(a=1:3)
class(A) <- "data.frame"
row.names(A) <- letters[24:26] # failed at one point in Dec 2006
A
##


## extreme cases for subsetting of data frames
w <- women[1, ]
w[]
w[,drop = TRUE]
w[1,]
w[,]
w[1, , drop = FALSE]
w[, , drop = FALSE]
w[1, , drop = TRUE]
w[, , drop = TRUE]
## regression test: code changed for 2.5.0


## data.frame() with zero columns ignored 'row.names'
(x <- data.frame(row.names=1:4))
nrow(x)
row.names(x)
attr(x, "row.names")
## ignored prior to 2.5.0.


## identical on data.frames
d0 <- d1 <- data.frame(1:4, row.names=1:4)
row.names(d0) <- NULL
dput(d0)
dput(d1)
identical(d0, d1)
all.equal(d0, d1)
row.names(d1) <- as.character(1:4)
dput(d1)
identical(d0, d1)
all.equal(d0, d1)
## identical used internal representation prior to 2.5.0


## all.equal
# ignored check.attributes in 2.4.1
all.equal(data.frame(x=1:5, row.names=letters[1:5]),
          data.frame(x=1:5,row.names=LETTERS[1:5]),
          check.attributes=FALSE)
# treated logicals as numeric
all.equal(c(T, F, F), c(T, T, F))
all.equal(c(T, T, F), c(T, F, F))
# ignored raw:
all.equal(as.raw(1:3), as.raw(1:3))
all.equal(as.raw(1:3), as.raw(3:1))
##


## tests of deparsing
# if we run this from stdin, we will have no source, so fake it
f <- function(x, xm  = max(1L, x)) {xx <- 0L; yy <- NA_real_}
attr(f, "srcref") <- srcref(srcfilecopy("",
    "function(x, xm  = max(1L, x)) {xx <- 0L; yy <- NA_real_}"),
    c(1L, 1L, 1L, 56L))
f # uses the source
dput(f) # not source
dput(f, control="all") # uses the source
cat(deparse(f), sep="\n")
dump("f", file="")
# remove the source
attr(f, "srcref") <- NULL
f
dput(f, control="all")
dump("f", file="")

expression(bin <- bin + 1L)
## did not preserve e.g. 1L at some point in pre-2.5.0


## NAs in substr were handled as large negative numbers
x <- "abcde"
substr(x, 1, 3)
substr(x, NA, 1)
substr(x, 1, NA)
substr(x, NA, 3) <- "abc"; x
substr(x, 1, NA) <- "AA"; x
substr(x, 1, 2) <- NA_character_; x
## "" or no change in 2.4.1, except last


## regression tests for pmin/pmax, rewritten in C for 2.5.0
# NULL == integer(0)
pmin(NULL, integer(0))
pmax(integer(0), NULL)
pmin(NULL, 1:3)# now ok
pmax(pi, NULL, 2:4)

x <- c(1, NA, NA, 4, 5)
y <- c(2, NA, 4, NA, 3)
pmin(x, y)
stopifnot(identical(pmin(x, y), pmin(y, x)))
pmin(x, y, na.rm=TRUE)
stopifnot(identical(pmin(x, y, na.rm=TRUE), pmin(y, x, na.rm=TRUE)))
pmax(x, y)
stopifnot(identical(pmax(x, y), pmax(y, x)))
pmax(x, y, na.rm=TRUE)
stopifnot(identical(pmax(x, y, na.rm=TRUE), pmax(y, x, na.rm=TRUE)))

x <- as.integer(x); y <- as.integer(y)
pmin(x, y)
stopifnot(identical(pmin(x, y), pmin(y, x)))
pmin(x, y, na.rm=TRUE)
stopifnot(identical(pmin(x, y, na.rm=TRUE), pmin(y, x, na.rm=TRUE)))
pmax(x, y)
stopifnot(identical(pmax(x, y), pmax(y, x)))
pmax(x, y, na.rm=TRUE)
stopifnot(identical(pmax(x, y, na.rm=TRUE), pmax(y, x, na.rm=TRUE)))

x <- as.character(x); y <- as.character(y)
pmin(x, y)
stopifnot(identical(pmin(x, y), pmin(y, x)))
pmin(x, y, na.rm=TRUE)
stopifnot(identical(pmin(x, y, na.rm=TRUE), pmin(y, x, na.rm=TRUE)))
pmax(x, y)
stopifnot(identical(pmax(x, y), pmax(y, x)))
pmax(x, y, na.rm=TRUE)
stopifnot(identical(pmax(x, y, na.rm=TRUE), pmax(y, x, na.rm=TRUE)))

# tests of classed quantities
x <- .leap.seconds[1:23]; y <- rev(x)
x[2] <- y[2] <- x[3] <- y[4] <- NA
format(pmin(x, y), tz="GMT")  # TZ names differ by platform
class(pmin(x, y))
stopifnot(identical(pmin(x, y), pmin(y, x)))
format(pmin(x, y, na.rm=TRUE), tz="GMT")
stopifnot(identical(pmin(x, y, na.rm=TRUE), pmin(y, x, na.rm=TRUE)))
format(pmax(x, y), tz="GMT")
stopifnot(identical(pmax(x, y), pmax(y, x)))
format(pmax(x, y, na.rm=TRUE), tz="GMT")
stopifnot(identical(pmax(x, y, na.rm=TRUE), pmax(y, x, na.rm=TRUE)))

x <- as.POSIXlt(x, tz="GMT"); y <- as.POSIXlt(y, tz="GMT")
format(pmin(x, y), tz="GMT")
class(pmin(x, y))
stopifnot(identical(pmin(x, y), pmin(y, x)))
format(pmin(x, y, na.rm=TRUE), tz="GMT")
stopifnot(identical(pmin(x, y, na.rm=TRUE), pmin(y, x, na.rm=TRUE)))
format(pmax(x, y), tz="GMT")
stopifnot(identical(pmax(x, y), pmax(y, x)))
format(pmax(x, y, na.rm=TRUE), tz="GMT")
stopifnot(identical(pmax(x, y, na.rm=TRUE), pmax(y, x, na.rm=TRUE)))
## regresion tests


## regression tests on names of 1D arrays
x <- as.array(1:3)
names(x) <- letters[x] # sets dimnames, really
names(x)
dimnames(x)
attributes(x)
names(x) <- NULL
attr(x, "names") <- LETTERS[x] # sets dimnames, really
names(x)
dimnames(x)
attributes(x)
## regression tests


## regression tests on NA attribute names
x <- 1:3
attr(x, "NA") <- 4
attributes(x)
attr(x, "NA")
attr(x, NA_character_)
try(attr(x, NA_character_) <- 5)
## prior to 2.5.0 NA was treated as "NA"


## qr with pivoting (PR#9623)
A <- matrix(c(0,0,0, 1,1,1), nrow = 3,
            dimnames = list(letters[1:3], c("zero","one")))
y <- matrix(c(6,7,8), nrow = 3, dimnames = list(LETTERS[1:3], "y"))
qr.coef(qr(A), y)
qr.fitted(qr(A), y)

qr.coef(qr(matrix(0:1, 1, dimnames=list(NULL, c("zero","one")))), 5)
## coef names were returned unpivoted <= 2.5.0

## readChar read extra items, terminated on zeros
x <- as.raw(65:74)
readChar(x, nchar=c(3,3,0,3,3,3))
f <- tempfile()
writeChar("ABCDEFGHIJ", con=f, eos=NULL)
readChar(f, nchar=c(3,3,0,3,3,3))
unlink(f)
##


## corner cases for cor
set.seed(1)
X <- cbind(NA, 1:3, rnorm(3))
try(cor(X, use = "complete"))
try(cor(X, use = "complete", method="spearman"))
try(cor(X, use = "complete", method="kendall"))
cor(X, use = "pair")
cor(X, use = "pair", method="spearman")
cor(X, use = "pair", method="kendall")

X[1,1] <- 1
cor(X, use = "complete")
cor(X, use = "complete", method="spearman")
cor(X, use = "complete", method="kendall")
cor(X, use = "pair")
cor(X, use = "pair", method="spearman")
cor(X, use = "pair", method="kendall")
## not consistent in 2.6.x


## confint on rank-deficient models (in part, PR#10494)
junk <- data.frame(x = rep(1, 10L),
                   u = factor(sample(c("Y", "N"), 10, replace=TRUE)),
                   ans = rnorm(10))
fit <-  lm(ans ~ x + u, data = junk)
confint(fit)
confint.default(fit)
## Mismatch gave NA for 'u' in 2.6.1


## corrupt data frame produced by subsetting (PR#10574)
x <- data.frame(a=1:3, b=2:4)
x[,3] <- x
x
## warning during printing < 2.7.0


## format.factor used to lose dim[names] and names (PR#11512)
x <- factor(c("aa", letters[-1]))
dim(x) <- c(13,2)
format(x, justify="right")
##


## removing columns in within (PR#1131)
abc <- data.frame(a=1:5, b=2:6, c=3:7)
within(abc, b<-NULL)
within(abc,{d<-a+7;b<-NULL})
within(abc,{a<-a+7;b<-NULL})
## Second produced corrupt data frame in 2.7.1


## aggregate on an empty data frame (PR#13167)
z <- data.frame(a=integer(0), b=numeric(0))
try(aggregate(z, by=z[1], FUN=sum))
## failed in unlist in 2.8.0, now gives explicit message.
aggregate(data.frame(a=1:10)[F], list(rep(1:2, each=5)), sum)
## used to fail obscurely.


## subsetting data frames with duplicate rows
z <- data.frame(a=1, a=2, b=3, check.names=FALSE)
z[] # OK
z[1, ]
## had row names a, a.1, b in 2.8.0.


## incorrect warning due to lack of fuzz.
TS <-  ts(co2[1:192], freq=24)
tmp2 <- window(TS, start(TS), end(TS))
## warned in 2.8.0

## failed to add tag
Call <- call("foo", 1)
Call[["bar"]] <- 2
Call
## unnamed call in 2.8.1

options(keep.source = TRUE)
## $<- on pairlists failed to duplicate (from Felix Andrews,
## https://stat.ethz.ch/pipermail/r-devel/2009-January/051698.html)
foo <- function(given = NULL) {
    callObj <- quote(callFunc())
    if(!is.null(given)) callObj$given <- given
    if (is.null(given)) callObj$default <- TRUE
    callObj
}

foo()
foo(given = TRUE)
foo("blah blah")
foo(given = TRUE)
foo()
## altered foo() in 2.8.1.

## Using  '#' flag in  sprintf():
forms <- c("%#7.5g","%#5.f", "%#7x", "%#5d", "%#9.0e")
nums <- list(-3.145, -31,   0xabc,  -123L, 123456)
rbind(mapply(sprintf, forms,               nums),
      mapply(sprintf, sub("#", '', forms), nums))
## gave an error in pre-release versions of 2.9.0

## (auto)printing of functions {with / without source attribute},
## including primitives
sink(con <- textConnection("of", "w")) ; c ; sink(NULL); close(con)
of2 <- capture.output(print(c))
stopifnot(identical(of2, of),
          identical(of2, "function (...)  .Primitive(\"c\")"))
## ^^ would have failed up to R 2.9.x
foo
print(foo, useSource = FALSE)
attr(foo, "srcref") <- NULL
foo
(f <- structure(function(){}, note = "just a note",
                yada = function() "not the same"))
print(f, useSource = FALSE) # must print attributes
print.function <- function(x, ...) { str(x,...); invisible(x) }
print.function
f
rm(print.function)
## auto-printing and printing differed up to R 2.9.x

printCoefmat(cbind(0,1))
## would print NaN up to R 2.9.0


## continuity correction for Kendall's tau.  Improves this example.
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "kendall",
         exact = TRUE)
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "kendall",
         exact = FALSE)
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "kendall",
         exact = FALSE, continuity = TRUE)
# and a little for Spearman's
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "spearman",
         exact = TRUE)
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "spearman",
         exact = FALSE)
cor.test(c(1, 2, 3, 4, 5), c(8, 6, 7, 5, 3), method = "spearman",
         exact = FALSE, continuity = TRUE)
## Kendall case is wish of PR#13691


## corrupt data frame, PR#13724
foo <- matrix(1:12, nrow = 3)
bar <- as.data.frame(foo)
val <- integer(0)
try(bar$NewCol <- val)
# similar, not in the report
try(bar[["NewCol"]] <- val)
# [ ] is tricker, so just check the result is reasonable and prints
bar["NewCol"] <- val
bar[, "NewCol2"] <- val
bar[FALSE, "NewCol3"] <- val
bar
## Succeeded but gave corrupt result in 2.9.0


## Printing NA_complex_
m22 <- matrix(list(NA_complex_, 3, "A string", NA_complex_), 2,2)
print(m22)
print(m22, na.print="<missing value>")
## used uninitialized variable in C, noticably Windows, for R <= 2.9.0


## non-standard variable names in update etc
## never guaranteed to work, requested by Sundar Dorai-Raj in
## https://stat.ethz.ch/pipermail/r-devel/2009-July/054184.html
update(`a: b` ~ x, ~ . + y)
## 2.9.1 dropped backticks


## print(ls.str(.)) did evaluate calls
E <- new.env(); E$cl <- call("print", "Boo !")
ls.str(E)
## 2.10.0 did print..


## complete.cases with no input
try(complete.cases())
try(complete.cases(list(), list()))
## gave unhelpful messages in 2.10.0, silly results in pre-2.10.1


## error messages from (C-level) evalList
tst <- function(y) { stopifnot(is.numeric(y)); y+ 1 }
try(tst()) # even nicer since R 3.5.0's change to sequential stopifnot()
try(c(1,,2))
## change in 2.8.0 made these less clear


## empty levels from cut.Date (cosmetic, PR#14162)
x <- as.Date(c("2009-03-21","2009-03-31"))
cut(x, breaks= "quarter") # had two levels in 2.10.1
cut(as.POSIXlt(x), breaks= "quarter")
## remove empty final level


## tests of error conditions in switch()
switch("a", a=, b=, c=, 4)
switch("a", a=, b=, c=, )
.Last.value
switch("a", a=, b=, c=, invisible(4))
.Last.value
## visiblilty changed in 2.11.0


## rounding error in aggregate.ts
## https://stat.ethz.ch/pipermail/r-devel/2010-April/057225.html
x <- rep(6:10, 1:5)
aggregate(as.ts(x), FUN = mean, ndeltat = 5)
x <- rep(6:10, 1:5)
aggregate(as.ts(x), FUN = mean, nfrequency = 0.2)
## platform-dependent in 2.10.1


## wish of PR#9574
a <- c(0.1, 0.3, 0.4, 0.5, 0.3, 0.0001)
format.pval(a, eps=0.01)
format.pval(a, eps=0.01, nsmall =2)
## granted in 2.12.0


## printing fractional dates
as.Date(0.5, origin="1969-12-31")
## changed to round down in 2.12.1


## printing data frames with  ""  colnames
dfr <- data.frame(x=1:6, CC=11:16, f = gl(3,2)); colnames(dfr)[2] <- ""
dfr
## now prints the same as data.matrix(dfr) does here


## format(., zero.print) --> prettyNum()
set.seed(9); m <- matrix(local({x <- rnorm(40)
                                sign(x)*round(exp(2*x))/10}), 8,5)
noquote(format(m, zero.print= "."))
## used to print  ". 0" instead of ".  "


## tests of NA having precedence over NaN -- all must print "NA"
min(c(NaN, NA))
min(c(NA, NaN)) # NaN in 2.12.2
min(NaN, NA_real_)  # NaN in 2.12.2
min(NA_real_, NaN)
max(c(NaN, NA))
max(c(NA, NaN))  # NaN in 2.12.2
max(NaN, NA_real_)  # NaN in 2.12.2
max(NA_real_, NaN)
## might depend on compiler < 2.13.0


## PR#14514
# Data are from Conover, "Nonparametric Statistics", 3rd Ed, p. 197,
# re-arranged to make a lower-tail test the issue of relevance:  we
# want to see if pregnant nurses exposed to nitrous oxide have higher
# rates of miscarriage, stratifying on the type of nurse.
Nitrous <- array(c(32,210,8,26,18,21,3,3,7,75,0,10), dim = c(2,2,3),
                 dimnames = list(c("Exposed","NotExposed"),
                 c("FullTerm","Miscarriage"),
                 c("DentalAsst","OperRoomNurse","OutpatientNurse")))
mantelhaen.test(Nitrous, exact=TRUE, alternative="less")
mantelhaen.test(Nitrous, exact=FALSE, alternative="less")
## exact = FALSE gave the wrong tail in 2.12.2.


## scan(strip.white=TRUE) could strip trailing (but not leading) space
## inside quoted strings.
writeLines(' "  A  "; "B" ;"C";" D ";"E ";  F  ;G  ', "foo")
cat(readLines("foo"), sep = "\n")
scan('foo', list(""), sep=";")[[1]]
scan('foo', "", sep=";")
scan('foo', list(""), sep=";", strip.white = TRUE)[[1]]
scan('foo', "", sep=";", strip.white = TRUE)
unlink('foo')

writeLines(' "  A  "\n "B" \n"C"\n" D "\n"E "\n  F  \nG  ', "foo2")
scan('foo2', "")
scan('foo2', "", strip.white=TRUE) # documented to be ignored ...
unlink('foo2')
## Changed for 2.13.0, found when investigating non-bug PR#14522.


## PR#14488: missing values in rank correlations
set.seed(1)
x <- runif(10)
y <- runif(10)
x[3] <- NA; y[5] <- NA
xy <- cbind(x, y)

cor(x, y, method = "spearman", use = "complete.obs")
cor(x, y, method = "spearman", use = "pairwise.complete.obs")
cor(na.omit(xy),  method = "spearman", use = "complete.obs")
cor(xy,  method = "spearman", use = "complete.obs")
cor(xy,  method = "spearman", use = "pairwise.complete.obs")
## inconsistent in R < 2.13.0


## integer overflow in rowsum() went undetected
# https://stat.ethz.ch/pipermail/r-devel/2011-March/060304.html
x <- 2e9L
rowsum(c(x, x), c("a", "a"))
rowsum(data.frame(z = c(x, x)), c("a", "a"))
## overflow in R < 2.13.0.


## method dispatch in [[.data.frame:
## https://stat.ethz.ch/pipermail/r-devel/2011-April/060409.html
d <- data.frame(num = 1:4,
          fac = factor(letters[11:14], levels = letters[1:15]),
          date = as.Date("2011-04-01") + (0:3),
          pv = package_version(c("1.2-3", "4.5", "6.7", "8.9-10")))
for (i in seq_along(d)) print(d[[1, i]])
## did not dispatch in R < 2.14.0


## some tests of 24:00 as midnight
as.POSIXlt("2011-05-16 24:00:00", tz = "GMT")
as.POSIXlt("2010-01-31 24:00:00", tz = "GMT")
as.POSIXlt("2011-02-28 24:00:00", tz = "GMT")
as.POSIXlt("2008-02-28 24:00:00", tz = "GMT")
as.POSIXlt("2008-02-29 24:00:00", tz = "GMT")
as.POSIXlt("2010-12-31 24:00:00", tz = "GMT")
## new in 2.14.0


## Unwarranted conversion of logical values
try(double(FALSE))
x <- 1:3
try(length(x) <- TRUE)
## coerced to integer in 2.13.x


## filter(recursive = TRUE) on input with NAs
# https://stat.ethz.ch/pipermail/r-devel/2011-July/061547.html
x <- c(1:4, NA, 6:9)
cbind(x, "1"=filter(x, 0.5, method="recursive"),
         "2"=filter(x, c(0.5, 0.0), method="recursive"),
         "3"=filter(x, c(0.5, 0.0, 0.0), method="recursive"))
## NAs in wrong place in R <= 2.13.1.


## PR#14679.  Format depends if TZ is set.
x <- as.POSIXlt(c("2010-02-27 22:30:33", "2009-08-09 06:01:03",
                  "2010-07-23 17:29:59"))
stopifnot(!is.na(trunc(x, units = "days")[1:3]))
## gave NAs after the first in R < 2.13.2


## explicit error message for silly input (tol = 0)
aa <- c(1, 2, 3, 8, 8, 8, 8, 8, 8, 8, 8, 8, 12, 13, 14)
try(smooth.spline(aa, seq_along(aa)))
fit <- smooth.spline(aa, seq_along(aa), tol = 0.1)
# actual output is too unstable to diff.
## Better message from R 2.14.2


## PR#14840
d <- data.frame(x = 1:9,
                y = 1:9 + 0.1*c(1, 2, -1, 0, 1, 1000, 0, 1, -1),
                w = c(1, 0.5, 2, 1, 2, 0, 1, 2, 1))
fit <- lm(y ~ x, data=d, weights=w)
summary(fit)
## issue is how the 5-number summary is labelled
## (also seen in example(case.names))


## is.unsorted got it backwards for dataframes of more than one column
## it is supposed to look for violations of x[2] > x[1], x[3] > x[2], etc.
is.unsorted(data.frame(x=2:1))
is.unsorted(data.frame(x=1:2, y=3:4))
is.unsorted(data.frame(x=3:4, y=1:2))
## R < 2.15.1 got these as FALSE, TRUE, FALSE.


library("methods")# (not needed here)
assertError <- tools::assertError
assertError( getMethod(ls, "bar", fdef=ls), verbose=TRUE)
assertError( getMethod(show, "bar"), verbose=TRUE)
## R < 2.15.1 gave
##   cannot coerce type 'closure' to vector of type 'character'


## corner cases for array
# allowed, gave non-array in 2.15.x
try(array(1, integer()))
# if no dims, an error to supply dimnames
try(array(1, integer(), list(1, 2)))
##


## is.na() on an empty dataframe (PR#14059)
DF <- data.frame(row.names=1:3)
is.na(DF); str(.Last.value)
is.na(DF[FALSE, ]); str(.Last.value)
## first failed in R 2.15.1, second gave NULL


## split() with dots in levels
df <- data.frame(x = rep(c("a", "a.b"), 3L), y = rep(c("b.c", "c"), 3L),
                 z = 1:6)
df
split(df, df[, 1:2]) # default is sep = "."
split(df, df[, 1:2], sep = ":")
##


## The difference between sort.list and order
z <- c(4L, NA, 2L, 3L, NA, 1L)
order(z, na.last = NA)
sort.list(z, na.last = NA)
sort.list(z, na.last = NA, method = "shell")
sort.list(z, na.last = NA, method = "quick")
sort.list(z, na.last = NA, method = "radix")
## Differences first documented in R 2.15.2


## PR#15028: names longer than cutoff NB (= 1000)
NB <- 1000
lns <- capture.output(
    setNames(c(255, 1000, 30000),
             c(paste(rep.int("a", NB+2), collapse=""),
               paste(rep.int("b", NB+2), collapse=""),
               paste(rep.int("c", NB+2), collapse=""))))
sub("^ +", '', lns[2* 1:3])
## *values* were cutoff when printed


## allows deparse limits to be set
form <- reallylongnamey ~ reallylongnamex0 + reallylongnamex1 + reallylongnamex2 + reallylongnamex3
form
op <- options(deparse.cutoff=80)
form
options(deparse.cutoff=50)
form
options(op)
## fixed to 60 in R 2.15.x


## PR#15179: user defined binary ops were not deparsed properly
quote( `%^%`(x, `%^%`(y,z)) )
quote( `%^%`(x) )
##


## Anonymous function calls were not deparsed properly
substitute(f(x), list(f = function(x) x + 1))
substitute(f(x), list(f = quote(function(x) x + 1)))
substitute(f(x), list(f = quote(f+g)))
substitute(f(x), list(f = quote(base::mean)))
substitute(f(x), list(f = quote(a[n])))
substitute(f(x), list(f = quote(g(y))))
## The first three need parens, the last three don't.


## PR#15247 : str() on invalid data frame names (where print() works):
d <- data.frame(1:3, "B", 4); names(d) <- c("A", "B\xba","C\xabcd")
str(d)
## gave an error in R <= 3.0.0


## PR#15299 : adding a simple vector to a classed object produced a bad result:
1:2 + table(1:2)
## Printed the class attribute in R <= 3.0.0


## PR#15311 : regmatches<- mishandled regexpr results.
  x <- c('1', 'B', '3')
  m <- regexpr('\\d', x)
  regmatches(x, m) <- c('A', 'C')
  print(x)
## Gave a warning and a wrong result up to 3.0.1


## Bad warning found by Radford Neal
  saveopt <- options(warnPartialMatchDollar=TRUE)
  pl <- pairlist(abc=1, def=2)
  pl$ab
  if (!is.null(saveopt[["warnPartialMatchDollar"]])) options(saveopt)
## 'abc' was just ''


## seq() with NaN etc inputs now gives explicit error messages
try(seq(NaN))
try(seq(to = NaN))
try(seq(NaN, NaN))
try(seq.int(NaN))
try(seq.int(to = NaN))
try(seq.int(NaN, NaN))
## R 3.0.1 gave messages from ':' or about negative-length vectors.


## Some dimnames were lost from 1D arrays: PR#15301
x <- array(0:2, dim=3, dimnames=list(d1=LETTERS[1:3]))
x
x[]
x[3:1]
x <- array(0, dimnames=list(d1="A"))
x
x[]
x[drop = FALSE]
## lost dimnames in 3.0.1


## PR#15396
load(file.path(Sys.getenv('SRCDIR'), 'arima.rda'))
(f1 <- arima(x, xreg = xreg, order = c(1,1,1), seasonal = c(1,0,1)))
(f2 <- arima(diff(x), xreg = diff(xreg), order = c(1,0,1), seasonal = c(1,0,1),
             include.mean = FALSE))
stopifnot(all.equal(coef(f1), coef(f2), tolerance = 1e-3, check.names = FALSE))
## first gave local optim in 3.0.1

## all.equal always checked the names
x <- c(a=1, b=2)
y <- c(a=1, d=2)
all.equal(x, y, check.names = FALSE)
## failed on mismatched attributes


## PR#15411, plus digits change
format(9992, digits = 3)
format(9996, digits = 3)
format(0.0002, digits = 0, nsmall = 2)
format(pi*10, digits = 0, nsmall = 1)
## second added an extra space; 3rd and 4th were not allowed.

## and one branch of this was wrong:
xx <- c(-86870268, 107833358, 302536985, 481015309, 675718935, 854197259,
        1016450281, 1178703303, 1324731023, 1454533441)
xx
## dropped spaces without long doubles

## and rounding was being detected improperly (PR#15583)
1000* ((10^(1/4)) ^ c(0:4))
7/0.07
## Spacing was incorrect


## PR#15468
M <- matrix(11:14, ncol=2, dimnames=list(paste0("Row", 1:2), paste0("Col",
1:2)))
L <- list(elem1=1, elem2=2)
rbind(M, L)
rbind(L, M)
cbind(M, L)
cbind(L, M)
## lost the dim of M, so returned NULL entries


## NA_character_ was not handled properly in min and max (reported by Magnus Thor Torfason)
str(min(NA, "bla"))
str(min("bla", NA))
str(min(NA_character_, "bla"))
str(max(NA, "bla"))
str(max("bla", NA))
str(max(NA_character_, "bla"))
## NA_character_ could be treated as "NA"; depending on the locale, it would not necessarily
## be the min or max.


## When two entries needed to be cut to width, str() mixed up
## the values (reported by Gerrit Eichner)
oldopts <- options(width=70, stringsAsFactors=TRUE)
n <- 11      # number of rows of data frame
M <- 10000   # order of magnitude of numerical values
longer.char.string <- "zjtvorkmoydsepnxkabmeondrjaanutjmfxlgzmrbjp"
X <- data.frame( A = 1:n * M,
                 B = rep( longer.char.string, n))
str( X, strict.width = "cut")
options(oldopts)
## The first row of the str() result was duplicated.


## PR15624: rounding in extreme cases
dpois(2^52,1,1)
dpois(2^52+1,1,1)
## second warned in R 3.0.2.


## Example from PR15625
f <- file.path(Sys.getenv('SRCDIR'), 'EmbeddedNuls.csv')
## This is a file with a UTF-8 BOM and some fields which are a single nul.
## The output does rely on this being run in a non-UTF-8 locale (C in tests).
read.csv(f) # warns
read.csv(f, skipNul = TRUE, fileEncoding = "UTF-8-BOM")
## 'skipNul' is new in 3.1.0.  Should not warn on BOM, ignore in second.


## all.equal datetime method
x <- Sys.time()
all.equal(x,x)
all.equal(x, as.POSIXlt(x))
all.equal(x, as.POSIXlt(x, tz = "EST5EDT"))
all.equal(x, x+1e-4)
isTRUE(all.equal(x, x+0.002)) # message will depend on representation error
## as.POSIXt method is new in 3.1.0.



## Misuse of PR#15633
try(bartlett.test(yield ~ block*N, data = npk))
try(fligner.test (yield ~ block*N, data = npk))
## used the first factor with an incorrect description in R < 3.0.3


## Misguided expectation of PR#15687
xx <- window(AirPassengers, start = 1960)
cbind(xx, xx)
op <- options(digits = 2)
cbind(xx, xx)
options(op)
## 'digits' was applied to the time.


## Related to PR#15190
difftime(
    as.POSIXct(c("1970-01-01 00:00:00", "1970-01-01 12:00:00"), tz="EST5EDT"),
    as.POSIXct(c("1970-01-01 00:00:00", "1970-01-01 00:00:00"), tz="UTC"))
## kept tzone from first arg.


## PR#15706
x1 <- as.dendrogram(hclust(dist(c(i=1,ii=2,iii=3,v=5,vi=6,vii=7))))
attr(cophenetic(x1), "Labels")
## gave a matrix in 3.0.3


## PR#15708
aa <- anova( lm(sr ~ ., data = LifeCycleSavings) )
op <- options(width = 50)
aa
options(width = 40)
aa ; options(op)
## did not line wrap "Signif. codes" previously


## PR#15718
d <- data.frame(a=1)
d[integer(), "a"] <- 2
## warned in 3.0.3.


## PR#15781
options(foo = 1)
print(options(foo = NULL))
## printed wrong value in 3.1.0


## getParseData bug reported by Andrew Redd
raw <- "
function( a   # parameter 1
         , b=2 # parameter 2
         ){a+b}"
p <- parse(text = raw)
getParseData(p)
## Got some parents wrong


## wish of PR#15819
set.seed(123); x <- runif(10); y <- rnorm(10)
op <- options(OutDec = ",")
fit <- lm(y ~ x)
summary(fit)
options(op)
## those parts using formatC still used a decimal point.


## Printing a list with "bad" component names
L <- list(`a\\b` = 1, `a\\c` = 2, `a\bc` = "backspace")
setClass("foo", representation(`\\C` = "numeric"))
## the next three all print correctly:
names(L)
unlist(L)
as.pairlist(L)
cat(names(L), "\n")# yes, backspace is backspace here
L
new("foo")
## the last two lines printed wrongly in R <= 3.1.1


## Printing of arrays where last dim(.) == 0 :
r <- matrix(,0,4, dimnames=list(Row=NULL, Col=paste0("c",1:4)))
r
t(r) # did not print "Row", "Col"
A <- array(dim=3:0, dimnames=list(D1=c("a","b","c"), D2=c("X","Y"), D3="I", D4=NULL))
A ## did not print *anything*
A[,,"I",] # ditto
A[,,0,]   # ditto
aperm(A, c(3:1,4))   # ditto
aperm(A, c(1:2, 4:3))# ditto
unname(A)            # ditto
format(A[,,1,])	     # ditto
aperm(A, 4:1) # was ok, is unchanged
## sometimes not printing anything in R <= 3.1.1


## Printing objects with very long names cut off literal values (PR#15999)
make_long_name <- function(n)
{
  paste0(rep("a", n), collapse = "")
}
setNames(TRUE, make_long_name(1000))  # value printed as TRU
setNames(TRUE, make_long_name(1002))  # value printed as T
setNames(TRUE, make_long_name(1003))  # value not printed
##


## PR#16437
dd <- data.frame(F = factor(rep(c("A","B","C"), each = 3)), num = 1:9)
cs <- list(F = contr.sum(3, contrasts = FALSE))
a1 <- aov(num ~ F, data = dd, contrasts = cs)
model.tables(a1, "means")
t1 <- TukeyHSD(a1) ## don't print to avoid precision issues.
a2 <- aov(num ~ 0+F, data = dd, contrasts = cs)
model.tables(a2, "means")
t2 <- TukeyHSD(a2)
attr(t1, "orig.call") <- attr(t2, "orig.call")
stopifnot(all.equal(t1, t2))
## functions both failed on a2 in R <= 3.2.2.


## deparse() did not add parens before [
substitute(a[1], list(a = quote(x * y)))
## should be (x * y)[1], was x * y[1]
# Check all levels of precedence
# (Comment out illegal ones)
quote(`$`(a :: b, c))
# quote(`::`(a $ b, c $ d))
quote(`[`(a $ b, c $ d))
quote(`$`(a[b], c))
quote(`^`(a[b], c[d]))
quote(`[`(a ^ b, c ^ d))
quote(`-`(a ^ b))
quote(`^`(-b, -d))
quote(`:`(-b, -d))
quote(`-`(a : b))
quote(`%in%`(a : b, c : d))
quote(`:`(a %in% b, c %in% d))
quote(`*`(a %in% b, c %in% d))
quote(`%in%`(a * b, c * d))
quote(`+`(a * b, c * d))
quote(`*`(a + b, c + d))
quote(`<`(a + b, c + d))
quote(`+`(a < b, c < d))
quote(`!`(a < b))
quote(`<`(!b, !d))
quote(`&`(!b, !d))
quote(`!`(a & b))
quote(`|`(a & b, c & d))
quote(`&`(a | b, c | d))
quote(`~`(a | b, c | d))
quote(`|`(a ~ b, c ~ d))
quote(`->`(a ~ b, d))
quote(`~`(a -> b, c -> d))
quote(`<-`(a, c -> d))
quote(`->`(a <- b, c))
quote(`=`(a, c <- d))
quote(`<-`(a, `=`(c, d)))
quote(`?`(`=`(a, b), `=`(c, d)))
quote(`=`(a, c ? d))
quote(`?`(a = b))
quote(`=`(b, ?d))

## dput() quoted the empty symbol (PR#16686)
a <- alist(one = 1, two = )
dput(a)
## deparsed two to quote()

## Deparsing of repeated unary operators; the first 3 were "always" ok:
quote(~~x)
quote(++x)
quote(--x)
quote(!!x) # was `!(!x)`
quote(??x) # Suboptimal
quote(~+-!?x) # ditto: ....`?`(x)
## `!` no longer produces parentheses now


## summary.data.frame() with NAs in columns of class "Date" -- PR#16709
x <- c(18000000, 18810924, 19091227, 19027233, 19310526, 19691228, NA)
x.Date <- as.Date(as.character(x), format = "%Y%m%d")
summary(x.Date)
DF.Dates <- data.frame(c1 = x.Date)
summary(DF.Dates) ## NA's missing from output :
DF.Dates$x1 <- 1:7
summary(DF.Dates) ## NA's still missing
DF.Dates$x2 <- c(1:6, NA)
## now, NA's show fine:
summary(DF.Dates)
## 2 of 4  summary(.) above did not show NA's  in R <= 3.2.3


## Printing complex matrix
matrix(1i,2,13)
## Spacing was wrong in R <= 3.2.4


E <- expression(poly = x^3 - 3 * x^2)
str(E)
## no longer shows "structure(...., .Names = ..)"


## summary(<logical>) working via table():
logi <- c(NA, logical(3), NA, !logical(2), NA)
summary(logi)
summary(logi[!is.na(logi)])
summary(TRUE)
## was always showing counts for NA's even when 0 in  2.8.0 <= R <= 3.3.1
ii <- as.integer(logi)
summary(ii)
summary(ii[!is.na(ii)])
summary(1L)


## str.default() for "AsIs" arrays
str(I(m <- matrix(pi*1:4, 2)))
## did look ugly (because of toString() for numbers) in R <= 3.3.1


## check automatic coercions from double to integer
##
## these should work due to coercion
sprintf("%d", 1)
sprintf("%d", NA_real_)
sprintf("%d", c(1,2))
sprintf("%d", c(1,NA))
sprintf("%d", c(NA,1))
##
## these should fail
sprintf("%d", 1.1)
sprintf("%d", c(1.1,1))
sprintf("%d", c(1,1.1))
sprintf("%d", NaN)
sprintf("%d", c(1,NaN))


## formatting of named raws:
setNames(as.raw(1:3), c("a", "bbbb", "c"))
## was quite ugly for R <= 3.4.2


## str(x) when is.vector(x) is false :
str(structure(c(a = 1, b = 2:7), color = "blue"))
## did print " atomic [1:7] ..." in R <= 3.4.x


## check stopifnot(exprs = ....)
tryCatch(stopifnot(exprs = {
  all.equal(pi, 3.1415927)
  2 < 2
  cat("Kilroy was here!\n")
  all(1:10 < 12)
  "a" < "b"
}), error = function(e) e$message) -> M ; cat("Error: ", M, "\n")

tryCatch(stopifnot(exprs = {
  all.equal(pi, 3.1415927)
  { cat("Kilroy was here!\n"); TRUE }
  pi < 3
  cat("whereas I won't be printed ...\n")
  all(1:10 < 12)
  "a" < "b"
}), error = function(e) e$message) -> M2 ; cat("Error: ", M2, "\n")

stopifnot(exprs = {
  all.equal(pi, 3.1415927)
  { cat("\nKilroy was here! ... "); TRUE }
  pi > 3
  all(1:10 < 12)
  "a" < "b"
  { cat("and I'm printed as well ...\n"); TRUE}
})
## without "{ .. }" :
stopifnot(exprs = 2 == 2)
try(stopifnot(exprs = 1 > 2))
## passing an expression object:
stopifnot(exprs = expression(2 == 2, pi < 4))
tryCatch(stopifnot(exprs = expression(
                       2 == 2,
                       { cat("\n Kilroy again .."); TRUE },
                       pi < 4,
                       0 == 1,
                       { cat("\n no way..\n"); TRUE })),
         error = function(e) e$message) -> M3
cat("Error: ", M3, "\n")
## was partly not ok for many weeks in R-devel, early 2018

