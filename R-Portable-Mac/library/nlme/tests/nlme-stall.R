## Taken from https://stat.ethz.ch/pipermail/r-devel/2018-January/075459.html

## Hung with x86_64 Linux/gcc 7.3 but not i686 Linux nor x86_64 macOS
## in early 2018.  Resolved by nlme 3.1-136.

## Optional since it used to hang, on one platform only AFAWK.
## gfortran with -fbounds-check detected a problem on one x86_64
## Fedora 26 system (but not another) and on one of winbuilder's
## subarchs.
if(!nzchar(Sys.getenv("TEST-NLME-STALL"))) q('no')

dat <- data.frame(
    x = c(3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3.69, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 1.61, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -0.47, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86, -1.86),
    y = c(0.35, 0.69, 0.57, 1.48, 6.08, -0.34, 0.53, 1.66, 0.02, 4.4, 8.42, 3.3, 2.32, -2.3, 7.52, -2.12, 3.41, -4.76, 7.9, 5.04, 10.26, -1.42, 7.85, -1.88, 3.81, -2.59, 4.32, 5.7, 1.18,  -1.74, 1.81, 6.16, 4.2, -0.39, 1.55, -1.4, 1.76, -4.14, -2.36, -0.24, 4.8, -7.07, 1.34, 1.98, 0.86, -3.96, -0.61, 2.68, -1.65, -2.06, 3.67, -0.19, 2.33, 3.78, 2.16, 0.35,  -5.6, 1.32, 2.99, 4.21, -0.9, 4.32, -4.01, 2.03, 0.9, -0.74, -5.78, 5.76, 0.52, 1.37, -0.9, -4.06, -0.49, -2.39, -2.67, -0.71, -0.4, 2.55, 0.97, 1.96, 8.13, -5.93, 4.01, 0.79,  -5.61, 0.29, 4.92, -2.89, -3.24, -3.06, -0.23, 0.71, 0.75, 4.6, 1.35, -3.35),
    f.block = rep(1:4, 24),
    id = paste0("a", rep(c(2,1,3), each = 4)))

dd <- dat
set.seed(33)
dd$y <- dat$y + rnorm(nrow(dat), mean = 0, sd = 0.1)

library(nlme)
fpl.B.range <- function(lx,A,B,C,D) A/(1+exp(-B*(lx-C))) + D


INIT <- c(A.a1=1, A.a2=0, A.a3=0,
          B = 1,  B.a2=0, B.a3=0,
          C = 0,  C.a2=0, C.a3=0,
          D = 1,  D.a2=0, D.a3=0)

## Typically this will fail with a singularity, but it should not hang.
try(nlme(y ~ fpl.B.range(x,A,B,C,D), data = dd,
         fixed = list(A ~ id, B ~ id, C ~ id, D ~ id),
         random = list(f.block = pdSymm(A+B+C+D ~ 1)),
         start = INIT,
#     control= nlmeControl(## NB: msMaxIter=200, ## gives singularity error at iter.55
#         msVerbose=TRUE), #==> passed as 'trace' to nlminb()
         verbose = TRUE)) -> res

## it stalls, I need to kill the R process
## --  [on lynne Fedora 26 (4.14.11-200.fc26.x86_64), Jan.2018]
## in R 3.4.3 and R 3.4.3 patched with nlme 3.1.131
##                    and R-devel with nlme 3.1.135
