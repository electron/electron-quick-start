options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

lfit2 <- survreg(Surv(time, status) ~ age + ph.ecog + strata(sex), lung)
lfit3 <- survreg(Surv(time, status) ~ sex + (age+ph.ecog)*strata(sex), lung)

lfit4 <-  survreg(Surv(time, status) ~ age + ph.ecog , lung,
		  subset=(sex==1))
lfit5 <- survreg(Surv(time, status) ~ age + ph.ecog , lung,
		  subset=(sex==2))

if (exists('censorReg')) {
    lfit1 <- censorReg(censor(time, status) ~ age + ph.ecog + strata(sex),lung)
    aeq(lfit4$coef, lfit1[[1]]$coef)
    aeq(lfit4$scale, lfit1[[1]]$scale)
    aeq(c(lfit4$scale, lfit5$scale), sapply(lfit1, function(x) x$scale))
    }
aeq(c(lfit4$scale, lfit5$scale), lfit3$scale )

#
# Test out ridge regression and splines
#
lfit0 <- survreg(Surv(time, status) ~1, lung)
lfit1 <- survreg(Surv(time, status) ~ age + ridge(ph.ecog, theta=5), lung)
lfit2 <- survreg(Surv(time, status) ~ sex + ridge(age, ph.ecog, theta=1), lung)
lfit3 <- survreg(Surv(time, status) ~ sex + age + ph.ecog, lung)

lfit0
lfit1
lfit2
lfit3


xx <- pspline(lung$age, nterm=3, theta=.3)
xx <- matrix(unclass(xx), ncol=ncol(xx))   # the raw matrix
lfit4 <- survreg(Surv(time, status) ~xx, lung)
lfit5 <- survreg(Surv(time, status) ~age, lung)

lfit6 <- survreg(Surv(time, status)~pspline(age, df=2), lung)

lfit7 <- survreg(Surv(time, status) ~ offset(lfit6$lin), lung)

lfit4
lfit5
lfit6
signif(lfit7$coef,6)
