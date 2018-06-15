### R code from vignette source 'SQUAREM.Rnw'

###################################################
### code chunk number 1: load
###################################################
library("SQUAREM") 


###################################################
### code chunk number 2: help
###################################################
help(package=SQUAREM)


###################################################
### code chunk number 3: rng
###################################################
require("setRNG") 
setRNG(list(kind="Wichmann-Hill", normal.kind="Box-Muller", seed=123))


###################################################
### code chunk number 4: data
###################################################
poissmix.dat <- data.frame(death=0:9, freq=c(162,267,271,185,111,61,27,8,3,1))


###################################################
### code chunk number 5: init
###################################################
y <- poissmix.dat$freq
tol <- 1.e-08

setRNG(list(kind="Wichmann-Hill", normal.kind="Box-Muller", seed=123))
p0 <- c(runif(1),runif(2,0,6))    


###################################################
### code chunk number 6: poissmix
###################################################
poissmix.em <- function(p,y) {
pnew <- rep(NA,3)
i <- 0:(length(y)-1)
zi <- p[1]*exp(-p[2])*p[2]^i / (p[1]*exp(-p[2])*p[2]^i + (1 - p[1])*exp(-p[3])*p[3]^i)
pnew[1] <- sum(y*zi)/sum(y)
pnew[2] <- sum(y*i*zi)/sum(y*zi)
pnew[3] <- sum(y*i*(1-zi))/sum(y*(1-zi))
p <- pnew
return(pnew)
}


###################################################
### code chunk number 7: loglik
###################################################
poissmix.loglik <- function(p,y) {
i <- 0:(length(y)-1)
loglik <- y*log(p[1]*exp(-p[2])*p[2]^i/exp(lgamma(i+1)) + 
		(1 - p[1])*exp(-p[3])*p[3]^i/exp(lgamma(i+1)))
return ( -sum(loglik) )
}


###################################################
### code chunk number 8: em
###################################################
pf1 <- fpiter(p=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, 
control=list(tol=tol))
pf1


###################################################
### code chunk number 9: squarem
###################################################
pf2 <- squarem(p=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, 
control=list(tol=tol))
pf2


###################################################
### code chunk number 10: squarem2
###################################################
pf3 <- squarem(p=p0, y=y, fixptfn=poissmix.em, control=list(tol=tol))
pf3


###################################################
### code chunk number 11: power
###################################################
power.method <- function(x, A) {
# Defines one iteration of the power method
# x = starting guess for dominant eigenvector
# A = a square matrix
ax <- as.numeric(A %*% x)
f <- ax / sqrt(as.numeric(crossprod(ax)))
f
}


###################################################
### code chunk number 12: bodewig
###################################################
b <- c(2, 1, 3, 4, 1,  -3,   1,   5,  3,   1,   6,  -2,  4,   5,  -2,  -1)
bodewig.mat <- matrix(b,4,4)
eigen(bodewig.mat)


###################################################
### code chunk number 13: accelerate
###################################################
p0 <- rnorm(4)

# Standard power method iteration
ans1 <- fpiter(p0, fixptfn=power.method, A=bodewig.mat)
# re-scaling the eigenvector so that it has unit length
ans1$par <- ans1$par / sqrt(sum(ans1$par^2))  
# dominant eigenvector
ans1  
# dominant eigenvalue
c(t(ans1$par) %*% bodewig.mat %*% ans1$par) / c(crossprod(ans1$par))  


###################################################
### code chunk number 14: sq.bodewig
###################################################
ans2 <- squarem(p0, fixptfn=power.method, A=bodewig.mat)
ans2
ans2$par <- ans2$par / sqrt(sum(ans2$par^2))
c(t(ans2$par) %*% bodewig.mat %*% ans2$par) / c(crossprod(ans2$par))  


###################################################
### code chunk number 15: sq2.bodewig
###################################################
ans3 <- squarem(p0, fixptfn=power.method, A=bodewig.mat, control=list(step.min0 = 0.5))
ans3
ans3$par <- ans3$par / sqrt(sum(ans3$par^2))
# eigenvalue
c(t(ans3$par) %*% bodewig.mat %*% ans3$par) / c(crossprod(ans3$par))  


###################################################
### code chunk number 16: sq3.bodewig
###################################################
# Third-order SQUAREM
ans4 <- squarem(p0, fixptfn=power.method, A=bodewig.mat, control=list(K=3, method="rre"))
ans4
ans4$par <- ans4$par / sqrt(sum(ans4$par^2))
# eigenvalue
c(t(ans4$par) %*% bodewig.mat %*% ans4$par) / c(crossprod(ans4$par))  


