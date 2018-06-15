### R code from vignette source 'longintro.Rnw'

###################################################
### code chunk number 1: longintro.Rnw:38-43
###################################################
options(continue = "  ", width = 60)
options(SweaveHooks=list(fig=function() par(mar = c(4.1, 4.1, 0.1, 1.1))))
pdf.options(pointsize = 10)
par(xpd = NA)  #stop clipping
library(rpart)


###################################################
### code chunk number 2: impurity
###################################################
getOption("SweaveHooks")[["fig"]]()
ptemp <- seq(0, 1, length = 101)[2:100]
gini <- 2* ptemp *(1-ptemp)
inform <- -(ptemp*log(ptemp) + (1-ptemp)*log(1-ptemp))
sgini <- gini *max(inform)/max(gini)
matplot(ptemp, cbind(gini, inform, sgini), type = 'l', lty = 1:3,
        xlab = "P", ylab = "Impurity", col = 1)
legend(.3, .2, c("Gini", "Information", "rescaled Gini"),
       lty = 1:3, col = 1, bty = 'n')


###################################################
### code chunk number 3: gini1
###################################################
getOption("SweaveHooks")[["fig"]]()
progstat <- factor(stagec$pgstat, levels = 0:1, labels = c("No", "Prog"))
cfit  <- rpart(progstat ~  age + eet + g2 + grade + gleason + ploidy,
               data = stagec, method = 'class')
print(cfit)
par(mar = rep(0.1, 4))
plot(cfit)
text(cfit)


###################################################
### code chunk number 4: summary(cfit3
###################################################



###################################################
### code chunk number 5: longintro.Rnw:468-472
###################################################
temp <- with(stagec, table(cut(grade, c(0, 2.5, 4)),
                          cut(gleason, c(2, 5.5, 10)),
                          exclude = NULL))
temp


###################################################
### code chunk number 6: dig1
###################################################
getOption("SweaveHooks")[["fig"]]()
set.seed(1953)  # An auspicious year
n <- 200
y <- rep(0:9, length = 200)
temp <- c(1,1,1,0,1,1,1,
          0,0,1,0,0,1,0,
          1,0,1,1,1,0,1,
          1,0,1,1,0,1,1,
          0,1,1,1,0,1,0,
          1,1,0,1,0,1,1,
          0,1,0,1,1,1,1,
          1,0,1,0,0,1,0,
          1,1,1,1,1,1,1,
          1,1,1,1,0,1,0)

lights <- matrix(temp, 10, 7, byrow = TRUE)    # The true light pattern 0-9
temp1 <- matrix(rbinom(n*7, 1, 0.9), n, 7) # Noisy lights
temp1 <- ifelse(lights[y+1, ] == 1, temp1, 1-temp1)
temp2 <- matrix(rbinom(n*17, 1, 0.5), n, 17) # Random lights
x <- cbind(temp1, temp2)

dfit <- rpart(y ~ x, method='class',
              control = rpart.control(xval = 10, minbucket = 2, cp = 0))
printcp(dfit)

fit9 <- prune(dfit, cp = 0.02)
par(mar = rep(0.1, 4))
plot(fit9, branch = 0.3, compress = TRUE)
text(fit9)


###################################################
### code chunk number 7: longintro.Rnw:810-813
###################################################
printcp(cfit)

summary(cfit, cp = 0.06)


###################################################
### code chunk number 8: cars
###################################################
getOption("SweaveHooks")[["fig"]]()
fit1 <- rpart(Reliability ~ Price + Country + Mileage + Type,
                data = cu.summary, parms = list(split = 'gini'))
fit2 <- rpart(Reliability ~ Price + Country + Mileage + Type,
                data = cu.summary, parms = list(split = 'information'))

par(mfrow = c(1,2), mar = rep(0.1, 4))
plot(fit1, margin = 0.05);  text(fit1, use.n = TRUE, cex = 0.8)
plot(fit2, margin = 0.05);  text(fit2, use.n = TRUE, cex = 0.8)


###################################################
### code chunk number 9: longintro.Rnw:999-1000
###################################################
summary(fit1, cp = 0.06)


###################################################
### code chunk number 10: longintro.Rnw:1004-1008
###################################################
fit3 <- rpart(Reliability ~ Price + Country + Mileage + Type,
                data=cu.summary, parms=list(split='information'),
              maxdepth=2)
summary(fit3)


###################################################
### code chunk number 11: kyphos
###################################################
getOption("SweaveHooks")[["fig"]]()
lmat <- matrix(c(0,3, 4,0), nrow = 2, ncol = 2, byrow = FALSE)
fit1 <- rpart(Kyphosis ~  Age + Number + Start, data = kyphosis)

fit2 <- rpart(Kyphosis ~  Age + Number + Start, data = kyphosis,
              parms = list(prior = c(0.65, 0.35)))
fit3 <- rpart(Kyphosis ~  Age + Number + Start, data = kyphosis,
              parms = list(loss = lmat))

par(mfrow = c(1, 3), mar = rep(0.1, 4))
plot(fit1);  text(fit1, use.n = TRUE, all = TRUE, cex = 0.8)
plot(fit2);  text(fit2, use.n = TRUE, all = TRUE, cex = 0.8)
plot(fit3);  text(fit3, use.n = TRUE, all = TRUE, cex = 0.8)


###################################################
### code chunk number 12: longintro.Rnw:1211-1215
###################################################
cars <- car90[, -match(c("Rim", "Tires", "Model2"), names(car90))]
carfit <- rpart(Price/1000 ~ ., data=cars)
carfit
printcp(carfit)


###################################################
### code chunk number 13: longintro.Rnw:1218-1219
###################################################
temp <- carfit$cptable


###################################################
### code chunk number 14: longintro.Rnw:1243-1244
###################################################
summary(carfit, cp = 0.1)


###################################################
### code chunk number 15: anova2
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mfrow=c(1,2))
rsq.rpart(carfit)
par(mfrow=c(1,1))


###################################################
### code chunk number 16: anova3
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(predict(carfit), jitter(resid(carfit)))
temp <- carfit$frame[carfit$frame$var == '<leaf>',]
axis(3, at = temp$yval, as.character(row.names(temp)))
mtext('leaf number', side = 3, line = 3)
abline(h = 0, lty = 2)


###################################################
### code chunk number 17: longintro.Rnw:1316-1322
###################################################
cfit2 <- rpart(pgstat ~ age + eet + g2 + grade + gleason + ploidy,
               data = stagec)

printcp(cfit2)

print(cfit2, cp = 0.03)


###################################################
### code chunk number 18: longintro.Rnw:1492-1496
###################################################
sfit <- rpart(skips ~ Opening + Solder + Mask + PadType + Panel,
              data = solder, method = 'poisson',
              control = rpart.control(cp = 0.05, maxcompete = 2))
sfit


###################################################
### code chunk number 19: longintro.Rnw:1507-1508
###################################################
summary(sfit, cp = 0.1)


###################################################
### code chunk number 20: poisson1
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar = rep(0.1, 4))
plot(sfit)
text(sfit, use.n = TRUE, min = 3)

fit.prune <- prune(sfit, cp = 0.10)
plot(fit.prune)
text(fit.prune, use.n = TRUE, min = 2)


###################################################
### code chunk number 21: longintro.Rnw:1555-1558
###################################################
require(survival)
temp <- coxph(Surv(pgtime, pgstat) ~ 1, stagec)
newtime <- predict(temp, type = 'expected')


###################################################
### code chunk number 22: exp3
###################################################
getOption("SweaveHooks")[["fig"]]()
require(survival)
pfit <- rpart(Surv(pgtime, pgstat) ~ age + eet + g2 + grade +
               gleason + ploidy, data = stagec)
print(pfit)

pfit2 <- prune(pfit, cp = 0.016)
par(mar = rep(0.2, 4))
plot(pfit2, uniform = TRUE, branch = 0.4, compress = TRUE)
text(pfit2, use.n = TRUE)


###################################################
### code chunk number 23: exp4
###################################################
getOption("SweaveHooks")[["fig"]]()
temp <- snip.rpart(pfit2, 6)
km <- survfit(Surv(pgtime, pgstat) ~ temp$where, stagec)
plot(km, lty = 1:4, mark.time = FALSE,
     xlab = "Years", ylab = "Progression")
legend(10, 0.3, paste('node', c(4,5,6,7)), lty = 1:4)


###################################################
### code chunk number 24: plots1
###################################################
getOption("SweaveHooks")[["fig"]]()
fit <- rpart(pgstat ~  age + eet + g2 + grade + gleason + ploidy,
             stagec, control = rpart.control(cp = 0.025))
par(mar = rep(0.2, 4))
plot(fit)
text(fit)


###################################################
### code chunk number 25: plots2
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar = rep(0.2, 4))
plot(fit, uniform = TRUE)
text(fit, use.n = TRUE, all = TRUE)


###################################################
### code chunk number 26: plots3
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar = rep(0.2, 4))
plot(fit, branch = 0)
text(fit, use.n = TRUE)


###################################################
### code chunk number 27: plots4
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar = rep(0.2, 4))
plot(fit, branch = 0.4,uniform = TRUE, compress = TRUE)
text(fit, all = TRUE, use.n = TRUE)


###################################################
### code chunk number 28: plots5
###################################################
getOption("SweaveHooks")[["fig"]]()
par(mar = rep(0.2, 4))
plot(fit, uniform = TRUE, branch = 0.2, compress = TRUE, margin = 0.1)
text(fit, all = TRUE, use.n = TRUE, fancy = TRUE, cex= 0.9)


###################################################
### code chunk number 29: longintro.Rnw:1780-1788
###################################################
carfit <- rpart(Price/1000 ~ ., cars)
carfit$cptable

price2 <-  cars$Price[!is.na(cars$Price)]/1000
temp <- xpred.rpart(carfit)
errmat <- price2 - temp
abserr <- colMeans(abs(errmat))
rbind(abserr, relative=abserr/mean(abs(price2-mean(price2))))


