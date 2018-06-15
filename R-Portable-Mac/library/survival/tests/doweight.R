options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

# Tests of the weighted Cox model
#
# Similar data set to test1, but add weights,
#                                    a double-death/censor tied time
#                                    a censored last subject
# The latter two are cases covered only feebly elsewhere.
# 
# The data set testw2 has the same data, but done via replication
#
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

testw1 <- data.frame(time=  c(1,1,2,2,2,2,3,4,5),
		    status= c(1,0,1,1,1,0,0,1,0),
		    x=      c(2,0,1,1,0,1,0,1,0),
		    wt =    c(1,2,3,4,3,2,1,2,1))
xx <- c(1,2,3,4,3,2,1,2,1)
testw2 <- data.frame(time=   rep(c(1,1,2,2,2,2,3,4,5), xx),
		     status= rep(c(1,0,1,1,1,0,0,1,0), xx),
		     x=      rep(c(2,0,1,1,0,1,0,1,0), xx),
		     id=     rep(1:9, xx))
indx <- match(1:9, testw2$id)
testw2 <- data.frame(time=   rep(c(1,1,2,2,2,2,3,4,5), xx),
		     status= rep(c(1,0,1,1,1,0,0,1,0), xx),
		     x=      rep(c(2,0,1,1,0,1,0,1,0), xx),
		     id=     rep(1:9, xx))
indx <- match(1:9, testw2$id)

fit0 <- coxph(Surv(time, status) ~x, testw1, weights=wt,
		    method='breslow', iter=0)
fit0b <- coxph(Surv(time, status) ~x, testw2, method='breslow', iter=0)
fit  <- coxph(Surv(time, status) ~x, testw1, weights=wt, method='breslow')
fitb <- coxph(Surv(time, status) ~x, testw2, method='breslow')

texp <- function(beta) {  # expected, Breslow estimate
    r <- exp(beta)
    temp <- cumsum(c(1/(r^2 + 11*r +7), 10/(11*r +5), 2/(2*r+1)))
    c(r^2, 1,r,r,1,r,1,r,1)* temp[c(1,1,2,2,2,2,2,3,3)]
    }
aeq(texp(0),  c(1/19, 1/19, rep(103/152, 5), rep(613/456,2))) #verify texp()

xbar <- function(beta) { # xbar, Breslow estimate
    r <- exp(beta)
    temp <- r* rep(c(2*r + 11, 11/10, 1), c(2, 5, 2))
    temp * texp(beta)
    }

fit0
summary(fit)
aeq(resid(fit0), testw1$status - texp(0))
resid(fit0, type='score')
resid(fit0, type='scho')

aeq(resid(fit0, type='mart'), (resid(fit0b, type='mart'))[indx])
aeq(resid(fit0, type='scor'), (resid(fit0b, type='scor'))[indx])
aeq(unique(resid(fit0, type='scho')), unique(resid(fit0b, type='scho')))


aeq(resid(fit, type='mart'), testw1$status - texp(fit$coef))
resid(fit, type='score')
resid(fit, type='scho')
aeq(resid(fit, type='mart'), (resid(fitb, type='mart'))[indx])
aeq(resid(fit, type='scor'), (resid(fitb, type='scor'))[indx])
aeq(unique(resid(fit, type='scho')), unique(resid(fitb, type='scho')))
rr1 <- resid(fit, type='mart')
rr2 <- resid(fit, type='mart', weighted=T)
aeq(rr2/rr1, testw1$wt)

rr1 <- resid(fit, type='score')
rr2 <- resid(fit, type='score', weighted=T)
aeq(rr2/rr1, testw1$wt)

fit  <- coxph(Surv(time, status) ~x, testw1, weights=wt, method='efron')
fit
resid(fit, type='mart')
resid(fit, type='score')
resid(fit, type='scho')

# Tests of the weighted Cox model, AG form of the data
#   Same solution as doweight1.s
#
testw3 <- data.frame(id  =  c( 1, 1, 2, 3, 3, 3, 4, 5, 5, 6, 7, 8, 8, 9),
		     begin= c( 0, 5, 0, 0,10,15, 0, 0,14, 0, 0, 0,23, 0),
		     time=  c( 5,10,10,10,15,20,20,14,20,20,30,23,40,50),
		    status= c( 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0),
		    x=      c( 2, 2, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0),
		    wt =    c( 1, 1, 2, 3, 3, 3, 4, 3, 3, 2, 1, 2, 2, 1))

fit0 <- coxph(Surv(begin,time, status) ~x, testw3, weights=wt,
		    method='breslow', iter=0)
fit  <- coxph(Surv(begin,time, status) ~x, testw3, weights=wt, method='breslow')
fit0
summary(fit)
resid(fit0, type='mart', collapse=testw3$id)
resid(fit0, type='score', collapse=testw3$id)
resid(fit0, type='scho')

resid(fit, type='mart', collapse=testw3$id)
resid(fit, type='score', collapse=testw3$id)
resid(fit, type='scho')
fit0 <- coxph(Surv(begin, time, status) ~x,testw3, weights=wt, iter=0)
resid(fit0, 'mart', collapse=testw3$id)
resid(coxph(Surv(begin, time, status) ~1, testw3, weights=wt)
		      , collapse=testw3$id)  #Null model

fit  <- coxph(Surv(begin,time, status) ~x, testw3, weights=wt, method='efron')
fit
resid(fit, type='mart', collapse=testw3$id)
resid(fit, type='score', collapse=testw3$id)
resid(fit, type='scho')
#
# Check out the impact of weights on the dfbetas
#    Am I computing them correctly?
#
wtemp <- rep(1,26)
wtemp[c(5,10,15)] <- 2:4
fit <- coxph(Surv(futime, fustat) ~ age + ecog.ps, ovarian, weights=wtemp)
rr <- resid(fit, 'dfbeta')

fit1 <- coxph(Surv(futime, fustat) ~ age + ecog.ps, ovarian, weights=wtemp,
	         subset=(-5))
fit2 <- coxph(Surv(futime, fustat) ~ age + ecog.ps, ovarian, weights=wtemp,
	         subset=(-10))
fit3 <- coxph(Surv(futime, fustat) ~ age + ecog.ps, ovarian, weights=wtemp,
	         subset=(-15))

#
# Effect of case weights on expected survival curves post Cox model
#
fit0  <- coxph(Surv(time, status) ~x, testw1, weights=wt, method='breslow',
	       iter=0)
fit0b <- coxph(Surv(time, status) ~x, testw2, method='breslow', iter=0)

surv1 <- survfit(fit0, newdata=list(x=0))
surv2 <- survfit(fit0b, newdata=list(x=0))
aeq(surv1$surv, surv2$surv)
#
# Check out the Efron approx. 
#

fit0 <- coxph(Surv(time, status) ~x,testw1, weights=wt, iter=0)
fit  <- coxph(Surv(time, status) ~x,testw1, weights=wt)
resid(fit0, 'mart')
resid(coxph(Surv(time, status) ~1, testw1, weights=wt))  #Null model

# lfun is the known log-likelihood for this data set, worked out in the
#   appendix of Therneau and Grambsch
# ufun is the score vector and ifun the information matrix
lfun <- function(beta) {
    r <- exp(beta)
    a <- 7*r +3
    b <- 4*r +2
    11*beta - ( log(r^2 + 11*r +7) + 
	(10/3)*(log(a+b) + log(2*a/3 +b) + log(a/3 +b)) + 2*log(2*r +1))
    }
aeq(fit0$log[1], lfun(0))
aeq(fit$log[2], lfun(fit$coef))

ufun <- function(beta, efron=T) {  #score statistic
    r <- exp(beta)
    xbar1 <- (2*r^2+11*r)/(r^2+11*r +7)
    xbar2 <- 11*r/(11*r +5)
    xbar3 <-  2*r/(2*r +1)
    xbar2b<- 26*r/(26*r+12)
    xbar2c<- 19*r/(19*r + 9)
    temp <- 11 - (xbar1 + 2*xbar3)
    if (efron) temp - (10/3)*(xbar2 + xbar2b + xbar2c)
    else       temp - 10*xbar2
    }
print(ufun(fit$coef) < 1e-4)  # Should be true

ifun <- function(beta, efron=T) {  # information matrix
    r <- exp(beta)
    xbar1 <- (2*r^2+11*r)/(r^2+11*r +7)
    xbar2 <- 11*r/(11*r +5)
    xbar3 <-  2*r/(2*r +1)
    xbar2b<- 26*r/(26*r+12)
    xbar2c<- 19*r/(19*r + 9)
    temp <- ((4*r^2 + 11*r)/(r^2+11*r +7) - xbar1^2) +
	    2*(xbar3 - xbar3^2)
    if (efron) temp + (10/3)*((xbar2- xbar2^2) + (xbar2b - xbar2b^2) +
			      (xbar2c -xbar2c^2))
    else       temp + 10 * (xbar2- xbar2^2)
    }

aeq(fit0$var, 1/ifun(0))
aeq(fit$var, 1/ifun(fit$coef))


      
# Make sure that the weights pass through the residuals correctly
rr1 <- resid(fit, type='mart')
rr2 <- resid(fit, type='mart', weighted=T)
aeq(rr2/rr1, testw1$wt)
rr1 <- resid(fit, type='score')
rr2 <- resid(fit, type='score', weighted=T)
aeq(rr2/rr1, testw1$wt)

#
# Look at the individual components
#
dt0 <- coxph.detail(fit0)
dt <- coxph.detail(fit)
aeq(sum(dt$score), ufun(fit$coef))  #score statistic
aeq(sum(dt0$score), ufun(0))
aeq(dt0$hazard, c(1/19, (10/3)*(1/16 + 1/(6+20/3) + 1/(6+10/3)), 2/3))



rm(fit, fit0, rr1, rr2, dt, dt0)
#
# Effect of weights on the robust variance
#
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0),
		    wt=    c(3,0,1,1,1,1,1),
                    id=    1:7)
testx <- data.frame(time=  c(4,4,4,1,1,2,2,3),
                    status=c(1,1,1,1,0,1,1,0),
                    x=     c(0,0,0,1,1,1,0,0),
		    wt=    c(1,1,1,1,1,1,1,1),
                    id=    1:8)
 
fit1 <- coxph(Surv(time, status) ~x + cluster(id), test1, method='breslow',
              weights=wt)
fit2 <- coxph(Surv(time, status) ~x + cluster(id), testx, method='breslow')

db1 <- resid(fit1, 'dfbeta', weighted=F)
db1 <- db1[-2]         #toss the missing
db2 <- resid(fit2, 'dfbeta')
aeq(db1, db2[3:8])

W <- c(3,1,1,1,1,1)   #Weights, after removal of the missing value
aeq(fit2$var, sum(db1*db1*W))
aeq(fit1$var, sum(db1*db1*W*W))

