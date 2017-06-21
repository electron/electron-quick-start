library(survival)
#
# A test of nesting.  It makes sure the model.frame is built correctly
#
tfun <- function(fit, mydata) {
    survfit(fit, newdata=mydata)
    }

myfit <- coxph(Surv(time, status) ~ age + factor(sex), lung)

temp1 <- tfun(myfit, lung[1:5,])
temp2 <- survfit(myfit, lung[1:5,])
indx <- match('call', names(temp1))  #the call components won't match

all.equal(unclass(temp1)[-indx], unclass(temp2)[-indx])

