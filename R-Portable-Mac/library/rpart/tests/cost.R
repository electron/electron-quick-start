library(rpart)
require(survival)
aeq <- function(x,y, ...) all.equal(as.vector(x), as.vector(y), ...)

#
# Check out using costs
#
fit1 <- rpart(Surv(time, status) ~ age + sex + ph.ecog + ph.karno + pat.karno
	      + meal.cal + wt.loss, data=lung,
	      maxdepth=1, maxcompete=6, xval=0)

fit2 <- rpart(Surv(time, status) ~ age + sex + ph.ecog + ph.karno + pat.karno
	      + meal.cal + wt.loss, data=lung,
	      maxdepth=1, maxcompete=6, xval=0, cost=(1+ 1:7/10))

temp1 <- fit1$splits[1:7,]
temp2 <- fit2$splits[1:7,]
temp3 <- c('age', 'sex', 'ph.ecog', 'ph.karno', 'pat.karno', 'meal.cal',
	   'wt.loss')
indx1 <- match(temp3, dimnames(temp1)[[1]])
indx2 <- match(temp3, dimnames(temp2)[[1]])
aeq(temp1[indx1,1], temp2[indx2,1])             #same n's ?
aeq(temp1[indx1,3], temp2[indx2,3]*(1+ 1:7/10)) #scaled importance


