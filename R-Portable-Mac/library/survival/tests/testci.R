options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)
aeq <- function(x,y,...) all.equal(as.vector(x), as.vector(y),...)

#
# Test out the survfit.ci function, which does competing risk
#   estimates
#
# First trivial test
tdata <- data.frame(time=c(1,2,2,3,3,3,5,6),
                    status = c(0,1,0,1,0,1,0,1),
                    event =  c(1,1,2,2,1,2,3,2),
                    grp = c(1,2,1,2,1,2,1,2))
fit <- survfit(Surv(time, status*event, type='mstate') ~1, tdata)

byhand <- function() {
    #everyone starts in state 0
    p1 <- c(1,0,0)

    p2 <- c(6/7, 1/7, 0)  # 0-1 transition at time 2
    u2 <- matrix(rep(c(1/49, -1/49, 0), each=8), ncol=3) #leverage matrix at time 2
    u2[1,] <- 0  #subject 1 is not present
    u2[2,1:2] <- u2[2, 1:2] + c(-1/7, 1/7)

    p3 <- c((6/7)*(3/5), 1/7, 12/35) # 0-2 transition at time 3, 5 at risk
    h3 <- matrix(c(3/5, 0, 2/5, 0,1,0, 0,1,0), byrow=T, ncol=3) #hazard mat
    u3 <- u2 %*% h3
    u3[4:8,1] <- u3[4:8,1] + p2[1]*2/25
    u3[4:8,3] <- u3[4:8,3]  -p2[1]*2/25
    u3[4,] <- u3[4,] + c(-p2[1]/5, 0, p2[1]/5)
    u3[6,] <- u3[4,]
 
    p6 <- c(0, 1/7, 6/7) # 0-2 at time 6, 1 at risk
    h6 <- matrix(c(-1,0,1,0,1,0,0,1,0), byrow=T, ncol=3)
    u6 <- cbind(0, u3[,2], -u3[,2])
    
    V <- rbind(0, colSums(u2^2), 
                  colSums(u3^2),
                  colSums(u3^2),
                  colSums(u6^2))
    list(P=rbind(p1, p2, p3, p3, p6), u2=u2, u3=u3, u6=u6, V=V)
}
bfit <- byhand()
aeq(fit$pstate, bfit$P[,c(2,3,1)])
aeq(fit$n.risk[,3], c(8,7,5,2,1))
aeq(fit$n.event[,1:2], c(0,1,0,0,0, 0,0 ,2,0,1))
aeq(fit$std^2, bfit$V[,c(2,3,1)])

# Times purposely has values that are before the start, exact, intermediate
#  and after the end of the observed times
sfit <- summary(fit, times=c(0, 1, 3.5, 6, 7), extend=TRUE)
aeq(sfit$pstate, rbind(c(0,0,1), bfit$P[c(1,3,5,5), c(2,3,1)]))
aeq(sfit$n.risk[,3], c(8,8, 2, 1, 0))
aeq(sfit$n.event,  matrix(c(0,0,1,0,0, 0,0,2,1,0, 0,0,0,0,0), ncol=3))

#
# For this we need the competing risks MGUS data set, first
#  event
#
tdata <- mgus1[mgus1$enum==1,]
# Ensure the old-style call using "etype" works (backwards compatability)
fit1 <- survfit(Surv(stop, status) ~ 1, etype=event, tdata)
fit1b <-survfit(Surv(stop, event) ~1, tdata)
indx <- match("call", names(fit1)) 
all.equal(unclass(fit1)[-indx], unclass(fit1b)[-indx])

# Now get the overall survival, and the hazard for progression
fit2 <- survfit(Surv(stop, status) ~1, tdata)  #overall to "first bad thing"
fit3 <- survfit(Surv(stop, status*(event=='pcm')) ~1, tdata,
                type='fleming')
fit4 <- survfit(Surv(stop, status*(event=='death')) ~1, tdata,
                type='fleming')

aeq(fit1$n.risk[,3], fit2$n.risk)
aeq(rowSums(fit1$n.event), fit2$n.event)

# Classic CI formula
#  integral [hazard(t) S(t-0) dt], where S= "survival to first event"
haz1 <- diff(c(0, -log(fit3$surv))) #Aalen hazard estimate for progression
haz2 <- diff(c(0, -log(fit4$surv))) #Aalen estimate for death
tsurv <- c(1, fit2$surv[-length(fit2$surv)])  #lagged survival
ci1 <- cumsum(haz1 *tsurv)
ci2 <- cumsum(haz2 *tsurv)
aeq(cbind(ci1, ci2), fit1$pstate[,1:2])

#
# Now, make sure that it works for subgroups
#
fit1 <- survfit(Surv(stop, event) ~ sex, tdata)
fit2 <- survfit(Surv(stop, event) ~ 1, tdata,
                        subset=(sex=='female'))
fit3 <- survfit(Surv(stop, event) ~ 1, tdata,
                   subset=(sex=='male'))

aeq(fit2$pstate, fit1$pstate[1:fit1$strata[1],])
aeq(fit2$std, fit1$std[1:fit1$strata[1],])
aeq(fit3$pstate, fit1$pstate[-(1:fit1$strata[1]),])

#  A second test of cumulative incidence
# compare results to Bob Gray's functions
#  The file gray1 is the result of 
#    library(cmprsk)
#    tstat <- ifelse(tdata$status==0, 0, 1+ (tdata$event=='death'))
#    gray1 <- cuminc(tdata$stop, tstat)
load("gray1.rda")
fit2 <- survfit(Surv(stop, event) ~ 1, tdata)

if (FALSE) {
    # lines of the two graphs should overlay
    plot(gray1[[1]]$time, gray1[[1]]$est, type='l',
         ylim=range(c(gray1[[1]]$est, gray1[[2]]$est)),
         xlab="Time")
    lines(gray1[[2]]$time, gray1[[2]]$est, lty=2)
    matlines(fit2$time, fit2$pstate, col=2, lty=1:2, type='s')
}
# To formally match these is a bit of a nuisance.
#  The cuminc function returns a full step function, and survfit only
# the bottoms of the steps.
temp1 <- tapply(gray1[[1]]$est, gray1[[1]]$time, max)[-1]  #toss time 0
indx1 <- match(names(temp1), fit2$time)
aeq(temp1, fit2$pstate[indx1,1])
    
