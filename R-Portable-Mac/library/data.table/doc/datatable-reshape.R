## ---- echo = FALSE, message = FALSE--------------------------------------
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)

## ----echo = FALSE---------------------------------------------------------------------------------
options(width = 100L)

## -------------------------------------------------------------------------------------------------
DT = fread("melt_default.csv")
DT
## dob stands for date of birth.

str(DT)

## -------------------------------------------------------------------------------------------------
DT.m1 = melt(DT, id.vars = c("family_id", "age_mother"),
                measure.vars = c("dob_child1", "dob_child2", "dob_child3"))
DT.m1
str(DT.m1)

## -------------------------------------------------------------------------------------------------
DT.m1 = melt(DT, measure.vars = c("dob_child1", "dob_child2", "dob_child3"),
               variable.name = "child", value.name = "dob")
DT.m1

## -------------------------------------------------------------------------------------------------
dcast(DT.m1, family_id + age_mother ~ child, value.var = "dob")

## -------------------------------------------------------------------------------------------------
dcast(DT.m1, family_id ~ ., fun.agg = function(x) sum(!is.na(x)), value.var = "dob")

## -------------------------------------------------------------------------------------------------
DT = fread("melt_enhanced.csv")
DT
## 1 = female, 2 = male

## -------------------------------------------------------------------------------------------------
DT.m1 = melt(DT, id = c("family_id", "age_mother"))
DT.m1[, c("variable", "child") := tstrsplit(variable, "_", fixed = TRUE)]
DT.c1 = dcast(DT.m1, family_id + age_mother + child ~ variable, value.var = "value")
DT.c1

str(DT.c1) ## gender column is character type now!

## -------------------------------------------------------------------------------------------------
colA = paste("dob_child", 1:3, sep = "")
colB = paste("gender_child", 1:3, sep = "")
DT.m2 = melt(DT, measure = list(colA, colB), value.name = c("dob", "gender"))
DT.m2

str(DT.m2) ## col type is preserved

## -------------------------------------------------------------------------------------------------
DT.m2 = melt(DT, measure = patterns("^dob", "^gender"), value.name = c("dob", "gender"))
DT.m2

## -------------------------------------------------------------------------------------------------
## new 'cast' functionality - multiple value.vars
DT.c2 = dcast(DT.m2, family_id + age_mother ~ variable, value.var = c("dob", "gender"))
DT.c2

