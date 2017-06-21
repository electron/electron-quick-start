library(nlme)
data(Orthodont)
# add a column with an NA that is not used in the fit
Orthodont$Others = runif(nrow(Orthodont))
is.na(Orthodont$Others[3]) = TRUE
fm1 = lme(Orthodont, random = ~1)
augPred(fm1, length.out = 2, level = c(0,1))
