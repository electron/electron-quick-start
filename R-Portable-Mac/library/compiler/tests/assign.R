##
## Assignment tests
##

library(compiler)

## Local assignment

### symbol
x <- 1
eval(compile(quote(x <- 2)))
stopifnot(x == 2)

### closure
`f<-` <- function(x, i, value) { x[i] <- value; x }
x <- 1
eval(compile(quote(f(x, 1) <- 2)))
stopifnot(x == 2)

### SPECIAL
`f<-` <- `[<-`
x <- 1
eval(compile(quote(f(x, 1) <- 2)))
stopifnot(x == 2)

### BUILTIN
`f<-` <- `names<-`
x <- 1
eval(compile(quote(f(x) <- "foo")))
stopifnot(identical(x, structure(1, names = "foo")))

## Super assignment

### symbol
x <- 1
eval(compile(quote((function() x <<- 2)())))
stopifnot(x == 2)

### closure
`f<-` <- function(x, i, value) { x[i] <- value; x }
x <- 1
eval(compile(quote((function() f(x, 1) <<- 2)())))
stopifnot(x == 2)

### SPECIAL
`f<-` <- `[<-`
x <- 1
eval(compile(quote((function() f(x, 1) <<- 2)())))
stopifnot(x == 2)

### BUILTIN
`f<-` <- `names<-`
x <- 1
eval(compile(quote((function() f(x) <<- "foo")())))
stopifnot(identical(x, structure(1, names = "foo")))

## Dollargets

### Default
x <- list(a = 1)
eval(compile(quote(x$a <- 2)))
stopifnot(identical(x, list(a = 2)))

### Dispatch
x <- structure(list(a = 1), class = "foo")
y <- NULL
`$<-.foo` <- function(x, tag, value) { y <<- list(tag, value); x }
eval(compile(quote(x$a <- 2)))
stopifnot(identical(y, list("a", 2)))

## Subassign

### Default
x <- 1
eval(compile(quote(x[1] <- 2)))
stopifnot(identical(x, 2))

### Dispatching
x <- structure(list(NULL), class = "foo")
y <- NULL
`[<-.foo` <- function(x, k, value) { y <<- rep(value, k); x }
eval(compile(quote(x[2] <- 3)))
stopifnot(identical(y, rep(3, 2)))

#### Missing args
x <- c(1, 2, 3)
eval(compile(quote(x[] <- c(4, 5, 6))))
stopifnot(identical(x, c(4, 5, 6)))

### Named args
x <- structure(list(NULL), class = "foo")
y <- NULL
`[<-.foo` <- function(x, k, value) { y <<- names(sys.call()[-1]); x }
eval(compile(quote(x[k = 2] <- 3)))
stopifnot(identical(y, c("", "k", "value")))

## Subassign2

### Default
x <- list(NULL)
eval(compile(quote(x[[1]] <- list(1))))
stopifnot(identical(x, list(list(1))))

### Dispatching
x <- structure(list(), class = "foo")
y <- 1
`[[<-.foo` <- function(x, i, value) { y[i] <<- value; x }
eval(compile(quote(x[[1]] <- 3)))
stopifnot(identical(y, 3))

## Nested assignments
x <- list(a = list(b = 1))
eval(compile(quote(x$a$b <- 2)))
stopifnot(identical(x, list(a = list(b = 2))))

x <- list(1, list(2))
eval(compile(quote(x[[1]][] <- 2)))
eval(compile(quote(x[[2]][[1]] <- 3)))
stopifnot(identical(x, list(2, list(3))))


## checkAssign
checkAssign <- compiler:::checkAssign
cenv <- compiler:::makeCenv(.GlobalEnv)
cntxt <- compiler:::make.toplevelContext(cenv, list(suppressAll = TRUE))
stopifnot(identical(checkAssign(quote(x <- 1), cntxt), TRUE))
stopifnot(identical(checkAssign(quote("x" <- 1), cntxt), TRUE))
stopifnot(identical(checkAssign(quote(3 <- 1), cntxt), FALSE))
stopifnot(identical(checkAssign(quote(f(x) <- 1), cntxt), TRUE))
stopifnot(identical(checkAssign(quote((f())(x) <- 1), cntxt), FALSE))
stopifnot(identical(checkAssign(quote(f(g(x)) <- 1), cntxt), TRUE))
stopifnot(identical(checkAssign(quote(f(g("x")) <- 1), cntxt), FALSE))


## flattenPlace
flattenPlace <- compiler:::flattenPlace
stopifnot(identical(flattenPlace(quote(f(g(h(x, k), j), i)))$places,
                    list(quote(f(`*tmp*`, i)),
                         quote(g(`*tmp*`, j)),
                         quote(h(`*tmp*`, k)))))
stopifnot(identical(flattenPlace(quote(f(g(h(x, k), j), i)))$origplaces,
                    list(quote(f(g(h(x, k), j), i)),
                         quote(g(h(x, k), j)),
                         quote(h(x, k)))))

## getAssignFun
getAssignFun <- compiler:::getAssignFun
stopifnot(identical(getAssignFun(quote(f)), quote(`f<-`)))
stopifnot(identical(getAssignFun("f"), NULL))
stopifnot(identical(getAssignFun(quote(f(x))), NULL))
stopifnot(identical(getAssignFun(quote(base::diag)), quote(base::`diag<-`)))
stopifnot(identical(getAssignFun(quote(base:::diag)), quote(base:::`diag<-`)))
