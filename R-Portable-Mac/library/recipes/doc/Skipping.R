## ----ex_setup, include=FALSE---------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  digits = 3,
  collapse = TRUE,
  comment = "#>"
  )
options(digits = 3)
library(recipes)

## ----car-pca-------------------------------------------------------------
library(recipes)
car_recipe <- recipe(mpg ~ ., data = mtcars) %>%
  step_log(disp, skip = TRUE) %>%
  step_center(all_predictors()) %>%
  prep(training = mtcars, retain = TRUE)

# These *should* produce the same results (as they do for `hp`)
juice(car_recipe) %>% head() %>% select(disp, hp)
bake(car_recipe, newdata = mtcars) %>% head() %>% select(disp, hp)

