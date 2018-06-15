library(survival)
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
options(na.action=na.exclude)
#
# More tests of factors in prediction, using a new data set
#
fit <- coxph(Surv(time, status) ~  factor(ph.ecog), lung)

tdata <- data.frame(ph.ecog = factor(0:3))
p1 <- predict(fit, newdata=tdata, type='lp')
p2 <- predict(fit, type='lp')
aeq(p1, p2[match(0:3, lung$ph.ecog)])

fit2 <- coxph(Surv(time, status) ~ factor(ph.ecog) + factor(sex), lung)
tdata <- expand.grid(ph.ecog = factor(0:3), sex=factor(1:2))
p1 <- predict(fit2, newdata=tdata, type='risk')

xdata <- expand.grid(ph.ecog=factor(1:3), sex=factor(1:2))
p2 <- predict(fit2, newdata=xdata, type='risk')
all.equal(p2, p1[c(2:4, 6:8)], check.attributes=FALSE)


fit3 <- survreg(Surv(time, status) ~ factor(ph.ecog) + age, lung)
tdata <- data.frame(ph.ecog=factor(0:3), age=50)
predict(fit, type='lp', newdata=tdata)
predict(fit3, type='lp', newdata=tdata)
