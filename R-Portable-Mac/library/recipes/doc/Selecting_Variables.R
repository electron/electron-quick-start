## ----ex_setup, include=FALSE---------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  digits = 3,
  collapse = TRUE,
  comment = "#>"
  )
options(digits = 3)

## ----credit--------------------------------------------------------------
library(recipes)
data("credit_data")
str(credit_data)

rec <- recipe(Status ~ Seniority + Time + Age + Records, data = credit_data)
rec

## ----var_info_orig-------------------------------------------------------
summary(rec, original = TRUE)

## ----dummy_1-------------------------------------------------------------
dummied <- rec %>% step_dummy(all_nominal())

## ----dummy_2-------------------------------------------------------------
dummied <- rec %>% step_dummy(Records) # or
dummied <- rec %>% step_dummy(all_nominal(), - Status) # or
dummied <- rec %>% step_dummy(all_nominal(), - all_outcomes()) 

## ----dummy_3-------------------------------------------------------------
dummied <- prep(dummied, training = credit_data)
with_dummy <- bake(dummied, newdata = credit_data)
with_dummy

