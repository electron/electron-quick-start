####=== Numerical / Arithmetic Tests
####--- ALL tests here should return  TRUE !
###
### '##P': These lines don't give TRUE but relevant ``Print output''

### --> d-p-q-r-tests.R  for distribution things

.proctime00 <- proc.time()
opt.conformance <- 0
Meps <- .Machine $ double.eps

## this uses random inputs, so set the seed
set.seed(1)

options(rErr.eps = 1e-30)
rErr <- function(approx, true, eps = .Options$rErr.eps)
{
    if(is.null(eps)) { eps <- 1e-30; options(rErr.eps = eps) }
    ifelse(Mod(true) >= eps,
	   1 - approx / true, # relative error
	   true - approx)     # absolute error (e.g. when true=0)
}

abs(1- .Machine$double.xmin * 10^(-.Machine$double.min.exp*log10(2)))/Meps < 1e3
##P (1- .Machine$double.xmin * 10^(-.Machine$double.min.exp*log10(2)))/Meps
if(opt.conformance)#fails at least on SGI/IRIX 6.5
abs(1- .Machine$double.xmax * 10^(-.Machine$double.max.exp*log10(2)))/Meps < 1e3

## More IEEE  Infinity/NaN checks
i1 <- pi / 0
i1 == (i2 <- 1:1 / 0:0)
is.infinite( i1) & is.infinite( i2) &   i1 > 12   &   i2 > 12
is.infinite(-i1) & is.infinite(-i2) & (-i1) < -12 & (-i2) < -12

is.nan(n1 <- 0 / 0)
is.nan( - n1)

i1 ==  i1 + i1
i1 ==  i1 * i1
is.nan(i1 - i1)
is.nan(i1 / i1)

1/0 == Inf & 0 ^ -1 == Inf
1/Inf == 0 & Inf ^ -1 == 0

iNA <- as.integer(NA)
!is.na(Inf) & !is.nan(Inf) &   is.infinite(Inf) & !is.finite(Inf)
!is.na(-Inf)& !is.nan(-Inf)&   is.infinite(-Inf)& !is.finite(-Inf)
 is.na(NA)  & !is.nan(NA)  &  !is.infinite(NA)  & !is.finite(NA)
 is.na(NaN) &  is.nan(NaN) &  !is.infinite(NaN) & !is.finite(NaN)
 is.na(iNA) & !is.nan(iNA) &  !is.infinite(iNA) & !is.finite(iNA)

## These are "double"s:
all(!is.nan(c(1.,NA)))
all(c(FALSE,TRUE,FALSE) == is.nan(c   (1.,NaN,NA)))
## lists are no longer allowed
## all(c(FALSE,TRUE,FALSE) == is.nan(list(1.,NaN,NA)))


##  log() and "pow()" -- POSIX is not specific enough..
log(0) == -Inf
is.nan(log(-1))# TRUE and warning

rp <- c(1:2,Inf); rn <- rev(- rp)
r <- c(rn, 0, rp, NA, NaN)
all(r^0 == 1)
ir <- suppressWarnings(as.integer(r))
all(ir^0  == 1)
all(ir^0L == 1)# not in R <= 2.15.0
all( 1^r  == 1)# not in R 0.64
all(1L^r  == 1)
all(1L^ir == 1)# not in R <= 2.15.0
all((rn ^ -3) == -((-rn) ^ -3))
#
all(c(1.1,2,Inf) ^ Inf == Inf)
all(c(1.1,2,Inf) ^ -Inf == 0)
.9 ^ Inf == 0
.9 ^ -Inf == Inf
## Wasn't ok in 0.64:
all(is.nan(rn ^ .5))# in some C's : (-Inf) ^ .5 gives Inf, instead of NaN


## Real Trig.:
cos(0) == 1
sin(3*pi/2) == cos(pi)
x <- rnorm(99)
all( sin(-x) == - sin(x))
all( cos(-x) == cos(x))

x <- 1:99/100
all(abs(1 - x / asin(sin(x))) <= 2*Meps)# "== 2*" for HP-UX
all(abs(1 - x / atan(tan(x))) <  2*Meps)

## Sun has asin(.) = acos(.) = 0 for these:
##	is.nan(acos(1.1)) && is.nan(asin(-2)) [!]

## gamma()
abs(gamma(1/2)^2 - pi) < 4* Meps
r <- rlnorm(5000) # NB random, and next has failed for some seed
all(abs(rErr(gamma(r+1), r*gamma(r))) < 500 * Meps)
## more accurate for integers n <= 50 since R 1.8.0	Sol8: perfect
n <-   20; all(		 gamma(1:n) == cumprod(c(1,1:(n-1))))# Lnx: up too n=28
n <-   50; all(abs(rErr( gamma(1:n), cumprod(c(1,1:(n-1))))) < 20*Meps)#Lnx: f=2
n <-  120; all(abs(rErr( gamma(1:n), cumprod(c(1,1:(n-1))))) < 1000*Meps)
n <- 10000;all(abs(rErr(lgamma(1:n),cumsum(log(c(1,1:(n-1)))))) < 100*Meps)

n <-   10; all(		 gamma(1:n) == cumprod(c(1,1:(n-1))))
n <-   20; all(abs(rErr( gamma(1:n), cumprod(c(1,1:(n-1))))) < 100*Meps)
n <-  120; all(abs(rErr( gamma(1:n), cumprod(c(1,1:(n-1))))) < 1000*Meps)
n <- 10000;all(abs(rErr(lgamma(1:n),cumsum(log(c(1,1:(n-1)))))) < 100*Meps)

all(is.nan(gamma(0:-47))) # + warn.

## choose() {and lchoose}:
n51 <- c(196793068630200, 229591913401900, 247959266474052)
abs(c(n51, rev(n51))- choose(51, 23:28)) <= 2
all(choose(0:4,2) == c(0,0,1,3,6))
## 3 to 8 units off and two NaN's in 1.8.1

## psi[gamma](x) and derivatives:
## psi == digamma:
gEuler <- 0.577215664901532860606512# = Euler's gamma
abs(digamma(1) + gEuler) <   32*Meps # i386 Lx: = 2.5*Meps
all.equal(digamma(1) - digamma(1/2), log(4), tolerance = 32*Meps)# Linux: < 1*Meps!
n <- 1:12
all.equal(digamma(n),
         - gEuler + c(0, cumsum(1/n)[-length(n)]),tolerance = 32*Meps)#i386 Lx: 1.3 Meps
all.equal(digamma(n + 1/2),
          - gEuler - log(4) + 2*cumsum(1/(2*n-1)),tolerance = 32*Meps)#i386 Lx: 1.8 Meps
## higher psigamma:
all.equal(psigamma(1, deriv=c(1,3,5)),
          pi^(2*(1:3)) * c(1/6, 1/15, 8/63), tolerance = 32*Meps)
x <- c(-100,-3:2, -99.9, -7.7, seq(-3,3, length=61), 5.1, 77)
## Intel icc showed a < 1ulp difference in the second.
stopifnot(all.equal( digamma(x), psigamma(x,0), tolerance = 2*Meps),
          all.equal(trigamma(x), psigamma(x,1), tolerance = 2*Meps))# TRUE (+ NaN warnings)
## very large x:
x <- 1e30 ^ (1:10)
a.relE <- function(appr, true) abs(1 - appr/true)
stopifnot(a.relE(digamma(x),   log(x)) < 1e-13,
          a.relE(trigamma(x),     1/x) < 1e-13)
x <- sqrt(x[2:6]); stopifnot(a.relE(psigamma(x,2), - 1/x^2) < 1e-13)
x <- 10^(10*(2:6));stopifnot(a.relE(psigamma(x,5), +24/x^5) < 1e-13)

## fft():
ok <- TRUE
##test EXTENSIVELY:	for(N in 1:100) {
    cat(".")
    for(n in c(1:30, 1000:1050)) {
	x <- rnorm(n)
	er <- Mod(rErr(fft(fft(x), inverse = TRUE)/n, x*(1+0i)))
	n.ok <- all(er < 1e-8) & quantile(er, 0.95, names=FALSE) < 10000*Meps
	if(!n.ok) cat("\nn=",n,": quantile(rErr, c(.95,1)) =",
		      formatC(quantile(er, prob= c(.95,1))),"\n")
	ok <- ok & n.ok
    }
    cat("\n")
##test EXTENSIVELY:	}
ok

## var():
for(n in 2:10)
    print(all.equal(n*(n-1)*var(diag(n)),
		    matrix(c(rep(c(n-1,rep(-1,n)),n-1), n-1), nr=n, nc=n),
		    tolerance = 20*Meps)) # use tolerance = 0 to see rel.error

## pmin() & pmax() -- "attributes" !
v1 <- c(a=2)
m1 <- cbind(  2:4,3)
m2 <- cbind(a=2:4,2)

all( pmax(v1, 1:3) == pmax(1:3, v1) & pmax(1:3, v1) == c(2,2,3))
all( pmin(v1, 1:3) == pmin(1:3, v1) & pmin(1:3, v1) == c(1,2,2))

oo <- options(warn = -1)# These four lines each would give 3-4 warnings :
 all( pmax(m1, 1:7) == pmax(1:7, m1) & pmax(1:7, m1) == c(2:4,4:7))
 all( pmin(m1, 1:7) == pmin(1:7, m1) & pmin(1:7, m1) == c(1:3,3,3,3,2))
 all( pmax(m2, 1:7) == pmax(1:7, m2) & pmax(1:7, m2) == pmax(1:7, m1))
 all( pmin(m2, 1:7) == pmin(1:7, m2) & pmin(1:7, m2) == c(1:3,2,2,2,2))
options(oo)

## pretty()
stopifnot(pretty(1:15)	    == seq(0,16, by=2),
	  pretty(1:15, h=2) == seq(0,15, by=5),
	  pretty(1)	    == 0:1,
	  pretty(pi)	    == c(2,4),
	  pretty(pi, n=6)   == 2:4,
	  pretty(pi, n=10)  == 2:5,
	  pretty(pi, shr=.1)== c(3, 3.5))

## gave infinite loop [R 0.64; Solaris], seealso PR#390 :
all(pretty((1-1e-5)*c(1,1+3*Meps), 7) == seq(0,1,len=3))

n <- 1000
x12 <- matrix(NA, 2,n); x12[,1] <- c(2.8,3) # Bug PR#673
for(j in 1:2) x12[j, -1] <- round(rnorm(n-1), dig = rpois(n-1, lam=3.5) - 2)
for(i in 1:n) {
    lp <- length(p <- pretty(x <- sort(x12[,i])))
    stopifnot(p[1] <= x[1] & x[2] <= p[lp],
              all(x==0) || all.equal(p, rev(-pretty(-x)), tolerance = 10*Meps))
}

## PR#741:
pi != (pi0 <- pi + 2*.Machine$double.eps)
is.na(match(c(1,pi,pi0), pi)[3])

## PR#749:
all(is.na(c(NA && TRUE, TRUE  && NA, NA && NA,
            NA || FALSE,FALSE || NA, NA || NA)))

all((c(NA || TRUE,  TRUE || NA,
    !c(NA && FALSE,FALSE && NA))))


## not sure what the point of this is: it gives mean(numeric(0)), that is NaN
(z <- mean(rep(NA_real_, 2), trim = .1, na.rm = TRUE))
is.na(z)

## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')
