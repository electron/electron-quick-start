#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 16   Optimization and Mazimum Likelihood Estimation

library(MASS)
pdf(file="ch16.pdf", width=8, height=8, pointsize=9)
options(width=65, digits=5)

# 16.3 General optimization

attach(geyser)
truehist(waiting, xlim = c(35, 110), ymax = 0.04, h = 5)
wait.dns <- density(waiting, n = 512, width = "SJ")
lines(wait.dns, lty = 2)

lmix2 <- deriv3(
     ~ -log(p*dnorm((x-u1)/s1)/s1 + (1-p)*dnorm((x-u2)/s2)/s2),
     c("p", "u1", "s1", "u2", "s2"),
     function(x, p, u1, s1, u2, s2) NULL)

(p0 <- c(p = mean(waiting < 70), u1 = 50, s1 = 5, u2 = 80, s2 = 5))

## using optim

mix.obj <- function(p, x)
{
  e <- p[1] * dnorm((x - p[2])/p[3])/p[3] +
       (1 - p[1]) * dnorm((x - p[4])/p[5])/p[5]
  if(any(e <= 0)) Inf else -sum(log(e))
}
optim(p0, mix.obj, x = waiting)$par # Nelder-Mead

optim(p0, mix.obj, x = waiting, method = "BFGS",
     control = list(parscale= c(0.1, rep(1, 4))))$par

# with derivatives
lmix2a <- deriv(
     ~ -log(p*dnorm((x-u1)/s1)/s1 + (1-p)*dnorm((x-u2)/s2)/s2),
     c("p", "u1", "s1", "u2", "s2"),
     function(x, p, u1, s1, u2, s2) NULL)
mix.gr <- function(p, x) {
   u1 <- p[2]; s1 <- p[3]; u2 <- p[4]; s2 <- p[5]; p <- p[1]
   colSums(attr(lmix2a(x, p, u1, s1, u2, s2), "gradient")) }

optim(p0, mix.obj, mix.gr, x = waiting, method = "BFGS",
     control = list(parscale= c(0.1, rep(1, 4))))$par

mix.nl0 <- optim(p0, mix.obj, mix.gr, method = "L-BFGS-B", hessian = TRUE,
                lower = c(0, -Inf, 0, -Inf, 0),
                upper = c(1, rep(Inf, 4)), x = waiting)
rbind(est = mix.nl0$par, se = sqrt(diag(solve(mix.nl0$hessian))))

dmix2 <- function(x, p, u1, s1, u2, s2)
             p * dnorm(x, u1, s1) + (1-p) * dnorm(x, u2, s2)
attach(as.list(mix.nl0$par))
wait.fdns <- list(x = wait.dns$x,
                  y = dmix2(wait.dns$x, p, u1, s1, u2, s2))
lines(wait.fdns)
par(usr = c(0, 1, 0, 1))
legend(0.1, 0.9, c("Normal mixture", "Nonparametric"),
       lty = c(1, 2), bty = "n")

pmix2 <- deriv(~ p*pnorm((x-u1)/s1) + (1-p)*pnorm((x-u2)/s2),
               "x", function(x, p, u1, s1, u2, s2) {})
pr0 <- (seq(along = waiting) - 0.5)/length(waiting)
x0 <- x1 <- as.vector(sort(waiting)) ; del <- 1; i <- 0
while((i <- 1 + 1) < 10 && abs(del) > 0.0005) {
  pr <- pmix2(x0, p, u1, s1, u2, s2)
  del <- (pr - pr0)/attr(pr, "gradient")
  x0 <- x0 - 0.5*del
  cat(format(del <- max(abs(del))), "\n")
}
detach()
par(pty = "s")
plot(x0, x1, xlim = range(x0, x1), ylim = range(x0, x1),
     xlab = "Model quantiles", ylab = "Waiting time")
abline(0, 1)
par(pty = "m")



mix1.obj <- function(p, x, y)
{
  q <- exp(p[1] + p[2]*y)
  q <- q/(1 + q)
  e <- q * dnorm((x - p[3])/p[4])/p[4] +
       (1 - q) * dnorm((x - p[5])/p[6])/p[6]
  if(any(e <= 0)) Inf else -sum(log(e))
}
p1 <- mix.nl0$par; tmp <- as.vector(p1[1])
p2 <- c(a = log(tmp/(1-tmp)), b = 0, p1[-1])
mix.nl1 <- optim(p2, mix1.obj, method = "L-BFGS-B",
                lower = c(-Inf, -Inf, -Inf, 0, -Inf, 0),
                upper = rep(Inf, 6), hessian = TRUE,
                x = waiting[-1], y = duration[-299])
rbind(est = mix.nl1$par, se = sqrt(diag(solve(mix.nl1$hessian))))


if(!exists("bwt")) {
  attach(birthwt)
  race <- factor(race, labels=c("white", "black", "other"))
  ptd <- factor(ptl > 0)
  ftv <- factor(ftv); levels(ftv)[-(1:2)] <- "2+"
  bwt <- data.frame(low=factor(low), age, lwt, race,
	   smoke=(smoke>0), ptd, ht=(ht>0), ui=(ui>0), ftv)
  detach(); rm(race, ptd, ftv)
}

logitreg <- function(x, y, wt = rep(1, length(y)),
               intercept = TRUE, start = rep(0, p), ...)
{
  fmin <- function(beta, X, y, w) {
      p <- plogis(X %*% beta)
      -sum(2 * w * ifelse(y, log(p), log(1-p)))
  }
  gmin <- function(beta, X, y, w) {
      eta <- X %*% beta; p <- plogis(eta)
      -2 * matrix(w *dlogis(eta) * ifelse(y, 1/p, -1/(1-p)), 1) %*% X
  }
  if(is.null(dim(x))) dim(x) <- c(length(x), 1)
  dn <- dimnames(x)[[2]]
  if(!length(dn)) dn <- paste("Var", 1:ncol(x), sep="")
  p <- ncol(x) + intercept
  if(intercept) {x <- cbind(1, x); dn <- c("(Intercept)", dn)}
  if(is.factor(y)) y <- (unclass(y) != 1)
  fit <- optim(start, fmin, gmin, X = x, y = y, w = wt,
               method = "BFGS", ...)
  names(fit$par) <- dn
  cat("\nCoefficients:\n"); print(fit$par)
  # R: use fit$value and fit$convergence
  cat("\nResidual Deviance:", format(fit$value), "\n")
  if(fit$convergence > 0)
      cat("\nConvergence code:", fit$convergence, "\n")
  invisible(fit)
}

options(contrasts = c("contr.treatment", "contr.poly"))
X <- model.matrix(terms(low ~ ., data=bwt), data = bwt)[, -1]
logitreg(X, bwt$low)

AIDSfit <- function(y, z, start=rep(mean(y), ncol(z)), ...)
{
  deviance <- function(beta, y, z) {
      mu <- z %*% beta
      2 * sum(mu - y - y*log(mu/y)) }
  grad <- function(beta, y, z) {
      mu <- z %*% beta
      2 * t(1 - y/mu) %*% z }
  optim(start, deviance, grad, lower = 0, y = y, z = z,
        method = "L-BFGS-B", ...)
}

Y <- scan()
12 14 33 50 67 74 123 141 165 204 253 246 240

library(nnet) # for class.ind
s <- seq(0, 13.999, 0.01); tint <- 1:14
X <- expand.grid(s, tint)
Z <- matrix(pweibull(pmax(X[,2] - X[,1],0), 2.5, 10),length(s))
Z <- Z[,2:14] - Z[,1:13]
Z <- t(Z) %*% class.ind(factor(floor(s/2))) * 0.01
round(AIDSfit(Y, Z)$par)
rm(s, X, Y, Z)

# End of ch16

