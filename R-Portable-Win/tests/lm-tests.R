###-- Linear Models, basic functionality -- weights included.

## From John Maindonald :
roller <- data.frame(
 weight     = c(1.9,  3.1,  3.3,  4.8,  5.3,  6.1,  6.4,  7.6,  9.8, 12.4),
 depression = c(  2,  1,    5,    5,   20,   20,   23,   10,   30,   25))

roller.lmu  <-  lm(weight~depression, data=roller)
roller.lsfu <- lsfit(roller$depression, roller$weight)

roller.lsf  <- lsfit(roller$depression, roller$weight, wt = 1:10)
roller.lsf0 <- lsfit(roller$depression, roller$weight, wt = 0:9)
roller.lm  <-  lm(weight~depression, data=roller, weights= 1:10)
roller.lm0 <-  lm(weight~depression, data=roller, weights= 0:9)
roller.lm9 <-  lm(weight~depression, data=roller[-1,],weights= 1:9)
roller.glm <- glm(weight~depression, data=roller, weights= 1:10)
roller.glm0<- glm(weight~depression, data=roller, weights= 0:9)

predict(roller.glm0, type="terms")# failed till 2003-03-31

## FIXME : glm()$residual [1] is NA,  lm()'s is ok.
## all.equal(residuals(roller.glm0, type = "partial"),
##          residuals(roller.lm0,  type = "partial") )


all.equal(deviance(roller.lm),
          deviance(roller.glm))
all.equal(weighted.residuals(roller.lm),
          residuals         (roller.glm))

all.equal(deviance(roller.lm0),
          deviance(roller.glm0))
all.equal(weighted.residuals(roller.lm0, drop=FALSE),
          residuals         (roller.glm0))

(im.lm0 <- influence.measures(roller.lm0))

all.equal(unname(im.lm0 $ infmat),
          unname(cbind(  dfbetas      (roller.lm0)
                       , dffits       (roller.lm0)
                       , covratio     (roller.lm0)
                       ,cooks.distance(roller.lm0)
                       ,lm.influence  (roller.lm0)$hat)
                 ))

all.equal(rstandard(roller.lm9),
          rstandard(roller.lm0),tolerance = 1e-14)
all.equal(rstudent(roller.lm9),
          rstudent(roller.lm0),tolerance = 1e-14)
all.equal(rstudent(roller.lm),
          rstudent(roller.glm))
all.equal(cooks.distance(roller.lm),
          cooks.distance(roller.glm))


all.equal(summary(roller.lm0)$coefficients,
          summary(roller.lm9)$coefficients, tolerance = 1e-14)
all.equal(print(anova(roller.lm0), signif.st=FALSE),
                anova(roller.lm9), tolerance = 1e-14)


###  more regression tests for lm(), glm(), etc :

## moved from ?influence.measures:
lm.SR <- lm(sr ~ pop15 + pop75 + dpi + ddpi, data = LifeCycleSavings)
(IM <- influence.measures(lm.SR))
summary(IM)
## colnames will differ in the next line
all.equal(dfbetas(lm.SR), IM$infmat[, 1:5], check.attributes = FALSE,
          tolerance = 1e-12)
signif(dfbeta(lm.SR), 3)
covratio (lm.SR)

## Multivariate lm ("mlm") --- Example from  ?SSD
reacttime <- matrix(c(
420, 420, 480, 480, 600, 780,
420, 480, 480, 360, 480, 600,
480, 480, 540, 660, 780, 780,
420, 540, 540, 480, 780, 900,
540, 660, 540, 480, 660, 720,
360, 420, 360, 360, 480, 540,
480, 480, 600, 540, 720, 840,
480, 600, 660, 540, 720, 900,
540, 600, 540, 480, 720, 780,
480, 420, 540, 540, 660, 780),
ncol = 6, byrow = TRUE,
dimnames = list(subj = 1:10,
              cond = c("deg0NA", "deg4NA", "deg8NA",
                       "deg0NP", "deg4NP", "deg8NP")))
mlmfit <- lm(reacttime ~ 1)
ImMLM <- influence.measures(mlmfit)## fails in R <= 3.5.1
## and the print() and summary() methods had failed additionally:
oo <- capture.output(ImMLM) # now ok
summary(ImMLM) # "ok"



## predict.lm(.)

all.equal(predict(roller.lm,                 se.fit=TRUE)$se.fit,
          predict(roller.lm, newdata=roller, se.fit=TRUE)$se.fit, tolerance =  1e-14)
