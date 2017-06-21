options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test some more features of surv.diff
#
#  First, what happens when one group is a dummy
#


#
# The AML data, with a third group of early censorings "tacked on"
#
aml3 <- list(time=   c( 9, 13, 13, 18, 23, 28, 31, 34, 45, 48, 161,
			   5,  5,  8,  8, 12, 16, 23, 27, 30, 33, 43, 45,
			   1,  2,  2,  3,  3,  3,  4),
	    status= c( 1,1,0,1,1,0,1,1,0,1,0, 1,1,1,1,1,0,1,1,1,1,1,1,
				0,0,0,0,0,0,0),
	    x     = as.factor(c(rep("Maintained", 11),
				rep("Nonmaintained", 12), rep("Dummy",7) )))

aml3 <- data.frame(aml3)

# These should give the same result (chisq, df), but the second has an
#  extra group
survdiff(Surv(time, status) ~x, aml)
survdiff(Surv(time, status) ~x, aml3)


#
# Now a test of the stratified log-rank
#   There are no tied times within institution, so the coxph program
#   can be used to give a complete test
#
fit <- survdiff(Surv(time, status) ~ pat.karno + strata(inst), cancer)

cfit <- coxph(Surv(time, status) ~ factor(pat.karno) + strata(inst),
		cancer, iter=0)

tdata <- na.omit(cancer[,c('time', 'status', 'pat.karno', 'inst')])

temp1 <- tapply(tdata$status-1, list(tdata$pat.karno, tdata$inst), sum)
temp1 <- ifelse(is.na(temp1), 0, temp1)
temp2 <- tapply(cfit$resid,  list(tdata$pat.karno, tdata$inst), sum)
temp2 <- ifelse(is.na(temp2), 0, temp2)

temp2 <- temp1 - temp2

#Now temp1=observed, temp2=expected
all.equal(c(temp1), c(fit$obs))
all.equal(c(temp2), c(fit$exp))

all.equal(fit$var[-1,-1], solve(cfit$var))

rm(tdata, temp1, temp2)
