### R code from vignette source 'timedep.Rnw'

###################################################
### code chunk number 1: preamble
###################################################
options(width=60, continue=" ")
makefig <- function(file, top=1, right=1, left=4) {
    pdf(file, width=9.5, height=7, pointsize=18)
    par(mar=c(4, left, top, right) +.1)
    }
library(survival)


###################################################
### code chunk number 2: testdata
###################################################
tdata <- data.frame(subject=c(5,5,5), time1=c(0,90, 120),
                    time2 = c(90, 120, 185), death=c(0,0,1),
                    creatinine=c(0.9, 1.5, 1.2))
tdata


###################################################
### code chunk number 3: fake
###################################################
getOption("SweaveHooks")[["fig"]]()
set.seed(1953)  # a good year
nvisit <- floor(pmin(lung$time/30.5, 12))
response <- rbinom(nrow(lung), nvisit, .05) > 0
badfit <- survfit(Surv(time/365.25, status) ~ response, data=lung)
plot(badfit, mark.time=FALSE, lty=1:2, 
     xlab="Years post diagnosis", ylab="Survival")
legend(1.5, .85, c("Responders", "Non-responders"), 
       lty=2:1, bty='n')


###################################################
### code chunk number 4: timedep.Rnw:200-202 (eval = FALSE)
###################################################
## fit <- coxph(Surv(time1, time2, status) ~ age + creatinine, 
##              data=mydata)


###################################################
### code chunk number 5: timedep.Rnw:273-274 (eval = FALSE)
###################################################
## newdata <- tmerge(data1, data2, id, newvar=tdc(time, value), ...)


###################################################
### code chunk number 6: timedep.Rnw:319-320
###################################################
cgd0[1:4,]


###################################################
### code chunk number 7: cgd1
###################################################
dim(cgd0)
newcgd <- tmerge(data1=cgd0[, 1:13], data2=cgd0, id=id, tstop=futime)
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime1)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime2)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime3)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime4)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime5)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime6)) 
newcgd <- tmerge(newcgd, cgd0, id=id, infect = event(etime7)) 
newcgd <- tmerge(newcgd, newcgd, id, enum=cumtdc(tstart))
dim(newcgd)
newcgd[1:5,c(1, 4:6, 13:17)]
attr(newcgd, "tcount")
coxph(Surv(tstart, tstop, infect) ~ treat + inherit + steroids +
      + cluster(id), newcgd)


###################################################
### code chunk number 8: cgd1b
###################################################
test  <- tmerge(cgd0[, 1:13], cgd0, id=id, tstop=futime,
                 infect = event(etime1), infect= event(etime2),
                 infect = event(etime3), infect= event(etime4),
                 infect = event(etime5), infect= event(etime6),
                 infect = event(etime7))
test <- tmerge(test, test,  id= id, enum = cumtdc(tstart))
all.equal(newcgd, test)


###################################################
### code chunk number 9: stanford
###################################################
jasa$subject <- 1:nrow(jasa)  #we need an identifier variable
tdata <- with(jasa, data.frame(subject = subject,
                               futime= pmax(.5, fu.date - accept.dt),
                               txtime= ifelse(tx.date== fu.date,
                                              (tx.date -accept.dt) -.5,
                                              (tx.date - accept.dt)),
                               fustat = fustat
                             ))

sdata <- tmerge(jasa, tdata, id=subject,
                  death = event(futime, fustat),
                  trt   =  tdc(txtime), 
                  options= list(idname="subject"))
attr(sdata, "tcount")
sdata$age <- sdata$age -48
sdata$year <- as.numeric(sdata$accept.dt - as.Date("1967-10-01"))/365.25

# model 6 of the table in K&P
coxph(Surv(tstart, tstop, death) ~ age*trt + surgery + year, 
      data= sdata, ties="breslow")


###################################################
### code chunk number 10: pbc
###################################################
temp <- subset(pbc, id <= 312, select=c(id:sex, stage)) # baseline
pbc2 <- tmerge(temp, temp, id=id, death = event(time, status)) #set range
pbc2 <- tmerge(pbc2, pbcseq, id=id, ascites = tdc(day, ascites),
               bili = tdc(day, bili), albumin = tdc(day, albumin),
               protime = tdc(day, protime), alk.phos = tdc(day, alk.phos))
fit1 <- coxph(Surv(time, status==2) ~ log(bili) + log(protime), pbc)
fit2 <- coxph(Surv(tstart, tstop, death==2) ~ log(bili) + log(protime), pbc2)
rbind('baseline fit' = coef(fit1),
      'time dependent' = coef(fit2))


###################################################
### code chunk number 11: timedep.Rnw:582-583
###################################################
attr(pbc2, "tcount")


###################################################
### code chunk number 12: timedep.Rnw:585-587
###################################################
#grab a couple of numbers for the paragraph below
atemp <- attr(pbc2, "tcount")[2:3,]


###################################################
### code chunk number 13: timedep.Rnw:668-674 (eval = FALSE)
###################################################
## temp <- subset(pbc, id <= 312, select=c(id:sex, stage))
## pbc2 <- tmerge(temp, temp, id=id, death = event(time, status))
## pbc2a <- tmerge(pbc2, pbcseq, id=id, ascites = tdc(day, ascites),
##                bili = tdc(day, bili), options= list(delay=14))
## pbc2b <- tmerge(pbc2, pbcseq, id=id, ascites = tdc(day+14, ascites),
##                bili = tdc(day+14, bili))


###################################################
### code chunk number 14: rep (eval = FALSE)
###################################################
## newd <- tmerge(data1=base, data2=timeline, id=repid, tstart=age1, 
##                tstop=age2, options(id="repid"))
## newd <- tmerge(newd, outcome, id=repid, mcount = cumtdc(age))
## newd <- tmerge(newd, subset(outcome, event='diabetes'), 
##                diabetes= tdc(age))
## newd <- tmerge(newd, subset(outcome, event='arthritis'), 
##                arthritis= tdc(age))


###################################################
### code chunk number 15: veteran1
###################################################
getOption("SweaveHooks")[["fig"]]()
options(show.signif.stars = FALSE)  # display user intelligence
vfit <- coxph(Surv(time, status) ~ trt + prior + karno, veteran)
vfit
quantile(veteran$karno)

zp <- cox.zph(vfit, transform= function(time) log(time +20))
zp
plot(zp[3])    # a plot for the 3rd variable in the fit
abline(0,0, col=2)
abline(h= vfit$coef[3], col=3, lwd=2, lty=2)


###################################################
### code chunk number 16: split
###################################################
vet2 <- survSplit(Surv(time, status) ~ ., data= veteran, cut=c(90, 180), 
                  episode= "tgroup", id="id")
vet2[1:7, c("id", "tstart", "time", "status", "tgroup", "age", "karno")]


###################################################
### code chunk number 17: split2
###################################################
vfit2 <- coxph(Surv(tstart, time, status) ~ trt + prior + 
                  karno:strata(tgroup), data=vet2)
vfit2
cox.zph(vfit2)


###################################################
### code chunk number 18: split3
###################################################
vfit2$means


###################################################
### code chunk number 19: split4
###################################################
quantile(veteran$karno)
cdata <- data.frame(tstart= rep(c(0,30,60), 2),
                    time =  rep(c(30,60, 100), 2),
                    status= rep(0,6),   #necessary, but ignored
                    tgroup= rep(1:3, 2),
                    trt  =  rep(1,6),
                    prior=  rep(0,6),
                    karno=  rep(c(40, 75), each=3),
                    curve=  rep(1:2, each=3))
cdata
sfit <- survfit(vfit2, newdata=cdata, id=curve)
km <- survfit(Surv(time, status) ~ I(karno>60), veteran)
plot(km, xmax=120, col=1:2, lwd=2, 
     xlab="Days from enrollment", ylab="Survival")
lines(sfit, col=1:2, lty=2, lwd=2)


###################################################
### code chunk number 20: vfit3 (eval = FALSE)
###################################################
## vfit3 <- coxph(Surv(time, status) ~ trt + prior + karno +
##                 I(karno * log(time + 20)), data=veteran)


###################################################
### code chunk number 21: vet3
###################################################
vfit3 <-  coxph(Surv(time, status) ~ trt + prior + karno + tt(karno),
                data=veteran,
                tt = function(x, t, ...) x * log(t+20))
vfit3


###################################################
### code chunk number 22: vet3b
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(zp[3])
abline(coef(vfit3)[3:4], col=2)


###################################################
### code chunk number 23: pbctime
###################################################
pfit1 <- coxph(Surv(time, status==2) ~ log(bili) + ascites + age, pbc)
pfit2 <- coxph(Surv(time, status==2) ~ log(bili) + ascites + tt(age),
                data=pbc,
                tt=function(x, t, ...) {
                    age <- x + t/365.25 
                    cbind(age=age, age2= (age-50)^2, age3= (age-50)^3)
                })
pfit2
anova(pfit2)
# anova(pfit1, pfit2)  #this fails
2*(pfit2$loglik - pfit1$loglik)[2]


###################################################
### code chunk number 24: expand
###################################################
dtimes <- sort(unique(with(pbc, time[status==2])))
tdata <- survSplit(Surv(time, status==2) ~., pbc, cut=dtimes)
tdata$c.age <- tdata$age + tdata$time/365.25 -50  #current age, centered at 50
pfit3 <- coxph(Surv(tstart, time, event) ~ log(bili) + ascites + c.age +
    I(c.age^2) + I(c.age^3), data=tdata)
rbind(coef(pfit2), coef(pfit3))


###################################################
### code chunk number 25: timedep.Rnw:1078-1085
###################################################
function(x, t, riskset, weights){ 
    obrien <- function(x) {
        r <- rank(x)
        (r-.5)/(.5+length(r)-r)
    }
    unlist(tapply(x, riskset, obrien))
}


###################################################
### code chunk number 26: timedep.Rnw:1095-1097
###################################################
function(x, t, riskset, weights) 
    unlist(tapply(x, riskset, rank))


