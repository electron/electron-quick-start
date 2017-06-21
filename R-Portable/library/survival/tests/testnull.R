options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# A test of  NULL models
#
fit1 <- coxph(Surv(stop, event) ~ rx + strata(number), bladder, iter=0)
fit2 <- coxph(Surv(stop, event) ~ strata(number), bladder)

all.equal(fit1$loglik[2], fit2$loglik)
all.equal(fit1$resid, fit2$resid)


fit1 <- coxph(Surv(start, stop, event) ~ rx + strata(number), bladder2, iter=0)
fit2 <- coxph(Surv(start, stop, event) ~ strata(number), bladder2)

all.equal(fit1$loglik[2], fit2$loglik)
all.equal(fit1$resid, fit2$resid)
