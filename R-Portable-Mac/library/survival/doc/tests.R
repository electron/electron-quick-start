### R code from vignette source 'tests.Rnw'

###################################################
### code chunk number 1: tests.Rnw:20-24
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=8) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #reset default


###################################################
### code chunk number 2: tests.Rnw:44-52
###################################################
library(survival)
age2 <- cut(flchain$age, c(49, 59, 69, 79, 89, 120),                   
            labels=c("50-59", "60-69", "70-79", "80-89", "90+"))

flchain$flc <- flchain$kappa + flchain$lambda                    
tab1 <- with(flchain, tapply(flc, list(sex, age2), mean))
cat("female&" , paste(round(tab1[1,], 1), collapse=" & "), "\\\\ \n")
cat("male &"  , paste(round(tab1[2,], 1), collapse=" & "), "\n")


###################################################
### code chunk number 3: data
###################################################
getOption("SweaveHooks")[["fig"]]()
library(survival)
library(splines)
age2 <- cut(flchain$age, c(49, 59, 69, 79, 89, 120),                   
            labels=c("50-59", "60-69", "70-79", "80-89", "90+"))
counts <- with(flchain, table(sex, age2))
counts
#
flchain$flc <- flchain$kappa + flchain$lambda                    
male <- (flchain$sex=='M')
mlow <- with(flchain[male,],  smooth.spline(age, flc))
flow <- with(flchain[!male,], smooth.spline(age, flc))
plot(flow, type='l', ylim=range(flow$y, mlow$y),
     xlab="Age", ylab="FLC")
lines(mlow, col=2)
cellmean <- with(flchain, tapply(flc, list(sex, age2), mean, na.rm=T))
matpoints(c(55,65,75, 85, 95), t(cellmean), pch='fm', col=1:2)

round(cellmean, 2)


###################################################
### code chunk number 4: tests.Rnw:384-393
###################################################
us2000 <- rowSums(uspop2[51:101,,'2000'])

fit1 <- lm(flc ~ sex, flchain, x=TRUE)
fit2 <- lm(flc ~ sex + ns(age,4), flchain, x=TRUE)
c(fit1$coef[2], fit2$coef[2])

wt1  <- solve(t(fit1$x)%*%fit1$x, t(fit1$x))[2,] # unadjusted
wt2 <-  solve(t(fit2$x)%*%fit2$x, t(fit2$x))[2,] # age-adjusted
table(wt1, flchain$sex)


###################################################
### code chunk number 5: pop
###################################################
getOption("SweaveHooks")[["fig"]]()
us2000 <- rowSums(uspop2[51:101,,'2000'])
tab0 <- table(flchain$age)
tab2 <- tapply(abs(wt2), flchain$age, sum)
matplot(50:100, cbind(tab0/sum(tab0), tab2/sum(tab2)),
        type='l', lty=1,
        xlab="Age", ylab="Density")

us2000 <- rowSums(uspop2[51:101,,'2000'])
matpoints(50:100, us2000/sum(us2000), pch='u')
legend(60, .02, c("Empirical reference", "LS reference"),
       lty=1, col=1:2, bty='n')


###################################################
### code chunk number 6: yfit
###################################################
yatesfit <- lm(flc ~ interaction(sex, age2) -1, data=flchain)
theta <- matrix(coef(yatesfit), nrow=2)
dimnames(theta) <- dimnames(counts)
round(theta,2)


###################################################
### code chunk number 7: tests.Rnw:548-570
###################################################
qform <- function(beta, var) # quadratic form b' (V-inverse) b
    sum(beta * solve(var, beta))
contrast <- function(cmat, fit) {
    varmat <- vcov(fit)
    if (class(fit) == "lm") sigma2 <- summary(fit)$sigma^2              
    else sigma2 <- 1   # for the Cox model case

    beta <- coef(fit)
    if (!is.matrix(cmat)) cmat <- matrix(cmat, nrow=1)
    if (ncol(cmat) != length(beta)) stop("wrong dimension for contrast")

    estimate <- drop(cmat %*% beta)  #vector of contrasts
    ss <- qform(estimate, cmat %*% varmat %*% t(cmat)) *sigma2
    list(estimate=estimate, ss=ss, var=drop(cmat %*% varmat %*% t(cmat)))
    }

yates.sex <- matrix(0, 2, 10)
yates.sex[1, c(1,3,5,7,9)] <-  1/5    #females
yates.sex[2, c(2,4,6,8,10)] <- 1/5    #males

contrast(yates.sex, yatesfit)$estimate  # the estimated "average" FLC for F/M
contrast(yates.sex[2,]-yates.sex[,1], yatesfit) # male - female contrast


###################################################
### code chunk number 8: tests.Rnw:573-599
###################################################
# Create the estimates table -- lots of fits
emat <- matrix(0., 6, 3)
dimnames(emat) <- list(c("Unadjusted", "MVUE: continuous age", 
                         "MVUE: categorical age", "Empirical (data) reference",
                         "US200 reference", "Uniform (Yates)"),
                       c("est", "se", "SS"))

#unadjusted
emat[1,] <- c(summary(fit1)$coef[2,1:2], anova(fit1)["sex", "Sum Sq"])
# MVUE -- do the two fits
fit2 <- lm(flc ~ ns(age,4) + sex, flchain)
emat[2,] <- c(summary(fit2)$coef[6, 1:2], anova(fit2)["sex", "Sum Sq"])
fit2 <- lm(flc ~ age2 + sex, flchain)
emat[3,] <- c(summary(fit2)$coef[6, 1:2], anova(fit2)["sex", "Sum Sq"])

#Remainder, use contrasts
tfun <- function(wt) {
    cvec <- c(matrix(c(-wt, wt), nrow=2, byrow=TRUE))
    temp <- contrast(cvec, yatesfit)
    c(temp$est, sqrt(temp$var), temp$ss)
}
emat[4,] <- tfun(colSums(counts)/sum(counts))

usgroup <- tapply(us2000, rep(1:5, c(10,10,10,10,11)), sum)/sum(us2000)
emat[5,]<- tfun(usgroup)
emat[6,] <- tfun(rep(1/5,5))


###################################################
### code chunk number 9: tests.Rnw:604-608
###################################################
temp <- dimnames(emat)[[1]]
for (i in 1:nrow(emat))
   cat(temp[i], sprintf(" &%5.3f", emat[i,1]),sprintf(" &%6.5f", emat[i,2]), 
       sprintf(" & %6.1f", emat[i,3]), "\\\\ \n")


###################################################
### code chunk number 10: weights
###################################################
casewt <- array(1, dim=c(2,5,4)) # case weights by sex, age group, estimator
csum <- colSums(counts)
casewt[,,2] <- counts[2:1,] / rep(csum, each=2)
casewt[,,3] <- rep(csum, each=2)/counts
casewt[,,4] <- 1/counts
#renorm each so that the mean weight is 1
for (i in 1:4) {
    for (j in 1:2) {
        meanwt <- sum(casewt[j,,i]*counts[j,])/ sum(counts[j,])
        casewt[j,,i] <- casewt[j,,i]/ meanwt
    }
}


###################################################
### code chunk number 11: tests.Rnw:652-662
###################################################
tname <- c("Unadjusted", "Min var", "Empirical", "Yates")
for (i in 1:2) {
    for (j in 1:4) {
        cat("&",tname[j], " & ",
            paste(sprintf("%4.2f", casewt[i,,j]), collapse= " & "),
             "\\\\\n")
       if (j==1) cat(c("Female", "Male")[i])
    }
    if (i==1) cat("\\hline ")
}


###################################################
### code chunk number 12: tests.Rnw:705-709
###################################################
temp <- 1/colSums(1/counts)
temp <- temp/sum(temp)
cat("Female", sprintf(" & %5.3f", -temp), "\\\\ \n")
cat("Male",   sprintf(" & %5.3f", temp), "\\\\ \n")


###################################################
### code chunk number 13: treatment
###################################################
fit3 <- lm(flc ~ sex * age2, flchain)
coef(fit3)
contrast(c(0,1, 0,0,0,0, .2,.2,.2,.2), fit3) #Yates


###################################################
### code chunk number 14: SAS
###################################################
options(contrasts=c("contr.SAS", "contr.poly"))
sfit1 <- lm(flc ~ sex, flchain)
sfit2 <- lm(flc ~ sex + age2, flchain)
sfit3 <- lm(flc ~ sex * age2, flchain)
contrast(c(0,-1, 0,0,0,0, -.2,-.2,-.2,-.2), sfit3) # Yates for SAS coding


###################################################
### code chunk number 15: nstt
###################################################
options(contrasts = c("contr.treatment", "contr.poly")) #R default
fit3a <- lm(flc ~ sex * age2, flchain)
options(contrasts = c("contr.SAS", "contr.poly"))
fit3b <- lm(flc~ sex * age2, flchain)
options(contrasts=c("contr.sum", "contr.poly"))
fit3c <- lm(flc ~ sex * age2, flchain)
#
nstt <- c(0,1, rep(0,8))  #test only the sex coef = the NSTT method
temp <- rbind(unlist(contrast(nstt, fit3a)),
              unlist(contrast(nstt, fit3b)),
              unlist(contrast(nstt, fit3c)))[,1:2]
dimnames(temp) <- list(c("R", "SAS", "sum"), c("effect", "SS"))
print(temp)
#
drop1(fit3a, .~.)


###################################################
### code chunk number 16: anova
###################################################
options(show.signif.stars = FALSE) #exhibit intelligence
sfit0  <- lm(flc ~ 1, flchain)
sfit1b <- lm(flc ~ age2, flchain)
anova(sfit0, sfit1b, sfit2, sfit3)


###################################################
### code chunk number 17: relrate
###################################################
options(contrasts= c("contr.treatment", "contr.poly")) # R default
cfit0 <- coxph(Surv(futime, death) ~ interaction(sex, age2), flchain)
cmean <- matrix(c(0, coef(cfit0)), nrow=2)
cmean <- rbind(cmean, cmean[2,] - cmean[1,])
dimnames(cmean) <- list(c("F", "M", "M/F ratio"), dimnames(counts)[[2]])
signif(exp(cmean),3)


###################################################
### code chunk number 18: cox anova
###################################################
options(contrasts=c("contr.SAS", "contr.poly"))
cfit1 <- coxph(Surv(futime, death) ~ sex, flchain)
cfit2 <- coxph(Surv(futime, death) ~ age2 + sex, flchain)
cfit3 <- coxph(Surv(futime, death) ~ sex + strata(age2), flchain)
# Unadjusted
summary(cfit1)
#
# LRT
anova(cfit2)
#
# Stratified
anova(cfit3)
summary(cfit3)
#
# Wald test
signif(summary(cfit2)$coefficients, 3)
#
anova(cfit1, cfit2)


###################################################
### code chunk number 19: coxfit
###################################################
wtindx <- with(flchain, tapply(death, list(sex, age2)))
cfitpop <- coxph(Surv(futime, death) ~ sex, flchain,
                robust=TRUE, weight = (casewt[,,3])[wtindx]) 
cfityates <- coxph(Surv(futime, death) ~ sex, flchain,
                robust=TRUE, weight = (casewt[,,4])[wtindx])
#
# Glue it into a table for viewing
#
tfun <- function(fit, indx=1) {
    c(fit$coef[indx], sqrt(fit$var[indx,indx]))
  }
coxp <- rbind(tfun(cfit1), tfun(cfit2,5), tfun(cfitpop), tfun(cfityates))
dimnames(coxp) <- list(c("Unadjusted", "Additive", "Empirical Population", 
                         "Uniform Population"),
                      c("Effect", "se(effect)"))
signif(coxp,3)


###################################################
### code chunk number 20: tests.Rnw:1219-1235
###################################################
cfit4 <- coxph(Surv(futime, death) ~ sex * age2, flchain)
# Uniform population contrast
ysex <- c(0,-1, 0,0,0,0, -.2,-.2,-.2,-.2) #Yates for sex, SAS coding
contrast(ysex[-1], cfit4) 
# Verify using cell means coding
cfit4b <- coxph(Surv(futime, death) ~ interaction(sex, age2), flchain)
temp <- matrix(c(0, coef(cfit4b)),2)  # the female 50-59 is reference
diff(rowMeans(temp)) #direct estimate of the Yates
#
temp2 <- rbind(temp, temp[2,] - temp[1,])
dimnames(temp2) <- list(c('female', 'male', 'difference'), levels(age2))
round(temp2, 3)
#                        
#
# NSTT contrast
contrast(c(1,0,0,0,0,0,0,0,0), cfit4)


###################################################
### code chunk number 21: nstt-lrt
###################################################
xmat4 <- model.matrix(cfit4)
cfit4b <- coxph(Surv(futime, death) ~ xmat4[,-1], flchain)
anova(cfit4b, cfit4)


###################################################
### code chunk number 22: ydata
###################################################
data1 <- data.frame(y = rep(1:6, length=20),
                    x1 = factor(letters[rep(1:3, length=20)]),
                    x2 = factor(LETTERS[rep(1:4, length=10)]),
		    x3 = 1:20)
data1$x1[19] <- 'c'
data1 <- data1[order(data1$x1, data1$x2),]
row.names(data1) <- NULL
with(data1, table(x1,x2))
     
# data2 -- single missing cell
indx <- with(data1, x1=='a' & x2=='D')
data2 <- data1[!indx,]

#data3 -- missing the diagonal
data3 <- data1[as.numeric(data1$x1) != as.numeric(data1$x2),]


###################################################
### code chunk number 23: tests.Rnw:1411-1414
###################################################
options(contrasts=c("contr.sum", "contr.poly"))
fit1 <- lm(y ~ x1*x2, data1)
drop1(fit1, .~.)


###################################################
### code chunk number 24: tests.Rnw:1421-1427
###################################################
options(contrasts=c("contr.SAS", "contr.poly"))
fit2 <- lm(y ~ x1*x2, data1)
drop1(fit2, .~.)
options(contrasts=c("contr.treatment", "contr.poly"))
fit3 <- lm(y ~ x1*x2, data1)
drop1(fit3, .~.)


###################################################
### code chunk number 25: att
###################################################
X <- model.matrix(fit2)
ux <- unique(X)
ux
indx <- rep(1:3, c(4,4,4))
effects <- t(rowsum(ux, indx)/4)  # turn sideways to fit the paper better
effects
yates <- effects[,-1] - effects[,1]
yates


###################################################
### code chunk number 26: tests.Rnw:1467-1470
###################################################
wt <- solve(t(X) %*% X, t(X)) # twelve rows (one per coef), n columns
casewt <- t(effects) %*% wt   # case weights for the three "row efffects"
for (i in 1:3) print(tapply(casewt[i,], data1$x2, sum))


###################################################
### code chunk number 27: tests.Rnw:1507-1508
###################################################
fit4 <- lm(y ~ x1*x2 + x3, data=data1)


