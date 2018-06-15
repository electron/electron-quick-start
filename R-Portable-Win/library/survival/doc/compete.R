### R code from vignette source 'compete.Rnw'

###################################################
### code chunk number 1: compete.Rnw:23-29
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=10) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #ensure default

require("survival")


###################################################
### code chunk number 2: sfig1
###################################################
getOption("SweaveHooks")[["fig"]]()
# A note to readers of this code: drawing multi-state figures in this
#  way via polygon and arrows statements is a major PITA.  Don't mimic
#  the code below, instead do yourself a favor and use a package
#  designed for the task such as diagram, DiagrammeR, shape or Gmisc.
# Survival is a recommended package that is included by lots of others so
#  I try to limit dependencies in the survival vignettes.
#
par(mar=c(.1, .1, .1, .1))
frame()
oldpar <- par(usr=c(0,100,0,100))
# first figure
xx <- c(0, 10, 10, 0)
yy <- c(0, 0, 10, 10)
polygon(xx +10, yy+70)
polygon(xx +30, yy+70)
arrows( 22, 75, 28, 75, length=.1)
text(c(15, 35), c(75,75), c("Alive", "Dead"))

# second figure
polygon(xx +60, yy+70)  
for (j in c(55, 70, 85)) {
    polygon(xx +80, yy+j)
    arrows(72, (5*75 +j+5)/6, 78, (100+j*5)/6, length=.1)
}
text(c(65, 85,85,85), c(70,55,70,85)+5, c("A", "D3", "D2", "D1")) 

# third figure
polygon(xx+10, yy+25)
for (j in c(15,35)) {
    polygon(xx +30, yy+j)
    arrows(22, (5*30 +j+4)/6, 28, (54+j*5)/6, length=.1)
}
arrows(28, 2+(65 + 35*5)/6, 22, 2+ (160 + 40)/6, length=.1)
arrows(35, 33, 35, 27, length=.1)
text(c(15, 35,35), c(30, 20, 40), c("Health", "Death", "Illness"))

# fourth
for (i in c(50, 68)) polygon(xx+i, yy+25)
arrows(62, 30, 67, 30, length=.1)
arrows(80, 30, 84, 30, length=.1)
text(90, 30, "...", cex=2)
text(c(55, 73), c(30, 30), c("0", "1"))
par(oldpar)


###################################################
### code chunk number 3: crfig2
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar=c(.1, .1, .1, .1))
frame()
oldpar <- par(usr=c(0,100,0,100))
# first figure
xx <- c(0, 10, 10, 0)
yy <- c(0, 0, 10, 10)
polygon(xx +10, yy+70) 
temp <- c(60, 80) 
for (j in 1:2) {
    polygon(xx + 30, yy+ temp[j])
    arrows(22, 70 + 3*j, 28, temp[j] +5, length=.1)
}
text(c(15, 35, 35), c(75, 65, 85),c("Entry", "Death", "PCM")) 
text(25, 55, "Competing Risk")

# Second figure
polygon(xx +60, yy+70)  
for (j in 1:2) {
    polygon(xx + 80, yy+ temp[j])
    arrows(72, 70+ 3*j, 78, temp[j] +5, length=.1)
}
text(50+ c(15, 35, 35), c(75, 65, 85),c("Entry", "Death", "PCM")) 
arrows(85, 78, 85, 72, length=.1)
text(75, 55, "Multi-state 1")

# third figure
polygon(xx+10, yy+25)
temp <- c(15, 35) 
for (j in 1:2) {
    polygon(2*xx +30, yy + temp[j])
    arrows(22, 25 + 3*j, 28, temp[j] +5, length=.1)
}
text(c(15, 40, 40), c(30, 20, 40),c("Entry", "Death w/o PCM", "PCM")) 
polygon(2*xx + 60, yy+temp[2])
arrows(52, 40, 58, 40, length=.1)
text(70, 40, "Death after PCM")
text(40, 10, "Multi-state 2")


###################################################
### code chunk number 4: mgus1
###################################################
getOption("SweaveHooks")[["fig"]]()
oldpar <- par(mfrow=c(1,2))
hist(mgus2$age, nclass=30, main='', xlab="Age")
with(mgus2, tapply(age, sex, mean))

mfit1 <- survfit(Surv(futime, death) ~ sex, data=mgus2)
mfit1
plot(mfit1, col=c(1,2), xscale=12, mark.time=FALSE, lwd=2,
     xlab="Years post diagnosis", ylab="Survival")
legend("topright", c("female", "male"), col=1:2, lwd=2, bty='n')
par(oldpar)


###################################################
### code chunk number 5: mgus2
###################################################
getOption("SweaveHooks")[["fig"]]()
etime <- with(mgus2, ifelse(pstat==0, futime, ptime))
event <- with(mgus2, ifelse(pstat==0, 2*death, 1))
event <- factor(event, 0:2, labels=c("censor", "pcm", "death"))
table(event)

mfit2 <- survfit(Surv(etime, event) ~ sex, data=mgus2)
print(mfit2, rmean=240, scale=12)
mfit2$transitions

plot(mfit2, col=c(1,2,1,2), lty=c(2,2,1,1),
     mark.time=FALSE, lwd=2,  xscale=12,
     xlab="Years post diagnosis", ylab="Probability in State")
legend(240, .6, c("death:female", "death:male", "pcm:female", "pcm:male"), 
       col=c(1,2,1,2), lty=c(1,1,2,2), lwd=2, bty='n')


###################################################
### code chunk number 6: mgus3
###################################################
getOption("SweaveHooks")[["fig"]]()
pcmbad <- survfit(Surv(etime, pstat) ~ sex, data=mgus2)
plot(pcmbad[2], mark.time=FALSE, lwd=2, fun="event", conf.int=FALSE, xscale=12,
     xlab="Years post diagnosis", ylab="Fraction with PCM")
lines(mfit2[2,1], lty=2, lwd=2, mark.time=FALSE, conf.int=FALSE)
legend(0, .25, c("Males, PCM, incorrect curve", "Males, PCM, competing risk"),
       col=1, lwd=2, lty=c(1,2), bty='n')


###################################################
### code chunk number 7: mgus4
###################################################
ptemp <- with(mgus2, ifelse(ptime==futime & pstat==1, ptime-.1, ptime))
newdata <- tmerge(mgus2, mgus2,  id=id, death=event(futime, death),
                  pcm = event(ptemp, pstat))
newdata <- tmerge(newdata, newdata, id, enum=cumtdc(tstart))
with(newdata, table(death, pcm))


###################################################
### code chunk number 8: mgus4g
###################################################
getOption("SweaveHooks")[["fig"]]()
temp <- with(newdata, ifelse(death==1, 2, pcm))
newdata$event <- factor(temp, 0:2, labels=c("censor", "pcm", "death"))  
mfit3 <- survfit(Surv(tstart, tstop, event) ~ sex, data=newdata, id=id)
print(mfit3, rmean=240, digits=2)
mfit3$transitions
plot(mfit3[,1], mark.time=FALSE, col=1:2, lty=1:2, lwd=2,
     xscale=12,
     xlab="Years post MGUS diagnosis", ylab="Fraction in the PCM state")
legend(48, .04, c("female", "male"), lty=1:2, col=1:2, lwd=2, bty='n') 


###################################################
### code chunk number 9: mgus5
###################################################
getOption("SweaveHooks")[["fig"]]()
# Death after PCM will correspond to data rows with
#  enum = 2 and event = death 
d2 <- with(newdata, ifelse(enum==2 & event=='death', 4, as.numeric(event)))
e2 <- factor(d2, labels=c("censor", "pcm", "death w/o pcm", 
                          "death after pcm"))
mfit4 <- survfit(Surv(tstart, tstop, e2) ~ sex, data=newdata, id=id)
plot(mfit2[2,], lty=c(1,2),
     xscale=12, mark.time=FALSE, lwd=2, 
     xlab="Years post diagnosis", ylab="Probability in State")
lines(mfit4[2,3], mark.time=FALSE, col=2, lty=1, lwd=2,
      conf.int=FALSE)

legend(200, .5, c("Death w/o PCM", "ever PCM", 
                  "Death after PCM"), col=c(1,1,2), lty=c(2,1,1), 
             lwd=2, bty='n', cex=.82)


###################################################
### code chunk number 10: cfit1
###################################################
options(show.signif.stars = FALSE)  # display intelligence
cfit2 <- coxph(Surv(etime, event=="death") ~ age + sex + mspike, mgus2)
summary(cfit2, scale=c(10, 1, 1))   # scale age in decades 



###################################################
### code chunk number 11: cfit2
###################################################
cfit1 <- coxph(Surv(etime, event=="pcm") ~ age + sex + mspike, mgus2)
cfit1
quantile(mgus2$mspike, na.rm=TRUE)


###################################################
### code chunk number 12: mpyears
###################################################
pfit1 <- pyears(Surv(ptime, pstat) ~ sex, mgus2, scale=12)
round(100* pfit1$event/pfit1$pyears, 1)  # PCM rate per year

temp <- summary(mfit1, rmean="common")  #print the mean survival time
round(temp$table[,1:6], 1)


###################################################
### code chunk number 13: PCMcurve
###################################################
getOption("SweaveHooks")[["fig"]]()
newdata <- expand.grid(sex=c("F", "M"), age=c(60, 80), mspike=1.2)
newdata

temp <- matrix(list(), 3,3)
dimnames(temp) <- list(from=c("Entry", "PCM", "Death"),
                       to  =c("Entry", "PCM", "Death"))
temp[1,2] <- list(survfit(cfit1, newdata, std.err=FALSE))
temp[1,3] <- list(survfit(cfit2, newdata, std.err=FALSE))
csurv  <- survfit(temp, p0 =c(1,0,0))
plot(csurv[,2], xmax=25*12, xscale=12, 
     xlab="Years after MGUS diagnosis", ylab="PCM",
     col=1:2, lty=c(1,1,2,2), lwd=2)
legend(10, .14, outer(c("female", "male   "), 
                     c("diagnosis at age 60", "diagnosis at age 80"), 
                      paste, sep=", "),
       col=1:2, lty=c(1,1,2,2), bty='n', lwd=2)


###################################################
### code chunk number 14: year20
###################################################
# Print out a M/F results at 20 years
temp <- summary(csurv, time=20*12)$pstate
cbind(newdata, PCM= round(100*temp[,2], 1))


###################################################
### code chunk number 15: fg1
###################################################
# (first three lines are identical to an earlier section)
etime <- with(mgus2, ifelse(pstat==0, futime, ptime))
event <- with(mgus2, ifelse(pstat==0, 2*death, 1))
event <- factor(event, 0:2, labels=c("censor", "pcm", "death"))

pcmdat <- finegray(Surv(etime, event) ~ ., data=mgus2,
                   etype="pcm")
pcmdat[1:4, c(1:3, 11:14)]

deathdat <- finegray(Surv(etime, event) ~ ., data=mgus2,
                     etype="death")
dim(pcmdat)
dim(deathdat)
dim(mgus2)


###################################################
### code chunk number 16: pfit2
###################################################
# The PCM curves of the multi-state model
pfit2 <- survfit(Surv(fgstart, fgstop, fgstatus) ~ sex,
                data=pcmdat, weight=fgwt)
# The death curves of the multi-state model
dfit2 <- survfit(Surv(fgstart, fgstop, fgstatus) ~ sex, 
                  data=deathdat, weight=fgwt)


###################################################
### code chunk number 17: fg2
###################################################
getOption("SweaveHooks")[["fig"]]()
fgfit1 <- coxph(Surv(fgstart, fgstop, fgstatus) ~ sex, data=pcmdat,
               weight= fgwt)
summary(fgfit1)
fgfit2 <- coxph(Surv(fgstart, fgstop, fgstatus) ~ sex, data=deathdat,
               weight= fgwt)
fgfit2

mfit2 <- survfit(Surv(etime, event) ~ sex, data=mgus2) #reprise the AJ
plot(mfit2[,1], col=1:2,
     lwd=2,  xscale=12,
     conf.times=c(5, 15, 25)*12,
     xlab="Years post diagnosis", ylab="Fraction with PCM")
ndata <- data.frame(sex=c("F", "M"))
fgsurv1 <- survfit(fgfit1, ndata)
lines(fgsurv1, fun="event", lty=2, lwd=2, col=1:2)
legend("topleft", c("Female, Aalen-Johansen", "Male, Aalen-Johansen",
                 "Female, Fine-Gray", "Male, Fine-Gray"),
       col=1:2, lty=c(1,1,2,2), bty='n')

# rate models with only sex
pfitr <- coxph(Surv(etime, event=="pcm") ~ sex, mgus2)
dfitr <- coxph(Surv(etime, event=="death") ~ sex, mgus2)
temp <- matrix(list(), 3,3)
temp[1,2] <- list(survfit(pfitr, ndata, std.err=FALSE))
temp[1,3] <- list(survfit(dfitr, ndata, std.err=FALSE))
rcurve <- survfit(temp, p0=c(entry=1, pcm=0, death=0))


###################################################
### code chunk number 18: fg3
###################################################
fgfit2a <- coxph(Surv(fgstart, fgstop, fgstatus) ~ age + sex + mspike,
                 data=pcmdat, weight=fgwt)

fgfit2b <-  coxph(Surv(fgstart, fgstop, fgstatus) ~ age + sex + mspike,
                 data=deathdat, weight=fgwt)
round(rbind(PCM= coef(fgfit2a), death=coef(fgfit2b)), 3)


###################################################
### code chunk number 19: finegray2
###################################################
getOption("SweaveHooks")[["fig"]]()
oldpar <- par(mfrow=c(1,2))
newdata <- expand.grid(sex= c("F", "M"), age=c(60, 80), mspike=1.2)
fsurv1 <- survfit(fgfit2a, newdata)  # time to progression curves
plot(fsurv1, xscale=12, col=1:2, lty=c(1,1,2,2), lwd=2, fun='event',
     xlab="Years", ylab="Fine-Gray predicted", 
     xmax=12*25, ylim=c(0, .15))
legend(1, .15, c("Female, 60", "Male, 60","Female: 80", "Male, 80"),
       col=c(1,2,1,2), lty=c(1,1,2,2), lwd=2, bty='n')

plot(csurv[,2], xscale=12, col=1:2, lty=c(1,1,2,2), lwd=2,
     xlab="Years", ylab="Multi-state predicted", 
     xmax=12*25, ylim=c(0, .15))
legend(1, .15, c("Female, 60", "Male, 60","Female: 80", "Male, 80"),
       col=c(1,2,1,2), lty=c(1,1,2,2), lwd=2, bty='n')
par(oldpar)


###################################################
### code chunk number 20: finegray-check
###################################################
getOption("SweaveHooks")[["fig"]]()
zph.fgfit2a <- cox.zph(fgfit2a)
zph.fgfit2a
plot(zph.fgfit2a[1])
abline(h=coef(fgfit2a)[1], lty=2, col=2)


###################################################
### code chunk number 21: finegray3
###################################################
getOption("SweaveHooks")[["fig"]]()
fsurv2 <- survfit(fgfit2b, newdata)  # time to progression curves
xtime <- 0:(30*12)  #30 years
y1a <- 1 - summary(fsurv1, times=xtime)$surv  #predicted pcm
y1b <- 1 - summary(fsurv2, times=xtime)$surv #predicted deaths before pcm
y1  <- (y1a + y1b)  #either

matplot(xtime/12, y1, col=1:2, lty=c(1,1,2,2), type='l',
        xlab="Years post diagnosis", ylab="FG: either endpoint")
abline(h=1, col=3)
legend("bottomright", c("Female, 60", "Male, 60","Female: 80", "Male, 80"),
       col=c(1,2,1,2), lty=c(1,1,2,2), lwd=2, bty='n')


###################################################
### code chunk number 22: pcmstack
###################################################
temp1 <- data.frame(mgus2, time=etime, status=(event=="pcm"), group='pcm')
temp2 <- data.frame(mgus2, time=etime, status=(event=="death"), group="death")
stacked <- rbind(temp1, temp2)
allfit <- coxph(Surv(time, status) ~ hgb + (age + sex)*strata(group),
                 data=stacked)


