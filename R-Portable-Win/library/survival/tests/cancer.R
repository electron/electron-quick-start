options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test out all of the routines on a more complex data set
#
temp <- survfit(Surv(time, status) ~ ph.ecog, lung)
summary(temp, times=c(30*1:11, 365*1:3))
print(temp[2:3])

temp <- survfit(Surv(time, status)~1, lung, type='fleming',
		   conf.int=.9, conf.type='log-log', error='tsiatis')
summary(temp, times=30 *1:5)

temp <- survdiff(Surv(time, status) ~ inst, lung, rho=.5)
print(temp, digits=6)

temp <- coxph(Surv(time, status) ~ ph.ecog + ph.karno + pat.karno + wt.loss 
	      + sex + age + meal.cal + strata(inst), lung)
summary(temp)
cox.zph(temp)
cox.zph(temp, transform='identity')

coxph(Surv(rep(0,length(time)), time, status) ~ ph.ecog + ph.karno + pat.karno
		+ wt.loss + sex + age + meal.cal + strata(inst), lung)

#
# Tests of using "."
#
fit1 <- coxph(Surv(time, status) ~ . - meal.cal - wt.loss - inst, lung)
fit2 <- update(fit1, .~. - ph.karno)
fit3 <- coxph(Surv(time, status) ~ age + sex + ph.ecog + pat.karno, lung)
all.equal(fit2, fit3)
