## ----include=FALSE-------------------------------------------------------
library(knitr)

## ------------------------------------------------------------------------
library(xtable)
x <- matrix(rnorm(6), ncol = 2)
x.small <- xtable(x, label = 'tabsmall', caption = 'A margin table')

## ----results='asis'------------------------------------------------------
print(x.small,floating.environment='margintable',
      latex.environments = "",
      table.placement = NULL)

