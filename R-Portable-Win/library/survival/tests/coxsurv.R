options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test out subscripting in the case of a coxph survival curve
#
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

fit <- coxph(Surv(time, status) ~ age + sex + meal.cal + strata(ph.ecog),
		data=cancer)
surv1 <- survfit(fit)
temp <- surv1[2:3]

which <- cumsum(surv1$strata)
zed   <- (which[1]+1):(which[3])
aeq(surv1$surv[zed], temp$surv)
aeq(surv1$time[zed], temp$time)

# This call should not create a model frame in the code -- so same
#  answer but a different path through the underlying code
fit <- coxph(Surv(time, status) ~ age + sex + meal.cal + strata(ph.ecog),
		x=T, data=cancer)
surv2 <- survfit(fit)
all.equal(surv1, surv2)

#
# Now a result with a matrix of survival curves
#
dummy <- data.frame(age=c(30,40,60), sex=c(1,2,2), meal.cal=c(500, 1000, 1500))
surv2 <- survfit(fit, newdata=dummy)

zed <- 1:which[1]
aeq(surv2$surv[zed,1], surv2[1,1]$surv)
aeq(surv2$surv[zed,2], surv2[1,2]$surv)
aeq(surv2$surv[zed,3], surv2[1,3]$surv)
aeq(surv2$surv[zed, ], surv2[1,1:3]$surv)
aeq(surv2$surv[zed],   (surv2[1]$surv)[,1])
aeq(surv2$surv[zed, ], surv2[1, ]$surv)

# And the depreciated form - call with a named vector as 'newdata'
#  the resulting $call component  won't match so delete it before comparing
surv3 <- survfit(fit, c(age=40, sex=2, meal.cal=1000))
all.equal(unclass(surv2[,2])[-length(surv3)], unclass(surv3)[-length(surv3)])



# Test out offsets, which have recently become popular due to a Langholz paper
fit1 <- coxph(Surv(time, status) ~ age + ph.ecog, lung)
fit2 <- coxph(Surv(time, status) ~ age + offset(ph.ecog * fit1$coef[2]), lung)
 
surv1 <- survfit(fit1, newdata=data.frame(age=50, ph.ecog=1))
surv2 <- survfit(fit2, newdata=data.frame(age=50, ph.ecog=1))
all.equal(surv1$surv, surv2$surv)

#
# Check out the start.time option
#
surv3 <- survfit(fit1, newdata=data.frame(age=50, ph.ecog=1),
                 start.time=100)
index <- match(surv3$time, surv1$time)
rescale <- summary(surv1, time=100)$surv
all.equal(surv3$surv, surv1$surv[index]/rescale)

