options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

# Create a "counting process" version of the simplest test data set
#
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))

test1b<- list(start= c(0, 3,  0,  0, 5,  0, 6,14,  0,  0, 10,20,30, 0),
	      stop = c(3,10, 10,  5,20,  6,14,20, 30,  10,20,30,40, 10),
	      status=c(0, 1,  0,  0, 1,  0, 0, 1,  0,   0, 0, 0, 1,  0),
	      x=     c(1, 1,  1,  1, 1,  0, 0, 0,  0,   0, 0, 0, 0,  NA),
	      id =   c(3, 3,  4,  5, 5,  6, 6, 6,  7,   1, 1, 1, 1,   2))

aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
#
#  Check out the various residuals under an Efron approximation
#
fit0 <- coxph(Surv(time, status)~ x, test1, iter=0)
fit  <- coxph(Surv(time, status) ~x, test1)
fit0b <- coxph(Surv(start, stop, status) ~ x, test1b, iter=0)
fitb  <- coxph(Surv(start, stop, status) ~x, test1b)
fitc  <- coxph(Surv(time, status) ~ offset(fit$coef*x), test1)
fitd  <- coxph(Surv(start, stop, status) ~ offset(fit$coef*x), test1b)

aeq(fit0b$coef, fit0$coef)

aeq(resid(fit0), resid(fit0b, collapse=test1b$id))
aeq(resid(fit), resid(fitb, collapse=test1b$id))
aeq(resid(fitc), resid(fitd, collapse=test1b$id))
aeq(resid(fitc), resid(fit))

aeq(resid(fit0, type='score'), resid(fit0b, type='score', collapse=test1b$id))
aeq(resid(fit, type='score'), resid(fitb, type='score', collapse=test1b$id))

aeq(resid(fit0, type='scho'), resid(fit0b, type='scho', collapse=test1b$id))
aeq(resid(fit, type='scho'), resid(fitb, type='scho', collapse=test1b$id))

# The two survivals will have different censoring times
#  nrisk, nevent, surv, and std should be the same
temp1 <- survfit(fit, list(x=1), censor=FALSE)
temp2 <- survfit(fitb, list(x=1), censor=FALSE)
all.equal(unclass(temp1)[c(3,4,6,8)], unclass(temp2)[c(3,4,6,8)])


