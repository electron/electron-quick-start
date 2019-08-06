### R code from vignette source 'validate.Rnw'

###################################################
### code chunk number 1: init
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=8) #text in graph about the same as regular text
require(survival, quietly=TRUE)


###################################################
### code chunk number 2: breslow1
###################################################
breslow1 <- function(beta) {
    # first test data set, Breslow approximation
    r = exp(beta)
    lpl = 2*beta - (log(3*r +3) + 2*log(r+3))
    U   = (6+ 3*r - r^2)/((r+1)*(r+3))
    H   =  r/(r+1)^2 + 6*r/(r+3)^2
    c(beta=beta, loglik=lpl, U=U, H=H)
}
beta <- log((3 + sqrt(33))/2)
temp <- rbind(breslow1(0), breslow1(beta))
dimnames(temp)[[1]] <- c("beta=0", "beta=solution")
temp


###################################################
### code chunk number 3: validate.Rnw:186-209
###################################################
iter <- matrix(0, nrow=6, ncol=4,
               dimnames=list(paste("iter", 0:5),
                             c("beta", "loglik", "U", "H")))
# Exact Newton-Raphson
beta <- 0
for (i in 1:6) {
    iter[i,] <- breslow1(beta)
    beta <- beta + iter[i,"U"]/iter[i,"H"]
}
print(iter, digits=10)

# coxph fits
test1 <- data.frame(time=  c(1, 1, 6, 6, 8, 9),
                    status=c(1, 0, 1, 1, 0, 1),
                    x=     c(1, 1, 1, 0, 0, 0))
temp <- matrix(0, nrow=6, ncol=4, 
                 dimnames=list(1:6, c("iter", "beta", "loglik", "H")))
for (i in 0:5) {
    tfit <- coxph(Surv(time, status) ~ x, data=test1, 
                  ties="breslow", iter.max=i)
    temp[i+1,] <- c(tfit$iter, coef(tfit), tfit$loglik[2], 1/vcov(tfit))
}
temp


###################################################
### code chunk number 4: mresid1
###################################################
mresid1 <- function(r) {
    status <- c(1,0,1,1,0,1)
    xbeta  <- c(r,r,r,1,1,1)
    temp1 <- 1/(3*r +3)
    temp2 <- 2/(r+3) + temp1
    status - xbeta*c(temp1, temp1, temp2, temp2, temp2, 1+ temp2)
}
r0 <- mresid1(1)
r1 <- round(mresid1((3 + sqrt(33))/2), 6)


###################################################
### code chunk number 5: iter
###################################################
temp <- matrix(0, 8, 3)
dimnames(temp) <- list(paste0("iteration ", 0:7, ':'), c("beta", "loglik", "H"))
bhat <- 0
for (i in 1:8) {
    r <- exp(bhat)
    temp[i,] <- c(bhat,  2*(bhat - log(3*r +3)), 2*r/(r+1)^2)
    bhat <- bhat + (r+1)/r 
}
round(temp,3)


###################################################
### code chunk number 6: breslow2
###################################################
ufun <- function(r) {
    4 - (r/(r+1) + r/(r+2) + 3*r/(3*r+2) + 6*r/(3*r+1) + 6*r/(3*r+2))
}
rhat <- uniroot(ufun, c(.5, 1.5), tol=1e-8)$root
bhat <- log(rhat)
c(rhat=rhat, bhat=bhat)


###################################################
### code chunk number 7: temp
###################################################
true2 <- function(beta, newx=0) {
    r <- exp(beta)
    loglik <- 4*beta - log(r+1) - log(r+2) - 3*log(3*r+2) - 2*log(3*r+1)
    u <- 1/(r+1) +  1/(3*r+1) + 4/(3*r+2) -
                 ( r/(r+2) +3*r/(3*r+2) + 3*r/(3*r+1))
    imat <- r/(r+1)^2 + 2*r/(r+2)^2 + 6*r/(3*r+2)^2 +
            3*r/(3*r+1)^2 + 3*r/(3*r+1)^2 + 12*r/(3*r+2)^2

    hazard <-c( 1/(r+1), 1/(r+2), 1/(3*r+2), 1/(3*r+1), 1/(3*r+1), 2/(3*r+2) )
    xbar <- c(r/(r+1), r/(r+2), 3*r/(3*r+2), 3*r/(3*r+1), 3*r/(3*r+1),
                3*r/(3*r+2))
   # The matrix of weights, one row per obs, one col per time
    #   deaths at 2,3,6,7,8,9
    wtmat <- matrix(c(1,0,0,0,1,0,0,0,0,0,
                      0,1,0,1,1,0,0,0,0,0,
                      0,0,1,1,1,0,1,1,0,0,
                      0,0,0,1,1,0,1,1,0,0,
                      0,0,0,0,1,1,1,1,0,0,
                      0,0,0,0,0,1,1,1,1,1), ncol=6)
    wtmat <- diag(c(r,1,1,r,1,r,r,r,1,1)) %*% wtmat

    x      <- c(1,0,0,1,0,1,1,1,0,0)
    status <- c(1,1,1,1,1,1,1,0,0,0)
    xbar <- colSums(wtmat*x)/ colSums(wtmat)
    n <- length(x)

   # Table of sums for score and Schoenfeld resids
    hazmat <- wtmat %*% diag(hazard) #each subject's hazard over time
    dM <- -hazmat  #Expected part
    for (i in 1:6) dM[i,i] <- dM[i,i] +1  #observed
    dM[7,6] <- dM[7,6] +1  # observed
    mart <- rowSums(dM)

    # Table of sums for score and Schoenfeld resids
    #  Looks like the last table of appendix E.2.1 of the book
    resid <- dM * outer(x, xbar, '-')
    score <- rowSums(resid)
    scho <- colSums(resid)
    # We need to split the two tied times up, to match coxph
    scho <- c(scho[1:5], scho[6]/2, scho[6]/2)
    var.g <- cumsum(hazard*hazard /c(1,1,1,1,1,2))
    var.d <- cumsum( (xbar-newx)*hazard)

    surv <- exp(-cumsum(hazard) * exp(beta*newx))
    varhaz <- (var.g + var.d^2/imat)* exp(2*beta*newx)

    list(loglik=loglik, u=u, imat=imat, xbar=xbar, haz=hazard,
	     mart=mart,  score=score, rmat=resid,
		scho=scho, surv=surv, var=varhaz)
    }
val2 <- true2(bhat)
rtemp <- round(val2$mart, 6)


###################################################
### code chunk number 8: wt1
###################################################
ufun <- function(r) {
    xbar <- c( (2*r^2 + 11*r)/(r^2 + 11*r +7), 11*r/(11*r + 5), 2*r/(2*r +1))
    11- (xbar[1] + 10* xbar[2] + 2* xbar[3])
}
rhat <- uniroot(ufun, c(1,3), tol= 1e-9)$root
bhat <- log(rhat)
c(rhat=rhat, bhat=bhat)


###################################################
### code chunk number 9: wt2
###################################################
wfun <- function(r) {
    beta <- log(r)
    pl <- 11*beta - (log(r^2 + 11*r + 7) + 10*log(11*r +5) + 2*log(2*r +1))
    xbar <- c((2*r^2 + 11*r)/(r^2 + 11*r +7), 11*r/(11*r +5), 2*r/(2*r +1))
    U <- 11 - (xbar[1] + 10*xbar[2] + 2*xbar[3])
    H <- ((4*r^2 + 11*r)/(r^2 + 11*r +7)- xbar[1]^2) + 
        10*(xbar[2] - xbar[2]^2) +  2*(xbar[3]- xbar[3]^2)
    c(loglik=pl, U=U, H=H)
}
temp <- matrix(c(wfun(1), wfun(rhat)), ncol=2, 
       dimnames=list(c("loglik", "U", "H"), c("beta=0", "beta-hat")))
round(temp, 6)       


