options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Simple test of (start, stop] Kaplan-Meier curves, using the test2 data
#   set
#
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))
test2 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0) )
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

fit1 <- survfit(Surv(start, stop, event) ~1, test2, type='fh2',
                error='tsiatis')
fit2 <- survfit(Surv(start, stop, event) ~x, test2, start.time=3,
		type='fh2')

cfit1<- survfit(coxph(Surv(start, stop, event)~1, test2))
cfit2<- survfit(coxph(Surv(start, stop, event) ~ strata(x), test2, subset=-1))

deaths <- (fit1$n.event + fit1$n.censor)>0
aeq(fit1$time[deaths], cfit1$time)
aeq(fit1$n.risk[deaths], cfit1$n.risk)
aeq(fit1$n.event[deaths], cfit1$n.event)
aeq(fit1$surv[deaths], cfit1$surv)
aeq(fit1$std.err[deaths], cfit1$std.err)

deaths <- (fit2$n.event + fit2$n.censor)>0
aeq(fit2$time[deaths], cfit2$time)
aeq(fit2$n.risk[deaths], cfit2$n.risk)
aeq(fit2$n.event[deaths], cfit2$n.event)
aeq(fit2$surv[deaths], cfit2$surv)

fit3 <- survfit(Surv(start, stop, event) ~1, test2) #Kaplan-Meier
aeq(fit3$n, 10)
aeq(fit3$time, c(1:9,14,17))
aeq(fit3$n.risk, c(0,2,3,3,4,5,4,4,5,2,1))
aeq(fit3$n.event,c(0,1,1,0,0,1,1,1,2,0,0))
aeq(fit3$surv[fit3$n.event>0], c(.5, 1/3, 4/15, 1/5, 3/20, 9/100))
#
#  Verify that both surv AND n.risk are right between time points.
#
fit <- survfit(Surv(time, status) ~1, test1)
temp <- summary(fit, time=c(.5,1, 1.5, 6, 7.5, 8, 8.9, 9, 10), extend=TRUE)

aeq(temp$n.risk, c(6,6,4,4,2,2,1,1,0))
aeq(temp$surv, c(1, fit$surv[c(1,1,2,2,3,3,4,4)]))
aeq(temp$n.event, c(0,1,0,2,0,0,0,1,0))
aeq(temp$std.err, c(0, (fit$surv*fit$std.err)[c(1,1,2,2,3,3,4,4)]))


fit <- survfit(Surv(start, stop, event) ~1, test2)
temp <- summary(fit, times=c(.5, 1.5, 2.5, 3, 6.5, 14.5, 16.5))
aeq(temp$surv, c(1, fit$surv[c(1,2,3,6, 10,10)]))
aeq(temp$n.risk, c(0, 2, 3, 3, 4, 1,1))
