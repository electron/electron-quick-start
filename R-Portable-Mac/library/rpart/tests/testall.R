# 
# This is a set of tests, with printout, that tries
#  to exercise all of the splitting rules
# It's less formal than the others in this directory, but covers
#  more.
# For all of the cross-validations I set xgroups explicitly, so as
#  to avoid any changes in random number allocation of the groups.

library(rpart)
require(survival)
options(digits=4)  #avoid trivial rounding changes across R versions

# 
#
# Survival, using the stagec data
#
#   Time to progression in years
#   status  1=progressed, 0= censored
#   age
#   early endocrine therapy   1=no 2=yes
#   % of cells in g2 phase, from flow cytometry
#   tumor grade (Farrow) 1,2,3,4
#   Gleason score (competing grading system)
#   ploidy
xgroup <- rep(1:10, length=nrow(stagec))
fit1 <- rpart(Surv(pgtime, pgstat) ~ age + eet + g2+grade+gleason +ploidy,
		stagec, method="poisson",
              control=rpart.control(usesurrogate=0, cp=0, xval=xgroup))
fit1
summary(fit1)

fit2 <- rpart(Surv(pgtime, pgstat) ~ age + eet + g2+grade+gleason +ploidy,
		stagec, xval=xgroup)
fit2
summary(fit2)


#
# Continuous y variable
#  Use deterministic xgroups: the first group is the 1st, 11th, 21st, etc
#  smallest obs, the second is 2, 12, 22, ...

mystate <- data.frame(state.x77, region=factor(state.region))
names(mystate) <- c("population","income" , "illiteracy","life" ,
       "murder", "hs.grad", "frost",     "area",      "region")

xvals <- 1:nrow(mystate)
xvals[order(mystate$income)] <- rep(1:10, length=nrow(mystate))

fit4 <- rpart(income ~ population + region + illiteracy +life + murder +
			hs.grad + frost , mystate,
		   control=rpart.control(minsplit=10, xval=xvals))

summary(fit4)


#
# Check out xpred.rpart
#
meany <- mean(mystate$income)
xpr <- xpred.rpart(fit4, xval=xvals)
xpr2 <- (xpr - mystate$income)^2
risk0 <- mean((mystate$income - meany)^2)
xpmean <- as.vector(apply(xpr2, 2, mean))   #kill the names
all.equal(xpmean/risk0, as.vector(fit4$cptable[,'xerror']))

xpstd <- as.vector(apply((sweep(xpr2, 2, xpmean))^2, 2, sum))
xpstd <- sqrt(xpstd)/(50*risk0)
all.equal(xpstd, as.vector(fit4$cptable[,'xstd']))

#
# recreate subset #3 of the xval
#
tfit4 <- rpart(income ~ population + region + illiteracy +life + murder +
			hs.grad + frost , mystate,  subset=(xvals!=3),
		   control=rpart.control(minsplit=10, xval=0))
tpred <- predict(tfit4, mystate[xvals==3,])
all.equal(tpred, xpr[xvals==3,ncol(xpr)])

# How much does this differ from the "real" formula, more complex,
#   found on page 309 of Breiman et al. ?
#xtemp <- (xpr2/outer(rep(1,50),xpmean)) -  ((mystate$income - meany)^2)/risk0
#real.se<- xpmean* sqrt(apply(xtemp^2,2,sum))/(risk0*50)


# Simple yes/no classification model
fit5 <- rpart(factor(pgstat) ~  age + eet + g2+grade+gleason +ploidy,
	  stagec, xval=xgroup)

fit5

fit6 <- rpart(factor(pgstat) ~  age + eet + g2+grade+gleason +ploidy,
		stagec, parm=list(prior=c(.5,.5)), xval=xgroup)
summary(fit6)
#
# Fit a classification model to the car data.
#  Now, since Reliability is an ordered category, this model doesn't
# make a lot of statistical sense, but it does test out some
# areas of the code that nothing else does
#
xcar <- rep(1:8, length=nrow(cu.summary))
carfit <- rpart(Reliability ~ Price + Country + Mileage + Type,
		   method='class', data=cu.summary, xval=xcar)

summary(carfit)

