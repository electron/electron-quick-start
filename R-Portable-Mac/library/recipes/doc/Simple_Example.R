## ----ex_setup, include=FALSE---------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  digits = 3,
  collapse = TRUE,
  comment = "#>"
  )
options(digits = 3)

## ----data----------------------------------------------------------------
library(recipes)
library(caret)
data(segmentationData)

seg_train <- segmentationData %>% 
  filter(Case == "Train") %>% 
  select(-Case, -Cell)
seg_test  <- segmentationData %>% 
  filter(Case == "Test")  %>% 
  select(-Case, -Cell)

## ----first_rec-----------------------------------------------------------
rec_obj <- recipe(Class ~ ., data = seg_train)
rec_obj

## ----step_code, eval = FALSE---------------------------------------------
#  rec_obj <- step_name(rec_obj, arguments)    ## or
#  rec_obj <- rec_obj %>% step_name(arguments)

## ----center_scale--------------------------------------------------------
standardized <- rec_obj %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) 
standardized

## ----trained-------------------------------------------------------------
trained_rec <- prep(standardized, training = seg_train)

## ----apply---------------------------------------------------------------
train_data <- bake(trained_rec, newdata = seg_train)
test_data  <- bake(trained_rec, newdata = seg_test)

## ----tibbles-------------------------------------------------------------
class(test_data)
test_data

## ----pca-----------------------------------------------------------------
trained_rec <- trained_rec %>%
  step_pca(ends_with("Ch1"), contains("area"), num = 5)
trained_rec

## ----pca_training--------------------------------------------------------
trained_rec <- prep(trained_rec, training = seg_train)

## ----pca_bake------------------------------------------------------------
test_data  <- bake(trained_rec, newdata = seg_test, all_predictors())
names(test_data)

## ----step_list, echo = FALSE---------------------------------------------
grep("^step_", ls("package:recipes"), value = TRUE)

## ----check, eval = FALSE-------------------------------------------------
#  trained_rec <- trained_rec %>%
#    check_missing(contains("Inten"))

## ----check_list, echo = FALSE--------------------------------------------
grep("^check_", ls("package:recipes"), value = TRUE)

