## ----loadLibs, include = FALSE-----------------------
library(MASS)
library(caret)
library(mlbench)
data(Sonar)
library(pls)
library(knitr)
opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  digits = 3,
  tidy = FALSE,
  background = "#FFFF00",
  fig.align = 'center',
  warning = FALSE,
  message = FALSE
  )
options(width = 55, digits = 3)
theme_set(theme_bw())

getInfo <- function(what = "Suggests") {
  text <- packageDescription("caret")[what][[1]]
  text <- gsub("\n", ", ", text, fixed = TRUE)
  text <- gsub(">=", "$\\\\ge$", text, fixed = TRUE)
  eachPkg <- strsplit(text, ", ", fixed = TRUE)[[1]]
  eachPkg <- gsub(",", "", eachPkg, fixed = TRUE)
  #out <- paste("\\\**", eachPkg[order(tolower(eachPkg))], "}", sep = "")
  #paste(out, collapse = ", ")
  length(eachPkg)
}

## ----install, eval = FALSE---------------------------
#  install.packages("caret", dependencies = c("Depends", "Suggests"))

## ----echo = FALSE, out.width = '80%'-----------------
knitr::include_graphics("train_algo.png")

## ----SonarSplit--------------------------------------
library(caret)
library(mlbench)
data(Sonar)

set.seed(107)
inTrain <- createDataPartition(
  y = Sonar$Class,
  ## the outcome data are needed
  p = .75,
  ## The percentage of data in the
  ## training set
  list = FALSE
)
## The format of the results

## The output is a set of integers for the rows of Sonar
## that belong in the training set.
str(inTrain)

## ----SonarDatasets-----------------------------------
training <- Sonar[ inTrain,]
testing  <- Sonar[-inTrain,]

nrow(training)
nrow(testing)

## ----plsTune1, eval = FALSE--------------------------
#  plsFit <- train(
#    Class ~ .,
#    data = training,
#    method = "pls",
#    ## Center and scale the predictors for the training
#    ## set and all future samples.
#    preProc = c("center", "scale")
#  )

## ----pls_fit-----------------------------------------
ctrl <- trainControl(
  method = "repeatedcv", 
  repeats = 3,
  classProbs = TRUE, 
  summaryFunction = twoClassSummary
)

set.seed(123)
plsFit <- train(
  Class ~ .,
  data = training,
  method = "pls",
  preProc = c("center", "scale"),
  tuneLength = 15,
  trControl = ctrl,
  metric = "ROC"
)
plsFit

## ----pls-plot----------------------------------------
ggplot(plsFit)

## ----plsPred-----------------------------------------
plsClasses <- predict(plsFit, newdata = testing)
str(plsClasses)
plsProbs <- predict(plsFit, newdata = testing, type = "prob")
head(plsProbs)

## ----plsCM-------------------------------------------
confusionMatrix(data = plsClasses, testing$Class)

## ----rdaFit------------------------------------------
## To illustrate, a custom grid is used
rdaGrid = data.frame(gamma = (0:4)/4, lambda = 3/4)
set.seed(123)
rdaFit <- train(
  Class ~ .,
  data = training,
  method = "rda",
  tuneGrid = rdaGrid,
  trControl = ctrl,
  metric = "ROC"
)
rdaFit
rdaClasses <- predict(rdaFit, newdata = testing)
confusionMatrix(rdaClasses, testing$Class)

## ----rs----------------------------------------------
resamps <- resamples(list(pls = plsFit, rda = rdaFit))
summary(resamps)

## ----BA----------------------------------------------
xyplot(resamps, what = "BlandAltman")

## ----diffs-------------------------------------------
diffs <- diff(resamps)
summary(diffs)

