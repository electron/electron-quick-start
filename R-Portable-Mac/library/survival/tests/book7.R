library(survival)
options(na.action=na.exclude)
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type

#
# Tests from the appendix of Therneau and Grambsch
#  Data set 1 + exact method

test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))

byhand7 <- function(beta) {
    r <- exp(beta)
    loglik <- 2*(beta - log(3*r + 3))
    u <- 2/(r+1)
    imat <- 2*r/(r+1)^2
    haz <- c(1/(3*r+3), 2/(r+3), 0, 1 )
                 
    ties <- c(1,1,2,2,3,4)
    wt <- c(r,r,r,1,1,1)
    mart <- c(1,0,1,1,0,1) -  wt* (cumsum(haz))[ties]  #martingale residual

    list(loglik=loglik, u=u, imat=imat, mart=mart)
}
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

fit0 <-coxph(Surv(time, status) ~x, test1, iter=0, method='exact')
truth0 <- byhand7(0)
aeq(truth0$loglik, fit0$loglik[1])
aeq(1/truth0$imat, fit0$var)
aeq(truth0$mart, fit0$resid[c(2:6,1)])

fit1 <- coxph(Surv(time, status) ~x, test1, iter=1, method='exact')
aeq(fit1$coef, truth0$u*fit0$var)
truth1 <- byhand7(fit1$coef)
aeq(fit1$loglik[2], truth1$loglik)
aeq(1/truth1$imat, fit1$var)
aeq(truth1$mart, resid(fit1)[c(3:7,1)])

# Beta is infinite for this model, so we will get a warning message
fit2 <-  coxph(Surv(time, status) ~x, test1, method='exact')
aeq(resid(fit2)[-2], c(0, 2/3, -1/3, -4/3,  1, 0))  #values from the book


#
# Now a multivariate case: start/stop data uses a different C routine
#
zz <- rep(0, nrow(lung))
fit1 <- coxph(Surv(time, status) ~ age + ph.ecog + sex, lung, method="exact")
fit2 <- coxph(Surv(zz, time, status) ~ age + ph.ecog + sex, lung,
              method="exact")
aeq(fit1$loglik, fit2$loglik)
aeq(fit1$var, fit2$var)
aeq(fit1$score, fit2$score)
aeq(fit1$resid, fit2$resid)
