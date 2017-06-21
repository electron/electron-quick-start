library(survival)
#
# Check that the survival curves from a Cox model with beta=0 
#  match ordinary survival
#
#  Aalen
surv1 <- survfit(Surv(time,status) ~ sex, data=lung, type='fleming',
                 error='tsiatis')
fit1 <- coxph(Surv(time, status) ~ age + strata(sex), data=lung, iter=0,
              method='breslow')
fit1$var <- 0*fit1$var   #sneaky, causes the extra term in the Cox variance
                         # calculation to be zero
surv2 <- survfit(fit1, type='aalen', vartype='tsiatis')
surv3 <- survfit(fit1)

arglist <- c('n', 'time', 'n.risk','n.event', 'n.censor', 'surv', 'strata',
             'std.err', 'upper', 'lower')
all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])
all.equal(unclass(surv1)[arglist], unclass(surv3)[arglist])


# Efron method
surv1 <- survfit(Surv(time,status) ~ sex, data=lung, type='fh2',
                 error='tsiatis')
surv2 <- survfit(fit1, type='efron', vartype='efron')
all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])

# Kaplan-Meier
surv1 <- survfit(Surv(time,status) ~ sex, data=lung)
surv2 <- survfit(fit1, type='kalb', vartype='green')
all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])


# Now add some random weights
rwt <- runif(nrow(lung), .5, 3)
surv1 <- survfit(Surv(time,status) ~ sex, data=lung, type='fleming',
                 error='tsiatis', weight=rwt)
fit1 <- coxph(Surv(time, status) ~ age + strata(sex), data=lung, iter=0,
              method='breslow', weight=rwt)
fit1$var <- 0*fit1$var   #sneaky
surv2 <- survfit(fit1, type='aalen', vartype='tsiatis')
surv3 <- survfit(fit1)

all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])
all.equal(unclass(surv1)[arglist], unclass(surv3)[arglist])


# Efron method
surv1 <- survfit(Surv(time,status) ~ sex, data=lung, type='fh2',
                 error='tsiatis', weight=rwt)
surv2 <- survfit(fit1, type='efron', vartype='efron')
all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])

# Kaplan-Meier
surv1 <- survfit(Surv(time,status) ~ sex, data=lung, weight=rwt)
surv2 <- survfit(fit1, type='kalb', vartype='green')
all.equal(unclass(surv1)[arglist], unclass(surv2)[arglist])

