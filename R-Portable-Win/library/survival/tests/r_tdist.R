options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test out the t-distribution
#

capacitor <- read.table('data.capacitor', row.names=1,
			col.names=c('', 'days', 'event', 'voltage'))
# First, a t-dist with 500 df should be nearly identical to the Gaussian

fitig <- survreg(Surv(days, event)~voltage, 
        dist = "gaussian", data = capacitor)
fit1 <- survreg(Surv(days, event) ~ voltage,
		 dist='t', parms=500, capacitor)
fitig
summary(fit1, corr=F)

# A more realistic fit
fit2 <- survreg(Surv(days, event) ~ voltage,
		 dist='t', parms=5, capacitor)
print(fit2)

xx <- seq(1,125, by=10)
resid(fit2, type='response')[xx]
resid(fit2, type='deviance')[xx]
resid(fit2, type='working') [xx]
resid(fit2, type='dfbeta')[xx,]
resid(fit2, type='dfbetas')[xx,]
resid(fit2, type='ldresp')[xx]
resid(fit2, type='ldshape')[xx]
resid(fit2, type='ldcase')[xx]
resid(fit2, type='matrix')[xx,]

predict(fit2, type='response')[xx]
predict(fit2, type='link')[xx]
predict(fit2, type='terms')[xx,]
predict(fit2, type='quantile')[xx]

rm(fitig, fit1, fit2, xx)
