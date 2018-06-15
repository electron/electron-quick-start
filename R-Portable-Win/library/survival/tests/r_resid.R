options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

fit1 <- survreg(Surv(futime, fustat) ~ age + ecog.ps, ovarian)
fit4 <- survreg(Surv(log(futime), fustat) ~age + ecog.ps, ovarian,
		dist='extreme')

print(fit1)
summary(fit4)		


# Hypothesis (and I'm fairly sure): censorReg shares the fault of many
#  iterative codes -- it returns the loglik and variance for iteration k
#  but the coef vector of iteration k+1.  Hence the "all.equal" tests
#  below don't come out perfect.
#
if (exists('censorReg')) {  #true for Splus, not R
    fit2 <- censorReg(censor(futime, fustat) ~ age + ecog.ps, ovarian)
    fit3 <- survreg(Surv(futime, fustat) ~ age + ecog.ps, ovarian,
		iter=0, init=c(fit2$coef,   log(fit2$scale)))

    aeq(resid(fit2, type='working')[,1], resid(fit3, type='working'))
    aeq(resid(fit2, type='response')[,1], resid(fit3, type='response'))

    temp <- sign(resid(fit3, type='working'))
    aeq(resid(fit2, type='deviance')[,1], 
	temp*abs(resid(fit3, type='deviance')))
    aeq(resid(fit2, type='deviance')[,1], resid(fit3, type='deviance'))
    }
#
# Now check fit1 and fit4, which should follow identical iteration paths
#   These tests should all be true
#
aeq(fit1$coef, fit4$coef)
 
resid(fit1, type='working')
resid(fit1, type='response')
resid(fit1, type='deviance')
resid(fit1, type='dfbeta')
resid(fit1, type='dfbetas')
resid(fit1, type='ldcase')
resid(fit1, type='ldresp')
resid(fit1, type='ldshape')
resid(fit1, type='matrix')

aeq(resid(fit1, type='working'),resid(fit4, type='working'))
#aeq(resid(fit1, type='response'), resid(fit4, type='response'))#should differ
aeq(resid(fit1, type='deviance'), resid(fit4, type='deviance'))
aeq(resid(fit1, type='dfbeta'),   resid(fit4, type='dfbeta'))
aeq(resid(fit1, type='dfbetas'),  resid(fit4, type='dfbetas'))
aeq(resid(fit1, type='ldcase'),   resid(fit4, type='ldcase'))
aeq(resid(fit1, type='ldresp'),   resid(fit4, type='ldresp'))
aeq(resid(fit1, type='ldshape'),  resid(fit4, type='ldshape'))
aeq(resid(fit1, type='matrix'),   resid(fit4, type='matrix'))
#
# Some tests of the quantile residuals
#
motor <- read.table('data.motor', col.names=c('temp', 'time', 'status'))

# These should agree exactly with Ripley and Venables' book
fit1 <- survreg(Surv(time, status) ~ temp, data=motor)
summary(fit1)

#
# The first prediction has the SE that I think is correct
#  The third is the se found in an early draft of Ripley; fit1 ignoring
#  the variation in scale estimate, except via it's impact on the
#  upper left corner of the inverse information matrix.
# Numbers 1 and 3 differ little for this dataset
#
predict(fit1, data.frame(temp=130), type='uquantile', p=c(.5, .1), se=T)

fit2 <- survreg(Surv(time, status) ~ temp, data=motor, scale=fit1$scale)
predict(fit2, data.frame(temp=130), type='uquantile', p=c(.5, .1), se=T)

fit3 <- fit2
fit3$var <- fit1$var[1:2,1:2]
predict(fit3, data.frame(temp=130), type='uquantile', p=c(.5, .1), se=T)

pp <- seq(.05, .7, length=40)
xx <- predict(fit1, data.frame(temp=130), type='uquantile', se=T,
	      p=pp)
#matplot(pp, cbind(xx$fit, xx$fit+2*xx$se, xx$fit - 2*xx$se), type='l')


#
# Now try out the various combinations of strata, #predicted, and
#  number of quantiles desired
#
fit1 <- survreg(Surv(time, status) ~ inst + strata(inst) + age + sex, lung)
qq1 <- predict(fit1, type='quantile', p=.3, se=T)
qq2 <- predict(fit1, type='quantile', p=c(.2, .3, .4), se=T)
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
aeq(qq1$fit, qq2$fit[,2])
aeq(qq1$se.fit, qq2$se.fit[,2])

qq3 <- predict(fit1, type='quantile', p=c(.2, .3, .4), se=T,
	       newdata= lung[1:5,])
aeq(qq3$fit, qq2$fit[1:5,])

qq4 <- predict(fit1, type='quantile', p=c(.2, .3, .4), se=T, newdata=lung[7,])
aeq(qq4$fit, qq2$fit[7,])

qq5 <- predict(fit1, type='quantile', p=c(.2, .3, .4), se=T, newdata=lung)
aeq(qq2$fit, qq5$fit)
aeq(qq2$se.fit, qq5$se.fit)
