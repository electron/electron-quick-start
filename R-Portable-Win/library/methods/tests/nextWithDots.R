setClass("A")
setClass("B", contains = c("array", "A"))
a = array(1:12, c(2,3,4))
bb = new("B", a)
a2 = array(8:1, rep(2,3))
stopifnot(identical(initialize(bb, a2), new("B",a2)))

withDots <- function(x, ...) names(list(...))

setGeneric("withDots")

setClass("C", representation(x="numeric", y="character"))

setMethod("withDots", "C", function(x, ...)
          callNextMethod()
          )
stopifnot(identical(withDots(1, a=1, b=2), withDots(new("C"), a=1, b=2)))
removeClass("C"); removeClass("B"); removeClass("A")
removeGeneric("withDots")
rm(a, bb, a2)
