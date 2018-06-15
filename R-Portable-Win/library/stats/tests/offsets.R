## tests of offsets, and prediction from them.

load("anorexia.rda") # copied from package MASS

## via formula
fit1 <- lm(Postwt ~ Prewt + Treat + offset(Prewt), data = anorexia)
summary(fit1)
pred <- fitted(fit1)
stopifnot(all.equal(predict(fit1, anorexia), pred))

## via argument
fit2 <- lm(Postwt ~ Prewt + Treat, data = anorexia, offset=Prewt)
summary(fit2)
stopifnot(all.equal(predict(fit2, anorexia), pred))

## now spili into two parts
anorexia$o1 <- 0.9*anorexia$Prewt
anorexia$o2 <- 0.1*anorexia$Prewt
fit3 <- lm(Postwt ~ Prewt + Treat + offset(o1) + offset(o2), data = anorexia)
summary(fit3)
stopifnot(all.equal(predict(fit3, anorexia), pred))

fit4 <- lm(Postwt ~ Prewt + Treat + offset(o1), data = anorexia, offset = o2)
summary(fit4)
stopifnot(all.equal(predict(fit4, anorexia), pred))

## using more than one offset failed in R 2.8.1
