library(nlme)
if(require("Hmisc")) {
    T.aug <- Orthodont
    label(T.aug$age) <- 'anyL'
    foo <- augPred(lme(distance ~ age, random = ~1|Subject, data=T.aug))
    ## failed in 3.1-72
}

## failed even if there is a variable with a class that is not being used.
T.aug <- Orthodont
T.aug$newage <- T.aug$age
class(T.aug$newage) <- 'anyC'
foo <- augPred(lme(distance ~ age, random = ~1|Subject, data=T.aug))
## failed in 3.1-72

## [Bug 16715] New: nlme: unable to use  predict and augPredict functions in non linear mixed models
## Date: Wed, 17 Feb 2016

M1.lis <- nlsList( SSlogis, data=Soybean)
## prints "Error in qr.solve(QR.B, cc): singular matrix 'a' in solve"
## ==> MM: 2016-03-11 "fixed": now prints it as warning [you could suppress or catch]
## ==> one NA row '1989P8' in this:
M1.lis
##  Nonlinear Logistic Growth -- each of the 3 par. (Asym, xmid, scal) has RE term
##  Model: weight ~ SSlogis(Time, Asym, xmid, scal) | Plot

M1.nlme <- nlme( M1.lis )
summary(M1.nlme)
## R 3.2.2 (nlme 3.1-121) :
## Nonlinear mixed-effects model fit by maximum likelihood
##   Model: weight ~ SSlogis(Time, Asym, xmid, scal)
##  Data: Soybean
##        AIC      BIC    logLik
##   1499.671 1539.881 -739.8354

## Random effects:
##  Formula: list(Asym ~ 1, xmid ~ 1, scal ~ 1)
##  Level: Plot
##  Structure: General positive-definite, Log-Cholesky parametrization
##          StdDev   Corr
## Asym     5.201186 Asym  xmid
## xmid     4.197467 0.721
## scal     1.404737 0.711 0.958
## Residual 1.123461

## Fixed effects: list(Asym ~ 1, xmid ~ 1, scal ~ 1)
##         Value Std.Error  DF  t-value p-value
## Asym 19.25301 0.8031921 362 23.97062       0
## xmid 55.01985 0.7272721 362 75.65235       0
## scal  8.40333 0.3152893 362 26.65276       0
##  Correlation:
##      Asym  xmid
## xmid 0.724
## scal 0.620 0.807

## Standardized Within-Group Residuals:
##         Min          Q1         Med          Q3         Max
## -6.08691772 -0.22160816 -0.03390491  0.29741145  4.84688248

## Number of Observations: 412
## Number of Groups: 48

M1.Fix <- fixef(M1.nlme)
## add fixed effect 'Variety' :
M2.nlme <- update(M1.nlme, fixed = Asym + xmid + scal ~ Variety,
                  start = c(M1.Fix[1], 1, M1.Fix[2], 1, M1.Fix[3], 1))
summary(M2.nlme)
pred.m2 <- predict(M2.nlme, level = 0:1)
stopifnot(is.data.frame(pred.m2), dim(pred.m2) == c(412, 3))

augp.m2 <- augPred(M2.nlme, level = 0:1)
## failed in nlme-3.1-124/5

stopifnot(is.data.frame(augp.m2), dim(augp.m2) == c(5308, 4)
          ,
          all.equal(colMeans(augp.m2[,c("Time","weight")]),
                    c(Time = 48.585908, weight =7.8599693), tolerance = 1e-7)# 2e-9
          ,
          identical(c(table(augp.m2[,".type"])),
                    c(predict.fixed = 2448L, predict.Plot = 2448L, original = 412L))
          ,
          identical(c(table(as.vector(table(augp.m2[,".groups"])))),
                    c("110" = 33L, "111" = 2L, "112" = 13L))
)
