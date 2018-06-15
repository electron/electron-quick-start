## ----set, include=FALSE--------------------------------------------------
library(knitr)
opts_chunk$set(fig.path='Figures/list', debug=TRUE, echo=TRUE)
opts_chunk$set(out.width='0.9\\textwidth')

## ----package, results='asis'------------------------------
library(xtable)
options(xtable.floating = FALSE)
options(xtable.timestamp = "")
options(width = 60)

## ----data-------------------------------------------------
require(xtable)
data(mtcars)
mtcars <- mtcars[, 1:6]
mtcarsList <- split(mtcars, f = mtcars$cyl)
### Reduce the size of the list elements
mtcarsList[[1]] <- mtcarsList[[1]][1,]
mtcarsList[[2]] <- mtcarsList[[2]][1:2,]
mtcarsList[[3]] <- mtcarsList[[3]][1:3,]
attr(mtcarsList, "subheadings") <- paste0("Number of cylinders = ",
                                          names(mtcarsList))
attr(mtcarsList, "message") <- c("Line 1 of Message",
                                 "Line 2 of Message")
str(mtcarsList)
attributes(mtcarsList)

## ----xtablelist-------------------------------------------
xList <- xtableList(mtcarsList)
str(xList)

## ----xtablelist1------------------------------------------
xList1 <- xtableList(mtcarsList, digits = c(0,2,0,0,0,1,2))
str(xList1)

## ----xtablelist2------------------------------------------
xList2 <- xtableList(mtcarsList, digits = c(0,2,0,0,0,1,2),
                            caption = "Caption to List",
                            label = "tbl:xtableList")
str(xList2)

## ----xtablelist3------------------------------------------
attr(mtcarsList, "subheadings") <- NULL
xList3 <- xtableList(mtcarsList)
str(xList3)

## ----xtablelist4------------------------------------------
attr(mtcarsList, "message") <- NULL
xList4 <- xtableList(mtcarsList)
str(xList4)

## ----singledefault, results='asis'------------------------
print.xtableList(xList)

## ----singlebooktabs, results='asis'-----------------------
print.xtableList(xList, booktabs = TRUE)

## ----singlebooktabs1, results='asis'----------------------
print.xtableList(xList1, booktabs = TRUE)

## ----sanitize---------------------------------------------
large <- function(x){
  paste0('{\\Large{\\bfseries ', x, '}}')
}
italic <- function(x){
  paste0('{\\emph{ ', x, '}}')
}
bold <- function(x){
  paste0('{\\bfseries ', x, '}')
}
red <- function(x){
  paste0('{\\color{red} ', x, '}')
}

## ----sanitizesingle, results='asis'-----------------------
print.xtableList(xList,
                 sanitize.rownames.function = italic,
                 sanitize.colnames.function = large,
                 sanitize.subheadings.function = bold,
                 sanitize.message.function = red,
                 booktabs = TRUE)

## ----singlecaption, results='asis'------------------------
print.xtableList(xList2, floating = TRUE)

## ----singlerotated, results='asis'------------------------
print.xtableList(xList, rotate.colnames = TRUE)

## ----nosubheadings, results='asis'------------------------
print.xtableList(xList3)

## ----nomessage, results='asis'----------------------------
print.xtableList(xList4)

## ----multipledefault, results='asis'----------------------
print.xtableList(xList, colnames.format = "multiple")

## ----multiplebooktabs, results='asis'---------------------
print.xtableList(xList, colnames.format = "multiple",
                 booktabs = TRUE)

## ----sanitizemultiple, results='asis'---------------------
print.xtableList(xList, colnames.format = "multiple",
                 sanitize.rownames.function = italic,
                 sanitize.colnames.function = large,
                 sanitize.subheadings.function = bold,
                 sanitize.message.function = red,                 
                 booktabs = TRUE)

## ----multiplecaption, results='asis'----------------------
print.xtableList(xList2, colnames.format = "multiple",
                 floating = TRUE)

## ----multiplerotated, results='asis'----------------------
print.xtableList(xList, colnames.format = "multiple",
                 rotate.colnames = TRUE)

## ----multiplenosubheadings, results='asis'----------------
print.xtableList(xList3, colnames.format = "multiple")

## ----multiplenomessage, results='asis'--------------------
print.xtableList(xList4, colnames.format = "multiple")

## ----lsmeans----------------------------------------------
library(lsmeans)
warp.lm <- lm(breaks ~ wool*tension, data = warpbreaks)
warp.lsm <- lsmeans(warp.lm, ~ tension | wool)
warp.sum <- summary(warp.lsm, adjust = "mvt")
warp.xtblList <- xtableLSMeans(warp.sum, digits = c(0,0,2,2,0,2,2))
str(warp.xtblList)

## ----lsmeansstr-------------------------------------------
print.xtableList(warp.xtblList, colnames.format = "multiple",
                 include.rownames = FALSE)

## ----lsmeanstable, results='asis'-------------------------
print.xtableList(warp.xtblList, colnames.format = "multiple",
                 include.rownames = FALSE)

## ----lsmeansbooktabs, results='asis'----------------------
print.xtableList(warp.xtblList, colnames.format = "multiple",
                 booktabs = TRUE,
                 include.rownames = FALSE)

