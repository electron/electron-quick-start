options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test out the strata capabilities
#
tol <- survreg.control()$rel.tolerance
aeq <- function(x,y,...) all.equal(as.vector(x), as.vector(y), ...)

# intercept only models
fit1 <- survreg(Surv(time, status) ~ strata(sex), lung)
fit2 <- survreg(Surv(time, status) ~ strata(sex) + sex, lung)
fit3a<- survreg(Surv(time,status) ~1, lung, subset=(sex==1))
fit3b<- survreg(Surv(time,status) ~1, lung, subset=(sex==2))

fit1
fit2
aeq(fit2$scale, c(fit3a$scale, fit3b$scale), tolerance=tol)
aeq(fit2$loglik[2], (fit3a$loglik + fit3b$loglik)[2], tolerance=tol)
aeq(fit2$coef[1] + 1:2*fit2$coef[2], c(fit3a$coef, fit3b$coef), tolerance=tol)

#penalized models
fit1 <- survreg(Surv(time, status) ~ pspline(age, theta=.92)+
                strata(sex), lung)
fit2 <- survreg(Surv(time, status) ~  pspline(age, theta=.92)+ 
		strata(sex) + sex, lung)
fit1
fit2

age1 <- ifelse(lung$sex==1, lung$age, mean(lung$age))
age2 <- ifelse(lung$sex==2, lung$age, mean(lung$age))
fit3 <- survreg(Surv(time,status) ~ pspline(age1, theta=.92) +
		pspline(age2, theta=.95) + sex + strata(sex), lung)
fit3a<- survreg(Surv(time,status) ~pspline(age, theta=.92), lung, 
		    subset=(sex==1))
fit3b<- survreg(Surv(time,status) ~pspline(age, theta=.95), lung, 
		     subset=(sex==2))
fit3b<- survreg(Surv(time,status) ~pspline(age, theta=.95),
                lung[lung$sex==2,], x=T) 
#
# The above line is tricky, and it took me a long time to realize
#  it's necessity.  The range of age1 = range(age) = 39-82.  That for
#  age2 = range of females = 41-77.  The basis functions for pspline are
#  based on age.  If I used data=lung, subset=(sex==2) in fit3b (earlier
#  form of the test, the pspline function is called before the subset
#  occurs, and fit3b has a different basis for the second spline than
#  fit3 does; leading to failure of the all.equal tests below.  A theta
#  of .95 on one basis is not exactly the same as a theta of .95 on the
#  other. Coefficients were within 1%, but not the same.  

aeq(fit3$scale, c(fit3a$scale, fit3b$scale))
aeq(fit3$loglik[2], (fit3a$loglik + fit3b$loglik)[2])
pred <- predict(fit3)
aeq(pred[lung$sex==1] , predict(fit3a))
aeq(pred[lung$sex==2],  predict(fit3b))




