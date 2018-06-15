options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

capacitor <- read.table('data.capacitor', row.names=1,
			col.names=c('', 'days', 'event', 'voltage'))

fitig <- survreg(Surv(days, event)~voltage, 
	dist = "gaussian", data = capacitor)
summary(fitig)

fitix <- survreg(Surv(days, event)~voltage, 
	dist = "extreme", data = capacitor)
summary(fitix)

fitil <- survreg(Surv(days, event)~voltage, 
	dist = "logistic", data = capacitor)
summary(fitil)
