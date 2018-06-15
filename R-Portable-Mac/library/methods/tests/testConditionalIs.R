setClass("maybe")

setClass("A", representation(x = "numeric"))

setIs("A", "maybe",
      test = function(object)length(object@x) >= 1 && object@x[[1]] > 0,
      coerce = function(from)from,
      replace = function(from, value)
      stop("meaningless to replace the \"maybe\" part of an object"))

aa <- new("A", x=1)

setGeneric("ff", function(x)"default ff")
## test that the setGeneric() call created the generic & default
stopifnot(is(ff, "standardGeneric"),
          identical(body(getMethod("ff","ANY")), "default ff"))

ffMaybe <- function(x) "ff maybe method"
setMethod("ff", "maybe", ffMaybe)

aa2 <- new("A", x = -1) # condition not TRUE
stopifnot(identical(ff(aa),  "default ff"),
	  identical(ff(aa2), "default ff"))# failed in R 2.11.0

## a method to test the condition
setMethod("ff", "A",
	  function(x) {
	      if(is(x, "maybe"))
		  ffMaybe(x)
	      else
		  callNextMethod()
	  })
stopifnot(identical(ff(aa), "ff maybe method"),
          identical(ff(aa2), "default ff"))

removeClass("A")
removeClass("maybe")
removeGeneric("ff")
