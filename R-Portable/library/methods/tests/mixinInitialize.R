setClass("A", representation(a="numeric"))

a1 <- new("A", a=1.5)
m1 <- as.matrix(1)

setClass("M", contains = "matrix", representation(fuzz = "numeric"))

set.seed(113)
f1 <- runif(3)

stopifnot(identical(as(new("M", 1:12, nrow = 3, fuzz = f1), "matrix"),
		    matrix(1:12, nrow=3)),
	  identical(as(new("M", 1:12, 3, fuzz = f1), "matrix"),
		    matrix(1:12, 3)),
	  identical(as(new("M", 1:12, ncol = 3, fuzz = f1), "matrix"),
		    matrix(1:12, ncol=3)))

setClass("B", contains = c("matrix", "A"))

stopifnot(## a new "B" element mixing two superclass objects
	  identical(new("B", m1, a1)@a, a1@a),
	  ## or not
	  identical(as(new("B", m1),"matrix"), m1),
	  ## or supplying a slot to override
	  identical(new("B", matrix(m1, nrow = 2), a1, a=pi)@a, pi))

## an extra level of inheritance
setClass("C", contains = "B", representation(c = "character"))
new("C", m1, c = "Testing")

## verify that validity tests work (PR#14284)
setValidity("B", function(object) {
    if(all(is.na(object@a) | (object@a > 0)))
      TRUE
    else
      "elements of slot \"a\" must be positive"
})

a2 <- new("A", a= c(NA,3, -1, 2))

## from the SoDA package on CRAN
muststop <- function(expr, silent = TRUE) {
    tryExpr <- substitute(tryCatch(expr, error=function(cond)cond))
    value <- eval.parent(tryExpr)
    if(inherits(value, "error")) {
        if(!silent)
          message("muststop reports: ", value)
        invisible(value)
    }
    else
      stop(gettextf("The expression  %s should have thrown an error, but instead returned an object of class \"%s\"",
           deparse(substitute(expr))[[1]], class(value)))
}

muststop(new("B", m1, a2))

removeClass("B")
removeClass("C")
removeClass("M")

## TODO:  make versions of above inheriting from "array" and "ts"

removeClass("A")

## removeClass() for a union where "matrix"/"array" is part:
setClassUnion("mn", c("matrix","numeric")); removeClass("mn")# gave "node stack overflow",
setClassUnion("an", c("array", "integer")); removeClass("an")#  (ditto)
setClassUnion("AM", c("array", "matrix"));  removeClass("AM")#  (ditto)
## as had "matrix" -> "array" -> "matrix" ... recursion

## and we want this to *still* work:
stopifnot(is(tryCatch(as(a3 <- array(1:24, 2:4), "matrix"), error=function(e)e),
	     "error"),
	  is(as(a2 <- array(1:12, 3:4), "matrix"),
	     "matrix"),
	  is(a2, "matrix"), is(a2, "array"), is(a3, "array"), !is(a3, "matrix"),
	  ## and yes, "for now":
	  identical(a2, matrix(1:12, 3)))

## subclassing a class that did not allow new() w/o extra args failed
## through version 3.1.1
setClass("BAR", slots = c(y="integer"))

setMethod("initialize", "BAR", function(.Object, Y) {.Object@y <- Y; .Object})

setClass("BAR3", contains = "BAR")
