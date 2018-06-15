#
# Test out anova, with strata terms
#
options(na.action=na.omit)
library(survival)

fit1 <- coxph(Surv(time, status) ~ ph.ecog + wt.loss + strata(sex) + 
              poly(age,3), lung)
ztemp <- anova(fit1)

tdata <- na.omit(lung[, c('time', 'status', 'ph.ecog', 'wt.loss', 'sex', 'age')])
fit2 <- coxph(Surv(time, status)~ ph.ecog + wt.loss + poly(age,3) + strata(sex),
              data=tdata)
ztemp2 <- anova(fit2)
all.equal(ztemp, ztemp2)


fit2 <-  coxph(Surv(time, status) ~ ph.ecog + wt.loss + strata(sex), tdata)
fit3 <-  coxph(Surv(time, status) ~ ph.ecog + strata(sex), tdata)

all.equal(ztemp$loglik, c(fit1$loglik[1], fit3$loglik[2], fit2$loglik[2],
                         fit1$loglik[2]))
all.equal(ztemp$Chisq[-1], 2* diff(ztemp$loglik))
all.equal(ztemp$Df[-1], c(1,1,3))

ztemp2 <- anova(fit3, fit2, fit1)
all.equal(ztemp2$loglik, ztemp$loglik[-1])
all.equal(ztemp2$Chisq[2:3], ztemp$Chisq[3:4])
# Change from ztemp2$P; it's a data frame and in R 3.0.2 abbreviated names
#   give a warning
all.equal(ztemp2[[4]][2:3], ztemp[[4]][3:4])


