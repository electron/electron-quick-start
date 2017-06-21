library(survival)
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
# One more test on coxph survival curves, to test out the individual
#  option.  First fit a model with a time dependent covariate
#
test2 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0) )

# True hazard function, from the validation document
lambda <- function(beta, x=0, method='efron') {
    r <- exp(beta)
    lambda <- c(1/(r+1), 1/(r+2), 1/(3*r +2), 1/(3*r+1),
                1/(3*r+1), 1/(3*r+2) + 1/(2*r +2))
    if (method == 'breslow') lambda[9] <- 2/(3*r +2)
    list(time=c(2,3,6,7,8,9), lambda=lambda)
    }

fit <- coxph(Surv(start, stop, event) ~x, test2)
# A curve for someone who never changes
surv1 <-survfit(fit, newdata=list(x=0), censor=FALSE)

true <- lambda(fit$coef, 0)

aeq(true$time, surv1$time)
aeq(-log(surv1$surv), cumsum(true$lambda))

# Reprise it with a time dependent subject who doesn't change
data2 <- data.frame(start=c(0, 4, 9, 11), stop=c(4, 9, 11, 17),
                      event=c(0,0,0,0), x=c(0,0,0,0))
surv2 <- survfit(fit, newdata=data2, individual=TRUE, censor=FALSE)
aeq(surv2$surv, surv1$surv)


#
# Now a more complex data set with multiple strata
#
test3 <- data.frame(start=c(1, 2, 5, 2, 1, 7, 3, 4, 8, 8,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                    stop =c(2, 3, 6, 7, 8, 9, 9, 9,14,17,
                            1:11),
                    event=c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
                            0, 1, 1, 0, 0, 1, 1, 0, 1, 0,1),
                    x    =c(1, 0, 0, 1, 0, 1, 1, 1, 0, 0,
                            1, 2, 3, 2, 1, 1, 1, 0, 2, 1,0),
                    grp = c(rep('a', 10), rep('b', 11)))

fit2 <- coxph(Surv(start, stop, event) ~ x + strata(grp), test3)

# The above tests show the program works for a simple case, use it to
#  get a true baseline for strata 2
fit2b <- coxph(Surv(start, stop, event) ~x, test3,
               subset=(grp=='b'), init=fit2$coef, iter=0)
temp <- survfit(fit2b,  newdata=list(x=0), censor=F)
true2 <- list(time=temp$time, lambda=diff(c(0, -log(temp$surv))))
true1 <- lambda(fit2$coef, x=0)

# Separate strata, one value
surv3 <- survfit(fit2, list(x=0), censor=FALSE)
aeq(true1$time, (surv3[1])$time)
aeq(-log(surv3[1]$surv), cumsum(true1$lambda))

data4 <- data.frame(start=c(0, 4, 9, 11), stop=c(4, 9, 11, 17),
                      event=c(0,0,0,0), x=c(0,0,0,0), grp=rep('a', 4))
surv4a <- survfit(fit2, newdata=data4, individual=T, censor=FALSE)
aeq(-log(surv4a$surv), cumsum(true1$lambda))

data4$grp <- rep('b',4)
surv4b <- survfit(fit2, newdata=data4, individual=T, censor=FALSE)
aeq(-log(surv4b$surv), cumsum(true2$lambda))


# Now for something more complex
# Subject 1 skips day 4.  Since there were no events that day the survival
#  will be the same, but the times will be different.
# Subject 2 spends some time in strata 1, some in strata 2, with
#   moving covariates
#
data5 <- data.frame(start=c(0,5,9,11,
                             0, 4, 3),
                    stop =c(4,9,11,17, 4,8,7),
                    event=rep(0,7),
                    x=c(1,1,1,1, 0,1,2),
                    grp=c('a', 'a', 'a', 'a', 'a', 'a', 'b'),
                    subject=c(1,1,1,1, 2,2,2))
surv5 <- survfit(fit2, newdata=data5, censor=FALSE, id=subject)

aeq(surv5[1]$time, c(2,3,5,6,7,8))  #surv1 has 2, 3, 6, 7, 8, 9
aeq(surv5[1]$surv, surv3[1]$surv ^ exp(fit2$coef))

tlam <- c(true1$lambda[1:2]* exp(fit2$coef * data5$x[5]),
          true1$lambda[3:5]* exp(fit2$coef * data5$x[6]),      
          true2$lambda[3:4]* exp(fit2$coef * data5$x[7]))
aeq(-log(surv5[2]$surv), cumsum(tlam))

                          
                          
