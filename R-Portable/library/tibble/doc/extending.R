## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(tibble)

## ---- eval = FALSE-------------------------------------------------------
#  devtools::use_package("tibble")

## ------------------------------------------------------------------------
#' @export
foo <- function(x) {
  stopifnot(is.numeric(x))
  structure(x, class = "foo")
}

## ------------------------------------------------------------------------
type_sum(1)
type_sum(1:10)
type_sum(Sys.time())

## ------------------------------------------------------------------------
type_sum(foo(1:10))

## ------------------------------------------------------------------------
#' @export
type_sum.foo <- function(x, ...) {
  "foo"
}

type_sum(foo(1:10))

## ------------------------------------------------------------------------
obj_sum(1)
obj_sum(1:10)
obj_sum(Sys.time())
obj_sum(list(1:5))
obj_sum(list("a", "b", "c"))

## ------------------------------------------------------------------------
x <- as.POSIXlt(Sys.time() + c(0, 60, 3600)) 
str(unclass(x))

## ------------------------------------------------------------------------
x
length(x)
str(x)

## ------------------------------------------------------------------------
#' @export
obj_sum.POSIXlt <- function(x) {
  rep("POSIXlt", length(x))
}

