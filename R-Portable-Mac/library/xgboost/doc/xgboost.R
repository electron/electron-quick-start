## ----knitropts,echo=FALSE,message=FALSE----------------------------------
if (require('knitr')) opts_chunk$set(fig.width = 5, fig.height = 5, fig.align = 'center', tidy = FALSE, warning = FALSE, cache = TRUE)

## ----prelim,echo=FALSE---------------------------------------------------
xgboost.version <- packageDescription("xgboost")$Version


## ----Training and prediction with iris-----------------------------------
library(xgboost)
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test
bst <- xgboost(data = train$data, label = train$label, max_depth = 2, eta = 1, 
               nrounds = 2, objective = "binary:logistic")
xgb.save(bst, 'model.save')
bst = xgb.load('model.save')
pred <- predict(bst, test$data)

## ----Dump Model----------------------------------------------------------
xgb.dump(bst, 'model.dump')

## ----xgb.DMatrix---------------------------------------------------------
dtrain <- xgb.DMatrix(train$data, label = train$label)
class(dtrain)
head(getinfo(dtrain,'label'))

## ----save model----------------------------------------------------------
xgb.DMatrix.save(dtrain, 'xgb.DMatrix')
dtrain = xgb.DMatrix('xgb.DMatrix')

## ----Customized loss function--------------------------------------------
logregobj <- function(preds, dtrain) {
   labels <- getinfo(dtrain, "label")
   preds <- 1/(1 + exp(-preds))
   grad <- preds - labels
   hess <- preds * (1 - preds)
   return(list(grad = grad, hess = hess))
}

evalerror <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  err <- sqrt(mean((preds-labels)^2))
  return(list(metric = "MSE", value = err))
}

dtest <- xgb.DMatrix(test$data, label = test$label)
watchlist <- list(eval = dtest, train = dtrain)
param <- list(max_depth = 2, eta = 1, silent = 1)

bst <- xgb.train(param, dtrain, nrounds = 2, watchlist, logregobj, evalerror, maximize = FALSE)

## ----Temp file cleaning, include=FALSE-----------------------------------
file.remove("xgb.DMatrix")
file.remove("model.dump")
file.remove("model.save")

