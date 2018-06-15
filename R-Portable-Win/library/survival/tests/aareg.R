options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test aareg, for some simple data where the answers can be computed
#  in closed form
#
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)
   
test1 <- data.frame(time=  c(4, 3,1,1,2,2,3),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0),
		    wt=    c(1, 1:6))

tfit  <- aareg(Surv(time, status) ~ x, test1)
aeq(tfit$times, c(1,2,2))
aeq(tfit$nrisk, c(6,4,4))
aeq(tfit$coefficient, matrix(c(0,0,1/3, 1/3, 1, -1/3), ncol=2))
aeq(tfit$tweight, matrix(c(3,3,3, 3/2, 3/4, 3/4), ncol=2))
aeq(tfit$test.statistic, c(1,1))
aeq(tfit$test.var,       c(1, -1/4, -1/4, 1/4 + 9/16 + 1/16))

tfit <- aareg(Surv(time, status) ~ x, test1, test='nrisk')
aeq(tfit$tweight, matrix(c(3,3,3, 3/2, 3/4, 3/4), ncol=2)) #should be as before
aeq(tfit$test.statistic, c(4/3, 6/3+ 4 - 4/3))
aeq(tfit$test.var,       c(16/9, -16/9, -16/9, 36/9 + 16 + 16/9))

# In the 1-variable case, this is the same as the default Aalen weight
tfit <- aareg(Surv(time, status) ~ x, test1, test='variance')
aeq(tfit$test.statistic, c(1,1))
aeq(tfit$test.var,       c(1, -1/4, -1/4, 1/4 + 9/16 + 1/16))

#
# Repeat the above, with case weights
#
tfit <- aareg(Surv(time, status) ~x, test1, weights=wt)  
aeq(tfit$times, c(1,2,2))
aeq(tfit$nrisk, c(21,16,16))
aeq(tfit$coefficient, matrix(c(0,0,5/12, 2/9, 1, -5/12), ncol=2))
aeq(tfit$tweight, matrix(c(12,12,12, 36/7, 3,3), ncol=2))
aeq(tfit$test.statistic, c(5, 72/63 + 3 - 15/12))
aeq(tfit$test.var,       c(25, -25/4, -25/4, (72/63)^2 + 9 + (5/4)^2))

tfit <- aareg(Surv(time, status) ~x, test1, weights=wt, test='nrisk')
aeq(tfit$test.statistic, c(20/3,  42/9 + 16 - 16*5/12))
aeq(tfit$test.var,       c(400/9, -400/9, -400/9, 
			    (42/9)^2 + 16^2 + (16*5/12)^2))

#
# Make a test data set with no NAs, in sorted order, no ties,
#   15 observations
tdata <- lung[15:29, c('time', 'status', 'age', 'sex', 'ph.ecog')]
tdata$status <- tdata$status -1
tdata <- tdata[order(tdata$time, tdata$status),]
row.names(tdata) <- 1:15
tdata$status[8] <- 0      #for some variety

afit <- aareg(Surv(time, status) ~ age + sex + ph.ecog, tdata, nmin=6)
#
# Now, do it "by hand"
cfit <- coxph(Surv(time, status) ~ age + sex + ph.ecog, tdata, iter=0,
               method='breslow')
dt1   <- coxph.detail(cfit)
sch1  <- resid(cfit, type='schoen')

# First estimate of Aalen: from the Cox computations, first 9
#  The first and last cols of the ninth are somewhat unstable (approx =0)
mine <- rbind(solve(dt1$imat[,,1], sch1[1,]),
              solve(dt1$imat[,,2], sch1[2,]),
              solve(dt1$imat[,,3], sch1[3,]),
              solve(dt1$imat[,,4], sch1[4,]),
              solve(dt1$imat[,,5], sch1[5,]),
              solve(dt1$imat[,,6], sch1[6,]),
              solve(dt1$imat[,,7], sch1[7,]),
              solve(dt1$imat[,,8], sch1[8,]),
              solve(dt1$imat[,,9], sch1[9,])) 
mine <- diag(1/dt1$nrisk[1:9]) %*% mine

aeq(mine, afit$coef[1:9, -1])

rm(tfit, afit, mine, dt1, cfit, sch1)

#
# Check out the dfbeta matrix from aareg
#   Note that it is kept internally in time order, not data set order
# Those who want residuals should use the resid function!

#
# First, the simple test case where I know the anwers
#
afit <- aareg(Surv(time, status) ~ x, test1, dfbeta=T)
temp <- c(rep(0,6),             #intercepts at time 1
          c(2,-1,-1,0,0,0)/9,   #alpha at time 1
          c(0,0,0,2, -1, -1)/9, #intercepts at time 2
          c(0,0,0,-2,1,1)/9)    #alpha at time 2
aeq(afit$dfbeta, temp)

#
#Now a multivariate data set
#
afit <- aareg(Surv(time, status) ~ age + sex + ph.ecog, lung, dfbeta=T)

ord <- order(lung$time, -lung$status)
cfit <- coxph(Surv(time, status) ~ age + sex + ph.ecog, lung[ord,],
	        method='breslow', iter=0, x=T)
cdt  <- coxph.detail(cfit, riskmat=T)

# an arbitrary list of times
acoef <- rowsum(afit$coef, afit$times) #per death time coefs
indx <- match(cdt$time, afit$times)
for (i in c(2,5,27,54,101, 135)) {
    lwho <- (cdt$riskmat[,i]==1)
    lmx <- cfit$x[lwho,]
    lmy <- 1*( cfit$y[lwho,2]==1 & cfit$y[lwho,1] == cdt$time[i])
    fit <- lm(lmy~ lmx)
    cat("i=", i, "coef=", aeq(fit$coef, acoef[i,]))

    rr <- diag(resid(fit))
    zz <- cbind(1,lmx)
    zzinv <- solve(t(zz) %*% zz)
    cat(" twt=", aeq(1/(diag(zzinv)), afit$tweight[indx[i],]))

    df <- t(zzinv %*% t(zz)  %*% rr)
    cat(" dfbeta=", aeq(df, afit$dfbeta[lwho,,i]), "\n")
    }
	  
rm(afit, cfit, cdt, lwho, lmx, lmy, fit, rr, zz, df)


# Repeat it with case weights
ww <- rep(1:5, length=nrow(lung))/ 3.0
afit <- aareg(Surv(time, status) ~ age + sex + ph.ecog, lung, dfbeta=T,
	      weights=ww)
cfit <- coxph(Surv(time, status) ~ age + sex + ph.ecog, lung[ord,],
	        method='breslow', iter=0, x=T, weight=ww[ord])
cdt  <- coxph.detail(cfit, riskmat=T)

acoef <- rowsum(afit$coef, afit$times) #per death time coefs
for (i in c(2,5,27,54,101, 135)) {
    who <- (cdt$riskmat[,i]==1)
    x <- cfit$x[who,]
    y <- 1*( cfit$y[who,2]==1 & cfit$y[who,1] == cdt$time[i])
    w <- cfit$weight[who]
    fit <- lm(y~x, weights=w)
    cat("i=", i, "coef=", aeq(fit$coef, acoef[i,]))

    rr <- diag(resid(fit))
    zz <- cbind(1,x)
    zzinv <- solve(t(zz)%*% (w*zz))
    cat(" twt=", aeq(1/(diag(zzinv)), afit$tweight[indx[i],]))
 
    df <- t(zzinv %*% t(zz) %*% (w*rr))
    cat(" dfbeta=", aeq(df, afit$dfbeta[who,,i]), "\n")
    }
	  
rm(afit, cfit, cdt, who, x, y, fit, rr, zz, df)
rm(ord, acoef)
    
#
# Check that the test statistic computed within aareg and
#  the one recomputed within summary.aareg are the same.
# Of course, they could both be wrong, but at least they'll agree!
# If the maxtime argument is used in summary, it recomputes the test,
#  even if we know that it wouldn't have had to.
#
# Because the 1-variable and >1 variable case have different code, test
#  them both.
#
afit <- aareg(Surv(time, status) ~ age, lung, dfbeta=T)
asum <- summary(afit, maxtime=max(afit$times))
aeq(afit$test.stat, asum$test.stat)
aeq(afit$test.var,  asum$test.var)
aeq(afit$test.var2, asum$test.var2)

print(afit)

afit <- aareg(Surv(time, status) ~ age, lung, dfbeta=T, test='nrisk')
asum <- summary(afit, maxtime=max(afit$times))
aeq(afit$test.stat, asum$test.stat)
aeq(afit$test.var,  asum$test.var)
aeq(afit$test.var2, asum$test.var2)

summary(afit)

#
# Mulitvariate
#
afit <- aareg(Surv(time, status) ~ age + sex + ph.karno + pat.karno, lung,
	      dfbeta=T)
asum <- summary(afit, maxtime=max(afit$times))
aeq(afit$test.stat, asum$test.stat)
aeq(afit$test.var,  asum$test.var)
aeq(afit$test.var2, asum$test.var2)

print(afit)

afit <- aareg(Surv(time, status) ~ age + sex + ph.karno + pat.karno, lung,
	      dfbeta=T, test='nrisk')
asum <- summary(afit, maxtime=max(afit$times))
aeq(afit$test.stat, asum$test.stat)
aeq(afit$test.var,  asum$test.var)
aeq(afit$test.var2, asum$test.var2)

summary(afit)

# Weights play no role in the final computation of the test statistic, given
#  the coefficient matrix, nrisk, and dfbeta as inputs.  (Weights do
#  change the inputs).  So there is no need to reprise the above with
#  case weights.
