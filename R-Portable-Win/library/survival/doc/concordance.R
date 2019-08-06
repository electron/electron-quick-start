### R code from vignette source 'concordance.Rnw'

###################################################
### code chunk number 1: concordance.Rnw:23-32
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=10) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #ensure default

#require("survival")
#library(survival)
library(survival)
library(splines)


###################################################
### code chunk number 2: examples1
###################################################
# logistic regression using Fisher's iris data
fit1 <- glm(Species=="versicolor" ~ ., family=binomial, data=iris) 
concordance(fit1)  # this gives the AUC 

# linear regression
fit2 <- lm(karno ~ age + trt, data=veteran)
concordance(fit2)  # 2*concordance-1 = somers' d


###################################################
### code chunk number 3: examples2
###################################################
# parametric survival regression
fit3 <- survreg(Surv(time, status) ~ karno + age + trt, data=veteran)
concordance(fit3)

# 3 Cox models
fit4 <- coxph(Surv(time, status) ~ karno + age + trt, data=veteran)
fit5 <- update(fit4, . ~ . + celltype)
fit6 <- update(fit5, . ~ . + prior)
ctest <- concordance(fit4, fit5, fit6)
ctest


###################################################
### code chunk number 4: rplot
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mfrow=c(1,2))
c3 <- concordance(fit3, ranks=TRUE)
c4 <- concordance(fit3, ranks=TRUE, timewt="S/G")

# For technical reasons the code returns ranks on Somers' d scale, 
#  from -1 to 1. Transform them to 0-1
d.to.c <- function(x)  (x+1)/2
plot(d.to.c(rank) ~ time, data=c3$ranks, log='x',
     ylab="Rank")
lfit <- with(c3$ranks, lowess(log(time), d.to.c(rank)))
lines(exp(lfit$x), lfit$y, col=2, lwd=2)
abline(.5,0, lty=2)

matplot(c3$ranks$time, cbind(c3$ranks$timewt, c4$ranks$timewt),
        type="l", col=c("black", "red"), lwd=2,
        xlab="Time", ylab="Weight", log="x")

legend("topright", legend=c("n(t)","S(t)/G(t)"), lty=1:2, 
       col=c("black","red"), bty="n")


###################################################
### code chunk number 5: varest
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(variance ~ time, c3$ranks, ylim=c(0, .34), log="x")
abline(h=1/3, col=2)


###################################################
### code chunk number 6: test
###################################################
ctest <- concordance(fit4, fit5, fit6)
ctest

# compare concordance values of fit4 and fit5
contr <- c(-1, 1, 0)
dtest <- contr %*% coef(ctest)
dvar  <- contr %*% vcov(ctest) %*% contr

c(contrast=dtest, sd=sqrt(dvar), z=dtest/sqrt(dvar))


###################################################
### code chunk number 7: lungcompare
###################################################
colSums(is.na(lung)) # count missing values/variable

# First attempt
fit6 <- coxph(Surv(time, status) ~ age + ph.ecog, data=lung)
fit7 <- coxph(Surv(time, status) ~ meal.cal + pat.karno, data=lung)
#tryCatch(concordance(fit6,fit7))   # produces an error

# Second attempt
lung2 <- na.omit(subset(lung, select= -c(inst, wt.loss)))

fit6b <- coxph(Surv(time, status) ~ age + ph.ecog, data=lung2)
fit7b <- coxph(Surv(time, status) ~ meal.cal + pat.karno, data=lung2)
concordance(fit6b,fit7b) 


###################################################
### code chunk number 8: tmwt
###################################################
getOption("SweaveHooks")[["fig"]]()
colonfit <- coxph(Surv(time, status) ~ rx + nodes + extent, data=colon,
                 subset=(etype==2))   # death only
cord1 <- concordance(colonfit, timewt="n",    ranks=TRUE)
cord2 <- concordance(colonfit, timewt="S",    ranks=TRUE)
cord3 <- concordance(colonfit, timewt="S/G",  ranks=TRUE)
cord4 <- concordance(colonfit, timewt="n/G2", ranks=TRUE)
c(n= coef(cord1), S=coef(cord2), "S/G"= coef(cord3), "n/G2"= coef(cord4))

matplot(cord1$ranks$time/365.25, cbind(cord1$ranks$timewt,
                                       cord2$ranks$timewt,
                                       cord3$ranks$timewt,
                                       cord4$ranks$timewt), 
        type= "l", ylim= c(0, 6000),
        xlab="Years since enrollment", ylab="Weight")
legend("left", c("n(t)", "S(t)", "S(t)/G(t)", "n(t)/G^2(t)"), lwd=2,
       col=1:4, lty=1:4, bty="n")


###################################################
### code chunk number 9: mgus1
###################################################
getOption("SweaveHooks")[["fig"]]()
fit6 <- coxph(Surv(futime/12, death) ~ hgb, data=mgus2)
zp <- cox.zph(fit6, transform="identity")
plot(zp, df=4, resid=FALSE, ylim=c(-.4, .1), xlab="Years")
abline(0,0, lty=3, col=2)


###################################################
### code chunk number 10: mgus2
###################################################
getOption("SweaveHooks")[["fig"]]()
c6a <- concordance(fit6, timewt="n",    ranks=TRUE)
c6b <- concordance(fit6, timewt="S",    ranks=TRUE)
c6c <- concordance(fit6, timewt="S/G",  ranks=TRUE)
c6d <- concordance(fit6, timewt="n/G2", ranks=TRUE)
c(n= coef(c6a), S=coef(c6b), "S/G"= coef(c6c), "n/G2"= coef(c6d))

par(mfrow=c(1,2))
rfit <- lm(rank ~ ns(time,3), data=c6a$ranks)
termplot(rfit, se=TRUE, col.se=1, col.term=1, 
         xlab="Years", ylab="Smoothed rank")

matplot(c6a$ranks$time, cbind(c6a$ranks$timewt,
                              c6b$ranks$timewt,
                              c6c$ranks$timewt,
                              c6d$ranks$timewt), 
        type= "l", 
        xlab="Years since enrollment", ylab="Weight")


# distribution of death times
quantile(c6a$ranks$time)


