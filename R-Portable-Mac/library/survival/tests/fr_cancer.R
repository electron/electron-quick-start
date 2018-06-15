options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Here is a test case with multiple smoothing terms
#

fit0 <- coxph(Surv(time, status) ~ ph.ecog + age, lung)
fit1 <- coxph(Surv(time, status) ~ ph.ecog + pspline(age,3), lung)
fit2 <- coxph(Surv(time, status) ~ ph.ecog + pspline(age,4), lung)
fit3 <- coxph(Surv(time, status) ~ ph.ecog + pspline(age,8), lung)



fit4 <- coxph(Surv(time, status) ~ ph.ecog + pspline(wt.loss,3), lung)

fit5 <-coxph(Surv(time, status) ~ ph.ecog + pspline(age,3) + 
	     pspline(wt.loss,3), lung)

fit1
fit2
fit3
fit4
fit5

rm(fit1, fit2, fit3, fit4, fit5)
