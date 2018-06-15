#
library(survival)

# Some simple tests of the Surv function
#  The first two are motivated by a bug, pointed out by Kevin Buhr,
#    where a mixture of NAs and invalid values didn't work right
#  Even for the simplest things a test case is good.
#  All but the third should produce warning messages
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
temp <- Surv(c(1, 10, 20, 30), c(2, NA, 0, 40), c(1,1,1,1))
aeq(temp, c(1,10,NA,30,  2,NA,0,40, 1,1,1,1))

temp <- Surv(c(1, 10, 20, 30), c(2, NA, 0, 40), type='interval2')
aeq(temp, c(1,10,20,30,  2,1,1,40, 3,0,NA,3))

#No error
temp <- Surv(1:5)
aeq(temp, c(1:5, 1,1,1,1,1))

temp1 <- Surv(c(1,10,NA, 30, 30), c(1,NA,10,20, 40), type='interval2')
temp2 <- Surv(c(1,10,10,30,30), c(9, NA, 5, 20,40), c(1, 0, 2,3,3),
              type='interval')
aeq(temp1, temp2)
aeq(temp1, c(1,10,10,30,30, 1,1,1,1, 40, 1,0,2,NA,3))

# Use of inf
temp1 <- Surv(c(1,10,NA, 30, 30), c(1,NA,10,30, 40), type='interval2')
temp2 <- Surv(c(1,10,-Inf, 30, 30), c(1,Inf,10,30, 40), type='interval2')
aeq(temp1, temp2)
