options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Data courtesy of Bercedis Peterson, Duke University.
#  v4 of survreg fails due to 2 groups that have only 1 subject; the coef
#  for them easily gets out of hand.  In fact, this data set is my toughest
#  test of the minimizer.
#
# A shrinkage model for this coefficient is therefore interesting


peterson <- data.frame(
		  scan('data.peterson', what=list(grp=0, time=0, status=0)))

fitp <- survreg(Surv(time, status) ~ factor(grp), peterson)
summary(fitp)

# Now a shrinkage model.  Give the group coefficients
#  about 1/2 the scale parameter of the original model, i.e., .18.
#
ffit <- survreg(Surv(time, status) ~ frailty(grp, theta=.1), peterson)
ffit

#
# Try 3 degrees of freedom, since there are 6 groups
#   compare them to the unconstrained ones.  The frailty coefs are
#   on a "sum to constant" constraint rather than "first coef=0", so
#   some conversion is neccessary
#
ffit3 <- survreg(Surv(time, status) ~ frailty(grp, df=3), peterson)
print(ffit3)

temp <- mean(c(0, fitp$coef[-1])) - mean(ffit3$frail)
temp2 <- c(fitp$coef[1] + temp, c(0,fitp$coef[-1]) - temp)
xx <- rbind(c(nrow(peterson), table(peterson$grp)),
	    temp2,
	    c(ffit3$coef, ffit3$frail))
dimnames(xx) <- list(c("N", "factor", "frailty"),
		     c("Intercept", paste("grp", 1:6)))
signif(xx,3)

rm(ffit, ffit3, temp, temp2, xx, fitp)
