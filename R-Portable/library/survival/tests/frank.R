library(survival)
#
# Check out intercept/interaction for Frank H
#
age2 <- lung$age - 50
fit1 <- coxph(Surv(time, status) ~ age * strata(sex), lung)
fit2 <- coxph(Surv(time, status) ~ age2*strata(sex), lung)

tdata <- data.frame(age=50:60, age2=0:10, sex=c(1,2,1,2,1,2,1,2,1,2,1))

surv1 <- survfit(fit1, tdata)
surv2 <- survfit(fit2, tdata)
# The call won't match, but the rest should
icall <- match("call", names(surv1))
all.equal(unclass(surv1)[-icall], unclass(surv2)[-icall])


# It should match what I get with a single strata fit

fit3 <- coxph(Surv(time, status) ~ age, data=lung,
              init=fit1$coef[1], subset=(sex==1), iter=0)
surv1b <- survfit(fit3, newdata=list(age=c(50,52, 54)))
all.equal(c(surv1b$surv), surv1[c(1,3,5)]$surv)



