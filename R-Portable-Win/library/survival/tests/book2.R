library(survival)
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type

#
# Tests from the appendix of Therneau and Grambsch
#  b. Data set 1 and Efron estimate
#
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))

byhand <- function(beta, newx=0) {
    r <- exp(beta)
    loglik <- 2*beta - (log(3*r +3) + log((r+5)/2) + log(r+3))
    u <- (30 + 23*r - r^3)/ ((r+1)*(r+3)*(r+5))
    tfun <- function(x)  x - x^2
    imat <- tfun(r/(r+1)) + tfun(r/(r+5)) + tfun(r/(r+3))

    # The matrix of weights, one row per obs, one col per time
    #  Time of 1, 6, 6+0 (second death), and 9  
    wtmat <- matrix(c(1,1,1,1,1,1,
                      0,0,1,1,1,1,
                      0,0,.5, .5, 1,1,
                      0,0,0,0,0,1), ncol=4)
    wtmat <- diag(c(r,r,r,1,1,1)) %*% wtmat

    x <- c(1,1,1,0,0,0)
    status <- c(1,0,1,1,0,1)
    xbar <- colSums(wtmat*x)/ colSums(wtmat)
    haz <-  1/ colSums(wtmat)  # one death at each of the times

    hazmat <- wtmat %*% diag(haz) #each subject's hazard over time
    mart <- status - rowSums(hazmat)

    a <- r+1; b<- r+3; d<- r+5  # 'c' in the book, 'd' here
    score <- c((2*r + 3)/ (3*a^2),
               -r/ (3*a^2),
               (675+ r*(1305 +r*(756 + r*(-4 +r*(-79 -13*r)))))/(3*(a*b*d)^2),
               r*(1/(3*a^2) - a/(2*b^2) - b/(2*d^2)), 
               2*r*(177 + r*(282 +r*(182 + r*(50 + 5*r)))) /(3*(a*b*d)^2), 
               2*r*(177 + r*(282 +r*(182 + r*(50 + 5*r)))) /(3*(a*b*d)^2))

    # Schoenfeld residual
    d <- mean(xbar[2:3])
    scho <- c(1/(r+1), 1- d, 0- d , 0)

    surv  <- exp(-cumsum(haz)* exp(beta*newx))[c(1,3,4)]
    varhaz.g <- cumsum(haz^2)  # since all numerators are 1

    varhaz.d <- cumsum((newx-xbar) * haz)

    varhaz <- (varhaz.g + varhaz.d^2/ imat) * exp(2*beta*newx)

    list(loglik=loglik, u=u, imat=imat, xbar=xbar, haz=haz,
	     mart=mart,  score=score, var.g=varhaz.g, var.d=varhaz.d,
		scho=scho, surv=surv, var=varhaz[c(1,3,4)])
    }


aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

fit0 <-coxph(Surv(time, status) ~x, test1, iter=0)
truth0 <- byhand(0,0)
aeq(truth0$loglik, fit0$loglik[1])
aeq(1/truth0$imat, fit0$var)
aeq(truth0$mart, fit0$resid[c(2:6,1)])
aeq(resid(fit0), c(-3/4, NA, 5/6, -1/6, 5/12, 5/12, -3/4))
aeq(truth0$scho, resid(fit0, 'schoen'))
aeq(truth0$score, resid(fit0, 'score')[c(3:7,1)])
sfit <- survfit(fit0, list(x=0), censor=FALSE)
aeq(sfit$std.err^2, truth0$var)
aeq(sfit$surv, truth0$surv)

fit <- coxph(Surv(time, status) ~x, test1, eps=1e-8)
aeq(round(fit$coef,6), 1.676857)
truebeta <- log(cos(acos((45/23)*sqrt(3/23))/3) * 2* sqrt(23/3))
truth <- byhand(truebeta, 0)
aeq(truth$loglik, fit$loglik[2])
aeq(1/truth$imat, fit$var)
aeq(truth$mart, fit$resid[c(2:6,1)])
aeq(truth$scho, resid(fit, 'schoen'))
aeq(truth$score, resid(fit, 'score')[c(3:7,1)])

# Per comments in the source code, the below is expected to fail for Efron 
#  at the tied death times.  (When predicting for new data, predict
#  treats a time in the new data set that exactly matches one in the original
#  as being just after the original, i.e., experiences the full hazard
#  jump there, in the same way that censors do.)
expect <- predict(fit, type='expected', newdata=test1) #force recalc
use <- !(test1$time==6 | is.na(test1$status))
aeq(test1$status[use] - resid(fit)[use], expect[use])  

sfit <- survfit(fit, list(x=0), censor=FALSE)
aeq(sfit$surv, truth$surv)
aeq(sfit$std.err^2, truth$var)

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
