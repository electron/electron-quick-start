#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 7   Generalized Linear Models

library(MASS)
options(width=65, digits=5, height=9999)
pdf(file="ch07.pdf", width=8, height=6, pointsize=9)
options(contrasts = c("contr.treatment", "contr.poly"))

ax.1 <- glm(Postwt ~ Prewt + Treat + offset(Prewt),
            family = gaussian, data = anorexia)
summary(ax.1)

# 7.2  Binomial data

options(contrasts = c("contr.treatment", "contr.poly"))
ldose <- rep(0:5, 2)
numdead <- c(1, 4, 9, 13, 18, 20, 0, 2, 6, 10, 12, 16)
sex <- factor(rep(c("M", "F"), c(6, 6)))
SF <- cbind(numdead, numalive = 20 - numdead)
budworm.lg <- glm(SF ~ sex*ldose, family = binomial)
summary(budworm.lg)

plot(c(1,32), c(0,1), type = "n", xlab = "dose",
     ylab = "prob", log = "x")
text(2^ldose, numdead/20, labels = as.character(sex))
ld <- seq(0, 5, 0.1)
lines(2^ld, predict(budworm.lg, data.frame(ldose = ld,
  sex = factor(rep("M", length(ld)), levels = levels(sex))),
  type = "response"), col = 3)
lines(2^ld, predict(budworm.lg, data.frame(ldose = ld,
  sex = factor(rep("F", length(ld)), levels = levels(sex))),
  type = "response"), lty = 2, col = 2)

budworm.lgA <- update(budworm.lg, . ~ sex * I(ldose - 3))
summary(budworm.lgA, cor = F)$coefficients
anova(update(budworm.lg, . ~ . + sex * I(ldose^2)),
      test = "Chisq")

budworm.lg0 <- glm(SF ~ sex + ldose - 1, family = binomial)
summary(budworm.lg0, cor = F)$coefficients

dose.p(budworm.lg0, cf = c(1,3), p = 1:3/4)
dose.p(update(budworm.lg0, family = binomial(link = probit)),
       cf = c(1, 3), p = 1:3/4)

options(contrasts = c("contr.treatment", "contr.poly"))
attach(birthwt)
race <- factor(race, labels = c("white", "black", "other"))
table(ptl)
ptd <- factor(ptl > 0)
table(ftv)
ftv <- factor(ftv)
levels(ftv)[-(1:2)] <- "2+"
table(ftv)  # as a check
bwt <- data.frame(low = factor(low), age, lwt, race,
   smoke = (smoke > 0), ptd, ht = (ht > 0), ui = (ui > 0), ftv)
detach(); rm(race, ptd, ftv)

birthwt.glm <- glm(low ~ ., family = binomial, data = bwt)
summary(birthwt.glm)
birthwt.step <- stepAIC(birthwt.glm, trace = FALSE)
birthwt.step$anova
birthwt.step2 <- stepAIC(birthwt.glm, ~ .^2 + I(scale(age)^2)
   + I(scale(lwt)^2), trace = FALSE)
birthwt.step2$anova
summary(birthwt.step2)$coef
table(bwt$low, predict(birthwt.step2) > 0)

## R has a similar gam() in package gam and a different gam() in package mgcv
if(require(gam)) {
    attach(bwt)
    age1 <- age*(ftv=="1"); age2 <- age*(ftv=="2+")
    birthwt.gam <- gam(low ~ s(age) + s(lwt) + smoke + ptd +
                       ht + ui + ftv + s(age1) + s(age2) + smoke:ui, binomial,
                       bwt, bf.maxit=25)
    print(summary(birthwt.gam))
    print(table(low, predict(birthwt.gam) > 0))
    par(mfrow = c(2, 2))
    if(interactive()) plot(birthwt.gam, ask = TRUE, se = TRUE)
    par(mfrow = c(1, 1))
    detach()
}

library(mgcv)
attach(bwt)
age1 <- age*(ftv=="1"); age2 <- age*(ftv=="2+")
(birthwt.gam <- gam(low ~ s(age) + s(lwt) + smoke + ptd +
    ht + ui + ftv + s(age1) + s(age2) + smoke:ui, binomial, bwt))
table(low, predict(birthwt.gam) > 0)
par(mfrow = c(2, 2))
plot(birthwt.gam, se = TRUE)
par(mfrow = c(1, 1))
detach()

# 7.3  Poisson models

names(housing)
house.glm0 <- glm(Freq ~ Infl*Type*Cont + Sat,
                  family = poisson, data = housing)
summary(house.glm0)

addterm(house.glm0, ~. + Sat:(Infl+Type+Cont), test = "Chisq")

house.glm1 <- update(house.glm0, . ~ . + Sat:(Infl+Type+Cont))
summary(house.glm1)
1 - pchisq(deviance(house.glm1), house.glm1$df.resid)

dropterm(house.glm1, test = "Chisq")

addterm(house.glm1, ~. + Sat:(Infl+Type+Cont)^2, test = "Chisq")

hnames <- lapply(housing[, -5], levels) # omit Freq
house.pm <- predict(house.glm1, expand.grid(hnames),
                   type = "response")  # poisson means
house.pm <- matrix(house.pm, ncol = 3, byrow = TRUE,
                   dimnames = list(NULL, hnames[[1]]))
house.pr <- house.pm/drop(house.pm %*% rep(1, 3))
cbind(expand.grid(hnames[-1]), round(house.pr, 2))

loglm(Freq ~ Infl*Type*Cont + Sat*(Infl+Type+Cont),
       data = housing)

library(nnet)
(house.mult <- multinom(Sat ~ Infl + Type + Cont,
                        weights = Freq, data = housing))
house.mult2 <- multinom(Sat ~ Infl*Type*Cont,
                         weights = Freq, data = housing)
anova(house.mult, house.mult2, test = "none")

house.pm <- predict(house.mult, expand.grid(hnames[-1]),
                    type = "probs")
cbind(expand.grid(hnames[-1]), round(house.pm, 2))

house.cpr <- apply(house.pr, 1, cumsum)
logit <- function(x) log(x/(1-x))
house.ld <- logit(house.cpr[2, ]) - logit(house.cpr[1, ])
sort(drop(house.ld))
mean(.Last.value)

house.plr <- polr(Sat ~ Infl + Type + Cont,
                  data = housing, weights = Freq)
house.plr

house.pr1 <- predict(house.plr, expand.grid(hnames[-1]),
                     type = "probs")
cbind(expand.grid(hnames[-1]), round(house.pr1, 2))

Fr <- matrix(housing$Freq, ncol = 3, byrow = TRUE)
2 * sum(Fr * log(house.pr/house.pr1))

house.plr2 <- stepAIC(house.plr, ~.^2)
house.plr2$anova


# 7.4  A negative binomial family

glm(Days ~ .^4, family = poisson, data = quine)
quine.nb <- glm(Days ~ .^4, family = negative.binomial(2), data = quine)
quine.nb0 <- update(quine.nb, . ~ Sex/(Age + Eth*Lrn))
anova(quine.nb0, quine.nb, test = "Chisq")

quine.nb <- glm.nb(Days ~ .^4, data = quine)
quine.nb2 <- stepAIC(quine.nb)
quine.nb2$anova
dropterm(quine.nb2, test = "Chisq")
quine.nb3 <-
  update(quine.nb2, . ~ . - Eth:Age:Lrn - Sex:Age:Lrn)
anova(quine.nb2, quine.nb3)
c(theta = quine.nb2$theta, SE = quine.nb2$SE)

par(mfrow = c(2,2), pty = "m")
rs <- resid(quine.nb2, type = "deviance")
plot(predict(quine.nb2), rs, xlab = "Linear predictors",
    ylab = "Deviance residuals")
abline(h = 0, lty = 2)
qqnorm(rs, ylab = "Deviance residuals")
qqline(rs)
par(mfrow = c(1,1))


# End of ch07
