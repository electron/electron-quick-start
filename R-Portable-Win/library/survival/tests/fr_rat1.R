options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

# Tests using the rats data
#
#  (Female rats, from Mantel et al, Cancer Research 37,
#    3863-3868, November 77)

rfit <- coxph(Surv(time,status) ~ rx + frailty(litter), rats,
	     method='breslow', subset= (sex=='f'))
names(rfit)
rfit

rfit$iter
rfit$df
rfit$history[[1]]

rfit1 <- coxph(Surv(time,status) ~ rx + frailty(litter, theta=1), rats,
	     method='breslow', subset=(sex=="f"))
rfit1

rfit2 <- coxph(Surv(time,status) ~ frailty(litter), rats, subset=(sex=='f'))
rfit2
