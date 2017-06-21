options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Verify that scale can be fixed at a value
#    coefs will differ slightly due to different iteration paths
tol <- .001

# Intercept only models
fit1 <- survreg(Surv(time,status) ~ 1, lung)
fit2 <- survreg(Surv(time,status) ~ 1, lung, scale=fit1$scale)
all.equal(fit1$coef, fit2$coef, tolerance= tol)
all.equal(fit1$loglik, fit2$loglik, tolerance= tol)

# The two robust variance matrices are not the same, since removing
#   an obs has a different effect on the two models.  This just
#   checks for failure, not for correctness
fit3 <- survreg(Surv(time,status) ~ 1, lung, robust=TRUE)
fit4 <- survreg(Surv(time,status) ~ 1, lung, scale=fit1$scale, robust=TRUE)


# multiple covariates
fit1 <- survreg(Surv(time,status) ~ age + ph.karno, lung)
fit2 <- survreg(Surv(time,status) ~ age + ph.karno, lung,
		scale=fit1$scale)
all.equal(fit1$coef, fit2$coef, tolerance=tol)
all.equal(fit1$loglik[2], fit2$loglik[2], tolerance=tol)

fit3 <- survreg(Surv(time,status) ~ age + ph.karno, lung, robust=TRUE)
fit4 <- survreg(Surv(time,status) ~ age + ph.karno, lung, 
                scale=fit1$scale, robust=TRUE)

# penalized models
fit1 <- survreg(Surv(time, status) ~ pspline(age), lung)
fit2 <- survreg(Surv(time, status) ~ pspline(age), lung, scale=fit1$scale)
all.equal(fit1$coef, fit2$coef, tolerance=tol)
all.equal(fit1$loglik[2], fit2$loglik[2], tolerance=tol)

fit3 <- survreg(Surv(time,status) ~ pspline(age) + ph.karno, lung, robust=TRUE)
fit4 <- survreg(Surv(time,status) ~ pspline(age) + ph.karno, lung, 
                scale=fit1$scale, robust=TRUE)


