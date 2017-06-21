## from PR#8905
library(nlme)
data(Orthodont)
fm <- lme(distance ~ poly(age, 3) + Sex, data = Orthodont, random = ~ 1)
# data for predictions
Newdata <- head(Orthodont)
Newdata$Sex <- factor(Newdata$Sex, levels = levels(Orthodont$Sex))
(pr <- predict(fm, Newdata))
stopifnot(all.equal(c(pr), fitted(fm)[1:6]))

## https://stat.ethz.ch/pipermail/r-devel/2013-September/067600.html
## but with a different fix.

m0 <- lme(distance ~ Sex, random = ~1|Subject, data = Orthodont)
Fitted <- predict(m0, level = 0)
Fitted.Newdata <- predict(m0, level = 0, newdata = Orthodont)
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)

Fitted <- predict(m0, level = 1)
Fitted.Newdata <- predict(m0, level = 1, newdata = Orthodont)
sum(abs(Fitted - Fitted.Newdata))
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)

m1 <- lme(distance ~ 1, random = ~1|Subject, data = Orthodont)
Fitted <- predict(m1, level = 0)
Fitted.Newdata <- predict(m1, level = 0, newdata = Orthodont)
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)

Fitted <- predict(m1, level = 1)
Fitted.Newdata <- predict(m1, level = 1, newdata = Orthodont)
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)

m2 <- lme(distance ~ 0, random = ~1|Subject, data = Orthodont)
Fitted <- predict(m2, level = 0)
Fitted.Newdata <- predict(m2, level = 0, newdata = Orthodont)
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)

Fitted <- predict(m2, level = 1)
Fitted.Newdata <- predict(m2, level = 1, newdata = Orthodont)
stopifnot(sum(abs(Fitted - Fitted.Newdata)) == 0)


m3 <- lme(fixed = distance ~ age, data = Orthodont,
          random = ~ 1 | Subject)
m4 <- update(m3, random = ~ age | Subject)
m5 <- update(m4, fixed = distance ~ age * Sex)

newD <- expand.grid(age = seq(7,15, by = .25),
                    Sex = c("Male", "Female"),
                    Subject = c("M01", "F01"))
(n.age <- attr(newD, "out.attrs")$dim[["age"]]) # 33
str(p5 <- predict(m5, newdata = newD, asList = TRUE, level=0:1))
pp5 <- cbind(newD, p5[,-1])
stopifnot(identical(colnames(pp5),
                    c("age", "Sex", "Subject", "predict.fixed", "predict.Subject")))
fixef(m5) # (Intercept) age SexF age:SexF
p5Mf <- pp5[pp5$Sex == "Male", "predict.fixed"]
p5MS <- subset(pp5, subset = Subject == "M01" & Sex == "Male",
               select = "predict.Subject", drop=TRUE)
X.1 <- cbind(1, newD[1:n.age,"age"])
stopifnot(all.equal(p5Mf[  1:n.age],
                    p5Mf[-(1:n.age)], tol = 1e-15)
         ,
          all.equal(p5Mf[  1:n.age],
                    c(X.1 %*% fixef(m5)[1:2]), tol = 1e-15)
         ,
          all.equal(p5MS,
                    c(X.1 %*% (fixef(m5)[1:2] + as.numeric(ranef(m5)["M01",]))), tole = 1e-15)
          )

##--- simulate():---------

## border cases
ort.0 <- simulate(m3, method = character())# "nothing" stored
ort.M <- simulate(m3, method = "ML",   seed=47)
ort.R <- simulate(m3, method = "REML", seed=47)
stopifnot(identical(names(ort.0), "null"),
          identical(names(ort.M), "null"),
          identical(names(ort.R), "null"),
          identical(ort.0$null, list()),
          identical(names(ort.M$null), "ML"),
          identical(names(ort.R$null), "REML"),
          all.equal(loM <- ort.M$null$ML  [,"logLik"], -215.437, tol = 2e-6)
         ,
          all.equal(loR <- ort.R$null$REML[,"logLik"], -217.325, tol = 2e-6)
          )

system.time(
 orthS3 <- simulate.lme(list(fixed = distance ~ age, data = Orthodont,
                              random = ~ 1 | Subject), nsim = 3,
                         m2 = list(random = ~ age | Subject), seed = 47)
)
## the same, starting from two fitted models :
ort.S3 <- simulate(m3, m2 = m4, nsim = 3, seed = 47)
attr(ort.S3, "call") <- attr(orthS3, "call")
stopifnot(all.equal(orthS3, ort.S3, tolerance = 1e-15))

logL <- sapply(orthS3, function(E) sapply(E,
                       function(M) M[,"logLik"]), simplify="array")

stopifnot(is.array(logL), length(d <- dim(logL)) == 3, d == c(3,2,2),
    sapply(orthS3, function(E) sapply(E, function(M) M[,"info"])) == 0
   , # typically even identical():
    all.equal(logL[1,,"null"], c(ML = loM, REML = loR), tol = 1e-15)
   ,
    all.equal(c(logL) + 230,
              c(14.563 , 2.86712, 1.00026, 12.6749, 1.1615,-0.602989,
                16.2301, 2.95877, 2.12854, 14.3586, 1.2534, 0.582263), tol=8e-6)
)
