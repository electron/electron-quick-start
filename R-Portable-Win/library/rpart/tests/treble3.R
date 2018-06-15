#
# The treble test for classification trees
#  
#
library(rpart)
xgrp <- rep(1:10,length=nrow(cu.summary))
carfit <- rpart(Country ~ Reliability + Price + Mileage + Type,
		 method='class', data=cu.summary, 
		 control=rpart.control(xval=xgrp))

carfit2 <- rpart(Country ~ Reliability + Price + Mileage + Type,
		 method='class', data=cu.summary, 
		 weight=rep(3,nrow(cu.summary)),
		 control=rpart.control(xval=xgrp))

all.equal(carfit$frame$wt,    carfit2$frame$wt/3)
all.equal(carfit$frame$dev,   carfit2$frame$dev/3)
all.equal(carfit$frame[,5:7], carfit2$frame[,5:7])
all.equal(carfit$frame$yval2[,12:21], carfit2$frame$yval2[,12:21])
all.equal(carfit[c('where', 'csplit')],
	  carfit2[c('where', 'csplit')])
xx <- carfit2$splits
xx[,'improve'] <- xx[,'improve'] / ifelse(xx[,5]> 0,1,3) # surrogate?
all.equal(xx, carfit$splits)
all.equal(as.vector(carfit$cptable), 
	  as.vector(carfit2$cptable%*% diag(c(1,1,1,1,sqrt(3)))))

summary(carfit2)

