#  File src/library/stats/tests/nafns.R
#  Part of the R package, https://www.R-project.org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

## Tests of functions handling NAs in fits
## These functions were introduced in 1.3.0.
## They are used by lm and glm in base R, and by
## packages MASS, rpart and survival.

## Comparison strictness is set at 256eps, increased from 100eps for v.2.1.0
## May look lenient, but notice that the Ozone levels that are being modeled
## can be more than 100.

dim(airquality)
nd <- airquality[c(6,25:27), ]

sm <- function(x) cat("length", length(x), "with", sum(is.na(x)), "NAs\n")

# default is to omit some rows
fit <- lm(Ozone ~ ., data=airquality, na.action=na.omit)
summary(fit)
sm(fitted(fit))
sm(resid(fit))
sm(predict(fit))
(pp <- predict(fit, nd))

fit2 <- lm(Ozone ~ ., data=airquality, na.action=na.exclude)
summary(fit2) # same as before
sm(fitted(fit2))
sm(resid(fit2))
sm(predict(fit2))
(pp2 <- predict(fit2, nd))

## same as before: napredict is only applied to predictions on the
## original data, following Therneau's original code (and S-PLUS).
## However, as from R 1.8.0 there is a separate na.action arg to predict.lm()
stopifnot(all.equal(pp, pp2))

## should fail
try(fit3 <- lm(Ozone ~ ., data=airquality, na.action=na.fail))

## more precise tests.
f1 <- fitted(fit)
f2 <- fitted(fit2)
common <- match(names(f1), names(f2))
stopifnot(max(abs(f1 - f2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(f2[-common])))

r1 <- resid(fit)
r2 <- resid(fit2)
common <- match(names(r1), names(r2))
stopifnot(max(abs(r1 - r2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(r2[-common])))

p1 <- predict(fit)
p2 <- predict(fit2)
common <- match(names(p1), names(p2))
stopifnot(max(abs(p1 - p2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(p2[-common])))


### now try out glm
gfit <- glm(Ozone ~ ., data=airquality, na.action=na.omit)
summary(gfit)
sm(fitted(gfit))
sm(resid(gfit))
sm(predict(gfit))
predict(gfit, nd)
(pp <- predict(gfit, nd))

gfit2 <- glm(Ozone ~ ., data=airquality, na.action=na.exclude)
summary(gfit2) # same as before
sm(fitted(gfit2))
sm(resid(gfit2))
sm(predict(gfit2))
(pp2 <- predict(gfit2, nd))
stopifnot(all.equal(pp, pp2))

## more precise tests.
f1 <- fitted(gfit)
f2 <- fitted(gfit2)
common <- match(names(f1), names(f2))
stopifnot(max(abs(f1 - f2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(f2[-common])))

r1 <- resid(gfit)
r2 <- resid(gfit2)
common <- match(names(r1), names(r2))
stopifnot(max(abs(r1 - r2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(r2[-common])))

p1 <- predict(gfit)
p2 <- predict(gfit2)
common <- match(names(p1), names(p2))
stopifnot(max(abs(p1 - p2[common])) <= 256*.Machine$double.eps)
stopifnot(all(is.na(p2[-common])))

## tests of diagnostic measures.
set.seed(11)
x <- 1:10
y <- c(rnorm(9),NA)
fit <- lm(y ~ x, na.action=na.exclude)
fit2 <- lm(y ~ x, subset=-10)

lm.influence(fit2); lm.influence(fit)

rstandard(fit2); rstandard(fit)
rstudent(fit2); rstudent(fit)

dffits(fit2); dffits(fit)

dfbetas(fit2); dfbetas(fit)

covratio(fit2); covratio(fit)

cooks.distance(fit2); cooks.distance(fit)

(inf <- influence.measures(fit))
(inf2 <- influence.measures(fit2))

summary(inf)
summary(inf2)

plot(fit)
