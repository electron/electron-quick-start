#-*- R -*-

# initialization

library(nlme)
library(lattice)
options(width = 65, digits = 5)
options(contrasts = c(unordered = "contr.helmert", ordered = "contr.poly"))
pdf(file = "ch08.pdf")

# Chapter 8    Fitting Nonlinear Mixed-Effects Models

# 8.1 Fitting Nonlinear Models in S with nls and nlsList

## outer = ~1 is used to display all five curves in one panel
plot(Orange, outer = ~1)
logist <-
   function(x, Asym, xmid, scal) Asym/(1 + exp(-(x - xmid)/scal))
logist <- deriv(~Asym/(1+exp(-(x-xmid)/scal)),
    c("Asym", "xmid", "scal"), function(x, Asym, xmid, scal){})
Asym <- 180; xmid <- 700; scal <- 300
logist(Orange$age[1:7], Asym, xmid, scal)
fm1Oran.nls <- nls(circumference ~ logist(age, Asym, xmid, scal),
   data = Orange, start = c(Asym = 170, xmid = 700, scal = 500))
summary(fm1Oran.nls)
plot(fm1Oran.nls)
plot(fm1Oran.nls, Tree ~ resid(.), abline = 0)
Orange.sortAvg <- sortedXyData("age", "circumference", Orange)
Orange.sortAvg
NLSstClosestX(Orange.sortAvg, 130)
logistInit <- function(mCall, LHS, data) {
    xy <- sortedXyData(mCall[["x"]], LHS, data)
    if(nrow(xy) < 3) {
        stop("Too few distinct input values to fit a logistic")
    }
    Asym <- max(abs(xy[,"y"]))
    if (Asym != max(xy[,"y"])) Asym <- -Asym  # negative asymptote
    xmid <- NLSstClosestX(xy, 0.5 * Asym)
    scal <- NLSstClosestX(xy, 0.75 * Asym) - xmid
    value <- c(Asym, xmid, scal)
    names(value) <- mCall[c("Asym", "xmid", "scal")]
    value
}
logist <- selfStart(logist, initial = logistInit)
class(logist)
logist <- selfStart(~ Asym/(1 + exp(-(x - xmid)/scal)),
   initial = logistInit, parameters = c("Asym", "xmid", "scal"))
getInitial(circumference ~ logist(age, Asym, xmid, scal), Orange)
nls(circumference ~ logist(age, Asym, xmid, scal), Orange)
getInitial(circumference ~ SSlogis(age,Asym,xmid,scal), Orange)
nls(circumference ~ SSlogis(age, Asym, xmid, scal), Orange)
fm1Oran.lis <-
   nlsList(circumference ~ SSlogis(age, Asym, xmid, scal) | Tree,
           data = Orange)
fm1Oran.lis <- nlsList(SSlogis, Orange)
fm1Oran.lis.noSS <-
    nlsList(circumference ~ Asym/(1+exp(-(age-xmid)/scal)),
             data = Orange,
             start = c(Asym = 170, xmid = 700, scal = 500))
fm1Oran.lis
summary(fm1Oran.lis)
plot(intervals(fm1Oran.lis), layout = c(3,1))
plot(fm1Oran.lis, Tree ~ resid(.), abline = 0)
Theoph[1:4,]
fm1Theo.lis <- nlsList(conc ~ SSfol(Dose, Time, lKe, lKa, lCl),
   data = Theoph)
fm1Theo.lis
plot(intervals(fm1Theo.lis), layout = c(3,1))
pairs(fm1Theo.lis, id = 0.1)

# 8.2 Fitting Nonlinear Mixed-Effects Models with nlme

## no need to specify groups, as Orange is a groupedData object
## random is omitted - by default it is equal to fixed
(fm1Oran.nlme <-
   nlme(circumference ~ SSlogis(age, Asym, xmid, scal),
       data = Orange,
       fixed = Asym + xmid + scal ~ 1,
       start = fixef(fm1Oran.lis)))
summary(fm1Oran.nlme)
summary(fm1Oran.nls)
pairs(fm1Oran.nlme)
fm2Oran.nlme <- update(fm1Oran.nlme, random = Asym ~ 1)
anova(fm1Oran.nlme, fm2Oran.nlme)
plot(fm1Oran.nlme)
## level = 0:1 requests fixed (0) and within-group (1) predictions
plot(augPred(fm2Oran.nlme, level = 0:1),
     layout = c(5,1))
qqnorm(fm2Oran.nlme, abline = c(0,1))
(fm1Theo.nlme <- nlme(fm1Theo.lis))
try( intervals(fm1Theo.nlme, which="var-cov") ) ## failing: Non-positive definite...
(fm2Theo.nlme <- update(fm1Theo.nlme,
  random = pdDiag(lKe + lKa + lCl ~ 1)))
fm3Theo.nlme <-
  update(fm2Theo.nlme, random = pdDiag(lKa + lCl ~ 1))
anova(fm1Theo.nlme, fm3Theo.nlme, fm2Theo.nlme)
plot(fm3Theo.nlme)
qqnorm(fm3Theo.nlme, ~ ranef(.))
CO2
plot(CO2, outer = ~Treatment*Type, layout = c(4,1))
(fm1CO2.lis <- nlsList(SSasympOff, CO2))
(fm1CO2.nlme <- nlme(fm1CO2.lis))
(fm2CO2.nlme <- update(fm1CO2.nlme, random = Asym + lrc ~ 1))
anova(fm1CO2.nlme, fm2CO2.nlme)
plot(fm2CO2.nlme,id = 0.05,cex = 0.8,adj = -0.5)
fm2CO2.nlmeRE <- ranef(fm2CO2.nlme, augFrame = TRUE)
fm2CO2.nlmeRE
class(fm2CO2.nlmeRE)
plot(fm2CO2.nlmeRE, form = ~ Type * Treatment)
contrasts(CO2$Type)
contrasts(CO2$Treatment)
fm3CO2.nlme <- update(fm2CO2.nlme,
  fixed = list(Asym ~ Type * Treatment, lrc + c0 ~ 1),
  start = c(32.412, 0, 0, 0, -4.5603, 49.344))
summary(fm3CO2.nlme)
anova(fm3CO2.nlme, Terms = 2:4)
fm3CO2.nlmeRE <- ranef(fm3CO2.nlme, aug = TRUE)
plot(fm3CO2.nlmeRE, form = ~ Type * Treatment)
fm3CO2.fix <- fixef(fm3CO2.nlme)
fm4CO2.nlme <- update(fm3CO2.nlme,
  fixed = list(Asym + lrc ~ Type * Treatment, c0 ~ 1),
  start = c(fm3CO2.fix[1:5], 0, 0, 0, fm3CO2.fix[6]))
summary(fm4CO2.nlme)
fm5CO2.nlme <- update(fm4CO2.nlme, random = Asym ~ 1)
anova(fm4CO2.nlme, fm5CO2.nlme)
CO2$type <- 2 * (as.integer(CO2$Type) - 1.5)
CO2$treatment <- 2 * (as.integer(CO2$Treatment) - 1.5)
fm1CO2.nls <- nls(uptake ~ SSasympOff(conc, Asym.Intercept +
  Asym.Type * type + Asym.Treatment * treatment +
  Asym.TypeTreatment * type * treatment, lrc.Intercept +
  lrc.Type * type + lrc.Treatment * treatment +
  lrc.TypeTreatment * type * treatment, c0), data = CO2,
  start = c(Asym.Intercept = 32.371, Asym.Type = -8.0086,
    Asym.Treatment = -4.2001, Asym.TypeTreatment = -2.7253,
    lrc.Intercept = -4.5267, lrc.Type =  0.13112,
    lrc.Treatment = 0.093928, lrc.TypeTreatment = 0.17941,
    c0 = 50.126))
anova(fm5CO2.nlme, fm1CO2.nls)
# plot(augPred(fm5CO2.nlme, level = 0:1),  ## FIXME: problem with levels
#      layout = c(6,2))  ## Actually a problem with contrasts.
## This fit just ping-pongs.
#fm1Quin.nlme <-
#  nlme(conc ~ quinModel(Subject, time, conc, dose, interval,
#                        lV, lKa, lCl),
#       data = Quinidine, fixed = lV + lKa + lCl ~ 1,
#       random = pdDiag(lV + lCl ~ 1), groups =  ~ Subject,
#       start = list(fixed = c(5, -0.3, 2)),
#       na.action = NULL, naPattern =  ~ !is.na(conc), verbose = TRUE)
#fm1Quin.nlme
#fm1Quin.nlmeRE <- ranef(fm1Quin.nlme, aug = TRUE)
#fm1Quin.nlmeRE[1:3,]
# plot(fm1Quin.nlmeRE, form = lCl ~  Age + Smoke + Ethanol +  ## FIXME: problem in max
#      Weight + Race + Height + glyco + Creatinine + Heart,
#      control = list(cex.axis = 0.7))
#fm1Quin.fix <- fixef(fm1Quin.nlme)
#fm2Quin.nlme <- update(fm1Quin.nlme,
#  fixed = list(lCl ~ glyco, lKa + lV ~ 1),
#  start = c(fm1Quin.fix[3], 0, fm1Quin.fix[2:1]))
fm2Quin.nlme <-
    nlme(conc ~ quinModel(Subject, time, conc, dose, interval,
                          lV, lKa, lCl),
         data = Quinidine, fixed = list(lCl ~ glyco, lV + lKa ~ 1),
         random = pdDiag(diag(c(0.3,0.3)), form = lV + lCl ~ 1),
         groups =  ~ Subject,
         start = list(fixed = c(2.5, 0, 5.4, -0.2)),
         na.action = NULL, naPattern =  ~ !is.na(conc))
summary(fm2Quin.nlme)  # wrong values
options(contrasts = c("contr.treatment", "contr.poly"))
fm2Quin.fix <- fixef(fm2Quin.nlme)
## subsequent fits don't work
#fm3Quin.nlme <- update(fm2Quin.nlme,
#  fixed = list(lCl ~ glyco + Creatinine, lKa + lV ~ 1),
#  start = c(fm2Quin.fix[1:2], 0.2, fm2Quin.fix[3:4]))
#summary(fm3Quin.nlme)
#fm3Quin.fix <- fixef(fm3Quin.nlme)
#fm4Quin.nlme <- update(fm3Quin.nlme,
#  fixed = list(lCl ~ glyco + Creatinine + Weight, lKa + lV ~ 1),
#  start = c(fm3Quin.fix[1:3], 0, fm3Quin.fix[4:5]))
#summary(fm4Quin.nlme)
## This fit just ping-pongs
##fm1Wafer.nlmeR <-
##    nlme(current ~ A + B * cos(4.5679 * voltage) +
##         C * sin(4.5679 * voltage), data = Wafer,
##         fixed = list(A ~ voltage + I(voltage^2), B + C ~ 1),
##         random = list(Wafer = A ~ voltage + I(voltage^2),
##         Site = pdBlocked(list(A~1, A~voltage+I(voltage^2)-1))),
###  start = fixef(fm4Wafer), method = "REML", control = list(tolerance=1e-2))
##         start = c(-4.255, 5.622, 1.258, -0.09555, 0.10434),
##         method = "REML", control = list(tolerance = 1e-2))
##fm1Wafer.nlmeR
##fm1Wafer.nlme <- update(fm1Wafer.nlmeR, method = "ML")

(fm2Wafer.nlme <-
 nlme(current ~ A + B * cos(w * voltage + pi/4),
      data = Wafer,
      fixed = list(A ~ voltage + I(voltage^2), B + w ~ 1),
      random = list(Wafer = pdDiag(list(A ~ voltage + I(voltage^2), B + w ~ 1)),
      Site = pdDiag(list(A ~ voltage+I(voltage^2), B ~ 1))),
      start = c(-4.255, 5.622, 1.258, -0.09555, 4.5679)))
plot(fm2Wafer.nlme, resid(.) ~ voltage | Wafer,
     panel = function(x, y, ...) {
         panel.grid()
         panel.xyplot(x, y)
         panel.loess(x, y, lty = 2)
         panel.abline(0, 0)
     })
## anova(fm1Wafer.nlme, fm2Wafer.nlme, test = FALSE)
# intervals(fm2Wafer.nlme)

# 8.3  Extending the Basic nlme Model

#fm4Theo.nlme <- update(fm3Theo.nlme,
#   weights = varConstPower(power = 0.1))
# this fit is way off
#fm4Theo.nlme
#anova(fm3Theo.nlme, fm4Theo.nlme)
#plot(fm4Theo.nlme)
## xlim used to hide an unusually high fitted value and enhance
## visualization of the heteroscedastic pattern
# plot(fm4Quin.nlme, xlim = c(0, 6.2))
#fm5Quin.nlme <- update(fm4Quin.nlme, weights = varPower())
#summary(fm5Quin.nlme)
#anova(fm4Quin.nlme, fm5Quin.nlme)
#plot(fm5Quin.nlme, xlim = c(0, 6.2))
var.nlme <- nlme(follicles ~ A + B * sin(2 * pi * w * Time) +
                     C * cos(2 * pi * w *Time), data = Ovary,
                     fixed = A + B + C + w ~ 1, random = pdDiag(A + B + w ~ 1),
                                    #  start = c(fixef(fm5Ovar.lme), 1))
                     start = c(12.18, -3.298, -0.862, 1))
##fm1Ovar.nlme
##ACF(fm1Ovar.nlme)
##plot(ACF(fm1Ovar.nlme,  maxLag = 10), alpha = 0.05)
##fm2Ovar.nlme <- update(fm1Ovar.nlme, correlation = corAR1(0.311))
##fm3Ovar.nlme <- update(fm1Ovar.nlme, correlation = corARMA(p=0, q=2))
##anova(fm2Ovar.nlme, fm3Ovar.nlme, test = FALSE)
##intervals(fm2Ovar.nlme)
##fm4Ovar.nlme <- update(fm2Ovar.nlme, random = A ~ 1)
##anova(fm2Ovar.nlme, fm4Ovar.nlme)
##if (interactive()) fm5Ovar.nlme <- update(fm4Ovar.nlme, correlation = corARMA(p=1, q=1))
# anova(fm4Ovar.nlme, fm5Ovar.nlme)
# plot(ACF(fm5Ovar.nlme,  maxLag = 10, resType = "n"),
#        alpha = 0.05)
# fm5Ovar.lmeML <- update(fm5Ovar.lme, method = "ML")
# intervals(fm5Ovar.lmeML)
# fm6Ovar.lmeML <- update(fm5Ovar.lmeML, random = ~1)
# anova(fm5Ovar.lmeML, fm6Ovar.lmeML)
# anova(fm6Ovar.lmeML, fm5Ovar.nlme)
# intervals(fm5Ovar.nlme, which = "fixed")
fm1Dial.lis <-
  nlsList(rate ~ SSasympOff(pressure, Asym, lrc, c0) | QB,
           data = Dialyzer)
fm1Dial.lis
plot(intervals(fm1Dial.lis))
fm1Dial.gnls <- gnls(rate ~ SSasympOff(pressure, Asym, lrc, c0),
  data = Dialyzer, params = list(Asym + lrc ~ QB, c0 ~ 1),
  start = c(53.6, 8.6, 0.51, -0.26, 0.225))
fm1Dial.gnls
Dialyzer$QBcontr <- 2 * (Dialyzer$QB == 300) - 1
fm1Dial.nls <-
  nls(rate ~ SSasympOff(pressure, Asym.Int + Asym.QB * QBcontr,
  lrc.Int + lrc.QB * QBcontr, c0), data = Dialyzer,
  start = c(Asym.Int = 53.6, Asym.QB = 8.6, lrc.Int = 0.51,
  lrc.QB = -0.26, c0 = 0.225))
summary(fm1Dial.nls)
logLik(fm1Dial.nls)
plot(fm1Dial.gnls, resid(.) ~ pressure, abline = 0)
fm2Dial.gnls <- update(fm1Dial.gnls,
                       weights = varPower(form = ~ pressure))
anova(fm1Dial.gnls, fm2Dial.gnls)
ACF(fm2Dial.gnls, form = ~ 1 | Subject)
plot(ACF(fm2Dial.gnls, form = ~ 1 | Subject), alpha = 0.05)
fm3Dial.gnls <-
 update(fm2Dial.gnls, corr = corAR1(0.716, form = ~ 1 | Subject))
fm3Dial.gnls
intervals(fm3Dial.gnls)
anova(fm2Dial.gnls, fm3Dial.gnls)
# restore two fitted models
fm2Dial.lme <-
  lme(rate ~(pressure + I(pressure^2) + I(pressure^3) + I(pressure^4))*QB,
      Dialyzer, ~ pressure + I(pressure^2),
      weights = varPower(form = ~ pressure))
fm2Dial.lmeML <- update(fm2Dial.lme, method = "ML")
fm3Dial.gls <-
  gls(rate ~(pressure + I(pressure^2) + I(pressure^3) + I(pressure^4))*QB,
      Dialyzer, weights = varPower(form = ~ pressure),
      corr = corAR1(0.771, form = ~ 1 | Subject))
fm3Dial.glsML <- update(fm3Dial.gls, method = "ML")
anova( fm2Dial.lmeML, fm3Dial.glsML, fm3Dial.gnls, test = FALSE)

# cleanup

proc.time()

