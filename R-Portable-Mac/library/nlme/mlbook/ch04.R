library(nlme)
# data(bdf)
## Fit the null model
## Compare with Table 4.1, p. 47
fm1 <- lme(langPOST ~ 1, data = bdf, random = ~ 1 | schoolNR)
VarCorr(fm1)
-2*c(logLik(fm1))                       # deviance
## Fit model with fixed IQ term and random intercept
## Compare with Table 4.2, p. 49
## From the results in Tables 4.2 and 4.4, it appears that
##  maximum likelihood fits are used, not REML fits.
fm2 <- update(fm1, langPOST ~ IQ.ver.cen)
summary(fm2)
VarCorr(fm2)
-2 * c(logLik(fm2))                     # deviance
## Purely fixed-effects model for comparison
## Compare with Table 4.3, p. 51
fm3 <- lm(langPOST ~ IQ.ver.cen, data = bdf)
summary(fm3)
-2 * c(logLik(fm3))                     # deviance
## Model with average IQ for the school
## Compare with Table 4.4, p. 55
fm4 <- update(fm2, langPOST ~ IQ.ver.cen + avg.IQ.ver.cen)
summary(fm4)
VarCorr(fm4)
-2 * c(logLik(fm4))                     # deviance
