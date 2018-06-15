#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

options(width=65, digits=5, height=9999)
pdf(file="ch01.pdf", width=8, height=6, pointsize=9)

# Chapter 1   Introduction

# 1.1 A quick overview of S

2 + 3
sqrt(3/4)/(1/3 - 2/pi^2)

library(MASS)
mean(chem)
m <- mean(chem); v <- var(chem)/length(chem)
m/sqrt(v)

std.dev <- function(x) sqrt(var(x))
t.test.p <- function(x, mu=0) {
    n <- length(x)
    t <- sqrt(n) * (mean(x) - mu) / std.dev(x)
    2 * (1 - pt(abs(t), n - 1))
}

t.stat <- function(x, mu = 0) {
   n <- length(x)
   t <- sqrt(n) * (mean(x) - mu) / std.dev(x)
   list(t = t, p = 2 * (1 - pt(abs(t), n - 1)))
}
z <- rnorm(300, 1, 2)  # generate 300 N(1, 4) variables.
t.stat(z)
unlist(t.stat(z, 1))  # test mu=1, compact result

# 1.4  An introductory session

x <- rnorm(1000)
y <- rnorm(1000)
truehist(c(x,y+3), nbins=25)

# ?truehist

contour(dd <- kde2d(x,y))
image(dd)

x <- seq(1, 20, 0.5)
x
w <- 1 + x/2
y <- x + w*rnorm(x)
dum <-  data.frame(x, y, w)
dum
rm(x, y, w)

fm <- lm(y ~ x,  data=dum)
summary(fm)
fm1 <- lm(y ~ x,  data = dum, weight = 1/w^2)
summary(fm1)

lrf <-  loess(y ~ x, dum)

attach(dum)
plot(x, y)
lines(spline(x, fitted(lrf)), col = 2)

abline(0, 1, lty = 3, col = 3)
abline(fm, col = 4)
abline(fm1, lty = 4, col = 5)

plot(fitted(fm), resid(fm), xlab = "Fitted Values", ylab = "Residuals")

qqnorm(resid(fm))
qqline(resid(fm))

detach()
rm(fm,fm1,lrf,dum)

hills
# S: splom(~ hills)
pairs(hills)

# S: if(interactive()) brush(hills)

attach(hills)
plot(dist, time)
if(interactive()) identify(dist, time, row.names(hills))
abline(lm(time ~ dist))
# library(lqs)
abline(lqs(time ~ dist), lty=3, col=4)
detach()

if(interactive()){
plot(c(0,1), c(0,1), type="n")
xy <- locator(type = "p")
abline(lm(y ~ x, xy), col = 4)
abline(rlm(y ~ x, xy, method = "MM"), lty = 3, col = 3)
abline(lqs(y ~ x, xy), lty = 2, col = 2)
rm(xy)
}

attach(michelson)
search()
plot(Expt, Speed, main="Speed of Light Data", xlab="Experiment No.")
fm <-  aov(Speed ~ Run + Expt)
summary(fm)
fm0 <- update(fm, . ~ . - Run)
anova(fm0, fm)
detach()
rm(fm, fm0)

1 - pf(4.3781, 4, 76)
qf(0.95, 4, 76)

# End of ch01
