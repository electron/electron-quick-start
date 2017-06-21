options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Trivial test of stratified residuals
#   Make a second strata = replicate of the first, and I should get the
#   exact same answers
test1 <- data.frame(time=  c(9, 3,1,1,6,6,8),
                    status=c(1,NA,1,0,1,1,0),
                    x=     c(0, 2,1,1,1,0,0))
test2 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0) )

temp <- as.matrix(test1)
n    <- nrow(temp)
ndead<- sum(test1$status[!is.na(test1$status)])
temp <- data.frame(rbind(temp, temp)) #later releases of S have rbind.data.frame
tstrat <- rep(1:2, c(n,n))

fit1 <- coxph(Surv(time, status) ~x, test1)
fit2 <- coxph(Surv(time, status) ~x + strata(tstrat), temp)

all.equal(resid(fit1) , (resid(fit2))[1:n])
all.equal(resid(fit1, type='score') , (resid(fit2, type='score'))[1:n])
all.equal(resid(fit1, type='schoe') , (resid(fit2, type='schoe'))[1:ndead])


#AG model
temp <- as.matrix(test2)
n    <- nrow(temp)
ndead<- sum(test2$event[!is.na(test2$event)])
temp <- data.frame(rbind(temp, temp))
tstrat <- rep(1:2, c(n,n))

fit1 <- coxph(Surv(start, stop, event) ~x, test2)
fit2 <- coxph(Surv(start, stop, event) ~x + strata(tstrat), temp)

all.equal(resid(fit1) , (resid(fit2))[1:n])
all.equal(resid(fit1, type='score') , (resid(fit2, type='score'))[1:n])
all.equal(resid(fit1, type='schoe') , (resid(fit2, type='schoe'))[1:ndead])
