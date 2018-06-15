library(survival)
#
# Test of the clogit function, and indirectly of the exact option
#
# Data set logan has the occupation of fathers, we create a 
#  multinomial response
#
nresp <- length(levels(logan$occupation))
n <- nrow(logan)
indx <- rep(1:n, nresp)
logan2 <- data.frame(logan[indx,],
                     id = indx,
                     occ2 = factor(rep(levels(logan$occupation), each=n)))
logan2$y <- (logan2$occupation == logan2$occ2)

#We expect two NA coefficients, so ignore the warning
fit1 <- clogit(y ~ occ2 + occ2:education + occ2:race + strata(id), logan2)

#since there is only one death per group, all methods are equal
dummy <- rep(1, nrow(logan2))
fit2 <- coxph(Surv(dummy, y) ~ occ2 + occ2:education + occ2:race + strata(id),
                   logan2, method='breslow')

all.equal(fit1$coef, fit2$coef)
all.equal(fit1$loglik, fit2$loglik)
all.equal(fit1$var, fit2$var)
all.equal(fit1$resid, fit2$resid)

