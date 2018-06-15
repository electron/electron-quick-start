## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  digits = 3,
  collapse = TRUE,
  comment = "#>"
  )
options(digits = 3)
library(recipes)

## ----iris-base-rec-------------------------------------------------------
library(recipes)
iris_rec <- recipe( ~ ., data = iris)
summary(iris_rec)

## ----iris-ref-cell-------------------------------------------------------
ref_cell <- iris_rec %>% 
  step_dummy(Species) %>%
  prep(training = iris, retain = TRUE)
summary(ref_cell)

# Get a row for each factor level
rows <- c(1, 51, 101)
juice(ref_cell, starts_with("Species"))[rows,]

## ----defaults------------------------------------------------------------
param <- getOption("contrasts")
param

## ----iris-helmert--------------------------------------------------------
# change it:
new_cont <- param
new_cont["unordered"] <- "contr.helmert"
options(contrasts = new_cont)

# now make dummy variables with new parameterization
helmert <- iris_rec %>% 
  step_dummy(Species) %>%
  prep(training = iris, retain = TRUE)
summary(helmert)

juice(helmert, starts_with("Species"))[rows,]

# Yuk; go back to the original method
options(contrasts = param)

## ----iris-2int-----------------------------------------------------------
iris_int <- iris_rec %>%
  step_interact( ~ Sepal.Width:Sepal.Length) %>%
  prep(training = iris, retain = TRUE)
summary(iris_int)

## ----mm-int--------------------------------------------------------------
model.matrix(~ Species*Sepal.Length, data = iris)[rows,]

## ----nope, eval = FALSE--------------------------------------------------
#  # Must I do this?
#  iris_rec %>%
#    step_interact( ~ Species_versicolor:Sepal.Length +
#                     Species_virginica:Sepal.Length)

## ----iris-sel------------------------------------------------------------
iris_int <- iris_rec %>% 
  step_dummy(Species) %>%
  step_interact( ~ starts_with("Species"):Sepal.Length) %>%
  prep(training = iris, retain = TRUE)
summary(iris_int)

## ----sel-input, eval = FALSE---------------------------------------------
#  starts_with("Species")

## ----sel-output, eval = FALSE--------------------------------------------
#  (Species_versicolor + Species_virginica)

## ----int-form------------------------------------------------------------
iris_int

## ----iris-dont-----------------------------------------------------------
iris_int <- iris_rec %>% 
  step_interact( ~ Species:Sepal.Length) %>%
  prep(training = iris, retain = TRUE)
summary(iris_int)

