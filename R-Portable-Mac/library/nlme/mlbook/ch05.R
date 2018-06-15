library(nlme)
# data(bdf)
## Model with random slope for IQ.ver.cen
## Compare with Table 5.1, p. 71.
fm5 <- lme(langPOST ~ IQ.ver.cen + avg.IQ.ver.cen,
           data = bdf, random = ~ IQ.ver.cen, method = "ML")
summary(fm5)
VarCorr(fm5)
-2 * c(logLik(fm5))                     # deviance
## Add centered class size and interaction
## Compare with Table 5.2, p. 75
fm6 <- update(fm5, langPOST ~ avg.IQ.ver.cen + IQ.ver.cen * grpSiz.cen)
summary(fm6)
VarCorr(fm6)
-2 * c(logLik(fm6))                     # deviance
