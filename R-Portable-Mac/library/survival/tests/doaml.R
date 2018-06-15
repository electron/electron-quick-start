options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
#
# These results can be found in Miller
#
fit <- coxph(Surv(aml$time, aml$status) ~ aml$x, method='breslow')
fit
resid(fit, type='mart')
resid(fit, type='score')
resid(fit, type='scho')

# Test the drop of an itercept: should have no effect
fit2 <- coxph(Surv(time, status) ~ x -1, method='breslow',
                   data=aml)
aeq(fit$loglik, fit2$loglik)
aeq(coef(fit), coef(fit2))
aeq(fit$var, fit2$var)

fit <- survfit(Surv(aml$time, aml$status) ~ aml$x)
fit
summary(fit)
survdiff(Surv(aml$time, aml$status)~ aml$x)

#
# Test out the weighted K-M
#
#  First, equal case weights- shouldn't change the survival, but will
#    halve the variance
temp2 <-survfit(Surv(aml$time, aml$status)~1, type='kaplan', weight=rep(2,23))
temp  <-survfit(Surv(time, status)~1, aml)
aeq(temp$surv, temp2$surv)
aeq(temp$std.err^2, 2*temp2$std.err^2)

# Risk weights-- use a null Cox model
tfit <- coxph(Surv(aml$time, aml$status) ~ offset(log(1:23)))
sfit <- survfit(tfit, type='aalen', censor=FALSE)

# Now compute it by hand.  The survfit program will produce a curve
#   corresponding to the mean offset.  This is a change on 7/2010,
#   which caused S(new) = S(old)^exp(mean(log(1:23))).
#  Ties are a nuisance
rscore <- exp(log(1:23) - mean(log(1:23)))[order(aml$time)]
atime <- sort(aml$time)
denom <- rev(cumsum(rev(rscore)))
denom <- denom[match(unique(atime), atime)]
deaths <- tapply(aml$status, aml$time, sum)
chaz <- cumsum(deaths/denom)
all.equal(sfit$surv, as.vector(exp(-chaz[deaths>0])))
cvar <- cumsum(deaths/denom^2)
all.equal(sfit$std^2, as.vector(cvar[deaths>0]))

# And the Efron result
summary(survfit(tfit))

# Lots of ties, so its a good test case
x1 <- coxph(Surv(time, status)~x, aml, method='efron')
x1
x2 <- coxph(Surv(rep(0,23),time, status) ~x, aml, method='efron')
aeq(x1$coef, x2$coef)


rm(x1, x2, atime, denom, deaths, chaz,cvar, tfit, sfit, temp, temp2, fit)
