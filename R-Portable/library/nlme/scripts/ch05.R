#-*- R -*-

# initialization

library(nlme)
options(width = 65, digits = 5)
options(contrasts = c(unordered = "contr.helmert", ordered = "contr.poly"))
pdf(file = "ch05.pdf")

# Chapter 5    Extending the Basic Linear Mixed-Effects Models

# 5.1 General Formulation of the Extended Model

vf1Fixed <- varFixed(~ age)
vf1Fixed <- Initialize(vf1Fixed, data = Orthodont)
varWeights(vf1Fixed)
vf1Ident <- varIdent(c(Female = 0.5), ~ 1 | Sex)
vf1Ident <- Initialize(vf1Ident, Orthodont)
varWeights(vf1Ident)
vf2Ident <- varIdent(form =  ~ 1 | Sex, fixed = c(Female = 0.5))
vf2Ident <- Initialize(vf2Ident, Orthodont)
varWeights(vf2Ident)
vf3Ident <- varIdent(form = ~ 1 | Sex * age)
vf3Ident <- Initialize(vf3Ident, Orthodont)
varWeights(vf3Ident)
vf1Power <- varPower(1)
formula(vf1Power)
vf2Power <- varPower(fixed = 0.5)
vf3Power <- varPower(form = ~ fitted(.) | Sex,
  fixed = list(Male = 0.5, Female = 0))
vf1Exp <- varExp(form = ~ age | Sex, fixed = c(Female = 0))
vf1ConstPower <- varConstPower(power = 0.5,
      fixed = list(const = 1))
vf1Comb <- varComb(varIdent(c(Female = 0.5), ~ 1 | Sex),
                     varExp(1, ~ age))
vf1Comb <- Initialize(vf1Comb, Orthodont)
varWeights(vf1Comb)
fm1Dial.lme <-
    lme(rate ~(pressure + I(pressure^2) + I(pressure^3) + I(pressure^4))*QB,
        Dialyzer, ~ pressure + I(pressure^2))
fm1Dial.lme
plot(fm1Dial.lme, resid(.) ~ pressure, abline = 0)
fm2Dial.lme <- update(fm1Dial.lme,
                        weights = varPower(form = ~ pressure))
fm2Dial.lme
anova(fm1Dial.lme, fm2Dial.lme)
plot(fm2Dial.lme, resid(., type = "p") ~ pressure,
     abline = 0)
intervals(fm2Dial.lme)
plot(fm2Dial.lme, resid(.) ~ pressure|QB, abline = 0)
fm3Dial.lme <- update(fm2Dial.lme,
                      weights=varPower(form = ~ pressure | QB))
fm3Dial.lme
anova(fm2Dial.lme, fm3Dial.lme)
fm4Dial.lme <- update(fm2Dial.lme,
                      weights = varConstPower(form = ~ pressure))
anova(fm2Dial.lme, fm4Dial.lme)
plot(augPred(fm2Dial.lme), grid = TRUE)
anova(fm2Dial.lme)
anova(fm2Dial.lme, Terms = 8:10)
options(contrasts = c("contr.treatment", "contr.poly"))
fm1BW.lme <- lme(weight ~ Time * Diet, BodyWeight,
                   random = ~ Time)
fm1BW.lme
fm2BW.lme <- update(fm1BW.lme, weights = varPower())
fm2BW.lme
anova(fm1BW.lme, fm2BW.lme)
summary(fm2BW.lme)
anova(fm2BW.lme, L = c("Time:Diet2" = 1, "Time:Diet3" = -1))
cs1CompSymm <- corCompSymm(value = 0.3, form = ~ 1 | Subject)
cs2CompSymm <- corCompSymm(value = 0.3, form = ~ age | Subject)
cs1CompSymm <- Initialize(cs1CompSymm, data = Orthodont)
corMatrix(cs1CompSymm)
cs1Symm <- corSymm(value = c(0.2, 0.1, -0.1, 0, 0.2, 0),
                   form = ~ 1 | Subject)
cs1Symm <- Initialize(cs1Symm, data = Orthodont)
corMatrix(cs1Symm)
cs1AR1 <- corAR1(0.8, form = ~ 1 | Subject)
cs1AR1 <- Initialize(cs1AR1, data = Orthodont)
corMatrix(cs1AR1)
cs1ARMA <- corARMA(0.4, form = ~ 1 | Subject, q = 1)
cs1ARMA <- Initialize(cs1ARMA, data = Orthodont)
corMatrix(cs1ARMA)
cs2ARMA <- corARMA(c(0.8, 0.4), form = ~ 1 | Subject, p=1, q=1)
cs2ARMA <- Initialize(cs2ARMA, data = Orthodont)
corMatrix(cs2ARMA)
spatDat <- data.frame(x = (0:4)/4, y = (0:4)/4)
cs1Exp <- corExp(1, form = ~ x + y)
cs1Exp <- Initialize(cs1Exp, spatDat)
corMatrix(cs1Exp)
cs2Exp <- corExp(1, form = ~ x + y, metric = "man")
cs2Exp <- Initialize(cs2Exp, spatDat)
corMatrix(cs2Exp)
cs3Exp <- corExp(c(1, 0.2), form = ~ x + y, nugget = TRUE)
cs3Exp <- Initialize(cs3Exp, spatDat)
corMatrix(cs3Exp)
fm1Ovar.lme <- lme(follicles ~ sin(2*pi*Time) + cos(2*pi*Time),
                   data = Ovary, random = pdDiag(~sin(2*pi*Time)))
fm1Ovar.lme
ACF(fm1Ovar.lme)
plot(ACF(fm1Ovar.lme,  maxLag = 10), alpha = 0.01)
fm2Ovar.lme <- update(fm1Ovar.lme, correlation = corAR1())
anova(fm1Ovar.lme, fm2Ovar.lme)
if (interactive()) intervals(fm2Ovar.lme)
fm3Ovar.lme <- update(fm1Ovar.lme, correlation = corARMA(q = 2))
fm3Ovar.lme
anova(fm2Ovar.lme, fm3Ovar.lme, test = F)
fm4Ovar.lme <- update(fm1Ovar.lme,
                       correlation = corCAR1(form = ~Time))
anova(fm2Ovar.lme, fm4Ovar.lme, test = F)
(fm5Ovar.lme <- update(fm1Ovar.lme,
                       corr = corARMA(p = 1, q = 1)))
anova(fm2Ovar.lme, fm5Ovar.lme)
plot(ACF(fm5Ovar.lme,  maxLag = 10, resType = "n"), alpha = 0.01)
Variogram(fm2BW.lme, form = ~ Time)
plot(Variogram(fm2BW.lme, form = ~ Time, maxDist = 42))
fm3BW.lme <- update(fm2BW.lme,
                    correlation = corExp(form = ~ Time))
intervals(fm3BW.lme)
anova(fm2BW.lme, fm3BW.lme)
fm4BW.lme <-
      update(fm3BW.lme, correlation = corExp(form =  ~ Time,
                        nugget = TRUE))
anova(fm3BW.lme, fm4BW.lme)
plot(Variogram(fm3BW.lme, form = ~ Time, maxDist = 42))
plot(Variogram(fm3BW.lme, form = ~ Time, maxDist = 42,
               resType = "n", robust = TRUE))
fm5BW.lme <- update(fm3BW.lme, correlation = corRatio(form = ~ Time))
fm6BW.lme <- update(fm3BW.lme, correlation = corSpher(form = ~ Time))
fm7BW.lme <- update(fm3BW.lme, correlation = corLin(form = ~ Time))
fm8BW.lme <- update(fm3BW.lme, correlation = corGaus(form = ~ Time))
anova(fm3BW.lme, fm5BW.lme, fm6BW.lme, fm7BW.lme, fm8BW.lme)
fm1Orth.gls <- gls(distance ~ Sex * I(age - 11), Orthodont,
                   correlation = corSymm(form = ~ 1 | Subject),
                   weights = varIdent(form = ~ 1 | age))
fm1Orth.gls
intervals(fm1Orth.gls)
fm2Orth.gls <-
   update(fm1Orth.gls, corr = corCompSymm(form = ~ 1 | Subject))
anova(fm1Orth.gls, fm2Orth.gls)
intervals(fm2Orth.gls)
fm3Orth.gls <- update(fm2Orth.gls, weights = NULL)
anova(fm2Orth.gls, fm3Orth.gls)
plot(fm3Orth.gls, resid(., type = "n") ~ age | Sex)
fm4Orth.gls <- update(fm3Orth.gls,
                      weights = varIdent(form = ~ 1 | Sex))
anova(fm3Orth.gls, fm4Orth.gls)
qqnorm(fm4Orth.gls, ~resid(., type = "n"))
# not in book but needed for the following command
fm3Orth.lme <-
    lme(distance~Sex*I(age-11), data = Orthodont,
        random = ~ I(age-11) | Subject,
        weights = varIdent(form = ~ 1 | Sex))
anova(fm3Orth.lme, fm4Orth.gls, test = FALSE)
fm1Dial.gls <-
  gls(rate ~(pressure + I(pressure^2) + I(pressure^3) + I(pressure^4))*QB,
      Dialyzer)
plot(fm1Dial.gls, resid(.) ~ pressure, abline = 0)
fm2Dial.gls <- update(fm1Dial.gls,
                      weights = varPower(form = ~ pressure))
anova(fm1Dial.gls, fm2Dial.gls)
ACF(fm2Dial.gls, form = ~ 1 | Subject)
plot(ACF(fm2Dial.gls, form = ~ 1 | Subject), alpha = 0.01)
(fm3Dial.gls <- update(fm2Dial.gls,
                      corr = corAR1(0.771, form = ~ 1 | Subject)))
intervals(fm3Dial.gls)
anova(fm2Dial.gls, fm3Dial.gls)
anova(fm3Dial.gls, fm2Dial.lme, test = FALSE)
fm1Wheat2 <- gls(yield ~ variety - 1, Wheat2)
Variogram(fm1Wheat2, form = ~ latitude + longitude)
plot(Variogram(fm1Wheat2, form = ~ latitude + longitude,
      maxDist = 32), xlim = c(0,32))
fm2Wheat2 <- update(fm1Wheat2, corr = corSpher(c(28, 0.2),
                               form = ~ latitude + longitude,
                               nugget = TRUE))
fm2Wheat2
fm3Wheat2 <- update(fm1Wheat2,
                    corr = corRatio(c(12.5, 0.2),
                    form = ~ latitude + longitude, nugget = TRUE))
fm3Wheat2
anova(fm2Wheat2, fm3Wheat2)
anova(fm1Wheat2, fm3Wheat2)
plot(Variogram(fm3Wheat2, resType = "n"))
plot(fm3Wheat2, resid(., type = "n") ~ fitted(.), abline = 0)
qqnorm(fm3Wheat2, ~ resid(., type = "n"))
fm4Wheat2 <- update(fm3Wheat2, model = yield ~ variety)
anova(fm4Wheat2)
anova(fm3Wheat2, L = c(-1, 0, 1))

# cleanup

proc.time()

