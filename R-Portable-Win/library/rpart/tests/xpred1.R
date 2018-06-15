#
# Test out the "return.all" argument of xpred
#   this is a very small test case for debugging
#
library(rpart)

tdata <- data.frame(y=1:12, x1= 12:1, x2=c(1,1,5,5,4,4,9,9,7,7,3,3))
xgrp <- rep(1:3, length=12)

fit1 <- rpart(y ~ x1 + x2, tdata, minsplit=6)
xfit1 <- xpred.rpart(fit1, xval=xgrp, return.all=T)

xfit2 <- array(0, dim=dim(xfit1))
cplist <- as.numeric(dimnames(xfit1)[[2]])

for (i in 1:3) {
    tfit <- rpart(y ~ x1+x2, tdata, subset=(xgrp !=i), minsplit=6)
    # xvals are actually done on the absolute risk (node's risk /n), not on
    #   the rescaled risk ((node risk)/ (top node risk)) which is the basis
    #   for the printed CP.  To get the right answer we need to rescale.
    cp2 <- cplist * (fit1$frame$dev[1] / fit1$frame$n[1]) / 
                    (tfit$frame$dev[1] / tfit$frame$n[1])

    for (j in 1:length(cp2)) {
        tfit2 <- prune(tfit, cp=cp2[j])
        temp <- predict(tfit2, newdata=tdata[xgrp==i,], type='matrix')
        xfit2[xgrp==i, j] <- temp
        }
    }

all.equal(xfit1, xfit2, check.attributes=FALSE)
