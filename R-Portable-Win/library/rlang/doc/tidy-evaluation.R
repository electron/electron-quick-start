## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library("rlang")

## ---- eval = FALSE-------------------------------------------------------
#  # Taking an expression:
#  dplyr::mutate(mtcars, cyl2 = cyl * 2)
#  
#  # Taking a value:
#  var <- mtcars$cyl * 2
#  dplyr::mutate(mtcars, cyl2 = !! var)

## ---- eval = FALSE-------------------------------------------------------
#  # Taking a symbol:
#  dplyr::select(mtcars, cyl)
#  
#  # Taking an unquoted symbol:
#  var <- quote(sym)
#  dplyr::select(mtcars, !! var)

## ---- eval = FALSE-------------------------------------------------------
#  # Taking a column position:
#  dplyr::select(mtcars, 2)
#  
#  # Taking an unquoted column position:
#  var <- 2
#  dplyr::select(mtcars, !! var)

