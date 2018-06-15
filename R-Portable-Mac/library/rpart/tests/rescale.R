#
# Test out the rescaling done for Surv objects
#
library(rpart)
require(survival)

aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)
tdata <- data.frame(time=c(1,4,3,2,5,7,8,9,4), status=c(0,1,1,0,0,1,1,0,1),
		    x=1:9)
fit2 <- rpart.exp(Surv(tdata$time, tdata$status), NULL, wt=rep(1,9))

#
# Here is what it should be, in order
#    for the intervals (0,3], (3,4], (4,7], (7,9]
deaths <- c( 1, 2,  1, 1)
pyears <- c(24, 6, 10, 3)
rate   <- deaths/pyears
cumhaz <- cumsum(c(0, rate*c(3,1,3,2)))

aeq(fit2$y[,2], tdata$status)
aeq(fit2$y[,1], approx(c(0,3,4,7,9), cumhaz, tdata$time)$y)



 

