library(survival)
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type

# Tests of the weighted Cox model
#  This is section 1.3 of my appendix -- no yet found in any of the
#  printings though, it awaits the next edition
#
# Efron approximation
#
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

testw1 <- data.frame(time=  c(1,1,2,2,2,2,3,4,5),
		    status= c(1,0,1,1,1,0,0,1,0),
		    x=      c(2,0,1,1,0,1,0,1,0),
		    wt =    c(1,2,3,4,3,2,1,2,1))
xx <- testw1$wt

# Efron estimate
byhand <- function(beta, newx=0) {
    r <- exp(beta)
    a <- 7*r +3; b<- 4*r+2
    loglik <- 11*beta - (log(r^2 + 11*r +7) + 10*log(11*r +5)/3 +
                         10*log(a*2/3 +b)/3 + 10*log(a/3 +b)/3 +2*log(2*r+1))

    hazard <- c(1/(r^2 + 11*r +7), 
                10/(3*c(11*r +5, a*2/3 +b, a/3+b)), 2/(2*r+1))
    temp <- c(hazard[1], hazard[1]+hazard[2] + hazard[3]*2/3 + hazard[4]/3,
              cumsum(hazard)[4:5])
    risk <- c(r^2, 1,r,r,1,r,1,r,1)
    expected <- risk* temp[c(1,1,2,2,2,3,3,4,4)]
    
    # The matrix of weights, one row per obs, one col per death
    #   deaths at 1,2,2,2, and 4
    riskmat <- matrix(c(1,1,1,1,1,1,1,1,1,
                        0,0,1,1,1,1,1,1,1,
                        0,0,2/3,2/3,2/3,1,1,1,1,
                        0,0,1/3,1/3,1/3,1,1,1,1,
                        0,0,0,0,0,0,0,1,1), ncol=5)
    wtmat <- diag(c(r^2, 2, 3*r, 4*r, 3, 2*r, 1, 2*r, 1)) %*% riskmat

    x      <- c(2,0,1,1,0,1,0,1,0)
    xbar   <- colSums(x*wtmat)/ colSums(wtmat)
    imat   <- (4*r^2 + 11*r)*hazard[1] - xbar[1]^2  +
              10* mean(xbar[2:4] - xbar[2:4]^2) + 2*(xbar[5] - xbar[5]^2)

    status <- c(1,0,1,1,1,0,0,1,0)
    wt     <- c(1,2,3,4,3,2,1,2,1)
   # Table of sums for score  resids
    hazmat <- riskmat %*% diag(c(1,10/3,10/3, 10/3,2)/colSums(wtmat)) 
    dM <- -risk*hazmat  #Expected part
    dM[1,1] <- dM[1,1] +1  # deaths at time 1
    for (i in 2:4) dM[3:5, i] <- dM[3:5,i] + 1/3
    dM[8,5] <- dM[8,5] +1
    mart <- rowSums(dM)
    resid <-dM * outer(x, xbar ,'-')

    # Increments to the variance of the hazard
    var.g <- cumsum(hazard^2* c(1,3/10, 3/10, 3/10, 1/2))
    var.d <- cumsum((xbar-newx)*hazard)

    sxbar <- c(xbar[1], mean(xbar[2:4]), xbar[5])  #xbar for Schoen
    list(loglik=loglik, imat=imat, hazard=hazard, xbar=xbar,
         mart=status-expected, expected=expected,
         score=rowSums(resid), schoen=c(2,1,1,0,1) - sxbar[c(1,2,2,2,3)],
         varhaz=((var.g + var.d^2/imat)* exp(2*beta*newx))[c(1,4,5)])
    }

# Verify
temp <- byhand(0,0)
aeq(temp$xbar, c(13/19, 11/16, 26/38, 19/28, 2/3))
aeq(temp$hazard, c(1/19, 5/24, 5/19, 5/14, 2/3))

fit0 <- coxph(Surv(time, status) ~x, testw1, weights=wt, iter=0)
fit  <- coxph(Surv(time, status) ~x, testw1, weights=wt)

truth0 <- byhand(0,pi)
aeq(fit0$loglik[1], truth0$loglik)
aeq(1/truth0$imat, fit0$var)
aeq(truth0$mart, fit0$resid)
aeq(truth0$scho, resid(fit0, 'schoen'))
aeq(truth0$score, resid(fit0, 'score')) 
sfit <- survfit(fit0, list(x=pi), censor=FALSE)
aeq(sfit$std.err^2, truth0$var)  
aeq(-log(sfit$surv), cumsum(truth0$hazard)[c(1,4,5)]) 

truth <- byhand(fit$coef, .3)
aeq(truth$loglik, fit$loglik[2])
aeq(1/truth$imat, fit$var)
aeq(truth$mart, fit$resid)
aeq(truth$scho, resid(fit, 'schoen'))
aeq(truth$score, resid(fit, 'score'))

sfit <- survfit(fit, list(x=.3), censor=FALSE)
aeq(sfit$std.err^2, truth$var)  
aeq(-log(sfit$surv), (cumsum(truth$hazard)* exp(fit$coef*.3))[c(1,4,5)]) 


fit0
summary(fit)
resid(fit0, type='score')
resid(fit0, type='scho')

resid(fit, type='score')
resid(fit, type='scho')

rr1 <- resid(fit, type='mart')
rr2 <- resid(fit, type='mart', weighted=T)
aeq(rr2/rr1, testw1$wt)

rr1 <- resid(fit, type='score')
rr2 <- resid(fit, type='score', weighted=T)
aeq(rr2/rr1, testw1$wt)

