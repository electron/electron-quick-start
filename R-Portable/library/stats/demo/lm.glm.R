### Examples from: "An Introduction to Statistical Modelling"
###			By Annette Dobson
###
### == with some additions ==

#  Copyright (C) 1997-2015 The R Core Team

require(stats); require(graphics)

## Plant Weight Data (Page 9)
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2,10, labels=c("Ctl","Trt"))
weight <- c(ctl,trt)
anova  (lm(weight~group))
summary(lm(weight~group -1))


## Birth Weight Data (Page 14)
age <- c(40, 38, 40, 35, 36, 37, 41, 40, 37, 38, 40, 38,
	 40, 36, 40, 38, 42, 39, 40, 37, 36, 38, 39, 40)
birthw <- c(2968, 2795, 3163, 2925, 2625, 2847, 3292, 3473, 2628, 3176,
	    3421, 2975, 3317, 2729, 2935, 2754, 3210, 2817, 3126, 2539,
	    2412, 2991, 2875, 3231)
sex <- gl(2,12, labels=c("M","F"))
plot(age, birthw, col=as.numeric(sex), pch=3*as.numeric(sex),
     main="Dobson's Birth Weight Data")
lines(lowess(age[sex=='M'], birthw[sex=='M']), col=1)
lines(lowess(age[sex=='F'], birthw[sex=='F']), col=2)
legend("topleft", levels(sex), col=1:2, pch=3*(1:2), lty=1, bty="n")

summary(l1 <- lm(birthw ~ sex + age),    correlation=TRUE)
summary(l0 <- lm(birthw ~ sex + age -1), correlation=TRUE)
anova(l1,l0)
summary(li <- lm(birthw ~ sex + sex:age -1), correlation=TRUE)
anova(li,l0)

summary(zi <- glm(birthw ~ sex + age, family=gaussian()))
summary(z0 <- glm(birthw ~ sex + age - 1, family=gaussian()))
anova(zi, z0)

summary(z.o4 <- update(z0, subset = -4))
summary(zz <- update(z0, birthw ~ sex+age-1 + sex:age))
anova(z0,zz)

## Poisson Regression Data (Page 42)
x <- c(-1,-1,0,0,0,0,1,1,1)
y <- c(2,3,6,7,8,9,10,12,15)
summary(glm(y~x, family=poisson(link="identity")))


## Calorie Data (Page 45)
calorie <- data.frame(
    carb = c(33,40,37,27,30,43,34,48,30,38,
	     50,51,30,36,41,42,46,24,35,37),
    age	 = c(33,47,49,35,46,52,62,23,32,42,
	     31,61,63,40,50,64,56,61,48,28),
    wgt	 = c(100, 92,135,144,140,101, 95,101, 98,105,
	     108, 85,130,127,109,107,117,100,118,102),
    prot = c(14,15,18,12,15,15,14,17,15,14,
	     17,19,19,20,15,16,18,13,18,14))
summary(lmcal <- lm(carb~age+wgt+prot, data= calorie))


## Extended Plant Data (Page 59)
ctl <-	c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trtA <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
trtB <- c(6.31,5.12,5.54,5.50,5.37,5.29,4.92,6.15,5.80,5.26)
group <- gl(3, length(ctl), labels=c("Ctl","A","B"))
weight <- c(ctl,trtA,trtB)
anova(lmwg <- lm(weight~group))
summary(lmwg)
coef(lmwg)
coef(summary(lmwg))#- incl.  std.err,  t- and P- values.


## Fictitious Anova Data (Page 64)
y <- c(6.8,6.6,5.3,6.1,7.5,7.4,7.2,6.5,7.8,9.1,8.8,9.1)
a <- gl(3,4)
b <- gl(2,2, length(a))
anova(z <- lm(y~a*b))


## Achievement Scores (Page 70)
y <- c(6,4,5,3,4,3,6, 8,9,7,9,8,5,7, 6,7,7,7,8,5,7)
x <- c(3,1,3,1,2,1,4, 4,5,5,4,3,1,2, 3,2,2,3,4,1,4)
m <- gl(3,7)
anova(z <- lm(y~x+m))


## Beetle Data (Page 78)
dose <- c(1.6907, 1.7242, 1.7552, 1.7842, 1.8113, 1.8369, 1.861, 1.8839)
x <- c( 6, 13, 18, 28, 52, 53, 61, 60)
n <- c(59, 60, 62, 56, 63, 59, 62, 60)
dead <- cbind(x, n-x)
summary(     glm(dead ~ dose, family=binomial(link=logit)))
summary(     glm(dead ~ dose, family=binomial(link=probit)))
summary(z <- glm(dead ~ dose, family=binomial(link=cloglog)))
anova(z, update(z, dead ~ dose -1))


## Anther Data (Page 84)
## Note that the proportions below are not exactly
## in accord with the sample sizes quoted below.
## In particular, the last value, 5/9, should have been 0.556 instead of 0.555:
n <- c(102,  99,   108,	 76,   81,   90)
p <- c(0.539,0.525,0.528,0.724,0.617,0.555)
x <- round(n*p)
## x <- n*p
y <- cbind(x,n-x)
f <- rep(c(40,150,350),2)
(g <- gl(2,3))
summary(glm(y ~ g*f, family=binomial(link="logit")))
summary(glm(y ~ g + f, family=binomial(link="logit")))
## The "final model"
summary(glm.p84 <- glm(y~g,  family=binomial(link="logit")))
op <- par(mfrow = c(2,2), oma = c(0,0,1,0))
plot(glm.p84) # well ?
par(op)

## Tumour Data (Page 92)
counts <- c(22,2,10,16,54,115,19,33,73,11,17,28)
type <- gl(4,3,12,labels=c("freckle","superficial","nodular","indeterminate"))
site <- gl(3,1,12,labels=c("head/neck","trunk","extremities"))
data.frame(counts,type,site)
summary(z <- glm(counts ~ type + site, family=poisson()))

## Randomized Controlled Trial (Page 93)
counts <- c(18,17,15, 20,10,20, 25,13,12)
outcome   <- gl(3, 1, length(counts))
treatment <- gl(3, 3)
summary(z <- glm(counts ~ outcome + treatment, family=poisson()))

## Peptic Ulcers and Blood Groups
counts <- c(579, 4219, 911, 4578, 246, 3775, 361, 4532, 291, 5261, 396, 6598)
group <- gl(2, 1, 12, labels=c("cases","controls"))
blood <- gl(2, 2, 12, labels=c("A","O"))
city  <- gl(3, 4, 12, labels=c("London","Manchester","Newcastle"))
cbind(group, blood, city, counts) # gives internal codes for the factors

summary(z1 <- glm(counts ~ group*(city + blood), family=poisson()))
summary(z2 <- glm(counts ~ group*city + blood, family=poisson()),
        correlation = TRUE)
anova(z2, z1, test = "Chisq")
