library(survival)

#
# The survival code was failing for certain data sets when called as
#    survfit(Surv(time2-time1, status) ~ ......
# The issue was how tied floating point numbers are handled, and the
#    fact that unique(x), factor(x) and tapply(x) are not guarranteed to
#    all be the same.  
# This test fails in survival 2.36-5, fixed in 2.36-6.  Data sets that
#    can cause it are few and far between.
#

load('ties.rda')
x <- time2 -time1

#  Here is the heart of the old problem
#       length(unique(x))== length(table(x))
#  And the prior fix which worked ALMOST always
#       x <- round(x, 15)
#       length(unique(round(x,15)))== length(table(round(x,15)))

fit1 <- survfit(Surv(x) ~1)
length(fit1$time) == length(fit1$surv)


# a second test, once "rounding.R"

tdata <- data.frame(time=c(1,2, sqrt(2)^2, 2, sqrt(2)^2),
                    status=rep(1,5), 
                    group=c(1,1,1,2,2))
fit <- survfit(Surv(time, status) ~ group, data=tdata)

all.equal(sum(fit$strata), length(fit$time))
