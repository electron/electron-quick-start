### R code from vignette source 'ipred-examples.Rnw'

###################################################
### code chunk number 1: preliminaries
###################################################
options(prompt=">", width=50)
set.seed(210477)


###################################################
### code chunk number 2: bagging
###################################################
library("ipred")
library("rpart")
library("MASS")
data("GlaucomaM", package="TH.data")
gbag <- bagging(Class ~ ., data = GlaucomaM, coob=TRUE)


###################################################
### code chunk number 3: print-bagging
###################################################
print(gbag)


###################################################
### code chunk number 4: double-bagging
###################################################
scomb <- list(list(model=slda, predict=function(object, newdata)
  predict(object, newdata)$x))
gbagc <- bagging(Class ~ ., data = GlaucomaM, comb=scomb)


###################################################
### code chunk number 5: predict.bagging
###################################################
predict(gbagc, newdata=GlaucomaM[c(1:3, 99:102), ])


###################################################
### code chunk number 6: indirect.formula
###################################################
data("GlaucomaMVF", package="ipred")
GlaucomaMVF <- GlaucomaMVF[,-63]
formula.indirect <- Class~clv + lora + cs ~ .


###################################################
### code chunk number 7: indirect.fit
###################################################
classify <- function (data) {
  attach(data)
  res <- ifelse((!is.na(clv) & !is.na(lora) & clv >= 5.1 & lora >=
        49.23372) | (!is.na(clv) & !is.na(lora) & !is.na(cs) &
        clv < 5.1 & lora >= 58.55409 & cs < 1.405) | (is.na(clv) &
        !is.na(lora) & !is.na(cs) & lora >= 58.55409 & cs < 1.405) |
        (!is.na(clv) & is.na(lora) & cs < 1.405), 0, 1)
  detach(data)
  factor (res, labels = c("glaucoma", "normal"))
}
fit <- inclass(formula.indirect, pFUN = list(list(model = lm)), 
  cFUN = classify, data = GlaucomaMVF)


###################################################
### code chunk number 8: print.indirect
###################################################
print(fit)


###################################################
### code chunk number 9: predict.indirect
###################################################
predict(object = fit, newdata = GlaucomaMVF[c(1:3, 86:88),])


###################################################
### code chunk number 10: bagging.indirect
###################################################
mypredict.rpart <- function(object, newdata) {
  RES <- predict(object, newdata)
  RET <- rep(NA, nrow(newdata))
  NAMES <- rownames(newdata)
  RET[NAMES %in% names(RES)] <- RES[NAMES[NAMES %in% names(RES)]]
  RET
}
fit <- inbagg(formula.indirect, pFUN = list(list(model = rpart, predict =
mypredict.rpart)), cFUN = classify, nbagg = 25,  data = GlaucomaMVF)


###################################################
### code chunk number 11: plda
###################################################
mypredict.lda <- function(object, newdata){    
  predict(object, newdata = newdata)$class
}


###################################################
### code chunk number 12: cvlda
###################################################
errorest(Class ~ ., data= GlaucomaM, 
  model=lda, estimator = "cv", predict= mypredict.lda)


###################################################
### code chunk number 13: cvindirect
###################################################
errorest(formula.indirect, 
  data = GlaucomaMVF, model = inclass, 
  estimator = "632plus", 
  pFUN = list(list(model = lm)), cFUN = classify)


###################################################
### code chunk number 14: varsel-def
###################################################
mymod <- function(formula, data, level=0.05) {
  # select all predictors that are associated with an
  # univariate t.test p-value of less that level
  sel <- which(lapply(data, function(x) {
    if (!is.numeric(x))
      return(1)
    else 
     return(t.test(x ~ data$Class)$p.value)
    }) < level)
  # make sure that the response is still there
  sel <- c(which(colnames(data) %in% "Class"), sel)
  # compute a LDA using the selected predictors only
  mod <- lda(formula , data=data[,sel]) 
  # and return a function for prediction
  function(newdata) {
    predict(mod, newdata=newdata[,sel])$class
  }
}


###################################################
### code chunk number 15: varsel-comp
###################################################
errorest(Class ~ . , data=GlaucomaM, model=mymod, estimator = "cv",
est.para=control.errorest(k=5))


