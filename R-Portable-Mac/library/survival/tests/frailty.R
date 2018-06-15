library(survival)
#
# The constuction of a survival curve with sparse frailties
#
# In this case the coefficient vector is kept in two parts, the
#  fixed coefs and the (often very large) random effects coefficients
# The survfit function treats the second set of coefficients as fixed
#  values, to avoid an unmanagable variance matrix, and behaves like
#  the second fit below.

fit1 <- coxph(Surv(time, status) ~ age + frailty(inst), lung)
sfit1 <- survfit(fit1)

# A parallel model with the frailties treated as fixed offsets
offvar <- fit1$frail[as.numeric(factor(lung$inst))]
fit2 <- coxph(Surv(time, status) ~ age + offset(offvar),lung)
fit2$var <- fit1$var  #force variances to match

all.equal(fit1$coef, fit2$coef)
sfit2 <- survfit(fit2, newdata=list(age=fit1$means, offvar=0))
all.equal(sfit1$surv, sfit2$surv)
all.equal(sfit1$var, sfit2$var)
