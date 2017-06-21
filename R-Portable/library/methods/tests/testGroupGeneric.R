## reset inherited methods of group members
## (contributed by Martin Morgan, 2011-2-9)
setClass("A", representation("numeric"))
a <- new("A")

setMethod("Logic", c("A", "A"), function(e1, e2) FALSE)
res0 <- a & a                           # inherit &,A,A-method
setMethod("Logic", c("A", "A"), function(e1, e2) TRUE)
stopifnot(a & a)

removeMethod("Logic", c("A", "A"))
stopifnot(logical() == a & a)

removeClass("A")

### Find inherited group methods:
if(require(Matrix)) { ## , lib.loc = .Library
    sm <- selectMethod("-", c("dgCMatrix", "numeric"))# direct match with "Arith"
    s2 <- selectMethod("-", c("dtCMatrix", "numeric"))# ambiguity match with "Arith"
    stopifnot(sm@generic == "Arith", s2@generic == "Arith")
}
## was not ok in R 2.14.x

## some tests of callGeneric().  It's reccommended for use with group generics
setGeneric("f1", signature=c("a"),
           function(..., a) standardGeneric("f1"))
setMethod("f1", c(a="ANY"), function(..., a) list(a=a, ...))
setMethod("f1", c(a="missing"), function(..., a) callGeneric(a=1, ...))
f2 <- function(b,c,d, a) {
    if (missing(a))
        f1(b=b, c=c, d=d)
    else
        f1(a=a, b=b, c=c, d=d)
}

## use callGeneric both directly (f1) and indirectly (f2)
## Latter failed pre rev. 66408; Bug ID 15937
stopifnot(identical(c(1,2,3,4), as.vector(unlist(f1(2,3,4)))))
stopifnot(identical(c(1,2,3,4), as.vector(unlist(f2(2,3,4)))))

## test callGeneric() with no arguments.  This is rarely used
## because nearly all applications use the groups Ops, etc.
## whose members are primitives => must supply args to callGeneric

Hide <- setClass("Hide", slots = c(data = "vector"), contains = "vector")

unhide <- function(obj)
    obj@data

setGeneric("%p%", function(e1, e2) e1 + e2, group = "Ops2")
setGeneric("%gt%", function(e1, e2) e1 > e2, group = "Ops2")

setGroupGeneric("Ops2", function(e1,e2)NULL, knownMembers = c("%p%","%gt%"))

setMethod("Ops2", c("Hide", "Hide"),
          function(e1, e2) {
              e1 <- unhide(e1)
              e2 <- unhide(e2)
              callGeneric()
          })

setMethod("Ops2", c("Hide", "vector"),
          function(e1, e2) {
              e1 <- unhide(e1)
              callGeneric()
          })
setMethod("Ops2", c("vector", "Hide"),
          function(e1, e2) {
              e2 <- unhide(e2)
              callGeneric()
          })

h1 <- Hide(data = 1:10)
h2 <- Hide(data = (1:10)*.5+ 0.5)

stopifnot(all.equal(h1%p%h2, h1@data + h2@data))
stopifnot(all.equal(h1 %gt% h2, h1@data > h2@data))

removeClass("Hide")
for(g in c("f1", "%p%", "%gt%", "Ops2"))
    removeGeneric(g)


