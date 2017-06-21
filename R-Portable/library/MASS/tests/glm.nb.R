## glm.nb with weights
library(MASS)
yeast <- data.frame(cbind(numbers = 0:5, fr = c(213, 128, 37, 18, 3, 1)))

attach(yeast)
n <- rep(numbers, fr)

## fitting using glm.nb with weights - wrong results in 7.2-18
yeast2.fit <- glm.nb(numbers~1, link = log, weights=fr)
summary(yeast2.fit)

## fitting extending the vector and using glm.nb - correct result ##
yeast3.fit<-glm.nb(n~1, link = log)
summary(yeast3.fit)

stopifnot(all.equal(deviance(yeast2.fit), deviance(yeast3.fit)))
stopifnot(all.equal(yeast2.fit$theta, yeast3.fit$theta))

detach(yeast)

# another one, corrected in 7.2-43
set.seed(13245)
x <- c(-5:5)
mu <- exp(1 + 0.1*x)
y <- rnegbin(length(mu), mu = mu, theta = 1.5)
dat <- data.frame(x, y)
dat2 <- dat[rep(1:11, each=2), ]
w <- round(runif(11),2)
dat2$w <- as.vector(rbind(w, 1-w))
fm2 <- glm.nb(y ~ x, dat)
gm2 <- glm.nb(y ~ x, dat2, weights = w)
summary(fm2)
summary(gm2) # failed before
stopifnot(all.equal(fm2$theta, gm2$theta)) # differed
stopifnot(all.equal(deviance(fm2), deviance(gm2)))
fm3 <- glm(y ~ x, negative.binomial(theta = fm2$theta), dat)
gm3 <- glm(y ~ x, negative.binomial(theta = fm2$theta), dat2, weights =w)
summary(fm3)
summary(gm3)
stopifnot(all.equal(deviance(fm3), deviance(gm3)))

fit <- glm.nb(Days ~ Sex/(Age + Eth*Lrn), data = quine)
set.seed(1)
simulate(fit, nsim=5)[1:10, ]
if(getRversion() >= "2.9.0") {
    fit2 <- glm.convert(fit)
    set.seed(1)
    print(simulate(fit2, nsim=5)[1:10, ])
}
