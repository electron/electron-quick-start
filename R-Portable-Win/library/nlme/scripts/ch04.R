#-*- R -*-

# initialization

library(nlme)
library(lattice)
options(width = 65, digits = 5)
options(contrasts = c(unordered = "contr.helmert", ordered = "contr.poly"))
pdf(file = 'ch04.pdf')

# Chapter 4    Fitting Linear Mixed-Effects Models

# 4.1 Fitting Linear Models in S with lm and lmList

fm1Orth.lm <- lm(distance ~ age, Orthodont)
fm1Orth.lm
par(mfrow=c(2,2))
plot(fm1Orth.lm)                               # Figure 4.1
fm2Orth.lm <- update(fm1Orth.lm, formula = distance ~ Sex*age)
summary(fm2Orth.lm)
fm3Orth.lm <- update(fm2Orth.lm, formula = . ~ . - Sex)
summary(fm3Orth.lm)
bwplot(getGroups(Orthodont)~resid(fm2Orth.lm)) # Figure 4.2
fm1Orth.lis <- lmList(distance ~ age | Subject, Orthodont)
getGroupsFormula(Orthodont)
fm1Orth.lis <- lmList(distance ~ age, Orthodont)
formula(Orthodont)
fm1Orth.lis <- lmList(Orthodont)
fm1Orth.lis
summary(fm1Orth.lis)
pairs(fm1Orth.lis, id = 0.01, adj = -0.5)      # Figure 4.3
fm2Orth.lis <- update(fm1Orth.lis, distance ~ I(age-11))
intervals(fm2Orth.lis)
plot(intervals(fm2Orth.lis))                   # Figure 4.5
IGF
plot(IGF)                                      # Figure 4.6
fm1IGF.lis <- lmList(IGF)
coef(fm1IGF.lis)
plot(intervals(fm1IGF.lis))                    # Figure 4.7
fm1IGF.lm <- lm(conc ~ age, data = IGF)
summary(fm1IGF.lm)

# 4.2 Fitting Linear Mixed-Effects Models with lme

fm1Orth.lme <- lme(distance ~ I(age-11), data = Orthodont,
                     random = ~ I(age-11) | Subject)
fm1Orth.lme <- lme(distance ~ I(age-11), data = Orthodont)
fm1Orth.lme <- lme(fm2Orth.lis)
fm1Orth.lme
fm2Orth.lme <- update(fm1Orth.lme, distance~Sex*I(age-11))
summary(fm2Orth.lme)
fitted(fm2Orth.lme, level = 0:1)
resid(fm2Orth.lme, level = 1)
resid(fm2Orth.lme, level = 1, type = "pearson")
newOrth <- data.frame(Subject = rep(c("M11","F03"), c(3, 3)),
                      Sex = rep(c("Male", "Female"), c(3, 3)),
                      age = rep(16:18, 2))
predict(fm2Orth.lme, newdata = newOrth)
predict(fm2Orth.lme, newdata = newOrth, level = 0:1)
fm2Orth.lmeM <- update(fm2Orth.lme, method = "ML")
summary(fm2Orth.lmeM)
compOrth <-
      compareFits(coef(fm2Orth.lis), coef(fm1Orth.lme))
compOrth

plot(compOrth, mark = fixef(fm1Orth.lme)) # Figure 4.8
## Figure 4.9
plot(comparePred(fm2Orth.lis, fm1Orth.lme, length.out = 2),
     layout = c(8,4), between = list(y = c(0, 0.5, 0)))
plot(compareFits(ranef(fm2Orth.lme), ranef(fm2Orth.lmeM)),
     mark = c(0, 0))
fm4Orth.lm <- lm(distance ~ Sex * I(age-11), Orthodont)
summary(fm4Orth.lm)
anova(fm2Orth.lme, fm4Orth.lm)
#fm1IGF.lme <- lme(fm1IGF.lis)
#fm1IGF.lme
#intervals(fm1IGF.lme)
#summary(fm1IGF.lme)
pd1 <- pdDiag(~ age)
pd1
formula(pd1)
#fm2IGF.lme <- update(fm1IGF.lme, random = pdDiag(~age))
(fm2IGF.lme <- lme(conc ~ age, IGF,
                   random = pdDiag(~age)))
#anova(fm1IGF.lme, fm2IGF.lme)
anova(fm2IGF.lme)
#update(fm1IGF.lme, random = list(Lot = pdDiag(~ age)))
pd2 <- pdDiag(value = diag(2), form = ~ age)
pd2
formula(pd2)
lme(conc ~ age, IGF, pdDiag(diag(2), ~age))
fm4OatsB <- lme(yield ~ nitro, data = Oats,
                 random =list(Block = pdCompSymm(~ Variety - 1)))
summary(fm4OatsB)
corMatrix(fm4OatsB$modelStruct$reStruct$Block)[1,2]
fm4OatsC <- lme(yield ~ nitro, data = Oats,
        random=list(Block=pdBlocked(list(pdIdent(~ 1),
                                         pdIdent(~ Variety-1)))))
summary(fm4OatsC)
## establishing the desired parameterization for contrasts
options(contrasts = c("contr.treatment", "contr.poly"))
fm1Assay <- lme(logDens ~ sample * dilut, Assay,
                random = pdBlocked(list(pdIdent(~ 1), pdIdent(~ sample - 1),
                pdIdent(~ dilut - 1))))
fm1Assay
anova(fm1Assay)
formula(Oxide)
fm1Oxide <- lme(Thickness ~ 1, Oxide)
fm1Oxide
intervals(fm1Oxide, which = "var-cov")
fm2Oxide <- update(fm1Oxide, random = ~ 1 | Lot)
anova(fm1Oxide, fm2Oxide)
coef(fm1Oxide, level = 1)
coef(fm1Oxide, level = 2)
ranef(fm1Oxide, level = 1:2)
fm1Wafer <- lme(current ~ voltage + I(voltage^2), data = Wafer,
                random = list(Wafer = pdDiag(~voltage + I(voltage^2)),
                Site = pdDiag(~voltage + I(voltage^2))))
summary(fm1Wafer)
fitted(fm1Wafer, level = 0)
resid(fm1Wafer, level = 1:2)
newWafer <-
    data.frame(Wafer = rep(1, 4), voltage = c(1, 1.5, 3, 3.5))
predict(fm1Wafer, newWafer, level = 0:1)
newWafer2 <- data.frame(Wafer = rep(1, 4), Site = rep(3, 4),
                        voltage = c(1, 1.5, 3, 3.5))
predict(fm1Wafer, newWafer2, level = 0:2)

# 4.3 Examining a Fitted Model

plot(fm2Orth.lme, Subject~resid(.), abline = 0)
plot(fm2Orth.lme, resid(., type = "p") ~ fitted(.) | Sex,
      id = 0.05, adj = -0.3)
fm3Orth.lme <-
  update(fm2Orth.lme, weights = varIdent(form = ~ 1 | Sex))
fm3Orth.lme
plot(fm3Orth.lme, distance ~ fitted(.),
      id = 0.05, adj = -0.3)
anova(fm2Orth.lme, fm3Orth.lme)
qqnorm(fm3Orth.lme, ~resid(.) | Sex)
plot(fm2IGF.lme, resid(., type = "p") ~ fitted(.) | Lot,
      layout = c(5,2))
qqnorm(fm2IGF.lme, ~ resid(.), id = 0.05, adj = -0.75)
plot(fm1Oxide)
qqnorm(fm1Oxide)
plot(fm1Wafer, resid(.) ~ voltage | Wafer)
plot(fm1Wafer, resid(.) ~ voltage | Wafer,
      panel = function(x, y, ...) {
                 panel.grid()
                 panel.xyplot(x, y)
                 panel.loess(x, y, lty = 2)
                 panel.abline(0, 0)
              })
with(Wafer,
     coef(lm(resid(fm1Wafer) ~ cos(4.19*voltage)+sin(4.19*voltage)-1)))
nls(resid(fm1Wafer) ~ b3*cos(w*voltage) + b4*sin(w*voltage), Wafer,
      start = list(b3 = -0.0519, b4 = 0.1304, w = 4.19))
fm2Wafer <- update(fm1Wafer,
      . ~ . + cos(4.5679*voltage) + sin(4.5679*voltage),
      random = list(Wafer=pdDiag(~voltage+I(voltage^2)),
             Site=pdDiag(~voltage+I(voltage^2))))
summary(fm2Wafer)
intervals(fm2Wafer)
qqnorm(fm2Wafer)
qqnorm(fm2Orth.lme, ~ranef(.), id = 0.10, cex = 0.7)
pairs(fm2Orth.lme, ~ranef(.) | Sex,
      id = ~ Subject == "M13", adj = -0.3)
fm2IGF.lme
c(0.00031074, 0.0053722)/abs(fixef(fm2IGF.lme))
fm3IGF.lme <- update(fm2IGF.lme, random = ~ age - 1)
anova(fm2IGF.lme, fm3IGF.lme)
qqnorm(fm1Oxide, ~ranef(., level = 1), id=0.10)
qqnorm(fm1Oxide, ~ranef(., level = 2), id=0.10)
#fm3Wafer <- update(fm2Wafer,
#              random = list(Wafer = ~voltage+I(voltage^2),
#                            Site = pdDiag(~voltage+I(voltage^2))),
#                   control = list(msVerbose = TRUE, msMaxIter = 200)
#                   )
#fm3Wafer
#anova(fm2Wafer, fm3Wafer)
#fm4Wafer <- update(fm2Wafer,
#                   random = list(Wafer = ~ voltage + I(voltage^2),
#                   Site = pdBlocked(list(~1,
#                   ~voltage+I(voltage^2) - 1))),
#                   control = list(msVerbose = TRUE,
#                   msMaxIter = 200))
#fm4Wafer
#anova(fm3Wafer, fm4Wafer)
#qqnorm(fm4Wafer, ~ranef(., level = 2), id = 0.05,
#        cex = 0.7, layout = c(3, 1))

# The next line is not in the book but is needed to get fm1Machine

fm1Machine <-
  lme(score ~ Machine, data = Machines, random = ~ 1 | Worker)

(fm3Machine <- update(fm1Machine, random = ~Machine-1|Worker))

# cleanup

proc.time()

