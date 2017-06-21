#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 8   Non-linear and Smooth Regression

library(MASS)
library(lattice)
options(width=65, digits=5, height=9999)
pdf(file="ch08.pdf", width=8, height=6, pointsize=9)


# From Chapter 6, for comparisons
set.seed(123)
cpus.samp <-
c(3, 5, 6, 7, 8, 10, 11, 16, 20, 21, 22, 23, 24, 25, 29, 33, 39, 41, 44, 45,
46, 49, 57, 58, 62, 63, 65, 66, 68, 69, 73, 74, 75, 76, 78, 83, 86,
88, 98, 99, 100, 103, 107, 110, 112, 113, 115, 118, 119, 120, 122,
124, 125, 126, 127, 132, 136, 141, 144, 146, 147, 148, 149, 150, 151,
152, 154, 156, 157, 158, 159, 160, 161, 163, 166, 167, 169, 170, 173,
174, 175, 176, 177, 183, 184, 187, 188, 189, 194, 195, 196, 197, 198,
199, 202, 204, 205, 206, 208, 209)

cpus1 <- cpus
attach(cpus)
for(v in names(cpus)[2:7])
  cpus1[[v]] <- cut(cpus[[v]], unique(quantile(cpus[[v]])),
                    include.lowest = TRUE)
detach()
cpus.lm <- lm(log10(perf) ~ ., data=cpus1[cpus.samp, 2:8])
cpus.lm2 <- stepAIC(cpus.lm, trace=FALSE)
res2 <- log10(cpus1[-cpus.samp, "perf"]) -
              predict(cpus.lm2, cpus1[-cpus.samp,])
cpus2 <- cpus[, 2:8]  # excludes names, authors' predictions
cpus2[, 1:3] <- log10(cpus2[, 1:3])

test.cpus <- function(fit)
  sqrt(sum((log10(cpus2[-cpus.samp, "perf"]) -
            predict(fit, cpus2[-cpus.samp,]))^2)/109)

# 8.1 An introductory example

attach(wtloss)
# alter margin 4; others are default
oldpar <- par(mar = c(5.1, 4.1, 4.1, 4.1))
plot(Days, Weight, type = "p", ylab = "Weight (kg)")
Wt.lbs <- pretty(range(Weight*2.205))
axis(side = 4, at = Wt.lbs/2.205, lab = Wt.lbs, srt = 90)
mtext("Weight (lb)", side = 4, line = 3)
par(oldpar) # restore settings
detach()


# 8.2  Fitting non-linear regression models

wtloss.st <- c(b0 = 90, b1 = 95, th = 120)
wtloss.fm <- nls(Weight ~ b0 + b1*2^(-Days/th),
   data = wtloss, start = wtloss.st, trace = TRUE)
wtloss.fm

expn <- function(b0, b1, th, x) {
   temp <- 2^(-x/th)
   model.func <- b0 + b1 * temp
   Z <- cbind(1, temp, (b1 * x * temp * log(2))/th^2)
   dimnames(Z) <- list(NULL, c("b0", "b1", "th"))
   attr(model.func, "gradient") <- Z
   model.func
}

wtloss.gr <- nls(Weight ~ expn(b0, b1, th, Days),
   data = wtloss, start = wtloss.st, trace = TRUE)

expn1 <- deriv(y ~ b0 + b1 * 2^(-x/th), c("b0", "b1", "th"),
               function(b0, b1, th, x) {})


negexp <- selfStart(model = ~ b0 + b1*exp(-x/th),
   initial = negexp.SSival, parameters = c("b0", "b1", "th"),
   template = function(x, b0, b1, th) {})

wtloss.ss <- nls(Weight ~ negexp(Days, B0, B1, theta),
                 data = wtloss, trace = TRUE)


# 8.3  Non-linear fitted model objects and method functions

summary(wtloss.gr)
deviance(wtloss.gr)
vcov(wtloss.gr)

A <- model.matrix(~ Strip - 1, data = muscle)
rats.nls1 <- nls(log(Length) ~ cbind(A, rho^Conc),
   data = muscle, start = c(rho = 0.1), algorithm = "plinear")
(B <- coef(rats.nls1))

st <- list(alpha = B[2:22], beta = B[23], rho = B[1])
rats.nls2 <- nls(log(Length) ~ alpha[Strip] + beta*rho^Conc,
                  data = muscle, start = st)

attach(muscle)
Muscle <- expand.grid(Conc = sort(unique(Conc)),
                     Strip = levels(Strip))
Muscle$Yhat <- predict(rats.nls2, Muscle)
Muscle$logLength <- rep(NA, nrow(Muscle))
ind <- match(paste(Strip, Conc),
            paste(Muscle$Strip, Muscle$Conc))
Muscle$logLength[ind] <- log(Length)
detach()

xyplot(Yhat ~ Conc | Strip, Muscle, as.table = TRUE,
  ylim = range(c(Muscle$Yhat, Muscle$logLength), na.rm = TRUE),
  subscripts = TRUE, xlab = "Calcium Chloride concentration (mM)",
  ylab = "log(Length in mm)", panel =
  function(x, y, subscripts, ...) {
     panel.xyplot(x, Muscle$logLength[subscripts], ...)
     llines(spline(x, y))
  })


# 8.5  Confidence intervals for parameters

expn2 <- deriv(~b0 + b1*((w0 - b0)/b1)^(x/d0),
        c("b0","b1","d0"), function(b0, b1, d0, x, w0) {})

wtloss.init <- function(obj, w0) {
  p <- coef(obj)
  d0 <-  - log((w0 - p["b0"])/p["b1"])/log(2) * p["th"]
  c(p[c("b0", "b1")], d0 = as.vector(d0))
}

out <- NULL
w0s <- c(110, 100, 90)
for(w0 in w0s) {
    fm <- nls(Weight ~ expn2(b0, b1, d0, Days, w0),
              wtloss, start = wtloss.init(wtloss.gr, w0))
    out <- rbind(out, c(coef(fm)["d0"], confint(fm, "d0")))
}
dimnames(out)[[1]] <- paste(w0s,"kg:")
out

fm0 <- lm(Wt*Time ~ Viscosity + Time - 1,  data = stormer)
b0 <- coef(fm0)
names(b0) <- c("b1", "b2")
b0
storm.fm <- nls(Time ~ b1*Viscosity/(Wt-b2), data = stormer,
                start = b0, trace = TRUE)

bc <- coef(storm.fm)
se <- sqrt(diag(vcov(storm.fm)))
dv <- deviance(storm.fm)

par(pty = "s")
b1 <- bc[1] + seq(-3*se[1], 3*se[1], length = 51)
b2 <- bc[2] + seq(-3*se[2], 3*se[2], length = 51)
bv <- expand.grid(b1, b2)

attach(stormer)
ssq <- function(b)
      sum((Time - b[1] * Viscosity/(Wt-b[2]))^2)
dbetas <- apply(bv, 1, ssq)

cc <- matrix(Time - rep(bv[,1],rep(23, 2601)) *
      Viscosity/(Wt - rep(bv[,2], rep(23, 2601))), 23)
dbetas <- matrix(drop(rep(1, 23) %*% cc^2), 51)

fstat <- matrix( ((dbetas - dv)/2) / (dv/21), 51, 51)

qf(0.95, 2, 21)

plot(b1, b2, type = "n")
lev <- c(1, 2, 5, 7, 10, 15, 20)
contour(b1, b2, fstat, levels = lev, labex = 0.75, lty = 2, add = TRUE)
contour(b1, b2, fstat, levels = qf(0.95,2,21), add = TRUE, labex = 0)
text(31.6, 0.3, labels = "95% CR", adj = 0, cex = 0.75)
points(bc[1], bc[2], pch = 3, mkh = 0.1)
detach()
par(pty = "m")

library(boot)
storm.fm <- nls(Time ~ b*Viscosity/(Wt - c), stormer,
                start = c(b=29.401, c=2.2183))
summary(storm.fm)$parameters
st <- cbind(stormer, fit=fitted(storm.fm))
storm.bf <- function(rs, i) {
#    st <- st # for S-PLUS
    st$Time <-  st$fit + rs[i]
    coef(nls(Time ~ b * Viscosity/(Wt - c), st,
             start = coef(storm.fm)))
}
rs <- scale(resid(storm.fm), scale = FALSE) # remove the mean
(storm.boot <- boot(rs, storm.bf, R = 9999)) ## slow
boot.ci(storm.boot, index = 1,
        type = c("norm", "basic", "perc", "bca"))
boot.ci(storm.boot, index = 2,
        type = c("norm", "basic", "perc", "bca"))


# 8.5  Assessing the linear approximation

opar <- par(pty = "m", mfrow = c(1, 3))
plot(profile(update(wtloss.gr, trace = FALSE)))
par(opar)


# 8.7  One-dimensional curve fitting

attach(GAGurine)
par(mfrow = c(3, 2))
plot(Age, GAG, main = "Degree 6 polynomial")
GAG.lm <- lm(GAG ~ Age + I(Age^2) + I(Age^3) + I(Age^4) +
   I(Age^5) + I(Age^6) + I(Age^7) + I(Age^8))
anova(GAG.lm)
GAG.lm2 <- lm(GAG ~ Age + I(Age^2) + I(Age^3) + I(Age^4) +
   I(Age^5) + I(Age^6))
xx <- seq(0, 17, len = 200)
lines(xx, predict(GAG.lm2, data.frame(Age = xx)))

library(splines)
plot(Age, GAG, type = "n", main = "Splines")
lines(Age, fitted(lm(GAG ~ ns(Age, df = 5))))
lines(Age, fitted(lm(GAG ~ ns(Age, df = 10))), lty = 3)
lines(Age, fitted(lm(GAG ~ ns(Age, df = 20))), lty = 4)
lines(smooth.spline(Age, GAG), lwd = 3)
legend(12, 50, c("df=5", "df=10", "df=20", "Smoothing"),
       lty = c(1, 3, 4, 1), lwd = c(1,1,1,3), bty = "n")
plot(Age, GAG, type = "n", main = "loess")
lines(loess.smooth(Age, GAG))
plot(Age, GAG, type = "n", main = "supsmu")
lines(supsmu(Age, GAG))
lines(supsmu(Age, GAG, bass = 3), lty = 3)
lines(supsmu(Age, GAG, bass = 10), lty = 4)
legend(12, 50, c("default", "base = 3", "base = 10"),
       lty = c(1, 3, 4), bty = "n")
plot(Age, GAG, type = "n", main = "ksmooth")
lines(ksmooth(Age, GAG, "normal", bandwidth = 1))
lines(ksmooth(Age, GAG, "normal", bandwidth = 5), lty = 3)
legend(12, 50, c("width = 1", "width = 5"), lty = c(1, 3), bty = "n")

library(KernSmooth)
plot(Age, GAG, type = "n", main = "locpoly")
(h <- dpill(Age, GAG))
lines(locpoly(Age, GAG, degree = 0, bandwidth = h))

lines(locpoly(Age, GAG, degree = 1, bandwidth = h), lty = 3)
lines(locpoly(Age, GAG, degree = 2, bandwidth = h), lty = 4)
legend(12, 50, c("const", "linear", "quadratic"),
       lty = c(1, 3, 4), bty = "n")
detach()


# 8.8  Additive models

## R has a different gam() in package mgcv
library(mgcv)
rock.lm <- lm(log(perm) ~ area + peri + shape, data = rock)
summary(rock.lm)
(rock.gam <- gam(log(perm) ~ s(area) + s(peri) + s(shape), data=rock))
#summary(rock.gam)
#anova(rock.lm, rock.gam)
par(mfrow = c(2, 3), pty = "s")
plot(rock.gam, se = TRUE, pages = 0)
rock.gam1 <- gam(log(perm) ~ area + peri + s(shape), data = rock)
plot(rock.gam1, se = TRUE)
par(pty="m")
#anova(rock.lm, rock.gam1, rock.gam)

library(mda)
rock.bruto <- bruto(rock[, -4], rock[, 4])
rock.bruto$type
rock.bruto$df


Xin <- as.matrix(cpus2[cpus.samp, 1:6])
test2 <- function(fit) {
 Xp <- as.matrix(cpus2[-cpus.samp, 1:6])
 sqrt(sum((log10(cpus2[-cpus.samp, "perf"]) -
           predict(fit, Xp))^2)/109)
}

cpus.bruto <- bruto(Xin, log10(cpus2[cpus.samp, 7]))
test2(cpus.bruto)
cpus.bruto$type
cpus.bruto$df
# examine the fitted functions
par(mfrow = c(3, 2))
Xp <- matrix(sapply(cpus2[cpus.samp, 1:6], mean), 100, 6, byrow = TRUE)
for(i in 1:6) {
 xr <- sapply(cpus2, range)
 Xp1 <- Xp; Xp1[, i] <- seq(xr[1, i], xr[2, i], len = 100)
 Xf <- predict(cpus.bruto, Xp1)
 plot(Xp1[ ,i], Xf, xlab=names(cpus2)[i], ylab=  "", type = "l")
}

cpus.mars <- mars(Xin, log10(cpus2[cpus.samp,7]))
showcuts <- function(obj)
{
 tmp <- obj$cuts[obj$sel, ]
 dimnames(tmp) <- list(NULL, dimnames(Xin)[[2]])
 tmp
}
showcuts(cpus.mars)
test2(cpus.mars)
# examine the fitted functions
Xp <- matrix(sapply(cpus2[cpus.samp, 1:6], mean), 100, 6, byrow = TRUE)
for(i in 1:6) {
 xr <- sapply(cpus2, range)
 Xp1 <- Xp; Xp1[, i] <- seq(xr[1, i], xr[2, i], len = 100)
 Xf <- predict(cpus.mars, Xp1)
 plot(Xp1[ ,i], Xf, xlab = names(cpus2)[i], ylab = "", type = "l")
}

cpus.mars2 <- mars(Xin, log10(cpus2[cpus.samp,7]), degree = 2)
showcuts(cpus.mars2)
test2(cpus.mars2)

cpus.mars6 <- mars(Xin, log10(cpus2[cpus.samp,7]), degree = 6)
showcuts(cpus.mars6)
test2(cpus.mars6)

if(require(acepack)) {
    attach(cpus2)
    cpus.avas <- avas(cpus2[, 1:6], perf)
    plot(log10(perf), cpus.avas$ty)
    par(mfrow = c(2, 3))
    for(i in 1:6) {
        o <- order(cpus2[, i])
        plot(cpus2[o, i], cpus.avas$tx[o, i], type = "l",
             xlab = names(cpus2[i]), ylab = "")
    }
    detach()
}

# 8.9  Projection-pursuit regression

attach(rock)
rock1 <- data.frame(area = area/10000, peri = peri/10000,
                    shape = shape, perm = perm)
detach()
(rock.ppr <- ppr(log(perm) ~ area + peri + shape, data = rock1,
                 nterms = 2, max.terms = 5))
rock.ppr
summary(rock.ppr)

par(mfrow = c(3, 2))
plot(rock.ppr)
plot(update(rock.ppr, bass = 5))
plot(rock.ppr2 <- update(rock.ppr, sm.method = "gcv", gcvpen = 2))
par(mfrow = c(1, 1))

summary(rock.ppr2)

summary(rock1) # to find the ranges of the variables
Xp <- expand.grid(area = seq(0.1, 1.2, 0.05),
                  peri = seq(0, 0.5, 0.02), shape = 0.2)
rock.grid <- cbind(Xp, fit = predict(rock.ppr2, Xp))
wireframe(fit ~ area + peri, rock.grid, screen = list(z=160,x=-60),
          aspect = c(1, 0.5), drape = TRUE)
# or
persp(seq(0.1, 1.2, 0.05), seq(0, 0.5, 0.02), matrix(rock.grid$fit, 23),
      d = 5, theta = -160, phi = 30, zlim = c(-1, 15))


(cpus.ppr <- ppr(log10(perf) ~ ., data = cpus2[cpus.samp,],
                 nterms = 2, max.terms = 10, bass = 5))
cpus.ppr <- ppr(log10(perf) ~ ., data = cpus2[cpus.samp,],
                nterms = 8, max.terms = 10, bass = 5)
test.cpus(cpus.ppr)

ppr(log10(perf) ~ ., data = cpus2[cpus.samp,],
    nterms = 2, max.terms = 10, sm.method = "spline")
cpus.ppr2 <- ppr(log10(perf) ~ ., data = cpus2[cpus.samp,],
   nterms = 7, max.terms = 10, sm.method = "spline")
test.cpus(cpus.ppr2)
res3 <- log10(cpus2[-cpus.samp, "perf"]) -
             predict(cpus.ppr, cpus2[-cpus.samp,])
wilcox.test(res2^2, res3^2, paired = TRUE, alternative = "greater")


# 8.10  Neural networks

library(nnet)
attach(rock)
area1 <- area/10000; peri1 <- peri/10000
rock1 <- data.frame(perm, area = area1, peri = peri1, shape)
rock.nn <- nnet(log(perm) ~ area + peri + shape, rock1,
    size = 3, decay = 1e-3, linout = TRUE, skip = TRUE,
    maxit = 1000, Hess = TRUE)
sum((log(perm) - predict(rock.nn))^2)
detach()
eigen(rock.nn$Hessian, TRUE)$values    # rock.nn$Hessian in R

Xp <- expand.grid(area = seq(0.1, 1.2, 0.05),
                 peri = seq(0, 0.5, 0.02), shape = 0.2)
rock.grid <- cbind(Xp, fit = predict(rock.nn, Xp))
wireframe(fit ~ area + peri, rock.grid, screen = list(z=160, x=-60),
          aspect = c(1, 0.5), drape = TRUE)
# or
persp(seq(0.1, 1.2, 0.05), seq(0, 0.5, 0.02), matrix(rock.grid$fit, 23),
      d = 5, theta = -160, phi = 30, zlim = c(-1, 15))

attach(cpus2)
cpus3 <-
 data.frame(syct= syct-2, mmin=mmin-3, mmax=mmax-4, cach=cach/256,
            chmin=chmin/100, chmax=chmax/100, perf=perf)
detach()

test.cpus <- function(fit)
 sqrt(sum((log10(cpus3[-cpus.samp, "perf"]) -
          predict(fit, cpus3[-cpus.samp,]))^2)/109)
cpus.nn1 <- nnet(log10(perf) ~ ., cpus3[cpus.samp,],
                linout = TRUE, skip = TRUE, size = 0)
test.cpus(cpus.nn1)

cpus.nn2 <- nnet(log10(perf) ~ ., cpus3[cpus.samp,], linout = TRUE,
                 skip = TRUE, size = 4, decay = 0.01, maxit = 1000)
test.cpus(cpus.nn2)
cpus.nn3 <- nnet(log10(perf) ~ ., cpus3[cpus.samp,], linout = TRUE,
                 skip = TRUE, size = 10, decay = 0.01, maxit = 1000)
test.cpus(cpus.nn3)
cpus.nn4 <- nnet(log10(perf) ~ ., cpus3[cpus.samp,], linout = TRUE,
                skip = TRUE, size = 25, decay = 0.01, maxit = 1000)
test.cpus(cpus.nn4)

CVnn.cpus <- function(formula, data = cpus3[cpus.samp, ],
    size = c(0, 4, 4, 10, 10),
    lambda = c(0, rep(c(0.003, 0.01), 2)),
    nreps = 5, nifold = 10, ...)
{
  CVnn1 <- function(formula, data, nreps=1, ri,  ...)
  {
    truth <- log10(data$perf)
    res <- numeric(length(truth))
    cat("  fold")
    for (i in sort(unique(ri))) {
      cat(" ", i,  sep="")
      for(rep in 1:nreps) {
        learn <- nnet(formula, data[ri !=i,], trace=FALSE, ...)
        res[ri == i] <- res[ri == i] +
                        predict(learn, data[ri == i,])
      }
    }
    cat("\n")
    sum((truth - res/nreps)^2)
  }
  choice <- numeric(length(lambda))
  ri <- sample(nifold, nrow(data), replace = TRUE)
  for(j in seq(along=lambda)) {
    cat("  size =", size[j], "decay =", lambda[j], "\n")
    choice[j] <- CVnn1(formula, data, nreps=nreps, ri=ri,
                       size=size[j], decay=lambda[j], ...)
    }
  cbind(size=size, decay=lambda, fit=sqrt(choice/100))
}
CVnn.cpus(log10(perf) ~ ., data = cpus3[cpus.samp,],
         linout = TRUE, skip = TRUE, maxit = 1000)

# End of ch08
