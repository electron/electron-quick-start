library(survival)
#
# Check out the Dory&Korn confidence interval option
#
tdata <- data.frame(time= 1:10,
                    status=c(1,0,1,0,1,0,0,0,1,0))

fit1 <- survfit(Surv(time, status) ~1, tdata, conf.lower='modified')
fit2 <- survfit(Surv(time, status) ~1, tdata)

stdlow <- fit2$std * sqrt(c(1, 10/9, 1, 8/7, 1, 6/5, 6/4, 6/3, 1, 2/1))
lower <- exp(log(fit2$surv) - qnorm(.975)*stdlow)
all.equal(fit1$lower, lower, check.attributes=FALSE)
