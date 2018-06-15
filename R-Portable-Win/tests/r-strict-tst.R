#### Strict "regression" (no output comparison) tests
#### or  [R]andom number generating functions

options(warn = 2)# warnings are errors here

## For integer valued comparisons
all.eq0 <- function(x,y, ...) all.equal(x,y, tolerance = 0, ...)

###------- Discrete Distributions ----------------

set.seed(17)
stopifnot(
    all.eq0(rhyper(100, 3024, 27466, 251),
	    c(25, 24, 21, 31, 25, 33, 28, 28, 27, 37, 26, 31, 27, 22, 21,
	      33, 22, 32, 27, 28, 29, 22, 20, 20, 21, 18, 23, 21, 26, 22, 28,
	      24, 25, 16, 38, 26, 35, 24, 28, 26, 21, 15, 19, 24, 26, 21, 28,
	      21, 27, 27, 24, 31, 22, 18, 27, 24, 28, 22, 25, 19, 29, 31, 27,
	      24, 26, 26, 24, 23, 20, 23, 23, 26, 22, 36, 29, 32, 23, 25, 20,
	      12, 36, 29, 28, 23, 24, 26, 29, 25, 28, 18, 18, 27, 24, 18, 22,
	      32, 31, 23, 26, 23))
   ,
    all.eq0(rhyper(100,  329, 3059, 225),
	    c(21, 21, 17, 21, 15, 25, 24, 15, 27, 21, 18, 22, 29, 17, 18,
	      19, 32, 23, 23, 22, 20, 20, 15, 23, 19, 25, 25, 18, 17, 17, 19,
	      28, 17, 20, 21, 21, 20, 17, 25, 21, 21, 15, 25, 25, 15, 21, 26,
	      14, 21, 23, 21, 14, 15, 24, 23, 21, 20, 20, 20, 24, 16, 21, 25,
	      30, 17, 19, 22, 19, 22, 23, 19, 20, 18, 15, 21, 12, 24, 20, 14,
	      20, 25, 22, 19, 23, 14, 19, 15, 23, 23, 15, 23, 26, 32, 23, 25,
	      19, 23, 18, 24, 25))
    ,
    ## using  branch II  in ../src/nmath/rhyper.c :
    print(ct3 <- system.time(N <- rhyper(100, 8000, 1e9-8000, 1e6))[1]) < 0.02
    ,
    all.eq0(N, c(11, 9, 7, 4, 8, 6, 10, 5, 9, 8, 10, 5, 8, 8, 4, 10, 9, 8, 7,
		 9, 11, 5, 7, 9, 8, 8, 5, 5, 10, 7, 8, 5, 4, 11, 9, 7, 8, 6, 7,
		 9, 14, 9, 8, 8, 8, 4, 12, 9, 8, 11, 10, 12, 9, 13, 13, 8, 8,
		 10, 9, 4, 7, 9, 11, 2, 5, 8, 7, 8, 11, 8, 6, 8, 6, 3, 4, 12,
		 8, 10, 9, 6, 3, 6, 7, 10, 7, 4, 5, 8, 10, 8, 7, 11, 8, 12, 4,
		 9, 5, 9, 7, 11))
)


N <- 1e10; m <- 1e5; n <- N-m; k <- 1e6
n /.Machine$integer.max ## 4.66
p <- m/N; q <- 1 - p
cat(sprintf(
   "N = n+m = %g, m = Np = %g; k = %g ==> (p,f) = (m,k)/N = (%g, %g)\n k*p*q = %.4g > 1: %s\n",
    N, m, k, m/N, k/N, k*p*q, k*p*q > 1))
set.seed(11)
rH <- rhyper(20, m=m, n=n, k=k) # now via qhyper() - may change!
stopifnot( is.finite(rH), 3 <= rH, rH <= 24) # allow slack for change
## gave all NA_integer_ in R < 3.3.0


stopifnot(identical(rgamma(1, Inf), Inf),
	  identical(rgamma(1, 0, 0), 0))
## gave NaN in R <= 3.3.0
