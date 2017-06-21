library(survival)
options(na.action=na.exclude, contrasts=c('contr.treatment', 'contr.poly'))

# Verify stratified fits in a simple way, but combining two data
#  sets and doing a single fit
#
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

tdata <- data.frame(time=c(lung$time, ovarian$futime),
                    status=c(lung$status-1, ovarian$fustat),
                    group =rep(0:1, c(nrow(lung), nrow(ovarian))))
fit1 <- survreg(Surv(time, status) ~ 1, lung)
fit2 <- survreg(Surv(futime, fustat) ~ 1, ovarian)
fit3 <- survreg(Surv(time, status) ~ group + strata(group), tdata)

aeq(c(fit1$coef, fit2$coef-fit1$coef), fit3$coef)
aeq(c(fit1$scale, fit2$scale), fit3$scale)
aeq(fit1$loglik[2] + fit2$loglik[2], fit3$loglik[2])

#
# Test out the cluster term in survreg, which means first a test
#  of the dfbeta residuals
# I also am checking that missing values propogate
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))
fit1 <- survreg(Surv(time, status) ~ x + cluster(1:7), test1)

db1 <- resid(fit1, 'dfbeta')
ijack <-db1
eps <- 1e-7
for (i in 1:7) {
    temp <- rep(1.0,7)
    temp[i] <- 1-eps
    tfit <- survreg(Surv(time, status) ~ x, test1, weight=temp)
    ijack[i,] <- c(tfit$coef, log(tfit$scale)) 
    }
ijack[2,] <- NA  # stick the NA back in
ijack <- (rep(c(fit1$coef, log(fit1$scale)), each=nrow(db1)) - ijack)/eps
all.equal(db1, ijack, tolerance=eps)
all.equal(t(db1[-2,])%*% db1[-2,], fit1$var)

# This is a harder test since there are multiple strata and multiple 
#  obs/subject.  Use of enum + strata(enum) in essenence fits a different
#  baseline Weibull to each strata, with common coefficients for rx, size, and
#  number.
fit1 <- survreg(Surv(stop-start, event) ~  rx + size + number + 
                factor(enum) + strata(enum), data=bladder2)

db1 <- resid(fit1, type='dfbeta', collapse=bladder2$id)
ijack <- db1  # a matrix of the same size
for (i in 1:nrow(db1)) {
    twt <- rep(1., nrow(bladder2))
    twt[bladder2$id==i] <- 1-eps
    tfit <- survreg(Surv(stop-start, event) ~ rx + size + number + 
                    factor(enum) + strata(enum), data=bladder2, 
                    weight=twt)
    ijack[i,] <- c(coef(tfit), log(tfit$scale)) 
    }
ijack <- (rep(c(fit1$coef, log(fit1$scale)), each=nrow(db1)) - ijack)/eps
all.equal(db1, ijack, tolerance=eps*2)

