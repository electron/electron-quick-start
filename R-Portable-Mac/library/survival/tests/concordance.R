library(survival)
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type

#
# Simple tests of concordance.  These numbers were derived in multiple
#   codes.
#
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

grank <- function(x, time, grp, wt) 
    unlist(tapply(x, grp, rank))
grank2 <- function(x, time, grp, wt) {  #for case weights
    if (length(wt)==0) wt <- rep(1, length(x))
    z <- double(length(x))
    for (i in unique(grp)) {
        indx <- which(grp==i)
        temp <- tapply(wt[indx], x[indx], sum)
        temp <- temp/2  + c(0, cumsum(temp)[-length(temp)])
        z[indx] <- temp[match(x[indx], names(temp))]
    }
    z
}


tdata <- aml[aml$x=='Maintained',]
tdata$y <- c(1,6,2,7,3,7,3,8,4,4,5)
tdata$wt <- c(1,2,3,2,1,2,3,4,3,2,1)
fit <- survConcordance(Surv(time, status) ~y, tdata)
aeq(fit$stats[1:4], c(14,24,2,0))
cfit <- coxph(Surv(time, status) ~ tt(y), tdata, tt=grank, method='breslow',
              iter=0, x=T)
cdt <- coxph.detail(cfit)
aeq(4*sum(cdt$imat),fit$stats[5]^2) 
aeq(2*sum(cdt$score), diff(fit$stats[2:1]))


# Lots of ties
tempx <- Surv(c(1,2,2,2,3,4,4,4,5,2), c(1,0,1,0,1,0,1,1,0,1))
tempy <- c(5,5,4,4,3,3,7,6,5,4)
fit2 <- survConcordance(tempx ~ tempy)
aeq(fit2$stats[1:4], c(13,13,5,2))
cfit2 <-  coxph(tempx ~ tt(tempy), tt=grank, method='breslow', iter=0)
aeq(4/cfit2$var, fit2$stats[5]^2)

# Bigger data
fit3 <- survConcordance(Surv(time, status) ~ age, lung)
aeq(fit3$stats[1:4], c(10717, 8706, 591, 28))
cfit3 <- coxph(Surv(time, status) ~ tt(age), lung, 
               iter=0, method='breslow', tt=grank, x=T)
cdt <- coxph.detail(cfit3)
aeq(4*sum(cdt$imat),fit3$stats[5]^2) 
aeq(2*sum(cdt$score), diff(fit3$stats[2:1]))


# More ties
fit4 <- survConcordance(Surv(time, status) ~ ph.ecog, lung)
aeq(fit4$stats[1:4], c(8392, 4258, 7137, 28))
cfit4 <- coxph(Surv(time, status) ~ tt(ph.ecog), lung, 
               iter=0, method='breslow', tt=grank)
aeq(4/cfit4$var, fit4$stats[5]^2)

# Case weights
fit5 <- survConcordance(Surv(time, status) ~ y, tdata, weight=wt)
fit6 <- survConcordance(Surv(time, status) ~y, tdata[rep(1:11,tdata$wt),])
aeq(fit5$stats[1:4], c(70, 91, 7, 0))  # checked by hand
aeq(fit5$stats[1:3], fit6$stats[1:3])  #spurious "tied on time" value, ignore
aeq(fit5$std, fit6$std)
cfit5 <- coxph(Surv(time, status) ~ tt(y), tdata, weight=wt, 
               iter=0, method='breslow', tt=grank2)
cfit6 <- coxph(Surv(time, status) ~ tt(y), tdata[rep(1:11,tdata$wt),], 
               iter=0, method='breslow', tt=grank)
aeq(4/cfit6$var, fit6$stats[5]^2)
aeq(cfit5$var, cfit6$var)

# Start, stop simplest cases
fit7 <- survConcordance(Surv(rep(0,11), time, status) ~ y, tdata)
aeq(fit7$stats, fit$stats)
aeq(fit7$std.err, fit$std.err)
fit7 <- survConcordance(Surv(rep(0,11), time, status) ~ y, tdata, weight=wt)
aeq(fit5$stats, fit7$stats)

# Multiple intervals for some, but same risk sets as tdata
tdata2 <- data.frame(time1=c(0,3, 5,  6,7,   0,  4,17,  7,  0,16,  2,  0, 
                             0,9, 5),
                     time2=c(3,9, 13, 7,13, 18, 17,23, 28, 16,31, 34, 45, 
                             9,48, 60),
                     status=c(0,1, 1, 0,0,  1,  0,1, 0, 0,1, 1, 0, 0,1, 0),
                     y = c(1,1, 6, 2,2, 7, 3,3, 7, 3,3, 8, 4, 4,4, 5),
                     wt= c(1,1, 2, 3,3, 2, 1,1, 2, 3,3, 4, 3, 2,2, 1))
fit8 <- survConcordance(Surv(time1, time2, status) ~y, tdata2, weight=wt)
aeq(fit5$stats, fit8$stats)
aeq(fit5$std.err, fit8$std.err)
cfit8 <- coxph(Surv(time1, time2, status) ~ tt(y), tdata2, weight=wt, 
               iter=0, method='breslow', tt=grank2)
aeq(4/cfit8$var, fit8$stats[5]^2)
aeq(fit8$stats[5]/(2*sum(fit8$stats[1:3])), fit8$std.err)

# Stratified
tdata3 <- data.frame(time1=c(tdata2$time1, rep(0, nrow(lung))),
                     time2=c(tdata2$time2, lung$time),
                     status = c(tdata2$status, lung$status -1),
                     x = c(tdata2$y, lung$ph.ecog),
                     wt= c(tdata2$wt, rep(1, nrow(lung))),
                     grp=rep(1:2, c(nrow(tdata2), nrow(lung))))
fit9 <- survConcordance(Surv(time1, time2, status) ~x + strata(grp),
                        data=tdata3, weight=wt)
aeq(fit9$stats[1,], fit5$stats)
aeq(fit9$stats[2,], fit4$stats)
