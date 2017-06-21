## PR#15678

library(nlme)
set.seed(1)
X1 <- gl(2,4)
X2 <- gl(2,2,8)
Y <- rnorm(8)
mis.dat <- data.frame(Y = Y,X1 = X1,X2 = X2)
mis.dat[3, "Y"] <- NA

## Fit model -----------------------
model <- lme(Y ~ 1, random = ~ 1 | X1/X2, data = mis.dat, na.action = na.omit)
summary(model)

labs <- with(na.omit(mis.dat), paste(X1, X2, sep = "/" ))
fit <- fitted(model)
stopifnot(identical(names(fit), labs))

