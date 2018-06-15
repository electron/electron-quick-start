### R code from vignette source 'splines.Rnw'

###################################################
### code chunk number 1: splines.Rnw:21-25
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=8) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #reset default


###################################################
### code chunk number 2: mplot
###################################################
getOption("SweaveHooks")[["fig"]]()
require(survival)
mfit <- coxph(Surv(futime, death) ~ sex + pspline(age, df=4), data=mgus)
mfit
termplot(mfit, term=2, se=TRUE, col.term=1, col.se=1)


###################################################
### code chunk number 3: mplot2
###################################################
ptemp <- termplot(mfit, se=TRUE, plot=FALSE)
attributes(ptemp)
ptemp$age[1:4,]


###################################################
### code chunk number 4: mplot3
###################################################
getOption("SweaveHooks")[["fig"]]()
ageterm <- ptemp$age  # this will be a data frame
center <- with(ageterm, y[x==50])
ytemp <- ageterm$y + outer(ageterm$se, c(0, -1.96, 1.96), '*')
matplot(ageterm$x, exp(ytemp - center), log='y',
        type='l', lty=c(1,2,2), col=1, 
        xlab="Age at diagnosis", ylab="Relative death rate")


###################################################
### code chunk number 5: hgb
###################################################
fit <- coxph(Surv(futime, death) ~ age + pspline(hgb, 4), mgus2)
fit
termplot(fit, se=TRUE, term=2, col.term=1, col.se=1,
         xlab="Hemoglobin level")


###################################################
### code chunk number 6: df
###################################################
termplot(fit, se=TRUE, col.term=1, col.se=1, term=2,
         xlab="Hemoglobin level", ylim=c(-.4, 1.3))
df <- c(3, 2.5, 2)
for (i in 1:3) {
    tfit <- coxph(Surv(futime, death) ~ age + 
                  pspline(hgb, df[i], nterm=8), mgus2)
    temp <- termplot(tfit, se=FALSE, plot=FALSE, term=2)
    lines(temp$hgb$x, temp$hgb$y, col=i+1, lwd=2)
}
legend(14, 1, paste("df=", c(4, df)), lty=1, col=1:4, lwd=2)


###################################################
### code chunk number 7: fit2.5
###################################################
fit2a <- coxph(Surv(futime, death) ~ age + pspline(hgb, 2.5, nterm=8), mgus2)
coef(fit2a)
plot(1:10, coef(fit2a)[-1])


###################################################
### code chunk number 8: fit2b
###################################################
temp <- c(1:7, 8,8,8)
fit2b <- coxph(Surv(futime, death) ~ age + 
               pspline(hgb, 2.5, nterm=8, combine=temp), 
               data= mgus2)
temp2 <- c(1:6, 7,7,7,7)
fit2c <- coxph(Surv(futime, death) ~ age + 
               pspline(hgb, 2.5, nterm=8, combine=temp2), 
               data= mgus2)
matplot(1:10, cbind(coef(fit2a)[-1], coef(fit2b)[temp+1], 
                    coef(fit2c)[temp2+1]), type='b', pch='abc',
                    xlab="Term", ylab="Pspline coef")


###################################################
### code chunk number 9: fit1
###################################################
getOption("SweaveHooks")[["fig"]]()
options(show.signif.stars=FALSE) # display intelligence
fit1 <- coxph(Surv(futime, death) ~ sex + pspline(age, 3), data=flchain)
fit1
termplot(fit1, term=2, se=TRUE, col.term=1, col.se=1,
         ylab="log hazard")


###################################################
### code chunk number 10: nfit
###################################################
options(show.signif.stars=FALSE)  # display statistical intellegence
require(splines, quietly=TRUE)
nfit1 <- coxph(Surv(futime, death) ~ sex + age, flchain)
nfit2 <- coxph(Surv(futime, death) ~ sex + ns(age, df=3), flchain)
nfit3 <- coxph(Surv(futime, death) ~ sex * ns(age, df=3), flchain)
anova(nfit1, nfit2, nfit3)


###################################################
### code chunk number 11: nfit2
###################################################
pdata <- expand.grid(age= 50:99, sex=c("F", "M"))
pdata[1:5,]

ypred <- predict(nfit3, newdata=pdata, se=TRUE)
yy <- ypred$fit + outer(ypred$se, c(0, -1.96, 1.96), '*')
matplot(50:99, exp(matrix(yy, ncol=6)), type='l', lty=c(1,1,2,2,2,2),
        lwd=2, col=1:2, log='y',
        xlab="Age", ylab="Relative risk")
legend(55, 20, c("Female", "Male"), lty=1, lwd=2, col=1:2, bty='n')
abline(h=1)


###################################################
### code chunk number 12: fit2
###################################################
agem <- with(flchain, ifelse(sex=="M", age, 60))
agef <- with(flchain, ifelse(sex=="F", age, 60))
fit2 <- coxph(Surv(futime, death) ~ sex + pspline(agef, df=3)
              + pspline(agem, df=3), data=flchain)
anova(fit2, fit1)


###################################################
### code chunk number 13: plot2
###################################################
getOption("SweaveHooks")[["fig"]]()
# predictions
pdata2 <- pdata
pdata2$agem <- with(pdata2, ifelse(sex=="M", age, 60))
pdata2$agef <- with(pdata2, ifelse(sex=="F", age, 60))
ypred2 <- predict(fit2, pdata2, se=TRUE)
yy <- ypred2$fit + outer(ypred2$se, c(0, -1.96, 1.96), '*')

# reference
refdata <- data.frame(sex='F', agef=65, agem=60)
ref <- predict(fit2, newdata=refdata, type="lp")

# plot
matplot(50:99, exp(matrix(yy-ref, ncol=6)), type='l', lty=c(1,1,2,2,2,2),
        lwd=2, col=1:2, log='y',
        xlab="Age", ylab="Relative risk")
legend(55, 20, c("Female", "Male"), lty=1, lwd=2, col=1:2, bty='n')
abline(h=1)


