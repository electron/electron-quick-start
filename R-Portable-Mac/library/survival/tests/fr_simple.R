options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Test the logic of the penalized code by fitting some no-frailty models
#  (theta=0).  It should give exactly the same answers as 'ordinary' coxph.
#
test1 <- data.frame(time=  c(4, 3,1,1,2,2,3),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))

test2 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0) )

zz <- rep(0, nrow(test1))
tfit1 <- coxph(Surv(time,status) ~x, test1, eps=1e-7)
tfit2 <- coxph(Surv(time,status) ~x + frailty(zz, theta=0, sparse=T), test1)
tfit3 <- coxph(Surv(zz,time,status) ~x + frailty(zz, theta=0, sparse=T), test1)

temp <- c('coefficients', 'var', 'loglik', 'linear.predictors',
	  'means', 'n', 'concordance')

all.equal(tfit1[temp], tfit2[temp])
all.equal(tfit2[temp], tfit3[temp])

zz <- rep(0, nrow(test2))
tfit1 <- coxph(Surv(start, stop, event) ~x, test2, eps=1e-7)
tfit2 <- coxph(Surv(start, stop, event) ~ x + frailty(zz, theta=0, sparse=T),
	       test2)
all.equal(tfit1[temp], tfit2[temp])


#
# Repeat the above tests, but with a strata added
#  Because the data set is simply doubled, the loglik will double,
#   beta is the same, variance is halved.
#
test3 <- rbind(test1, test1)
test3$x2 <- rep(1:2, rep(nrow(test1),2))
zz <- rep(0, nrow(test3))
tfit1 <- coxph(Surv(time,status) ~x + strata(x2), test3, eps=1e-7)
tfit2 <- coxph(Surv(time,status) ~x + frailty(zz, theta=0, sparse=T)
	       + strata(x2), test3)
tfit3 <- coxph(Surv(zz,time,status) ~x + frailty(zz, theta=0, sparse=T)
	         + strata(x2), test3)

all.equal(tfit1[temp], tfit2[temp])
all.equal(tfit2[temp], tfit3[temp])


test4 <- rbind(test2, test2)
test4$x2 <- rep(1:2, rep(nrow(test2),2))
zz <- rep(0, nrow(test4))
tfit1 <- coxph(Surv(start, stop, event) ~x, test4, eps=1e-7)
tfit2 <- coxph(Surv(start, stop, event) ~ x + frailty(zz, theta=0, sparse=T),
	       test4)
all.equal(tfit1[temp], tfit2[temp])

rm(test3, test4, tfit1, tfit2, tfit3, temp, zz)
