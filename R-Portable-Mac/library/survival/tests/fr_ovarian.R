options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test on the ovarian data

fit1 <- coxph(Surv(futime, fustat) ~ rx + age, ovarian)
fit2 <- coxph(Surv(futime, fustat) ~ rx + pspline(age, df=2), 
		data=ovarian)
fit2$iter

fit2$df

fit2$history

fit4 <- coxph(Surv(futime, fustat) ~ rx + pspline(age, df=4), 
		data=ovarian)
fit4


