library(MASS)

## Based on incorrect 'bug' report

hills$ispeed <- hills$time/hills$dist
hills$grad <- hills$climb/hills$dist

## weighted fit
fit0 <- rlm(time ~ dist + climb - 1, data = hills,
            weights = 1/dist^2, method="MM")
summary(fit0, cor=FALSE)
## equivalent to
fit1 <- rlm(ispeed ~ grad, data = hills, method="MM")
summary(fit1, cor=FALSE)

cf0 <- coef(summary(fit0))
cf1 <- coef(summary(fit1))
rownames(cf1) <- rownames(cf0)
stopifnot(all.equal(cf0, cf1))
stopifnot(all.equal(weighted.residuals(fit0), residuals(fit1)))

# test other cases
fit0 <- rlm(time ~ dist + climb - 1, data = hills, weights = 1/dist^2)
summary(fit0, cor=FALSE)
## equivalent to
fit1 <- rlm(ispeed ~ grad, data = hills)
summary(fit1, cor=FALSE)

cf0 <- coef(summary(fit0))
cf1 <- coef(summary(fit1))
rownames(cf1) <- rownames(cf0)
stopifnot(all.equal(cf0, cf1))
stopifnot(all.equal(weighted.residuals(fit0), residuals(fit1)))

fit0 <- rlm(time ~ dist + climb - 1, data = hills, weights = 1/dist^2,
            scale.est = "Huber")
summary(fit0, cor=FALSE)
## equivalent to
fit1 <- rlm(ispeed ~ grad, data = hills, scale.est = "Huber")
summary(fit1, cor=FALSE)

cf0 <- coef(summary(fit0))
cf1 <- coef(summary(fit1))
rownames(cf1) <- rownames(cf0)
stopifnot(all.equal(cf0, cf1))
stopifnot(all.equal(weighted.residuals(fit0), residuals(fit1)))


## cf lm fits

fit2 <- lm(time ~ dist + climb - 1, data = hills, weights = 1/dist^2)
fit3 <- lm(ispeed ~ grad, data = hills)
stopifnot(all.equal(weighted.residuals(fit2), residuals(fit3)))


## case weights: can't do MM as no weighted lqs.
wts <- rep(1, 35)
wts[c(1,11,21)] <- 10
h2 <- hills[rep(1:35, times=wts), ]
fit4 <- lm(ispeed ~ grad, data = hills, weights = wts)
fit5 <- lm(ispeed ~ grad, data = h2)
## same coefs, different se's.
fit6 <- rlm(ispeed ~ grad, data = h2, acc=1e-10)
fit7 <- rlm(ispeed ~ grad, data = hills,
            weights = wts, wt.method="case", acc=1e-10)
summary(fit6)
summary(fit7)
stopifnot(all.equal(coef(summary(fit6)), coef(summary(fit7))))
summary(fit6, "XtWX")
summary(fit7, "XtWX")
stopifnot(all.equal(coef(summary(fit6, "XtWX")), coef(summary(fit7, "XtWX"))))

fit8 <- rlm(ispeed ~ grad, data = h2, scale.est = "Huber", acc=1e-10)
fit9 <- rlm(ispeed ~ grad, data = hills, scale.est = "Huber",
            weights = wts, wt.method="case", acc=1e-10)
summary(fit8)
summary(fit9)
stopifnot(all.equal(coef(summary(fit8)), coef(summary(fit9))))
summary(fit8, "XtWX")
summary(fit9, "XtWX")
stopifnot(all.equal(coef(summary(fit8, "XtWX")), coef(summary(fit9, "XtWX"))))


## w was a matrix under some initializations
x <- matrix(1:200, 100,2)
B <- c(2.5, -1.3)
y <- x %*% B + rnorm(100)
r1 <- rlm(x, y, init=B, psi=psi.huber)
r2 <- rlm(x, y, init=B, psi=psi.bisquare)
r3 <- rlm(x, y, init=B, psi=psi.hampel)   # failed
r4 <- rlm(x, y, psi=psi.hampel)

## lqs with intercept lost contrasts
dat <- data.frame(trt = factor(rep(LETTERS[1:2], each=3)),resp = rt(6, df=3))
fit <- lqs(resp ~ trt, data = dat, contrasts = list(trt = "contr.sum"))
stopifnot(identical(predict(fit), predict(fit, newdata = dat)))

