## Tests for handling classes with same name & different package slots
## First:  Can we define the classes and get the separate definitions
## from the appropriate namespace or from the package slot in class(x)?
if(!require(Matrix)) q()

## from: example(chol)
sy2 <- new("dsyMatrix", Dim = as.integer(c(2,2)), x = c(14, NA,32,77))
c2 <- chol(sy2)

clM <- getClass("Cholesky")

setClass("Cholesky", contains = "numeric", representation(size = "integer"))

clG <- getClass("Cholesky", where = .GlobalEnv)

stopifnot(identical(getClass("Cholesky", where = asNamespace("Matrix")),
                    clM))

stopifnot(identical(getClass(class(c2)), clM))

stopifnot(identical(evalq(getClass("Cholesky"), asNamespace("Matrix")),
                    clM))
stopifnot(identical(getClass("Cholesky"), clG))

## Second:  tests of methods defined for the same generic
## (NOT YET!)

## Related: retaining package slots in methods signatures (reported by Martin Morgan)
setClass("A")
setGeneric("bar", function(x, y) standardGeneric("bar"))
setMethod(bar, signature(x="A", y="A"), function(x, y) {})
setMethod(bar, signature(x="A", y="ANY"), function(x, y) {})

## tests one use of .matchSigLength
stopifnot(all(nzchar(getMethod("bar", signature(x="A", y="ANY"))@target@package)))
