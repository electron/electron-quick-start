## some tests of inverse-gaussian GLMs based on a file supplied by
## David Firth, Feb 2009.

options(digits=5)
have_MASS <- requireNamespace('MASS', quietly = TRUE)

##  Data from Whitmore, G A (1986), Inverse Gaussian Ratio Estimation.
##  Applied Statistics 35(1), 8-15.
##
##  A "real, but disguised" set of data (Whitmore, 1986, p8).
##
##  For each of 20 products, x is projected sales and y is actual sales.

x <- c(5959, 3534, 2641, 1965, 1738, 1182, 667, 613, 610, 549,
       527, 353, 331, 290, 253, 193, 156, 133, 122, 114)
y <- c(5673, 3659, 2565, 2182, 1839, 1236, 918, 902, 756, 500,
       487, 463, 225, 257, 311, 212, 166, 123, 198, 99)

## Whitmore's model (2.4) is

fit <- glm(y ~ x - 1, weights = x^2,
           family = inverse.gaussian(link = "identity"),
           epsilon = 1e-12)
fit
coef(summary(fit))
##  Alternatively, use the explicit formula that's available for the MLE
##  in this example.  It's just a ratio estimate:
(beta.exact <- sum(y)/sum(x))
stopifnot(all.equal(beta.exact, as.vector(coef(fit))))
## and for a confidence interval via confint
if(have_MASS) {
    ci <- confint(fit, 1, level = 0.95)
    print(ci)
}
## and via asymptotic normality
sterr <- coef(summary(fit))[, "Std. Error"]
coef(fit) + (1.96 * sterr * c(-1, 1))

## David suggested the use of an inverse link

fit2 <- glm(y ~ I(1/x) - 1, weights = x^2,
            family = inverse.gaussian(link = "inverse"),
            epsilon = 1e-12)
coef(summary(fit2))
## which gives the same CIs both ways
if(have_MASS) {
    ci1 <- rev(1/(confint(fit2, 1, level = 0.95)))
    print(ci1)
    sterr <- (summary(fit2)$coefficients)[, "Std. Error"]
    ci2 <- 1/(coef(fit2) - (1.96 * sterr * c(-1, 1)))
    print(ci2)
    stopifnot(all.equal(as.vector(ci), as.vector(ci1), tolerance = 1e-5),
              all.equal(as.vector(ci), ci2, tolerance = 1e-3))
}
##  because the log likelihood for 1/beta is exactly quadratic.

##  The approximate intervals above differ slightly from the exact
##  confidence interval given in Whitmore (1986) -- as is to be
##  expected (they are based on asymptotic approximations, not the
##  exact pivot).


## Now simulate from this model
if(requireNamespace("SuppDists")) {
    print( ys <- simulate(fit, nsim = 3, seed = 1) )
    for(i in seq_len(3))
        print(coef(summary(update(fit, ys[, i] ~ .))))
}
