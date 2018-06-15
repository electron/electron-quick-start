options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Tests from the appendix of Therneau and Grambsch
#  d. Data set 2 and Efron estimate
#
test2 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0) )

byhand <- function(beta, newx=0) {
    r <- exp(beta)
    loglik <- 4*beta - (log(r+1) + log(r+2) + 2*log(3*r+2) + 2*log(3*r+1) +
        log(2*r +2))
    u <- 1/(r+1) +  1/(3*r+1) + 2*(1/(3*r+2) + 1/(2*r+2)) -
                 ( r/(r+2) +3*r/(3*r+2) + 3*r/(3*r+1))
    imat <- r*(1/(r+1)^2 + 2/(r+2)^2 + 6/(3*r+2)^2 +
            6/(3*r+1)^2 + 6/(3*r+2)^2 + 4/(2*r +2)^2)

    hazard <-c( 1/(r+1), 1/(r+2), 1/(3*r+2), 1/(3*r+1), 1/(3*r+1),
               1/(3*r+2), 1/(2*r +2) )


    # The matrix of weights, one row per obs, one col per time
    #   deaths at 2,3,6,7,8,9
    wtmat <- matrix(c(1,0,0,0,1, 0, 0,0,0,0,
                      0,1,0,1,1, 0, 0,0,0,0,
                      0,0,1,1,1, 0, 1,1,0,0,
                      0,0,0,1,1, 0, 1,1,0,0,
                      0,0,0,0,1, 1, 1,1,0,0,
                      0,0,0,0,0, 1, 1,1,1,1,
                      0,0,0,0,0,.5,.5,1,1,1), ncol=7)
    wtmat <- diag(c(r,1,1,r,1,r,r,r,1,1)) %*% wtmat

    x      <- c(1,0,0,1,0,1,1,1,0,0)
    status <- c(1,1,1,1,1,1,1,0,0,0)
    xbar <- colSums(wtmat*x)/ colSums(wtmat)
    n <- length(x)

   # Table of sums for score and Schoenfeld resids
    hazmat <- wtmat %*% diag(hazard) #each subject's hazard over time
    dM <- -hazmat  #Expected part
    for (i in 1:5) dM[i,i] <- dM[i,i] +1  #observed
    dM[6:7,6:7] <- dM[6:7,6:7] +.5  # observed
    mart <- rowSums(dM)

    # Table of sums for score and Schoenfeld resids
    #  Looks like the last table of appendix E.2.1 of the book
    resid <- dM * outer(x, xbar, '-')
    score <- rowSums(resid)
    scho <- colSums(resid)

    # We need to add the ties back up (they are symmetric)
    scho[6:7] <- rep(mean(scho[6:7]), 2)

    list(loglik=loglik, u=u, imat=imat, xbar=xbar, haz=hazard,
	     mart=mart,  score=score, rmat=resid,
		scho=scho)
    }


aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

fit0 <-coxph(Surv(start, stop, event) ~x, test2, iter=0)
truth0 <- byhand(0,0)
aeq(truth0$loglik, fit0$loglik[1])
aeq(1/truth0$imat, fit0$var)
aeq(truth0$mart, fit0$resid)
aeq(truth0$scho, resid(fit0, 'schoen'))
aeq(truth0$score, resid(fit0, 'score')) 


fit <- coxph(Surv(start, stop, event) ~x, test2, eps=1e-8)
truth <- byhand(fit$coef, 0)
aeq(truth$loglik, fit$loglik[2])
aeq(1/truth$imat, fit$var)
aeq(truth$mart, fit$resid)
aeq(truth$scho, resid(fit, 'schoen'))
aeq(truth$score, resid(fit, 'score'))

# Reprise the test, with strata
#  offseting the times ensures that we will get the wrong risk sets
#  if strata were not kept separate
test2b <- rbind(test2, test2, test2)
test2b$group <- rep(1:3, each= nrow(test2))
test2b$start <- test2b$start + test2b$group
test2b$stop  <- test2b$stop  + test2b$group
fit0 <- coxph(Surv(start, stop, event) ~ x + strata(group), test2b, iter=0)
aeq(3*truth0$loglik, fit0$loglik[1])
aeq(3*truth0$imat, 1/fit0$var)
aeq(rep(truth0$mart,3), fit0$resid)
aeq(rep(truth0$scho,3),  resid(fit0, 'schoen'))
aeq(rep(truth0$score,3), resid(fit0, 'score')) 

fit3 <- coxph(Surv(start, stop, event) ~x + strata(group), test2b, eps=1e-8)
aeq(3*truth$loglik, fit3$loglik[2])
aeq(3*truth$imat, 1/fit3$var)
aeq(rep(truth$mart,3), fit3$resid)
aeq(rep(truth$scho,3), resid(fit3, 'schoen'))
aeq(rep(truth$score,3), resid(fit3, 'score'))

# 
# Done with the formal test, now print out lots of bits
#
resid(fit)
resid(fit, 'scor')
resid(fit, 'scho')

predict(fit, type='lp')
predict(fit, type='risk')
predict(fit, type='expected')
predict(fit, type='terms')
predict(fit, type='lp', se.fit=T)
predict(fit, type='risk', se.fit=T)
predict(fit, type='expected', se.fit=T)
predict(fit, type='terms', se.fit=T)

summary(survfit(fit))
summary(survfit(fit, list(x=2)))
