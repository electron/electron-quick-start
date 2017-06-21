# 
# New tests 4/2010 to validate strata by covariate interactions
#
library(survival)
options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

tdata <- lung
tdata$sex <- lung$sex +3

# Both of these should produce warning messages about singular X, since there
#  are ph.ecog=3 subjects in only 1 of the strata. 
# Does not affect the test 
fit1 <- coxph(Surv(time, status) ~ age + sex:strata(ph.ecog), lung)
fit2 <- coxph(Surv(time, status) ~ age + sex:strata(ph.ecog), tdata)

aeq(fit1$coef, fit2$coef)
aeq(fit1$var, fit2$var)
aeq(predict(fit1), predict(fit2))
