## test (non-conditional) explicit inheritance
setClass("xy", representation(x="numeric", y="numeric"))

setIs("xy", "complex",
      coerce = function(from) complex(real = from@x, imaginary = from@y),
      replace = function(from, value) {
          from@x <- Re(value)
          from@y <- Im(value)
          from
      })

set.seed(124)
x1 <- rnorm(10)
y1 <- rnorm(10)
cc <- complex(real = x1, imaginary=y1)
xyc <- new("xy", x = x1, y = y1)
stopifnot(identical(cc, as(xyc, "complex")))
as(xyc, "complex") <- cc * 1i
stopifnot(identical(xyc, new("xy", x = -y1, y = x1)))

setGeneric("size", function(x)standardGeneric("size"))
## check that generic for size() was created w/o a default method
stopifnot(is(size, "standardGeneric"),
          is.null(selectMethod("size", "ANY",optional=TRUE)))

setMethod("size", "vector", function(x)length(x))

## class "xy" should inherit the vector method through complex
stopifnot(identical(size(xyc), length(x1)))
removeClass("xy")
removeGeneric("size")


### Related to  numeric <-> double <-> integer  proposals, end of 2015, on R-devel
myN   <- setClass("myN",   contains="numeric")
myNid <- setClass("myNid", contains="numeric", representation(id="character"))
NN <-    setClass("NN", representation(x="numeric"))

(m1 <- myN  (1:3))
(m2 <- myNid(1:3, id = "i3"))
tools::assertError(NN (1:3))# in all R versions
nn <- myN(2*pi)
##                     # current R  |  (not existing)
##                     # -----------|----------
class(getDataPart(m1)) # integer    |  numeric
class(getDataPart(m2)) # integer    |  numeric
## check for now [[conceivably, these *could* change !]] :
stopifnot(identical(getDataPart(m1), 1:3),
	  identical(getDataPart(m2), 1:3),
	  identical(S3Part(m1, strict=TRUE), 1:3),
	  identical(S3Part(m2, strict=TRUE), 1:3),
	  identical(2*pi, S3Part(nn, strict = TRUE)))

if(FALSE) ## --- all these fail still:
stopifnot(
    identical(as(1L, "numeric"), as.numeric(1L))
    ,
    identical(as(1L, "numeric"), 1.0)
    ,
    is.double(as(1L, "double"))
    )
