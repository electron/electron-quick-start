### R code from vignette source 'multi.Rnw'

###################################################
### code chunk number 1: multi.Rnw:32-75
###################################################
require(survival)
#require(Rcolorbrewer)
#brewer.pal(5, "Dark2")
palette(c("#000000", "#D95F02", "#1B9E77", "#7570B3", "#E7298A", "#66A61E"))
options(continue=' ')

# These functions are used in the document, but not discussed until the end
crisk <- function(what, horizontal = TRUE, ...) {
    nstate <- length(what)
    connect <- matrix(0, nstate, nstate,
                      dimnames=list(what, what))
    connect[1,-1] <- 1  # an arrow from state 1 to each of the others
    if (horizontal) statefig(c(1, nstate-1),  connect, ...)
    else statefig(matrix(c(1, nstate-1), ncol=1), connect, ...)
}

state3 <- function(what, horizontal=TRUE, ...) {
    if (length(what) != 3) stop("Should be 3 states")
    connect <- matrix(c(0,0,0, 1,0,0, 1,1,0), 3,3,
                      dimnames=list(what, what))
    if (horizontal) statefig(1:2, connect, ...)
    else statefig(matrix(1:2, ncol=1), connect, ...)
}

state4 <- function() {
    sname <- c("Entry", "CR", "Transplant", "Transplant")
    layout <- cbind(c(1/2, 3/4, 1/4, 3/4),
                    c(5/6, 1/2, 1/2, 1/6))
    connect <- matrix(0,4,4, dimnames=list(sname, sname))
    connect[1, 2:3] <- 1
    connect[2,4] <- 1
    statefig(layout, connect)
}

state5 <- function(what, ...) {
    sname <- c("Entry", "CR", "Tx", "Rel", "Death")
    connect <- matrix(0, 5, 5, dimnames=list(sname, sname))
    connect[1, -1] <- c(1,1,1, 1.4)
    connect[2, 3:5] <- c(1, 1.4, 1)
    connect[3, c(2,4,5)] <- 1
    connect[4, c(3,5)]  <- 1
    statefig(matrix(c(1,3,1)), connect, cex=.8,...)
}


###################################################
### code chunk number 2: multi.Rnw:81-82 (eval = FALSE)
###################################################
## curves <- survfit(Surv(time, status) ~ group, data=mydata)


###################################################
### code chunk number 3: simple1
###################################################
set.seed(1952)
crdata <- data.frame(time=1:11, 
                     endpoint=factor(c(1,1,2,0,1,1,3,0,2,3,0),
                                     labels=c("censor", "a", "b", "c")))
tfit  <- survfit(Surv(time, endpoint) ~ 1, data=crdata)
dim(tfit)
summary(tfit)


###################################################
### code chunk number 4: multi.Rnw:112-113
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(tfit, col=1:3, lwd=2, ylab="Probability in state")


###################################################
### code chunk number 5: overall
###################################################
myeloid[1:5,]


###################################################
### code chunk number 6: sfit0
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit0 <- survfit(Surv(futime, death) ~ trt, myeloid)
plot(sfit0, xscale=365.25, xaxs='r', col=1:2, lwd=2,
     xlab="Years post enrollment", ylab="Survival")
legend(20, .4, c("Arm A", "Arm B"),
       col=1:2, lwd=2, bty='n')


###################################################
### code chunk number 7: data1
###################################################
data1 <- myeloid
data1$crstat <- factor(with(data1, ifelse(is.na(crtime), death, 2)),
                        labels=c("censor", "death", "CR"))
data1$crtime <- with(data1, ifelse(crstat=="CR", crtime, futime))

data1$txstat <- factor(with(data1, ifelse(is.na(txtime), death, 2)),
                        labels=c("censor", "death", "transplant"))
data1$txtime <- with(data1, ifelse(txstat=="transplant", txtime, futime))
for (i in c("futime", "crtime", "txtime", "rltime"))
    data1[[i]] <- data1[[i]] * 12/365.25  #rescale to months


###################################################
### code chunk number 8: curve1
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit1 <- survfit(Surv(futime, death) ~ trt, data1) #survival
sfit2 <- survfit(Surv(crtime, crstat) ~ trt, data1) # CR
sfit3 <- survfit(Surv(txtime, txstat) ~ trt, data1)

layout(matrix(c(1,1,1,2,3,4), 3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))
plot(sfit2[,2], mark.time=FALSE, fun='event', xmax=48,
         lty=3, lwd=2, col=1:2, xaxt='n',
     xlab="Months post enrollment", ylab="Events")
lines(sfit1, mark.time=FALSE, xmax=48, fun='event', col=1:2, lwd=2)
lines(sfit3[,2], mark.time=FALSE, xmax=48, fun='event', col=1:2, 
          lty=2, lwd=2)

xtime <- c(0, 6, 12, 24, 36, 48)
axis(1, xtime, xtime) #marks every year rather than 10 months
temp <- outer(c("A", "B"), c("death", "transplant", "CR"),  paste)
temp[7] <- ""
legend(25, .3, temp[c(1,2,7,3,4,7,5,6,7)], lty=c(1,1,1, 2,2,2 ,3,3,3),
       col=c(1,2,0), bty='n', lwd=2)
abline(v=2, lty=2, col=3)

# add the state space diagrams
par(mar=c(4,.1,1,1))
crisk(c("Entry","Death", "CR"), alty=3)
crisk(c("Entry","Death", "Tx"), alty=2)
crisk(c("Entry","Death"))
par(oldpar)


###################################################
### code chunk number 9: badfit
###################################################
getOption("SweaveHooks")[["fig"]]()
badfit <- survfit(Surv(txtime, txstat=="transplant") ~ trt, data1)

layout(matrix(c(1,1,1,2,3,4), 3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))
plot(badfit, fun="event", xmax=48, xaxt='n', col=1:2, lty=2, lwd=2,
     xlab="Months from enrollment", ylab="P(state)")
axis(1, xtime, xtime)
lines(sfit3[,2], fun='event',  xmax=48, col=1:2, lwd=2)
legend(24, .3, c("Arm A", "Arm B"), lty=1, lwd=2,
       col=1:2, bty='n', cex=1.2)

par(mar=c(4,.1,1,1))
crisk(c("Entry", "transplant"), alty=2, cex=1.2)
crisk(c("Entry","transplant", "Death"), cex=1.2)
par(oldpar)


###################################################
### code chunk number 10: <data2
###################################################
temp <- myeloid
id <- which(temp$crtime == temp$txtime) # the one special person
temp$crtime[id] <- temp$crtime[id] -1   # move their CR back by 1 day
data2 <- tmerge(myeloid[, c('id', 'trt')], temp,
                 id=id, death=event(futime, death),
                        transplant = event(txtime),
                        response   = event(crtime),
                        relapse    = event(rltime),
                        priortx    = tdc(txtime),
                        priorcr    = tdc(crtime))
attr(data2, "tcount")

data2$event <- with(data2, factor(death + 2*response + 3*transplant + 
                                4*relapse, 0:4,
                                labels=c("censor", "death", "CR", 
                                         "transplant", "relapse")))
data2[1:10,c(1:4, 11, 9, 10)]


###################################################
### code chunk number 11: data2b
###################################################
for (i in c("tstart", "tstop"))
    data2[[i]] <- data2[[i]] *12/365.25  #scale to months

ctab <- table(table(data2$id))
ctab
with(data2, table( table(id, event)))

etab <- table(data2$event, useNA="ifany")
etab


###################################################
### code chunk number 12: cr2
###################################################
getOption("SweaveHooks")[["fig"]]()
crstat <- data2$event
crstat[crstat=="transplant"] <- "censor" # ignore transplants
crsurv <- survfit(Surv(tstart, tstop, crstat) ~ trt,
                  data= data2, id=id, influence=TRUE)

layout(matrix(c(1,1,2,3), 2,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))
plot(sfit2[,2], lty=3, lwd=2, col=1:2, xmax=12, 
     xlab="Months", ylab="CR")
lines(crsurv[,2], lty=1, lwd=2, col=1:2, xmax=12)
par(mar=c(4, .1, 1, 1))
crisk( c("Entry","CR", "Death"), alty=3)
state3(c("Entry", "CR", "Death/Relapse"))

par(oldpar)


###################################################
### code chunk number 13: cr2b
###################################################
print(crsurv, rmean=48, digits=2)


###################################################
### code chunk number 14: cr2c
###################################################
temp <- summary(crsurv, rmean=48)$table
delta <- round(temp[4,3] - temp[3,3], 2)


###################################################
### code chunk number 15: txsurv
###################################################
getOption("SweaveHooks")[["fig"]]()
event2 <- with(data2, ifelse(event=="transplant" & priorcr==1, 6,
               as.numeric(event)))
event2 <- factor(event2, 1:6, c(levels(data2$event), "tx after CR"))
txsurv <- survfit(Surv(tstart, tstop, event2) ~ trt, data2, id=id,
                  subset=(priortx ==0))

layout(matrix(c(1,1,1,2,2,0),3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1,.1))
plot(txsurv[,c(3,5)], col=1:2, lty=c(1,1,2,2), lwd=2, xmax=48,
     xaxt='n', xlab="Months", ylab="Transplanted")
axis(1, xtime, xtime)
legend(15, .13, c("A, transplant without CR", "B, transplant without CR",
                 "A, transplant after CR", "B, transplant after CR"),
       col=1:2, lty=c(1,1,2,2), lwd=2, bty='n')
state4()  # add the state figure
par(oldpar)


###################################################
### code chunk number 16: sfit4
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit4 <- survfit(Surv(tstart, tstop, event) ~ trt, data2, id=id)
sfit4$transitions
layout(matrix(1:2,1,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1,.1))
plot(sfit4, col=rep(1:4,each=2), lwd=2, lty=1:2, xmax=48, xaxt='n',
     xlab="Months", ylab="Current state")
axis(1, xtime, xtime)
text(c(40, 40, 40, 40), c(.51, .13, .32, .01),
     c("Death", "CR", "Transplant", "Recurrence"), col=1:4)

par(mar=c(5.1, .1, 1, .1))
state5()
par(oldpar)


###################################################
### code chunk number 17: reprise
###################################################
crsurv <- survfit(Surv(tstart, tstop, crstat) ~ trt,
                  data= data2, id=id, influence=TRUE)
curveA <- crsurv[1,]  # select treatment A
dim(curveA$pstate)    # P matrix for treatement A
dim(curveA$influence) # influence matrix for treatment A
table(data1$trt)
curveA$p0             # state distribution at time 0


###################################################
### code chunk number 18: meantime
###################################################
t48 <- pmin(48, curveA$time)   
delta <- diff(c(0, t48, 48))  # width of intervals
rfun <- function(pmat, delta) colSums(pmat * delta)  #area under the curve
rmean <- rfun(rbind(curveA$p0, curveA$pstate), delta)
round(rmean, 2)

# Apply the same calculation to each subject's influence slice
inf <- apply(curveA$influence, 1, rfun, delta=delta)
# inf is now a 5 state by 310 subject matrix, containing the IJ estimates
#  on the AUC or mean time.  The sum of squares is a variance.
se.rmean <- sqrt(rowSums(inf^2))
round(se.rmean, 2)


###################################################
### code chunk number 19: crisk
###################################################
crisk <- function(what, horizontal = TRUE, ...) {
    nstate <- length(what)
    connect <- matrix(0, nstate, nstate,
                      dimnames=list(what, what))
    connect[1,-1] <- 1  # an arrow from state 1 to each of the others
    if (horizontal) statefig(c(1, nstate-1),  connect, ...)
    else statefig(matrix(c(1, nstate-1), ncol=1), connect, ...)
}


###################################################
### code chunk number 20: state3
###################################################
state3 <- function(what, horizontal=TRUE, ...) {
    if (length(what) != 3) stop("Should be 3 states")
    connect <- matrix(c(0,0,0, 1,0,0, 1,1,0), 3,3,
                      dimnames=list(what, what))
    if (horizontal) statefig(1:2, connect, ...)
    else statefig(matrix(1:2, ncol=1), connect, ...)
}


###################################################
### code chunk number 21: state5
###################################################
state5 <- function(what, ...) {
    sname <- c("Entry", "CR", "Tx", "Rel", "Death")
    connect <- matrix(0, 5, 5, dimnames=list(sname, sname))
    connect[1, -1] <- c(1,1,1, 1.4)
    connect[2, 3:5] <- c(1, 1.4, 1)
    connect[3, c(2,4,5)] <- 1
    connect[4, c(3,5)]  <- 1
    statefig(matrix(c(1,3,1)), connect, cex=.8, ...)
}


###################################################
### code chunk number 22: state4
###################################################
state4 <- function() {
    sname <- c("Entry", "CR", "Transplant", "Transplant")
    layout <- cbind(x =c(1/2, 3/4, 1/4, 3/4),
                    y =c(5/6, 1/2, 1/2, 1/6))
    connect <- matrix(0,4,4, dimnames=list(sname, sname))
    connect[1, 2:3] <- 1
    connect[2,4] <- 1
    statefig(layout, connect)
}


