## ----installGithub, eval=FALSE-------------------------------------------
#  install.packages("drat", repos="https://cran.rstudio.com")
#  drat:::addRepo("dmlc")
#  install.packages("xgboost", repos="http://dmlc.ml/drat/", type = "source")

## ---- eval=FALSE---------------------------------------------------------
#  install.packages("xgboost")

## ----libLoading, results='hold', message=F, warning=F--------------------
require(xgboost)

## ----datasetLoading, results='hold', message=F, warning=F----------------
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test

## ----dataList, message=F, warning=F--------------------------------------
str(train)

## ----dataSize, message=F, warning=F--------------------------------------
dim(train$data)
dim(test$data)

## ----dataClass, message=F, warning=F-------------------------------------
class(train$data)[1]
class(train$label)

## ----trainingSparse, message=F, warning=F--------------------------------
bstSparse <- xgboost(data = train$data, label = train$label, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic")

## ----trainingDense, message=F, warning=F---------------------------------
bstDense <- xgboost(data = as.matrix(train$data), label = train$label, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic")

## ----trainingDmatrix, message=F, warning=F-------------------------------
dtrain <- xgb.DMatrix(data = train$data, label = train$label)
bstDMatrix <- xgboost(data = dtrain, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic")

## ----trainingVerbose0, message=T, warning=F------------------------------
# verbose = 0, no message
bst <- xgboost(data = dtrain, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic", verbose = 0)

## ----trainingVerbose1, message=T, warning=F------------------------------
# verbose = 1, print evaluation metric
bst <- xgboost(data = dtrain, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic", verbose = 1)

## ----trainingVerbose2, message=T, warning=F------------------------------
# verbose = 2, also print information about tree
bst <- xgboost(data = dtrain, max_depth = 2, eta = 1, nthread = 2, nrounds = 2, objective = "binary:logistic", verbose = 2)

## ----predicting, message=F, warning=F------------------------------------
pred <- predict(bst, test$data)

# size of the prediction vector
print(length(pred))

# limit display of predictions to the first 10
print(head(pred))

## ----predictingTest, message=F, warning=F--------------------------------
prediction <- as.numeric(pred > 0.5)
print(head(prediction))

## ----predictingAverageError, message=F, warning=F------------------------
err <- mean(as.numeric(pred > 0.5) != test$label)
print(paste("test-error=", err))

## ----DMatrix, message=F, warning=F---------------------------------------
dtrain <- xgb.DMatrix(data = train$data, label=train$label)
dtest <- xgb.DMatrix(data = test$data, label=test$label)

## ----watchlist, message=F, warning=F-------------------------------------
watchlist <- list(train=dtrain, test=dtest)

bst <- xgb.train(data=dtrain, max_depth=2, eta=1, nthread = 2, nrounds=2, watchlist=watchlist, objective = "binary:logistic")

## ----watchlist2, message=F, warning=F------------------------------------
bst <- xgb.train(data=dtrain, max_depth=2, eta=1, nthread = 2, nrounds=2, watchlist=watchlist, eval_metric = "error", eval_metric = "logloss", objective = "binary:logistic")

## ----linearBoosting, message=F, warning=F--------------------------------
bst <- xgb.train(data=dtrain, booster = "gblinear", max_depth=2, nthread = 2, nrounds=2, watchlist=watchlist, eval_metric = "error", eval_metric = "logloss", objective = "binary:logistic")

## ----DMatrixSave, message=F, warning=F-----------------------------------
xgb.DMatrix.save(dtrain, "dtrain.buffer")
# to load it in, simply call xgb.DMatrix
dtrain2 <- xgb.DMatrix("dtrain.buffer")
bst <- xgb.train(data=dtrain2, max_depth=2, eta=1, nthread = 2, nrounds=2, watchlist=watchlist, objective = "binary:logistic")

## ----DMatrixDel, include=FALSE-------------------------------------------
file.remove("dtrain.buffer")

## ----getinfo, message=F, warning=F---------------------------------------
label = getinfo(dtest, "label")
pred <- predict(bst, dtest)
err <- as.numeric(sum(as.integer(pred > 0.5) != label))/length(label)
print(paste("test-error=", err))

## ----dump, message=T, warning=F------------------------------------------
xgb.dump(bst, with_stats = T)

## ----saveModel, message=F, warning=F-------------------------------------
# save model to binary local file
xgb.save(bst, "xgboost.model")

## ----loadModel, message=F, warning=F-------------------------------------
# load binary model to R
bst2 <- xgb.load("xgboost.model")
pred2 <- predict(bst2, test$data)

# And now the test
print(paste("sum(abs(pred2-pred))=", sum(abs(pred2-pred))))

## ----clean, include=FALSE------------------------------------------------
# delete the created model
file.remove("./xgboost.model")

## ----saveLoadRBinVectorModel, message=F, warning=F-----------------------
# save model to R's raw vector
rawVec <- xgb.save.raw(bst)

# print class
print(class(rawVec))

# load binary model to R
bst3 <- xgb.load(rawVec)
pred3 <- predict(bst3, test$data)

# pred2 should be identical to pred
print(paste("sum(abs(pred3-pred))=", sum(abs(pred2-pred))))

