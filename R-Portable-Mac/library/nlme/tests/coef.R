## tests of fix for PR#9831
library(nlme)
val <- c("10"=1.10,"14"=1.14)
vf <- varIdent(value=val, form=~1|age, fixed=c("12"=1.12))
vfi <- Initialize(vf,Orthodont)
vfi
str(vfi)
stopifnot(
    all.equal(coef(vfi), c(0.0953101798043, 0.131028262406)),
    all.equal(coef(vfi, unconstrained = FALSE, allCoef = TRUE),
              c("8" = 1, "10" = 1.1, "14" = 1.14, "12" = 1.12)))

vfiCopy <- vfi        # copy of an initialized object
length(vfiCopy)             # length is 2
coef(vfiCopy) <- c(11,12)   # error in 3.1-84
stopifnot(identical(coef(vfiCopy), c(11,12)))

## error in 3.1-84
(gls. <- gls(distance ~ age, weights = vfi, data=Orthodont))
