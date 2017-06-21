### Tests of complex arithemetic.

Meps <- .Machine$double.eps
## complex
z <- 0i ^ (-3:3)
stopifnot(Re(z) == 0 ^ (-3:3))


## powers, including complex ones
a <- -4:12
m <- outer(a +0i, b <- seq(-.5,2, by=.5), "^")
dimnames(m) <- list(paste(a), "^" = sapply(b,format))
round(m,3)
stopifnot(m[,as.character(0:2)] == cbind(1,a,a*a),
                                        # latter were only approximate
          all.equal(unname(m[,"0.5"]),
                    sqrt(abs(a))*ifelse(a < 0, 1i, 1),
                    tolerance = 20*Meps))

## 2.10.0-2.12.1 got z^n wrong in the !HAVE_C99_COMPLEX case
z <- 0.2853725+0.3927816i
z2 <- z^(1:20)
z3 <- z^-(1:20)
z0 <- cumprod(rep(z, 20))
stopifnot(all.equal(z2, z0), all.equal(z3, 1/z0))
## was z^3 had value z^2 ....

## fft():
for(n in 1:30) cat("\nn=",n,":", round(fft(1:n), 8),"\n")


## polyroot():
stopifnot(abs(1 + polyroot(choose(8, 0:8))) < 1e-10)# maybe smaller..

## precision of complex numbers
signif(1.678932e80+0i, 5)
signif(1.678932e-300+0i, 5)
signif(1.678932e-302+0i, 5)
signif(1.678932e-303+0i, 5)
signif(1.678932e-304+0i, 5)
signif(1.678932e-305+0i, 5)
signif(1.678932e-306+0i, 5)
signif(1.678932e-307+0i, 5)
signif(1.678932e-308+0i, 5)
signif(1.678932-1.238276i, 5)
signif(1.678932-1.238276e-1i, 5)
signif(1.678932-1.238276e-2i, 5)
signif(1.678932-1.238276e-3i, 5)
signif(1.678932-1.238276e-4i, 5)
signif(1.678932-1.238276e-5i, 5)
signif(8.678932-9.238276i, 5)
## prior to 2.2.0 rounded real and imaginary parts separately.


## Complex Trig.:
abs(Im(cos(acos(1i))) -	 1) < 2*Meps
abs(Im(sin(asin(1i))) -	 1) < 2*Meps
##P (1 - Im(sin(asin(Ii))))/Meps
##P (1 - Im(cos(acos(Ii))))/Meps
abs(Im(asin(sin(1i))) -	 1) < 2*Meps
all.equal(cos(1i), cos(-1i)) # i.e. Im(acos(*)) gives + or - 1i:
abs(abs(Im(acos(cos(1i)))) - 1) < 4*Meps


set.seed(123) # want reproducible output
Isi <- Im(sin(asin(1i + rnorm(100))))
all(abs(Isi-1) < 100* Meps)
##P table(2*abs(Isi-1)	/ Meps)
Isi <- Im(cos(acos(1i + rnorm(100))))
all(abs(Isi-1) < 100* Meps)
##P table(2*abs(Isi-1)	/ Meps)
Isi <- Im(atan(tan(1i + rnorm(100)))) #-- tan(atan(..)) does NOT work (Math!)
all(abs(Isi-1) < 100* Meps)
##P table(2*abs(Isi-1)	/ Meps)

set.seed(123)
z <- complex(real = rnorm(100), imag = rnorm(100))
stopifnot(Mod ( 1 -  sin(z) / ( (exp(1i*z)-exp(-1i*z))/(2*1i) )) < 20 * Meps)
## end of moved from complex.Rd


## PR#7781
## This is not as given by e.g. glibc on AMD64
(z <- tan(1+1000i)) # 0+1i from R's own code.
stopifnot(is.finite(z))
##


## Branch cuts in complex inverse trig functions
atan(2)
atan(2+0i)
tan(atan(2+0i))
## should not expect exactly 0i in result
round(atan(1.0001+0i), 7)
round(atan(0.9999+0i), 7)
## previously not as in Abramowitz & Stegun.


## typo in z_atan2.
(z <- atan2(0+1i, 0+0i))
stopifnot(all.equal(z, pi/2+0i))
## was NA in 2.1.1


## Hyperbolic
x <- seq(-3, 3, len=200)
Meps <- .Machine$double.eps
stopifnot(
 Mod(cosh(x) - cos(1i*x))	< 20*Meps,
 Mod(sinh(x) - sin(1i*x)/1i)	< 20*Meps
)
## end of moved from Hyperbolic.Rd

## values near and on branch cuts
options(digits=5)
z <- c(2+0i, 2-0.0001i, -2+0i, -2+0.0001i)
asin(z)
acos(z)
atanh(z)
z <- c(0+2i, 0.0001+2i, 0-2i, -0.0001i-2i)
asinh(z)
acosh(z)
atan(z)
## According to C99, should have continuity from the side given if there
## are not signed zeros.
## Both glibc 2.12 and macOS 10.6 used continuity from above in the first set
## but they seem to assume signed zeros.
## Windows gave incorrect (NaN) values on the cuts.

stopifnot(identical(tanh(356+0i), 1+0i))
## Used to be NaN+0i on Windows

## Not a regression test, but rather one of the good cases:
(cNaN <- as.complex("NaN"))
stopifnot(identical(cNaN, complex(re = NaN)), is.nan(Re(cNaN)), Im(cNaN) == 0)
dput(cNaN) ## (real = NaN, imaginary = 0)
## Partly new behavior:
(c0NaN  <- complex(real=0, im=NaN))
(cNaNaN <- complex(re=NaN, im=NaN))
stopifnot(identical(cNaN, as.complex(NaN)),
          identical(vapply(c(cNaN, c0NaN, cNaNaN), format, ""),
                    c("NaN+0i", "0+NaNi", "NaN+NaNi")),
          identical(cNaN, NaN + 0i),
          identical(cNaN, Conj(cNaN)),
          identical(cNaN, cNaN+cNaN),

          identical(cNaNaN, 1i * NaN),
          identical(cNaNaN, complex(modulus= NaN)),
          identical(cNaNaN, complex(argument= NaN)),
          identical(cNaNaN, complex(arg=NaN, mod=NaN)),

          identical(c0NaN, c0NaN+c0NaN), # !
          ## Platform dependent, not TRUE e.g. on F21 gcc 4.9.2:
          ## identical(NA_complex_, NaN + NA_complex_ ) ,
          ## Probably TRUE, but by a standard ??
          ## identical(cNaNaN, 2 * c0NaN), # C-library arithmetic
          ## identical(cNaNaN, 2 * cNaN),  # C-library arithmetic
          ## identical(cNaNaN, NA_complex_ * Inf),
          TRUE)
