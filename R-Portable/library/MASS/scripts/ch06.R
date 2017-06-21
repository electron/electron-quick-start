#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 6   Linear Statistical Models

library(MASS)
library(lattice)
options(width=65, digits=5, height=9999)
pdf(file="ch06.pdf", width=8, height=6, pointsize=9)
options(contrasts = c("contr.helmert", "contr.poly"))


# 6.1  A linear regression example

xyplot(Gas ~ Temp | Insul, whiteside, panel =
  function(x, y, ...) {
    panel.xyplot(x, y, ...)
    panel.lmline(x, y, ...)
  }, xlab = "Average external temperature (deg. C)",
  ylab = "Gas consumption  (1000 cubic feet)", aspect = "xy",
  strip = function(...) strip.default(..., style = 1))


gasB <- lm(Gas ~ Temp, data = whiteside, subset = Insul=="Before")
gasA <- update(gasB, subset = Insul=="After")

summary(gasB)
summary(gasA)

varB <- deviance(gasB)/gasB$df.resid    # direct calculation
varB <- summary(gasB)$sigma^2           # alternative

gasBA <- lm(Gas ~ Insul/Temp - 1, data = whiteside)
summary(gasBA)

gasQ <- lm(Gas ~ Insul/(Temp + I(Temp^2)) - 1, data = whiteside)
summary(gasQ)$coef

# R: options(contrasts = c("contr.helmert", "contr.poly"))
gasPR <- lm(Gas ~ Insul + Temp, data = whiteside)
anova(gasPR, gasBA)

oldcon <- options(contrasts = c("contr.treatment", "contr.poly"))
gasBA1 <- lm(Gas ~ Insul*Temp, data = whiteside)
summary(gasBA1)$coef
options(oldcon)


# 6.2  Model formulae and model matrices

dat <- data.frame(a = factor(rep(1:3, 3)),
                  y = rnorm(9, rep(2:4, 3), 0.1))
obj <- lm(y ~ a, dat)
(alf.star <- coef(obj))
Ca <- contrasts(dat$a)      # contrast matrix for `a'
drop(Ca %*% alf.star[-1])
dummy.coef(obj)


N <- factor(Nlevs <- c(0,1,2,4))
contrasts(N)
contrasts(ordered(N))

N2 <- N
contrasts(N2, 2) <- poly(Nlevs, 2)
N2 <- C(N, poly(Nlevs, 2), 2)       # alternative
contrasts(N2)

fractions(ginv(contr.helmert(n = 4)))

Cp <- diag(-1, 4, 5);  Cp[row(Cp) == col(Cp) - 1] <- 1
Cp
fractions(ginv(Cp))


# 6.3  Regression diagnostics

(hills.lm <- lm(time ~ dist + climb, data = hills))
frame()
par(fig = c(0, 0.6, 0, 0.55))
plot(fitted(hills.lm), studres(hills.lm))
abline(h = 0, lty = 2)
# identify(fitted(hills.lm), studres(hills.lm), row.names(hills))
par(fig = c(0.6, 1, 0, 0.55), pty = "s")
qqnorm(studres(hills.lm))
qqline(studres(hills.lm))
par(pty = "m")
hills.hat <- lm.influence(hills.lm)$hat
cbind(hills, lev = hills.hat)[hills.hat > 3/35, ]
cbind(hills, pred = predict(hills.lm))["Knock Hill", ]
(hills1.lm <- update(hills.lm, subset = -18))
update(hills.lm, subset = -c(7, 18))
summary(hills1.lm)
summary(update(hills1.lm,  weights = 1/dist^2))
lm(time ~ -1 + dist + climb, hills[-18, ], weight = 1/dist^2)

# hills <- hills   # make a local copy (needed in S-PLUS)
hills$ispeed <- hills$time/hills$dist
hills$grad <- hills$climb/hills$dist
(hills2.lm <- lm(ispeed ~ grad, data = hills[-18, ]))
frame()
par(fig = c(0, 0.6, 0, 0.55))
plot(hills$grad[-18], studres(hills2.lm), xlab = "grad")
abline(h = 0, lty = 2)
# identify(hills$grad[-18], studres(hills2.lm), row.names(hills)[-18])
par(fig = c(0.6, 1, 0, 0.55), pty = "s")
qqnorm(studres(hills2.lm))
qqline(studres(hills2.lm))
par(pty = "m")
hills2.hat <- lm.influence(hills2.lm)$hat
cbind(hills[-18,], lev = hills2.hat)[hills2.hat > 1.8*2/34, ]


# 6.4  Safe prediction

quad1 <- lm(Weight ~ Days + I(Days^2), data = wtloss)
quad2 <- lm(Weight ~ poly(Days, 2), data = wtloss)

new.x <- data.frame(Days = seq(250, 300, 10),
                    row.names = seq(250, 300, 10))

predict(quad1, newdata = new.x)
predict(quad2, newdata = new.x)

# predict.gam(quad2, newdata = new.x) # S-PLUS only


# 6.5  Robust and resistant regression

# library(lqs)
phones.lm <- lm(calls ~ year, data = phones)
attach(phones); plot(year, calls); detach()
abline(phones.lm$coef)
abline(rlm(calls ~ year, phones, maxit=50), lty = 2, col = 2)
abline(lqs(calls ~ year, phones), lty =3, col = 3)
# legend(locator(1), lty = 1:3, col = 1:3,
#        legend = c("least squares", "M-estimate", "LTS"))

## cor = FALSE is the default in R
summary(lm(calls ~ year, data = phones))
summary(rlm(calls ~ year, maxit = 50, data = phones))
summary(rlm(calls ~ year, scale.est = "proposal 2", data = phones))
summary(rlm(calls ~ year, data = phones, psi = psi.bisquare))

lqs(calls ~ year, data = phones)
lqs(calls ~ year, data = phones, method = "lms")
lqs(calls ~ year, data = phones, method = "S")

summary(rlm(calls ~ year, data = phones, method = "MM"))

# library(robust) # S-PLUS only
# phones.lmr <- lmRob(calls ~ year, data = phones)
# summary(phones.lmr)
# plot(phones.lmr)

hills.lm
hills1.lm # omitting Knock Hill
rlm(time ~ dist + climb, data = hills)
summary(rlm(time ~ dist + climb, data = hills,
             weights = 1/dist^2, method = "MM"))
lqs(time ~ dist + climb, data = hills, nsamp = "exact")
summary(hills2.lm) # omitting Knock Hill
summary(rlm(ispeed ~ grad, data = hills))
summary(rlm(ispeed ~ grad, data = hills, method="MM"))
# summary(lmRob(ispeed ~ grad, data = hills))

lqs(ispeed ~ grad, data = hills)


# 6.6  Bootstrapping linear models

library(boot)
fit <- lm(calls ~ year, data = phones)
ph <- data.frame(phones, res = resid(fit), fitted = fitted(fit))
ph.fun <- function(data, i) {
  d <- data
  d$calls <- d$fitted + d$res[i]
  coef(update(fit, data=d))
}
(ph.lm.boot <- boot(ph, ph.fun, R = 999))

fit <- rlm(calls ~ year, method = "MM", data = phones)
ph <- data.frame(phones, res = resid(fit), fitted = fitted(fit))
(ph.rlm.boot <- boot(ph, ph.fun, R = 999))


# 6.7  Factorial designs and designed experiments

options(contrasts=c("contr.helmert", "contr.poly"))
(npk.aov <- aov(yield ~ block + N*P*K, data = npk))
summary(npk.aov)

alias(npk.aov)
coef(npk.aov)

options(contrasts=c("contr.treatment", "contr.poly"))
npk.aov1 <- aov(yield ~ block + N + K, data = npk)
summary.lm(npk.aov1)
se.contrast(npk.aov1, list(N == "0", N == "1"), data = npk)
model.tables(npk.aov1, type = "means", se = TRUE)

mp <- c("-", "+")
(NPK <- expand.grid(N = mp, P = mp, K = mp))

if(FALSE) { ## fac.design is part of S-PLUS.
blocks13 <- fac.design(levels = c(2, 2, 2),
    factor= list(N=mp, P=mp, K=mp), rep = 3, fraction = 1/2)

blocks46 <- fac.design(levels = c(2, 2, 2),
   factor = list(N=mp, P=mp, K=mp), rep = 3, fraction = ~ -N:P:K)

NPK <- design(block = factor(rep(1:6, each  = 4)),
             rbind(blocks13, blocks46))
i <- order(runif(6)[NPK$block], runif(24))
NPK <- NPK[i,]  # Randomized

lev <- rep(2, 7)
factors <- list(S=mp, D=mp, H=mp, G=mp, R=mp, B=mp, P=mp)
(Bike <- fac.design(lev, factors,
     fraction = ~ S:D:G + S:H:R + D:H:B + S:D:H:P))
replications(~ .^2, data=Bike)
}

if(require("FrF2")) {
NPK <- FrF2(8, factor.names = c("N", "P", "K"), default.levels = 0:1,
            blocks = 2, replications = 3)
print(NPK)
print(as.data.frame(NPK))

print(Bike <- FrF2(factor.names = c("S", "D", "H", "G", "R", "B", "P"),
                   default.levels = c("+", "-"), resolution = 3))
print(replications(~ .^2, data=Bike))
}

# 6.8  An unbalanced four-way layout

attach(quine)
table(Lrn, Age, Sex, Eth)

Means <- tapply(Days, list(Eth, Sex, Age, Lrn), mean)
Vars  <- tapply(Days, list(Eth, Sex, Age, Lrn), var)
SD <- sqrt(Vars)
par(mfrow = c(1, 2), pty="s")
plot(Means, Vars, xlab = "Cell Means", ylab = "Cell Variances")
plot(Means, SD, xlab = "Cell Means", ylab = "Cell Std Devn.")
detach()

## singular.ok = TRUE is the default in R
boxcox(Days+1 ~ Eth*Sex*Age*Lrn, data = quine, singular.ok = TRUE,
  lambda = seq(-0.05, 0.45, len = 20))

logtrans(Days ~ Age*Sex*Eth*Lrn, data = quine,
    alpha = seq(0.75, 6.5, len = 20), singular.ok = TRUE)

quine.hi <- aov(log(Days + 2.5) ~ .^4, quine)
quine.nxt <- update(quine.hi, . ~ . - Eth:Sex:Age:Lrn)
dropterm(quine.nxt, test = "F")

quine.lo <- aov(log(Days+2.5) ~ 1, quine)
addterm(quine.lo, quine.hi, test = "F")

quine.stp <- stepAIC(quine.nxt,
   scope = list(upper = ~Eth*Sex*Age*Lrn, lower = ~1),
   trace = FALSE)
quine.stp$anova

dropterm(quine.stp, test = "F")
quine.3 <- update(quine.stp, . ~ . - Eth:Age:Lrn)
dropterm(quine.3, test = "F")
quine.4 <- update(quine.3, . ~ . - Eth:Age)
quine.5 <- update(quine.4, . ~ . - Age:Lrn)
dropterm(quine.5, test = "F")


# 6.9  Predicting computer performance

par(mfrow = c(1, 2), pty = "s")
boxcox(perf ~ syct + mmin + mmax + cach + chmin + chmax,
       data = cpus, lambda = seq(0, 1, 0.1))

cpus1 <- cpus
attach(cpus)
for(v in names(cpus)[2:7])
  cpus1[[v]] <- cut(cpus[[v]], unique(quantile(cpus[[v]])),
                    include.lowest = TRUE)
detach()
boxcox(perf ~ syct + mmin + mmax + cach + chmin + chmax,
       data = cpus1, lambda = seq(-0.25, 1, 0.1))
par(mfrow = c(1, 1), pty = "m")

set.seed(123)
cpus2 <- cpus[, 2:8]  # excludes names, authors' predictions
cpus2[, 1:3] <- log10(cpus2[, 1:3])
#cpus.samp <- sample(1:209, 100)
cpus.samp <-
c(3, 5, 6, 7, 8, 10, 11, 16, 20, 21, 22, 23, 24, 25, 29, 33, 39, 41, 44, 45,
46, 49, 57, 58, 62, 63, 65, 66, 68, 69, 73, 74, 75, 76, 78, 83, 86,
88, 98, 99, 100, 103, 107, 110, 112, 113, 115, 118, 119, 120, 122,
124, 125, 126, 127, 132, 136, 141, 144, 146, 147, 148, 149, 150, 151,
152, 154, 156, 157, 158, 159, 160, 161, 163, 166, 167, 169, 170, 173,
174, 175, 176, 177, 183, 184, 187, 188, 189, 194, 195, 196, 197, 198,
199, 202, 204, 205, 206, 208, 209)

cpus.lm <- lm(log10(perf) ~ ., data = cpus2[cpus.samp, ])
test.cpus <- function(fit)
   sqrt(sum((log10(cpus2[-cpus.samp, "perf"]) -
             predict(fit, cpus2[-cpus.samp,]))^2)/109)
test.cpus(cpus.lm)
cpus.lm2 <- stepAIC(cpus.lm, trace=FALSE)
cpus.lm2$anova
test.cpus(cpus.lm2)


# 6.10  Multiple comparisons

immer.aov <- aov((Y1 + Y2)/2 ~ Var + Loc, data = immer)
summary(immer.aov)

model.tables(immer.aov, type = "means", se = TRUE, cterms = "Var")

if(FALSE) {
multicomp(immer.aov, plot = TRUE)

oats1 <- aov(Y ~ N + V + B, data = oats)
summary(oats1)
multicomp(oats1, focus = "V")
multicomp(oats1, focus = "N", comparisons = "mcc", control = 1)
lmat <- matrix(c(0,-1,1,rep(0, 11), 0,0,-1,1, rep(0,10),
                 0,0,0,-1,1,rep(0,9)),,3,
               dimnames = list(NULL,
               c("0.2cwt-0.0cwt", "0.4cwt-0.2cwt", "0.6cwt-0.4cwt")))
multicomp(oats1, lmat = lmat, bounds = "lower", comparisons = "none")
}

(tk <- TukeyHSD(immer.aov, which = "Var"))
plot(tk)

oats1 <- aov(Y ~ N + V + B, data = oats)
(tk <- TukeyHSD(oats1, which = "V"))
plot(tk)

## An alternative under R is to use package multcomp (which requires mvtnorm)
## This code is for multcomp >= 0.991-1
library(multcomp)
## next is slow:
(tk <- confint(glht(immer.aov, linfct = mcp(Var = "Tukey"))))
plot(tk)

confint(glht(oats1, linfct = mcp(V = "Tukey")))
lmat <- matrix(c(0,-1,1,rep(0, 11), 0,0,-1,1, rep(0,10),
                 0,0,0,-1,1,rep(0,9)),,3,
               dimnames = list(NULL,
               c("0.2cwt-0.0cwt", "0.4cwt-0.2cwt", "0.6cwt-0.4cwt")))
confint(glht(oats1, linfct = mcp(N = t(lmat[2:5, ])), alternative = "greater"))
plot(tk)

# End of ch06
