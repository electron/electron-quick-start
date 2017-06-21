#
# Ensure that factors work in prediction
#
library(survival)

options(na.action="na.exclude") # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

tfit <- coxph(Surv(time, status) ~ age + factor(ph.ecog), lung)
p1 <- predict(tfit, type='risk')

# Testing NA handling is important too
keep <- (is.na(lung$ph.ecog) | lung$ph.ecog !=1)
lung2 <- lung[keep,]
p2 <- predict(tfit, type='risk', newdata=lung[keep,])
aeq(p1[keep], p2)

# Same, for survreg
tfit <- survreg(Surv(time, status) ~ age + factor(ph.ecog), lung)
p1 <- predict(tfit, type='response')
p2 <- predict(tfit, type='response', newdata=lung2)
aeq(p1[keep], p2)


# Now repeat it tossing the missings
options(na.action=na.omit) 
keep2 <- (lung$ph.ecog[!is.na(lung$ph.ecog)] !=1)

tfit2 <- survreg(Surv(time, status) ~ age + factor(ph.ecog), lung)
p3 <- predict(tfit2, type='response')
p4 <- predict(tfit2, type='response', newdata=lung2, na.action=na.omit)
aeq(p3[keep2] , p4)
