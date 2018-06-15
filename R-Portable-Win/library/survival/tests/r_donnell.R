options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Good initial values are key to this data set
#   It killed v4 of survreg; 
#   data courtesy of Deborah Donnell, Fred Hutchinson Cancer Center
#

donnell <- scan("data.donnell", what=list(time1=0, time2=0, status=0))
donnell <- data.frame(donnell)

dfit <- survreg(Surv(time1, time2, status, type='interval') ~1, donnell)
summary(dfit)

#
# Fit the Donnell data using Statsci's code - should get the same coefs
#
if (exists('censorReg')) {
    dfitc <- censorReg(censor(time1, time2, status, type='interval') ~1, 
                   donnell)
    summary(dfitc)
    }
#
# Do a contour plot of the donnell data
#
npt <- 20
beta0  <- seq(.4, 3.6, length=npt)
logsig <- seq(-1.4, 0.41, length=npt)
donlog <- matrix(0,npt, npt)

for (i in 1:npt) {
    for (j in 1:npt) {
	fit <- survreg(Surv(time1, time2, status, type='interval') ~1,
			donnell, init=c(beta0[i],logsig[j]),
		        maxiter=0)
	donlog[i,j] <- fit$log[1]
	}
    }

clev <- -c(51, 51.5, 52:60, 65, 75, 85, 100, 150)
#clev <-  seq(-51, -50, length=10)

contour(beta0, logsig, pmax(donlog, -200), levels=clev, xlab="Intercept",
	ylab="Log(sigma)")
points(2.39, log(.7885), pch=1, col=2)
title("Donnell data")
#
# Compute the path of the iteration
#
#  All the intermediate stops produce an ignorable "did not converge"
# warning
options(warn=-1) #turn them off
niter <- 14
donpath <- matrix(0,niter+1,2)
for (i in 0:niter){
    fit <- survreg(Surv(time1, time2, status, type='interval') ~1,
		    donnell, maxiter=i)
    donpath[i+1,] <- c(fit$coef, log(fit$scale))
    }
points(donpath[,1], donpath[,2])
lines(donpath[,1], donpath[,2], col=4)
options(warn=0)  #reset
