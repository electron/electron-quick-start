options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Reproduce example 1 in the SAS lifereg documentation
#

# this fit doesn't give the same log-lik that they claim
motor <- read.table('data.motor', col.names=c('temp', 'time', 'status'))
fit1 <- survreg(Surv(time, status) ~ I(1000/(273.2+temp)), motor,
		subset=(temp>150), dist='lognormal')
summary(fit1)

# This one, with the loglik on the transformed scale (the inappropriate
#   scale, Ripley & Venables would argue) does agree.
# All coefs are of course identical.
fit2 <- survreg(Surv(log(time), status) ~ I(1000/(273.2+temp)), motor,
		subset=(temp>150), dist='gaussian')


# Give the quantile estimates, which is the lower half of "output 48.1.5"
#  in the SAS 9.2 manual

pp1 <- predict(fit1, newdata=list(temp=c(130,150)), p=c(.1, .5, .9),
		      type='quantile', se=T)
pp2 <- predict(fit1, newdata=list(temp=c(130,150)), p=c(.1, .5, .9),
		      type='uquantile', se=T)
pp1

temp130 <- matrix(0, nrow=3, ncol=6)
temp130[,1] <- pp1$fit[1,]
temp130[,2] <- pp1$se.fit[1,]
temp130[,3] <- pp2$fit[1,]
temp130[,4] <- pp2$se.fit[1,]
temp130[,5] <- exp(pp2$fit[1,] - 1.64*pp2$se.fit[1,])
temp130[,6] <- exp(pp2$fit[1,] + 1.64*pp2$se.fit[1,])
dimnames(temp130) <- list(c("p=.1", "p=.2", "p=.3"),
     c("Time", "se(time)", "log(time)", "se[log(time)]", 
       "lower 90", "upper 90"))
print(temp130)

# A set of examples, copied from the manual pages of SAS procedure
#  "reliability", which is part of their QC product.
#

color <- c("black", "red", "green", "blue", "magenta", "red4",
                        "orange", "DarkGreen", "cyan2", "DarkViolet")
palette(color)
pdf(file='reliability.pdf')

#
# Insulating fluids example
#
fluid <- read.table('data.fluid', col.names=c('time', 'voltage'))

# Adding a -1 to the fit just causes the each group to have it's own
# intercept, rather than a global intercept + constrasts.  The strata
# statement allows each to have a separate scale
ffit <- survreg(Surv(time) ~ voltage + strata(voltage) -1, fluid)

# Get predicted quantiles at each of the voltages
# By default predict() would give a line of results for each observation,
#  I only want the unique set of x's, i.e., only 4 cases
uvolt <- sort(unique(fluid$voltage))      #the unique levels
plist <- c(1, 2, 5, 1:9 *10, 95, 99)/100
pred  <- predict(ffit, type='quantile', p=plist,
                 newdata=data.frame(voltage=factor(uvolt)))
tfun <- function(x) log(-log(1-x))

matplot(t(pred), tfun(plist), type='l', log='x', lty=1,
        col=1:4, yaxt='n')
axis(2, tfun(plist), format(100*plist), adj=1)

kfit <- survfit(Surv(time) ~ voltage, fluid, type='fleming') #KM fit
for (i in 1:4) {
    temp <- kfit[i]
    points(temp$time, tfun(1-temp$surv), col=i, pch=i)
    }

# Now a table
temp <- array(0, dim=c(4,4,4))  #4 groups by 4 parameters by 4 stats
temp[,1,1] <- ffit$coef         # "EV Location" in SAS manual
temp[,2,1] <- ffit$scale        # "EV scale"
temp[,3,1] <- exp(ffit$coef)    # "Weibull Scale"
temp[,4,1] <- 1/ffit$scale      # "Weibull Shape"
 
temp[,1,2] <- sqrt(diag(ffit$var))[1:4]   #standard error
temp[,2,2] <- sqrt(diag(ffit$var))[5:8] * ffit$scale
temp[,3,2] <- temp[,1,2] * temp[,3,1]
temp[,4,2] <- temp[,2,2] / (temp[,2,1])^2

temp[,1,3] <- temp[,1,1] - 1.96*temp[,1,2]  #lower conf limits 
temp[,1,4]  <- temp[,1,1] + 1.96*temp[,1,2] # upper
# log(scale) is the natural parameter, in which the routine did its fitting
#  and on which the std errors were computed
temp[,2, 3] <- exp(log(ffit$scale) - 1.96*sqrt(diag(ffit$var))[5:8])
temp[,2, 4] <- exp(log(ffit$scale) + 1.96*sqrt(diag(ffit$var))[5:8])

temp[,3, 3:4] <- exp(temp[,1,3:4])
temp[,4, 3:4] <- 1/temp[,2,4:3]

dimnames(temp) <- list(uvolt, c("EV Location", "EV Scale", "Weibull scale",
                                "Weibull shape"),
                       c("Estimate", "SE", "lower 95% CI", "uppper 95% CI"))
print(aperm(temp, c(2,3,1)), digits=5)

rm(temp, uvolt, plist, pred, ffit, kfit) 

#####################################################################
# Turbine cracks data
cracks <- read.table('data.cracks', col.names=c('time1', 'time2', 'n'))
cfit <- survreg(Surv(time1, time2, type='interval2') ~1, 
                dist='weibull', data=cracks, weight=n)

summary(cfit)
#Their output also has Wiebull scale = exp(cfit$coef), shape = 1/(cfit$scale)

# Draw the SAS plot
#  The "type=fleming" argument reflects that they estimate hazards rather than
#  survival, and forces a Nelson-Aalen hazard estimate
#
plist <-  c(1, 2, 5, 1:8 *10)/100
plot(qsurvreg(plist, cfit$coef, cfit$scale), tfun(plist), log='x',
     yaxt='n', type='l',
     xlab="Weibull Plot for Time", ylab="Percent")
axis(2, tfun(plist), format(100*plist), adj=1)

kfit <- survfit(Surv(time1, time2, type='interval2') ~1, data=cracks,
                weight=n, type='fleming')
# Only plot point where n.event > 0 
# Why?  I'm trying to match them.  Personally, all should be plotted.
who <- (kfit$n.event > 0)
points(kfit$time[who], tfun(1-kfit$surv[who]), pch='+')
points(kfit$time[who], tfun(1-kfit$upper[who]), pch='-')
points(kfit$time[who], tfun(1-kfit$lower[who]), pch='-')

text(rep(3,6), seq(.5, -1.0, length=6), 
         c("Scale", "Shape", "Right Censored", "Left Censored", 
           "Interval Censored", "Fit"), adj=0)
text(rep(9,6), seq(.5, -1.0, length=6), 
         c(format(round(exp(cfit$coef), 2)),
           format(round(1/cfit$scale, 2)),
           format(tapply(cracks$n, cfit$y[,3], sum)), "ML"), adj=1)

# Now a portion of his percentiles table
#  I don't get the same SE as SAS, I haven't checked out why.  The
#  estimates and se for the underlying Weibull model are the same.
temp <- predict(cfit, type='quantile', p=plist, se=T)
tempse <- sqrt(temp$se[1,])
mat <- cbind(temp$fit[1,], tempse, 
             temp$fit[1,] -1.96*tempse, temp$fit[1,] + 1.96*tempse)
dimnames(mat) <- list(plist*100, c("Estimate", "SE", "Lower .95", "Upper .95"))
print(mat)

#
# The cracks data has a particularly easy estimate, so use
# it to double check code
time <- c(cracks$time2[1], (cracks$time1 + cracks$time2)[2:8]/2, 
          cracks$time1[9])
cdf  <- cumsum(cracks$n)/sum(cracks$n)
all.equal(kfit$time, time)
all.equal(kfit$surv, 1-cdf[c(1:8,8)]) 
rm(time, cdf, kfit)


#######################################################
#
# Valve data
#   The input data has id, time, and an indicator of whether there was an
#   event at that time: -1=no, 1=yes.  No one has an event at their last time.
#  Convert the data to (start, stop] form
#  The input data has two engines with dual failures: 328 loses 2 valves at 
#    time 653, and number 402 loses 2 at time 139.  For each, fudge the first
#    time to be .1 days earlier.
#
temp <- matrix(scan('data.valve'), byrow=T, ncol=3)

n <- nrow(temp)
valve <- data.frame(id=temp[,1], 
                    time1 = c(0, ifelse(diff(temp[,1])==0, temp[-n,2],0)),
                    time2 = temp[,2],
                    status= as.numeric(temp[,3]==1))

indx <- (1:nrow(valve))[valve$time1==valve$time2]
valve$time1[indx]   <- valve$time1[indx] - .1
valve$time2[indx-1] <- valve$time2[indx-1] - .1

kfit <- survfit(Surv(time1, time2, status) ~1, valve, type='fh2')

plot(kfit, fun='cumhaz', ylab="Sample Mean Cumulative Failures", xlab='Time',
     ylim=range(-log(kfit$lower)))
title("Valve replacement data")

# The summary.survfit function doesn't have an option for printing out
#   cumulative hazards instead of survival --- need to add that
#   so I just reprise the central code of print.summary.survfit
xx <- summary(kfit)
temp <- cbind(xx$time, xx$n.risk, xx$n.event, -log(xx$surv), 
              xx$std.err/xx$surv, -log(xx$upper), -log(xx$lower))
dimnames(temp) <- list(rep("", nrow(temp)),
                       c("time", "n.risk", "n.event", "Cum haz", "std.err",
                         "lower 95%", "upper 95%"))
print(temp, digits=2)

# Note that I have the same estimates but different SE's.  We are using a
#  different estimator. It's a statistical argument as to which is
#  better (one could defend both sides): do you favor JASA or Technometrics?
rm(temp, kfit, indx, xx)
                    
######################################################
# Turbine data, lognormal fit
turbine <- read.table('data.turbine', 
                      col.names=c("time1", "time2", "n"))

tfit <- survreg(Surv(time1, time2, type='interval2') ~1, turbine,
                dist='lognormal', weights=n, subset=(n>0))

summary(tfit)

# Now, do his plot, but put bootstrap confidence bands on it!
#  First, make a simple data set without weights
tdata <- turbine[rep(1:nrow(turbine), turbine$n),]

qstat <- function(data) {
    temp <- survreg(Surv(time1, time2, type='interval2') ~1, data=data,
                    dist='lognormal')
    qsurvreg(plist, temp$coef, temp$scale, dist='lognormal')
    }

{if (exists('bootstrap')) {
    set.seed(1953)  # a good year :-)
    bfit <- bootstrap(tdata, qstat, B=1000)
    bci <- limits.bca(bfit, probs=c(.025, .975))
    }
else {
    values <- matrix(0, nrow=1000, ncol=length(plist))
    n <- nrow(tdata)
    for (i in 1:1000) {
        subset <- sample(1:n, n, replace=T)
        values[i,] <- qstat(tdata[subset,])
        }
    bci <- t(apply(values,2, quantile, c(.05, .95)))
    }
 }
xmat <- cbind(qsurvreg(plist, tfit$coef, tfit$scale, dist='lognormal'),
              bci)


matplot(xmat, qnorm(plist), 
        type='l', lty=c(1,2,2), col=c(1,1,1), 
        log='x', yaxt='n', ylab='Percent', 
        xlab='Time of Cracking (Hours x 100)')
axis(2, qnorm(plist), format(100*plist), adj=1)
title("Turbine Data")
kfit <- survfit(Surv(time1, time2, type='interval2') ~1, data=tdata)
points(kfit$time, qnorm(1-kfit$surv), pch='+')

dev.off()  #close the plot file

