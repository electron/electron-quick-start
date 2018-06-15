#### Testing  UseMethod() and even more NextMethod()
#### -------------------- 
#### i.e.,  S3 methods *only*. For S4, see  reg-S4.R
##                                          ~~~~~~~~

###-- Group methods

## previous versions used print() and hit an auto-printing bug.

### Arithmetic "Ops" :
">.bar" <- function(...) {cat("using >.bar\n"); FALSE}
">.foo" <- function(...) {cat("using >.foo\n"); TRUE}
Ops.foo <- function(...) {
    cat("using Ops.foo\n")
    NextMethod()
}
Ops.bar <- function(...) {
    cat("using Ops.bar\n")
    TRUE
}

x <- 2:4 ; class(x) <- c("foo", "bar")
y <- 4:2 ; class(y) <- c("bar", "foo")

## The next 4 give a warning each about incompatible methods:
x > y
y < x # should be the same (warning msg not, however)
x == y
x <= y

x > 3 ##[1] ">.foo"

rm(list=">.foo")
x > 3 #-> "Ops.foo" and ">.bar"



### ------------  was ./mode-methods.R till R ver. 1.0.x ----------------

###-- Using Method Dispatch on "mode" etc :
## Tests S3 dispatch with the class attr forced to be data.class
## Not very relevant when S4 methods are around, but kept for historical interest
abc <- function(x, ...) {
    cat("abc: Before dispatching; x has class `", class(x), "':", sep="")
    str(x)
    UseMethod("abc", x) ## UseMethod("abc") (as in S) fails
}

abc.default <- function(x, ...) sys.call()

"abc.(" <- function(x)
    cat("'(' method of abc:", deparse(sys.call(sys.parent())),"\n")
abc.expression <- function(x)
    cat("'expression' method of abc:", deparse(sys.call(sys.parent())),"\n")

abc(1)
e0 <- expression((x))
e1 <- expression(sin(x))
abc(e0)
abc(e1)
abc(e0[[1]])
abc(e1[[1]])
