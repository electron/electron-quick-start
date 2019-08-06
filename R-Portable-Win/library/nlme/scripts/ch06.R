#-*- R -*-

# initialization

library(nlme)
options(width = 65, digits = 5)
options(contrasts = c(unordered = "contr.helmert", ordered = "contr.poly"))
pdf(file = "ch06.pdf")

# Chapter 6    Nonlinear Mixed-Effects Models:
#              Basic Concepts and Motivating Examples

# 6.2 Indomethicin Kinetics

plot(Indometh)
fm1Indom.nls <- nls(conc ~ SSbiexp(time, A1, lrc1, A2, lrc2),
                    data = Indometh)
summary(fm1Indom.nls)
plot(fm1Indom.nls, Subject ~ resid(.), abline = 0)
(fm1Indom.lis <- nlsList(conc ~ SSbiexp(time, A1, lrc1, A2, lrc2),
                        data = Indometh))
plot(intervals(fm1Indom.lis))
(fm1Indom.nlme <- nlme(fm1Indom.lis,
                      random = pdDiag(A1 + lrc1 + A2 + lrc2 ~ 1),
                      control = list(tolerance = 0.0001)))
fm2Indom.nlme <- update(fm1Indom.nlme,
                        random = pdDiag(A1 + lrc1 + A2 ~ 1))
anova(fm1Indom.nlme, fm2Indom.nlme)
(fm3Indom.nlme <- update(fm2Indom.nlme, random = A1+lrc1+A2 ~ 1))
fm4Indom.nlme <-
    update(fm3Indom.nlme,
           random = pdBlocked(list(A1 + lrc1 ~ 1, A2 ~ 1)))
anova(fm3Indom.nlme, fm4Indom.nlme)
anova(fm2Indom.nlme, fm4Indom.nlme)
plot(fm4Indom.nlme, id = 0.05, adj = -1)
qqnorm(fm4Indom.nlme)
plot(augPred(fm4Indom.nlme, level = 0:1))
summary(fm4Indom.nlme)

# 6.3 Growth of Soybean Plants

head(Soybean)
plot(Soybean, outer = ~ Year * Variety)
(fm1Soy.lis <- nlsList(weight ~ SSlogis(Time, Asym, xmid, scal),
                       data = Soybean))
(fm1Soy.nlme <- nlme(fm1Soy.lis))
fm2Soy.nlme <- update(fm1Soy.nlme, weights = varPower())
anova(fm1Soy.nlme, fm2Soy.nlme)
plot(ranef(fm2Soy.nlme, augFrame = TRUE),
     form = ~ Year * Variety, layout = c(3,1))
soyFix <- fixef(fm2Soy.nlme)
options(contrasts = c("contr.treatment", "contr.poly"))
(fm3Soy.nlme <-
 update(fm2Soy.nlme,
        fixed = Asym + xmid + scal ~ Year,
        start = c(soyFix[1], 0, 0, soyFix[2], 0, 0, soyFix[3], 0, 0)))
anova(fm3Soy.nlme)
# The following line is not in the book but needed to fit the model
fm4Soy.nlme <-
    nlme(weight ~ SSlogis(Time, Asym, xmid, scal),
         data = Soybean,
         fixed = list(Asym ~ Year*Variety, xmid ~ Year + Variety, scal ~ Year),
         random = Asym ~ 1,
         start = c(17, 0, 0, 0, 0, 0, 52, 0, 0, 0, 7.5, 0, 0),
         weights = varPower(0.95), control = list(verbose = TRUE))
# FIXME: An update doesn't work for the fixed argument when fixed is a list
## p. 293-4 :
summary(fm4Soy.nlme)
plot(augPred(fm4Soy.nlme))# Fig 6.14, p. 295

# 6.4 Clinical Study of Phenobarbital Kinetics

(fm1Pheno.nlme <-
 nlme(conc ~ phenoModel(Subject, time, dose, lCl, lV),
      data = Phenobarb, fixed = lCl + lV ~ 1,
      random = pdDiag(lCl + lV ~ 1), start = c(-5, 0),
      na.action = NULL, naPattern = ~ !is.na(conc)))
fm1Pheno.ranef <- ranef(fm1Pheno.nlme, augFrame = TRUE)
# (These plots used to encounter difficulties, now fine):
plot(fm1Pheno.ranef, form = lCl ~ Wt + ApgarInd)
plot(fm1Pheno.ranef, form = lV  ~ Wt + ApgarInd)

options(contrasts = c("contr.treatment", "contr.poly"))
if(FALSE)## This fit just "ping-pongs" until max.iterations error
fm2Pheno.nlme <-
   update(fm1Pheno.nlme,
          fixed = list(lCl ~ Wt, lV ~ Wt + ApgarInd),
          start = c(-5.0935, 0, 0.34259, 0, 0),
          control = list(pnlsTol = 1e-4, maxIter = 500,
          msVerbose = TRUE, opt = "nlm"))
##summary(fm2Pheno.nlme)
##fm3Pheno.nlme <-
##    update(fm2Pheno.nlme,
##           fixed = lCl + lV ~ Wt,
##           start = fixef(fm2Pheno.nlme)[-5])
##plot(fm3Pheno.nlme, conc ~ fitted(.), abline = c(0,1))

# cleanup

proc.time()

