#
# Treble test for class trees with 2 outcomes
#
# fit1 and fit1b failed equality because .7 and .3 are not easily represented
# in binary.  Thus a complelxity param was 4e-17 (basically 0, but enough
# to cause a split where it shouldn't be). Eric Lunde 2005-08-03
library(rpart)
control <- rpart.control(maxsurrogate=0, cp=1e-15, xval=0)

fit1 <- rpart(Kyphosis ~ Age + Number + Start, data=kyphosis, 
              control=control,
              parms=list(prior=c(.7,.3), 
                loss=matrix(c(0,1,2,0),nrow=2,ncol=2)))
wts <- rep(3, nrow(kyphosis))
fit1b <- rpart(Kyphosis ~ Age + Number + Start, data=kyphosis, 
               control=control,
	       weights=wts,
               parms=list(prior=c(.7,.3), 
                 loss=matrix(c(0,1,2,0),nrow=2,ncol=2)))
fit1b$frame$wt   <- fit1b$frame$wt/3
fit1b$frame$dev  <- fit1b$frame$dev/3
fit1b$frame$yval2[,2:3] <- fit1b$frame$yval2[,2:3]/3
fit1b$splits[,3] <- fit1b$splits[,3]/3
fit1b$variable.importance <- fit1b$variable.importance/3
all.equal(fit1[-3], fit1b[-3])   #all but the "call"

# Now for a set of non-equal weights
nn <- nrow(kyphosis)
pseudo <- double(nn)
pseudo[1] <- pi/6
for (i in 2:nn) pseudo[i] <- 4*pseudo[i-1]*(1-pseudo[i-1])

wts <-  rep(1:7, length=nn)
temp <- rep(1:nn, wts)             #row replicates
xgrp <- rep(1:10, length=nn)[order(pseudo)]
xgrp2<- rep(xgrp, wts)

# The cp value stops one last split where the two predictors are
#  completely equal in importance (perfect surrogates), but the
#  weighted and unweighted pick a different one due to round off error
tempc <- rpart.control(minsplit=2, xval=xgrp2, maxsurrogate=0, cp=.039)
#  Direct: replicate rows in the data set, and use unweighted
fit2 <- rpart(Kyphosis ~ Age + Number + Start, data=kyphosis[temp,], 
               control=tempc, 
               parms=list(prior=c(.7,.3), 
                          loss=matrix(c(0,1,2,0),nrow=2,ncol=2)))
#  Weighted
tempc <- rpart.control(minsplit=2, xval=xgrp, maxsurrogate=0, cp=.039)
fit2b <- rpart(Kyphosis ~ Age + Number + Start, data=kyphosis, 
               control=tempc, weights=wts,
               parms=list(prior=c(.7,.3), 
                          loss=matrix(c(0,1,2,0),nrow=2,ncol=2)))

all.equal(fit2$frame[,-2],  fit2b$frame[,-2])  # the "n" component won't match
all.equal(fit2$cptable, fit2b$cptable)
all.equal(fit2$splits[,-1],fit2b$splits[,-1]) 
all.equal(fit2$csplit,    fit2b$csplit)
