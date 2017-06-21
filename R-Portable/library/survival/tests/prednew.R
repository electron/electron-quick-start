#
# Make sure that the newdata argument works for various
#   predictions
# We purposely use a subset of the lung data that has only some
#   of the levels of the ph.ecog
library(survival)
options(na.action=na.exclude, contrasts=c('contr.treatment', 'contr.poly'))
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))

myfit <- coxph(Surv(time, status) ~ age + factor(ph.ecog) + strata(sex), lung)

keep <- which(lung$inst<13 & (lung$ph.ecog==1 | lung$ph.ecog==2))
p1 <- predict(myfit, type='lp')
p2 <- predict(myfit, type="lp", newdata=lung[keep,])
p3 <- predict(myfit, type='lp', se.fit=TRUE)
p4 <- predict(myfit, type="lp", newdata=lung[keep,], se.fit=TRUE)
aeq(p1[keep], p2)
aeq(p1, p3$fit)
aeq(p1[keep], p4$fit)
aeq(p3$se.fit[keep], p4$se.fit)

p1 <- predict(myfit, type='risk')
p2 <- predict(myfit, type="risk", newdata=lung[keep,])
p3 <- predict(myfit, type='risk', se.fit=TRUE)
p4 <- predict(myfit, type="risk", newdata=lung[keep,], se.fit=TRUE)
aeq(p1[keep], p2)
aeq(p1, p3$fit)
aeq(p1[keep], p4$fit)
aeq(p3$se.fit[keep], p4$se.fit)

# The all.equal fails for type=expected, Efron approx, and tied death
#  times due to use of an approximation.  See comments in the source code.
myfit <- coxph(Surv(time, status) ~ age + factor(ph.ecog) + strata(sex), 
               data=lung, method='breslow')
p1 <- predict(myfit, type='expected')
p2 <- predict(myfit, type="expected", newdata=lung[keep,])
p3 <- predict(myfit, type='expected', se.fit=TRUE)
p4 <- predict(myfit, type="expected", newdata=lung[keep,], se.fit=TRUE)
aeq(p1[keep], p2)
aeq(p1, p3$fit)
aeq(p1[keep], p4$fit)
aeq(p3$se.fit[keep], p4$se.fit)

p1 <- predict(myfit, type='terms')
p2 <- predict(myfit, type="terms",newdata=lung[keep,])
p3 <- predict(myfit, type='terms', se.fit=T)
p4 <- predict(myfit, type="terms",newdata=lung[keep,], se.fit=T)
aeq(p1[keep,], p2)
aeq(p1, p3$fit)
aeq(p1[keep,], p4$fit)
aeq(p3$se.fit[keep,], p4$se.fit)

#
# Check out the logic whereby predict does not need to
#  recover the model frame.  The first call should not 
#  need to do so, the second should in each case.
#
myfit <- coxph(Surv(time, status) ~ age + factor(sex), lung, x=T)
p1 <- predict(myfit, type='risk', se=T)
myfit2 <- coxph(Surv(time, status) ~ age + factor(sex), lung)
p2 <- predict(myfit2, type='risk', se=T)
aeq(p1$fit, p2$fit)
aeq(p1$se, p2$se)

p1 <- predict(myfit, type='expected', se=T)
p2 <- predict(myfit2, type='expected', se=T)
aeq(p1$fit, p2$fit)
aeq(p1$se.fit, p2$se.fit)

p1 <- predict(myfit, type='terms', se=T)
p2 <- predict(myfit2, type='terms', se=T)
aeq(p1$fit, p2$fit)
aeq(p1$se.fit, p2$se.fit)
