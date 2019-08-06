### R code from vignette source 'population.Rnw'

###################################################
### code chunk number 1: population.Rnw:20-26
###################################################
options(continue="  ", width=70)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=8) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #reset default
library(survival)
library(splines)


###################################################
### code chunk number 2: fig1
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(c(50,85), c(2,4.5), type='n', xlab="Age", ylab="Effect")
#abline(.645, .042, lty=1, col=1, lwd=2)
#abline(.9, .027, lty=1, col=2, lwd=2)
abline(.35, .045, lty=1, col=1, lwd=2)
abline(1.1, .026, lty=1, col=2, lwd=2)
legend(50, 4.2, c("Treatment A", "Treatment B"), 
        col=c(1,2), lty=1, lwd=2, cex=1.3, bty='n')


###################################################
### code chunk number 3: solder1a
###################################################
summary(solder)
length(unique(solder$PadType))


###################################################
### code chunk number 4: solder1b
###################################################
getOption("SweaveHooks")[["fig"]]()
# reproduce their figure 1.1
temp <- lapply(1:5, function(x) tapply(solder$skips, solder[[x]], mean))
plot(c(0.5, 5.5), range(unlist(temp)), type='n', xaxt='n',
     xlab="Factors", ylab ="mean number of skips")

axis(1, 1:5, names(solder)[1:5])
for (i in 1:5) {
    y <- temp[[i]]
    x <- rep(i, length(y))
    text(x-.1, y, names(y), adj=1)
    segments(i, min(y), i, max(y))
    segments(x-.05, y, x+.05, y)
}


###################################################
### code chunk number 5: solder2
###################################################
with(solder[solder$Mask!='A6',], ftable(Opening, Solder, PadType))

fit1 <- lm(skips ~ Opening + Solder + Mask + PadType + Panel,
           data=solder, subset= (Mask != 'A6'))
y1 <- yates(fit1, ~Opening, population = "factorial")
print(y1, digits=2)  # (less digits, for vignette page width)


###################################################
### code chunk number 6: solder2b
###################################################
y2 <- yates(fit1, "Opening", population = "data", test="pairwise") 
print(y2, digits=2)
#
# compare the two results
temp <- rbind(diff(y1$estimate[,"pmm"]), diff(y2$estimate[,"pmm"]))
dimnames(temp) <- list(c("factorial", "empirical"), c("2 vs 1", "3 vs 2"))
round(temp,5)


###################################################
### code chunk number 7: solder3
###################################################
fit2 <- lm(skips ~ Opening + Mask*PadType + Panel, solder,
           subset= (Mask != "A6"))
temp <- yates(fit2, ~Opening, population="factorial")
print(temp, digits=2)


###################################################
### code chunk number 8: solder4
###################################################
fit3 <- lm(skips ~ Opening * Mask + Solder + PadType + Panel, solder)
temp <- yates(fit3, ~Mask, test="pairwise")
print(temp, digits=2)


###################################################
### code chunk number 9: glm
###################################################
gfit2 <- glm(skips ~ Opening * Mask + PadType + Solder, data=solder,
             family=poisson)
y1 <- yates(gfit2, ~ Mask, predict = "link") 
print(y1, digits =2)
print( yates(gfit2, ~ Mask, predict = "response"), digits=2) 


###################################################
### code chunk number 10: glm3
###################################################
gfit1 <- glm(skips ~ Opening + Mask +PadType + Solder, data=solder,
             family=poisson)
yates(gfit1, ~ Opening, test="pairwise", predict = "response", 
      population='data')
yates(gfit1, ~ Opening, test="pairwise", predict = "response", 
      population="yates")


###################################################
### code chunk number 11: data
###################################################
getOption("SweaveHooks")[["fig"]]()
male <- (flchain$sex=='M')
flchain$flc <- flchain$kappa + flchain$lambda
mlow <- with(flchain[male,],  smooth.spline(age, flc))
flow <- with(flchain[!male,], smooth.spline(age, flc))
plot(flow, type='l', ylim=range(flow$y, mlow$y),
     xlab="Age", ylab="FLC")
lines(mlow, col=2, lwd=2)
legend(60, 6, c("Female", "Male"), lty=1, col=1:2, lwd=2, bty='n')


###################################################
### code chunk number 12: counts
###################################################
flchain$flc <- flchain$kappa + flchain$lambda                    
age2 <- cut(flchain$age, c(49, 59, 69, 79, 89, 120),                   
            labels=c("50-59", "60-69", "70-79", "80-89", "90+"))
fgroup <- cut(flchain$flc, quantile(flchain$flc, c(0, .5, .75, .9, 1)),
              include.lowest=TRUE, labels=c("<50", "50-75", "75-90", ">90"))
counts <- with(flchain, table(sex, age2))
counts
#
# Mean FLC in each age/sex group
cellmean <- with(flchain, tapply(flc, list(sex, age2), mean))
round(cellmean,1)                 


###################################################
### code chunk number 13: flc1
###################################################
library(splines)
flc1 <- lm(flc ~ sex, flchain)
flc2a <- lm(flc ~ sex + ns(age, 3), flchain)
flc2b <- lm(flc ~ sex + age2, flchain)
flc3a <- lm(flc ~ sex * ns(age, 3), flchain)
flc3b <- lm(flc ~ sex * age2, flchain)
#
# prediction at age 65 (which is near the mean)
tdata <- data.frame(sex=c("F", "M"), age=65, age2="60-69")
temp <- rbind("unadjusted" = predict(flc1, tdata),
              "additive, continuous age" = predict(flc2a, tdata),
              "additive, discrete age"   = predict(flc2b, tdata),
              "interaction, cont age"    = predict(flc3a, tdata),
              "interaction, discrete"    = predict(flc3b, tdata))
temp <- cbind(temp, temp[,2]- temp[,1])
colnames(temp) <- c("Female", "Male", "M - F")
round(temp,2)


###################################################
### code chunk number 14: flc2
###################################################
yates(flc3a, ~sex)  # additive, continuous age
#
yates(flc3b, ~sex)  # interaction, categorical age
#
yates(flc3b, ~sex, population="factorial")


###################################################
### code chunk number 15: flc3
###################################################
yates(flc3a, ~ age, levels=c(65, 75, 85))  
yates(flc3b, ~ age2)


###################################################
### code chunk number 16: cox1
###################################################
options(show.signif.stars=FALSE)  # show statistical intelligence
coxfit1 <- coxph(Surv(futime, death) ~ sex, flchain)
coxfit2 <- coxph(Surv(futime, death) ~ sex + age, flchain)
coxfit3 <- coxph(Surv(futime, death) ~ sex * age, flchain)
anova(coxfit1, coxfit2, coxfit3)
#
exp(c(coef(coxfit1), coef(coxfit2)[1]))  # sex estimate without and with age


###################################################
### code chunk number 17: coxfit2
###################################################
coxfit4 <- coxph(Surv(futime, death) ~ fgroup*age + sex, flchain)
yates(coxfit4, ~ fgroup, predict="linear")
yates(coxfit4, ~ fgroup, predict="risk")


###################################################
### code chunk number 18: surv
###################################################
# longest time to death
round(max(flchain$futime[flchain$death==1]) / 365.25, 1)
#compute naive survival curve
flkm <- survfit(Surv(futime, death) ~ fgroup, data=flchain)
print(flkm, rmean= 13*365.25, scale=365.25)


###################################################
### code chunk number 19: surv2
###################################################
mypop <- flchain[seq(1, nrow(flchain), by=20), c("age", "sex")]
ysurv <- yates(coxfit4, ~fgroup, predict="survival", nsim=50,
               population = mypop, 
               options=list(rmean=365.25*13))
ysurv

# display side by side
temp <- rbind("simple KM" = summary(flkm, rmean=13*365.25)$table[, "*rmean"],
              "population adjusted" = ysurv$estimate[,"pmm"])
round(temp/365.25, 2)



###################################################
### code chunk number 20: surv3
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(flkm, xscale=365.25, fun="event", col=1:4, lty=2,
     xlab="Years", ylab="Death")
lines(ysurv$summary, fun="event", col=1:4, lty=1, lwd=2)
legend(0, .65, levels(fgroup), lty=1, lwd=2, col=1:4, bty='n')


###################################################
### code chunk number 21: nstt
###################################################
options(contrasts = c("contr.treatment", "contr.poly"))  # default
nfit1 <- lm(skips ~ Solder*Opening + PadType, solder)
drop1(nfit1, ~Solder)


###################################################
### code chunk number 22: nstt2
###################################################
options(contrasts = c("contr.SAS", "contr.poly"))
nfit2 <- lm(skips ~ Solder*Opening + PadType, solder)
drop1(nfit2, ~Solder)


###################################################
### code chunk number 23: means
###################################################
with(solder, tapply(skips, list(Solder, Opening), mean))


###################################################
### code chunk number 24: nstt3
###################################################
options(contrasts = c("contr.sum", "contr.poly"))
nfit3 <- lm(skips ~ Solder*Opening + PadType, solder)

drop1(nfit3, ~Solder )  
yates(nfit1, ~Solder, population='factorial')   


###################################################
### code chunk number 25: nstt4
###################################################
options(contrasts = c("contr.treatment", "contr.poly"))  # restore


###################################################
### code chunk number 26: sizes
###################################################
with(flchain, table(sex, age2))


