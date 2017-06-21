## a quick check on vcov for fitdistr (from 7.3-6/7)

library(MASS)

options(digits=4)
set.seed(1)
x <- rnorm(100)
fit <- fitdistr(x, "normal")
fit
vcov(fit)

x <- rlnorm(100)
fit <- fitdistr(x, "lognormal")
fit
vcov(fit)

x <- rpois(100, 4.5)
fit <- fitdistr(x, "poisson")
fit
vcov(fit)

x <- rexp(100, 13)
fit <- fitdistr(x, "exponential")
fit
vcov(fit)

x <- rgeom(100, 0.25)
fit <- fitdistr(x, "geometric")
fit
vcov(fit)
