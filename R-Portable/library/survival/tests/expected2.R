library(survival)
#
# A Cox model with a factor, followed by survexp.  
#
pfit2 <- coxph(Surv(time, status > 0) ~ trt + log(bili) +
          log(protime) + age + platelet + sex, data = pbc)
esurv <- survexp(~ trt, ratetable = pfit2, data = pbc)

temp <- pbc
temp$sex2 <- factor(as.numeric(pbc$sex), levels=2:0,
                    labels=c("f", "m", "unknown"))
esurv2 <- survexp(~ trt, ratetable = pfit2, data = temp, 
                  rmap=list(sex=sex2))

# The call components won't match, which happen to be first
all.equal(unclass(esurv)[-1], unclass(esurv2)[-1])
