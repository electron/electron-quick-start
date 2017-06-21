library(survival)
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type

# Tests of the weighted Cox model
#  This is section 1.3 of my appendix -- not yet found in the book
#  though, it awaits the next edition
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
xx <- testw1$wt
testw2 <- data.frame(time=   rep(c(1,1,2,2,2,2,3,4,5), xx),
		     status= rep(c(1,0,1,1,1,0,0,1,0), xx),
		     x=      rep(c(2,0,1,1,0,1,0,1,0), xx),
		     id=     rep(1:9, xx))
indx <- match(1:9, testw2$id)

# Breslow estimate
byhand <- function(beta, newx=0) {
    r <- exp(beta)
    loglik <- 11*beta - (log(r^2 + 11*r +7) + 10*log(11*r +5) +2*log(2*r+1))
    hazard <- c(1/(r^2 + 11*r +7), 10/(11*r +5), 2/(2*r+1))
    xbar <- c((2*r^2 + 11*r)*hazard[1], 11*r/(11*r +5), r*hazard[3])
    U <- 11- (xbar[1] + 10*xbar[2] + 2*xbar[3])
    imat <- (4*r^2 + 11*r)*hazard[1] - xbar[1]^2 +
            10*(xbar[2] - xbar[2]^2) + 2*(xbar[3] - xbar[3]^2)

    temp <- cumsum(hazard)
    risk <- c(r^2, 1,r,r,1,r,1,r,1)
    expected <- risk* temp[c(1,1,2,2,2,2,2,3,3)]
    
    # The matrix of weights, one row per obs, one col per death
    #   deaths at 1,2,2,2, and 4
    riskmat <- matrix(c(1,1,1,1,1,1,1,1,1,
                        0,0,1,1,1,1,1,1,1,
                        0,0,1,1,1,1,1,1,1,
                        0,0,1,1,1,1,1,1,1,
                        0,0,0,0,0,0,0,1,1), ncol=5)
    wtmat <- diag(c(r^2, 2, 3*r, 4*r, 3, 2*r, 1, 2*r, 1)) %*% riskmat

    x      <- c(2,0,1,1,0,1,0,1,0)
    status <- c(1,0,1,1,1,0,0,1,0)
    wt     <- c(1,2,3,4,3,2,1,2,1)
   # Table of sums for score and Schoenfeld resids
    hazmat <- riskmat %*% diag(c(1,3,4,3,2)/colSums(wtmat)) 
    dM <- -risk*hazmat  #Expected part
    dM[1,1] <- dM[1,1] +1  # deaths at time 1
    for (i in 2:4) dM[i+1, i] <- dM[i+1,i] +1
    dM[8,5] <- dM[8,5] +1
    mart <- rowSums(dM)
    resid <-dM * outer(x, xbar[c(1,2,2,2,3)] ,'-')

    # Increments to the variance of the hazard
    var.g <- cumsum(hazard^2/ c(1,10,2))
    var.d <- cumsum((xbar-newx)*hazard)

    list(loglik=loglik, U=U, imat=imat, hazard=hazard, xbar=xbar,
         mart=c(1,0,1,1,1,0,0,1,0)-expected, expected=expected,
         score=rowSums(resid), schoen=c(2,1,1,0,1) - xbar[c(1,2,2,2,3)],
         varhaz=(var.g + var.d^2/imat)* exp(2*beta*newx))
    }

aeq(byhand(0)$expected, c(1/19, 1/19, rep(103/152, 5), rep(613/456,2))) #verify 

fit0 <- coxph(Surv(time, status) ~x, testw1, weights=wt,
		    method='breslow', iter=0)
fit0b <- coxph(Surv(time, status) ~x, testw2, method='breslow', iter=0)
fit  <- coxph(Surv(time, status) ~x, testw1, weights=wt, method='breslow')
fitb <- coxph(Surv(time, status) ~x, testw2, method='breslow')

aeq(resid(fit0, type='mart'), (resid(fit0b, type='mart'))[indx])
aeq(resid(fit0, type='scor'), (resid(fit0b, type='scor'))[indx])
aeq(unique(resid(fit0, type='scho')), unique(resid(fit0b, type='scho')))

truth0 <- byhand(0,pi)
aeq(fit0$loglik[1], truth0$loglik)
aeq(1/truth0$imat, fit0$var)
aeq(truth0$mart, fit0$resid)
aeq(truth0$scho, resid(fit0, 'schoen'))
aeq(truth0$score, resid(fit0, 'score')) 
sfit <- survfit(fit0, list(x=pi), censor=FALSE)
aeq(sfit$std.err^2, truth0$var)
aeq(-log(sfit$surv), cumsum(truth0$haz))

truth <- byhand(0.85955744, .3)
aeq(truth$loglik, fit$loglik[2])
aeq(1/truth$imat, fit$var)
aeq(truth$mart, fit$resid)
aeq(truth$scho, resid(fit, 'schoen'))
aeq(truth$score, resid(fit, 'score'))

sfit <- survfit(fit, list(x=.3), censor=FALSE)
aeq(sfit$std.err^2, truth$var) 
aeq(-log(sfit$surv), (cumsum(truth$haz)* exp(fit$coef*.3)))


fit0
summary(fit)
resid(fit0, type='score')
resid(fit0, type='scho')

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

