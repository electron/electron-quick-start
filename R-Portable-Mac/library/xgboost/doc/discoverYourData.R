## ----libLoading, results='hold', message=F, warning=F--------------------
require(xgboost)
require(Matrix)
require(data.table)
if (!require('vcd')) install.packages('vcd')

## ---- results='hide'-----------------------------------------------------
data(Arthritis)
df <- data.table(Arthritis, keep.rownames = F)

## ------------------------------------------------------------------------
head(df)

## ------------------------------------------------------------------------
str(df)

## ------------------------------------------------------------------------
head(df[,AgeDiscret := as.factor(round(Age/10,0))])

## ------------------------------------------------------------------------
head(df[,AgeCat:= as.factor(ifelse(Age > 30, "Old", "Young"))])

## ---- results='hide'-----------------------------------------------------
df[,ID:=NULL]

## ------------------------------------------------------------------------
levels(df[,Treatment])

## ---- warning=FALSE,message=FALSE----------------------------------------
sparse_matrix <- sparse.model.matrix(Improved~.-1, data = df)
head(sparse_matrix)

## ------------------------------------------------------------------------
output_vector = df[,Improved] == "Marked"

## ------------------------------------------------------------------------
bst <- xgboost(data = sparse_matrix, label = output_vector, max_depth = 4,
               eta = 1, nthread = 2, nrounds = 10,objective = "binary:logistic")


## ------------------------------------------------------------------------
importance <- xgb.importance(feature_names = colnames(sparse_matrix), model = bst)
head(importance)

## ------------------------------------------------------------------------
importanceRaw <- xgb.importance(feature_names = colnames(sparse_matrix), model = bst, data = sparse_matrix, label = output_vector)

# Cleaning for better display
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]

head(importanceClean)

## ---- fig.width=8, fig.height=5, fig.align='center'----------------------
xgb.plot.importance(importance_matrix = importance)

## ---- warning=FALSE, message=FALSE---------------------------------------
c2 <- chisq.test(df$Age, output_vector)
print(c2)

## ---- warning=FALSE, message=FALSE---------------------------------------
c2 <- chisq.test(df$AgeDiscret, output_vector)
print(c2)

## ---- warning=FALSE, message=FALSE---------------------------------------
c2 <- chisq.test(df$AgeCat, output_vector)
print(c2)

## ---- warning=FALSE, message=FALSE---------------------------------------
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test

#Random Forest™ - 1000 trees
bst <- xgboost(data = train$data, label = train$label, max_depth = 4, num_parallel_tree = 1000, subsample = 0.5, colsample_bytree =0.5, nrounds = 1, objective = "binary:logistic")

#Boosting - 3 rounds
bst <- xgboost(data = train$data, label = train$label, max_depth = 4, nrounds = 3, objective = "binary:logistic")

