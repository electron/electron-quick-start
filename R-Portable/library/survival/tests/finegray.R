library(survival)
# Test data set 1 for Fine-Gray regression
fdata <- data.frame(time  =c(1,2,3,4,4,4,5,5,6,8,8, 9,10,12),
                    status=factor(c(1,2,0,1,0,0,2,1,0,0,2, 0,1 ,0), 0:2,
                             c("cen", "type1", "type2")),      
                    x     =c(5,4,3,1,2,1,1,2,2,4,6,1,2, 0),
                    id = 1:14)
test1 <- finegray(Surv(time, status) ~., fdata, count="fgcount")
test2 <- finegray(Surv(time, status) ~x, fdata, etype="type2")

# When creating the censoring time distribution remember that
#  censors happen after deaths, so the distribution does not drop until
#  time 3+, 4+, 6+, 8+ and 9+
csurv <- list(time=c(0, 3, 4, 6, 8, 9),
              p = cumprod(c(1, 11/12, 8/10, 5/6, 3/4, 2/3)))
#
# For estimation of event type 1, the first subject of event type
#  2 will have weights of curve$p over (0,3], (3,4], (4,6], (6,8], (8,9] 
#  and (9,12].  All that really matters is the weight at times 1, 4, 5,
#  and 10, however, which are the points at which events of type 1 happen
#  
# The next subject of event type 2 occurs at time 5, and will have a
#  weight of (9,12] /(4,5] = (5*4*2)/(7*5*3) = 8/21 at time 10.  The last
#  censor at time 6 has a weight of 2/3 at time 10.

all.equal(test1$id, c(1, 2,2,2,2, 3:6, 7, 7, 8:11, 11, 12:14))
twt <- c(1, csurv$p[c(1,2,3,6)], 1,1,1, 1, 1, 5/12, 1,1,1,  
                         1, 1/2, 1,1,1)
all.equal(test1$fgwt, twt)
#extra obs will end at times found in csurv$time, or max(time)=12
all.equal(test1$fgstop[test1$fgcount>0], c(4,6,12, 12,12))

#
# Verify the data reproduces a multi-state curve
#  censoring times may be different in the two setups so only 
#  compare at the event times
sfit <- survfit(Surv(time, status) ~1, fdata)
sfit1<- survfit(Surv(fgstart, fgstop, fgstatus) ~1, test1, weight=fgwt)
i1 <- sfit$n.event[,1] > 0
i2 <- sfit1$n.event > 0
all.equal(sfit$pstate[i1, 1], 1- sfit1$surv[i2])

sfit2 <- survfit(Surv(fgstart, fgstop, fgstatus) ~1, test2, weight=fgwt)
i1 <- sfit$n.event[,2] > 0
i2 <- sfit2$n.event > 0
all.equal(sfit$pstate[i1, 2], 1- sfit2$surv[i2])

# Test strata.  Make a single data set that has fdata for the first 19
#  rows, then fdata with outcomes switched for the second 19.  It should
#  reprise test1 and test2 in a single call.
fdata2 <- rbind(fdata, fdata)
fdata2$group <- rep(1:2, each=nrow(fdata))
temp <- c(1,3,2)[as.numeric(fdata$status)]
fdata2$status[fdata2$group==2] <- factor(temp, 1:3, levels(fdata$status))
test3 <- finegray(Surv(time, status) ~ .+ strata(group), fdata2)
vtemp <- c("fgstart", "fgstop", "fgstatus", "fgwt")
all.equal(test3[1:19, vtemp], test1[,vtemp])
all.equal(test3[20:38, vtemp], test2[,vtemp], check.attributes=FALSE)

#
# Test data set 2: use the larger MGUS data set
#  Time is in months which leads to lots of ties
etime <- with(mgus2, ifelse(pstat==0, futime, ptime))
event <- with(mgus2, ifelse(pstat==0, 2*death, 1))
e2 <- factor(event, 0:2, c('censor', 'pcm', 'death'))
edata <- finegray(Surv(etime, e2) ~ sex + id, mgus2, etype="pcm")

# Build G(t) = the KM of the censoring distribution
# An event at time x is not "at risk" for censoring at time x (Geskus 2011)
tt <- sort(unique(etime))  # all the times
ntime <- length(tt)
nrisk <- nevent <- double(ntime)
for (i in 1:ntime) {
    nrisk[i] <- sum((etime > tt[i] & event >0) | (etime >= tt[i] & event==0))
    nevent[i] <- sum(etime == tt[i] & event==0)
}
G <- cumprod(1- nevent/nrisk)

# The weight is defined as w(t)= G(t-)/G(s-) where s is the event time
# for a subject who experiences an endpoint other then the one of interest
type2 <- event[edata$id]==2  # the rows to be expanded
# These rows are copied over as is: endpoint 1 and censors
all(edata$fgstop[!type2] == etime[edata$id[!type2]])
all(edata$fgstart[!type2] ==0) 
all(edata$fgwt[!type2] ==1)

tdata <- edata[type2,]  #expanded rows
first <- match(tdata$id, tdata$id)  #points to the first row for each subject
Gwt <- c(1, G)[match(tdata$fgstop, tt)]  # G(t-)
all.equal(tdata$fgwt, Gwt/Gwt[first])

# Test data 3, left truncation.
# Ties are assumed to be ordered as event, censor, entry
# H(t) = truncation distribution, and is calculated on a reverse time scale
# Since there is only one row per subject every obs is a "start" event.
# Per equation 5 and 6 of Geskus both G and H are right continuous functions
#  (the value at t- epsilon is different than the value at t).
fdata <- data.frame(time1 = c(0,0,0,3,2,0,0,1,0,7,5, 0, 0, 0),
                    time2 = c(1,2,3,4,4,4,5,5,6,8,8, 9,10,12),
                    status= c(1,2,0,1,0,0,2,1,0,0,2, 0, 1 ,0), 
                    x     = c(5,4,3,1,2,1,1,2,2,4,6, 1, 2, 0),
                    id = 1:14)
tt <- sort(unique(c(fdata$time1, fdata$time2)))
ntime <- length(tt)
Grisk <- Gevent <- double(ntime)
Hrisk <- Hevent <- double(ntime)
for (i in 1:ntime) {
    Grisk[i] <- with(fdata, sum((time2 > tt[i] & status >0 & time1 < tt[i]) | 
                                (time2 >= tt[i] & status ==0 & time1 < tt[i])))
    Gevent[i]<- with(fdata, sum(time2 == tt[i] & status==0))
    Hrisk[i] <- with(fdata, sum(time2 > tt[i] & time1 <= tt[i]))
    Hevent[i]<- with(fdata, sum(time1 == tt[i]))
}
G <- cumprod(1- Gevent/pmax(1,Grisk))
G2 <- survfit(Surv(time1, time2 - .1*(status !=0), status==0) ~1, fdata)
all.equal(G2$surv[G2$n.event>0], G[Gevent>0])

H <- double(ntime)
# The loop below uses the definition of equation 6 in Geskus
for (i in 1:ntime) 
    H[i] <- prod((1- Hevent/pmax(1, Hrisk))[-(i:1)])
H2 <- rev(cumprod(rev(1 - Hevent/pmax(1, Hrisk))))  #alternate form
H3 <- survfit(Surv(-time2, -time1, rep(1,14)) ~1, fdata) # alternate 3
all.equal(tt, -rev(H3$time))
# c(0,H) = H(t-), H2 = H(t-) already due to the time reversal
all.equal(c(0, H), c(H2, 1))  
all.equal(H2, rev(H3$surv))

fg <- finegray(Surv(time1, time2, factor(status, 0:2)) ~ x, id=id, fdata)
stat2 <- !is.na(match(fg$id, fdata$id[fdata$status==2]))  #expanded ids
all(fg$fgwt[!stat2] ==1)  #ordinary rows are left alone
all(fg$fgstart[!stat2] == fdata$time1[fdata$status !=2])
all(fg$fgstop[!stat2]  == fdata$time2[fdata$status !=2])

tdata <- fg[stat2,]
index <- match(tdata$id, tdata$id)   # points to the first row for each
Gwt <- c(1, G)[match(tdata$fgstop, tt)]  # G(t-)
Hwt <- c(0, H)[match(tdata$fgstop, tt)]  # H(t-)
all.equal(tdata$fgwt,  Gwt*Hwt/(Gwt*Hwt)[index])

#
# Test data 4: mgus2 data on age scale
#  The answer is incorrect due to roundoff, but consistent
#
start <- mgus2$age  # age in years
end   <- start + etime/12  #etime in months
tt <- sort(unique(c(start, end)))  # all the times
ntime <- length(tt)
Grisk <- Gevent <-  double(ntime)
Hrisk <- Hevent <-  double(ntime)
for (i in 1:ntime) {
    Grisk[i] <- sum(((end > tt[i] & event >0) | (end >= tt[i] & event==0)) &
                      (tt[i] > start))
    Gevent[i] <- sum(end == tt[i] & event==0)
    Hrisk[i]  <- sum(start <= tt[i] & end > tt[i])
    Hevent[i] <- sum(start == tt[i])
}
G <- cumprod(1 - Gevent/pmax(1, Grisk))         # pmax to avoid 0/0
H <- rev(cumprod(rev(1-Hevent/pmax(1,Hrisk))))
H <- c(H[-1], 1)  #make it right continuous

wdata <- finegray(Surv(start, end, e2) ~ ., id=id, mgus2, timefix=FALSE)
type2 <- event[wdata$id]==2  # the rows to be expanded
tdata <- wdata[type2,]
first <- match(tdata$id, tdata$id)

Gwt <- c(1, G)[match(tdata$fgstop, tt)]  # G(t-)
Hwt <- c(0, H)[match(tdata$fgstop, tt)]  # H(t-)
all.equal(tdata$fgwt,  (Gwt/Gwt[first]) * (Hwt / Hwt[first]))

