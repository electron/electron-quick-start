####--- S4 Methods (and Classes)  --- see also ../src/library/methods/tests/
options(useFancyQuotes=FALSE)
require(methods)
assertError <- tools::assertError # "import"
##too fragile: showMethods(where = "package:methods")

## When this test comes too late, it fails too early in R <= 3.2.2
require(stats4)
detach("package:methods")
require("methods")
cc <- methods::getClassDef("standardGeneric")
cc ## (auto) print failed here, in R <= 3.2.2
stopifnot(.isMethodsDispatchOn()) ## was FALSE in R <= 3.2.2


## Needs cached primitive generic for '$'
new("envRefClass")# failed in R <= 3.2.0

##-- S4 classes with S3 slots [moved from ./reg-tests-1.R]
setClass("test1", representation(date="POSIXct"))
x <- new("test1", date=as.POSIXct("2003-10-09"))
stopifnot(format(x @ date) == "2003-10-09")
## line 2 failed in 1.8.0 because of an extraneous space in "%in%"

stopifnot(all.equal(3:3, 3.), all.equal(1., 1:1))

## trace (requiring methods):
f <- function(x, y) { c(x,y)}
xy <- 0
trace(f, quote(x <- c(1, x)), exit = quote(xy <<- x), print = FALSE)
fxy <- f(2,3)
stopifnot(identical(fxy, c(1,2,3)))
stopifnot(identical(xy, c(1,2)))
untrace(f)

## a generic and its methods

setGeneric("f")
setMethod("f", c("character", "character"), function(x,	 y) paste(x,y))

## trace the generic
trace("f", quote(x <- c("A", x)), exit = quote(xy <<- c(x, "Z")), print = FALSE)

## should work for any method

stopifnot(identical(f(4,5), c("A",4,5)),
          identical(xy, c("A", 4, "Z")))

stopifnot(identical(f("B", "C"), paste(c("A","B"), "C")),
          identical(xy, c("A", "B", "Z")))

## trace a method
trace("f", sig = c("character", "character"), quote(x <- c(x, "D")),
      exit = quote(xy <<- xyy <<- c(x, "W")), print = FALSE)

stopifnot(identical(f("B", "C"), paste(c("A","B","D"), "C")))
stopifnot(identical(xyy, c("A", "B", "D", "W")))
# got broken by Luke's lexical scoping fix:
#stopifnot(identical(xy, xyy))

## but the default method is unchanged
stopifnot(identical(f(4,5), c("A",4,5)),
          identical(xy, c("A", 4, "Z")))

removeGeneric("f")
## end of moved from trace.Rd


## print/show dispatch  [moved from  ./reg-tests-2.R ]
## The results  have waffled back and forth.
## Currently (R 2.4.0) the intent is that automatic printing of S4
## objects should correspond to a call to show(), as per the green
## book, p. 332.  Therefore, the show() method is called, once defined,
## for auto-printing foo, regardless of the S3 or S4 print() method.
## (But most of this example is irrelevant if one avoids S3 methods for
## S4 classes, as one should.)
setClass("bar", representation(a="numeric"))
foo <- new("bar", a=pi)
foo
show(foo)
print(foo)

setMethod("show", "bar", function(object){cat("show method\n")})
show(foo)
foo
print(foo)
# suppressed because output depends on current choice of S4 type or
# not.  Can reinstate when S4 type is obligatory
# print(foo, digits = 4)

## DON'T DO THIS:  S3 methods for S4 classes are a design error JMC iii.9.09
## print.bar <- function(x, ...) cat("print method\n")
## foo
## print(foo)
## show(foo)

setMethod("print", "bar", function(x, ...){cat("S4 print method\n")})
foo
print(foo)
show(foo)
## calling print() with more than one argument suppresses the show()
## method, largely to prevent an infinite loop if there is in fact no
## show() method for this class.  A better solution would be desirable.
print(foo, digits = 4)

setClassUnion("integer or NULL", members = c("integer","NULL"))
setClass("c1", representation(x = "integer", code = "integer or NULL"))
nc <- new("c1", x = 1:2)
str(nc)# gave ^ANULL^A in 2.0.0
##


library(stats4)
showMethods("coerce", classes=c("matrix", "numeric"))
## {gave wrong result for a while in R 2.4.0}

## the following showMethods() output tends to generate errors in the tests
## whenever the contents of the packages change. Searching in the
## diff's can easily mask real problems.  If there is a point
## to the printout, e.g., to verify that certain methods exist,
## hasMethod() would be a useful replacement

## showMethods(where = "package:stats4")
## showMethods("show")
## showMethods("show")
## showMethods("plot") # (ANY,ANY) and (profile.mle, missing)
## showMethods(classes="mle")
## showMethods(classes="matrix")


##--- "[" fiasco before R 2.2.0 :
d2 <- data.frame(b= I(matrix(1:6,3,2)))
## all is well:
d2[2,]
stopifnot(identical(d2[-1,], d2[2:3,]))
## Now make "[" into S4 generic by defining a trivial method
setClass("Mat", representation(Dim = "integer", "VIRTUAL"))
setMethod("[", signature(x = "Mat",
			 i = "missing", j = "missing", drop = "ANY"),
	  function (x, i, j, drop) x)
## Can even remove the method: it doesn't help
removeMethod("[", signature(x = "Mat",
                            i = "missing", j = "missing", drop = "ANY"))
d2[1:2,] ## used to fail badly; now okay
stopifnot(identical(d2[-1,], d2[2:3,]))
## failed in R <= 2.1.x


## Fritz' S4 "odditiy"
setClass("X", representation(bar="numeric"))
setClass("Y", contains="X")
## Now we define a generic foo() and two different methods for "X" and
## "Y" objects for arg missing:
setGeneric("foo", function(object, arg) standardGeneric("foo"))
setMethod("foo", signature(object= "X", arg="missing"),
          function(object, arg) cat("an X object with bar =", object@bar, "\n"))
setMethod("foo", signature(object= "Y", arg="missing"),
          function(object, arg) cat("a Y object with bar =", object@bar, "\n"))
## Finally we create a method where arg is "logical" only for class
## "X", hence class "Y" should inherit that:
setMethod("foo", signature(object= "X", arg= "logical"),
          function(object, arg) cat("Hello World!\n") )
## now create objects and call methods:
y <- new("Y", bar=2)
## showMethods("foo")
foo(y)
foo(y, arg=TRUE)## Hello World!
## OK, inheritance worked, and we have
## showMethods("foo")
foo(y)
## still 'Y' -- was 'X object' in R < 2.3


## Multiple inheritance
setClass("A", representation(x = "numeric"))
setClass("B", representation(y = "character"))
setClass("C", contains = c("A", "B"), representation(z = "logical"))
new("C")
setClass("C", contains = c("A", "B"), representation(z = "logical"),
         prototype = prototype(x = 1.5, y = "test", z = TRUE))
(cc <- new("C"))
## failed reconcilePropertiesAndPrototype(..) after svn r37018
stopifnot(identical(selectSuperClasses("C", dropVirtual = TRUE), c("A", "B")),
	  0 == length(.selectSuperClasses(getClass("B")@contains)))

## "Logic" group -- was missing in R <= 2.4.0
stopifnot(all(getGroupMembers("Logic") %in% c("&", "|")),
	  any(getGroupMembers("Ops") == "Logic"))
setClass("brob", contains="numeric")
b <- new("brob", 3.14)
logic.brob.error <- function(nm)
    stop("logic operator '", nm, "' not applicable to brobs")
logic2 <- function(e1,e2) logic.brob.error(.Generic)
setMethod("Logic", signature("brob", "ANY"), logic2)
setMethod("Logic", signature("ANY", "brob"), logic2)
## Now ensure that using group members gives error:
assertError(b & b)
assertError(b | 1)
assertError(TRUE & b)


## methods' hidden cbind() / rbind:
setClass("myMat", representation(x = "numeric"))
setMethod("cbind2", signature(x = "myMat", y = "missing"), function(x,y) x)
m <- new("myMat", x = c(1, pi))
stopifnot(identical(m, methods:::cbind(m)), identical(m, cbind(m)))


## explicit print or show on a basic class with an S4 bit
## caused infinite recursion
setClass("Foo", representation(name="character"), contains="matrix")
(f <- new("Foo", name="Sam", matrix()))
f2 <- new("Foo", .Data = diag(2), name="Diag")# explicit .Data
(m <- as(f, "matrix"))
## this has no longer (2.7.0) an S4 bit: set it explicitly just for testing:
stopifnot(isS4(m. <- asS4(m)),
          identical(m, f@.Data),
	  .hasSlot(f, "name"))# failed in R <= 2.13.1
show(m.)
print(m.)
## fixed in 2.5.0 patched

## callGeneric inside a method with new arguments {hence using .local()}:
setGeneric("Gfun", function(x, ...) standardGeneric("Gfun"),
	   useAsDefault = function(x, ...) sum(x, ...))
setClass("myMat", contains="matrix")
setClass("mmat2", contains="matrix")
setClass("mmat3", contains="mmat2")
setMethod(Gfun, signature(x = "myMat"),
	  function(x, extrarg = TRUE) {
	      cat("in 'myMat' method for 'Gfun() : extrarg=", extrarg, "\n")
	      Gfun(unclass(x))
	  })
setMethod(Gfun, signature(x = "mmat2"),
	  function(x, extrarg = TRUE) {
	      cat("in 'mmat2' method for 'Gfun() : extrarg=", extrarg, "\n")
	      x <- unclass(x)
	      callGeneric()
	  })
setMethod(Gfun, signature(x = "mmat3"),
	  function(x, extrarg = TRUE) {
	      cat("in 'mmat3' method for 'Gfun() : extrarg=", extrarg, "\n")
	      x <- as(x, "mmat2")
	      callGeneric()
	  })
wrapG <- function(x, a1, a2) {
    myextra <- missing(a1) && missing(a2)
    Gfun(x, extrarg = myextra)
}

(mm <- new("myMat", diag(3)))
Gfun(mm)
stopifnot(identical(wrapG(mm),    Gfun(mm, TRUE)),
          identical(wrapG(mm,,2), Gfun(mm, FALSE)))

Gfun(mm, extrarg = FALSE)
m2 <- new("mmat2", diag(3))
Gfun(m2)
Gfun(m2, extrarg = FALSE)
## The last two gave Error ...... variable ".local" was not found
(m3 <- new("mmat3", diag(3)))
Gfun(m3)
Gfun(m3, extrarg = FALSE) # used to not pass 'extrarg'

## -- a variant of the above which failed in version <= 2.5.1 :
setGeneric("Gf", function(x, ...) standardGeneric("Gf"))
setMethod(Gf, signature(x = "mmat2"),
          function(x, ...) {
              cat("in 'mmat2' method for 'Gf()\n")
              x <- unclass(x)
              callGeneric()
          })
setMethod(Gf, signature(x = "mmat3"),
          function(x, ...) {
              cat("in 'mmat3' method for 'Gf()\n")
              x <- as(x, "mmat2")
              callGeneric()
          })
setMethod(Gf, signature(x = "matrix"),
	  function(x, a1, ...) {
              cat(sprintf("matrix %d x %d ...\n", nrow(x), ncol(x)))
              list(x=x, a1=a1, ...)
          })

wrap2 <- function(x, a1, ...) {
    A1 <- if(missing(a1)) "A1" else as.character(a1)
    Gf(x, ..., a1 = A1)
}
## Gave errors in R 2.5.1 :
wrap2(m2, foo = 3.14)
wrap2(m2, 10, answer.all = 42)


## regression tests of dispatch: most of these became primitive in 2.6.0
setClass("c1", "numeric")
setClass("c2", "numeric")
x_c1 <- new("c1")
# the next failed < 2.5.0 as the signature in .BasicFunsList was wrong
setMethod("as.character", "c1", function(x, ...) "fn test")
as.character(x_c1)

setMethod("as.integer", "c1", function(x, ...) 42)
as.integer(x_c1)

setMethod("as.logical", "c1", function(x, ...) NA)
as.logical(x_c1)

setMethod("as.complex", "c1", function(x, ...) pi+0i)
as.complex(x_c1)

setMethod("as.raw", "c1", function(x) as.raw(10))
as.raw(x_c1)

# as.double, as.real use as.numeric for their methods to maintain equivalence
setMethod("as.numeric", "c1", function(x, ...) 42+pi)
identical(as.numeric(x_c1),as.double(x_c1))


setMethod(as.double, "c2", function(x, ...) x@.Data+pi)
x_c2 <- new("c2", pi)
identical(as.numeric(x_c2),as.double(x_c2))

## '!' changed signature from 'e1' to 'x' in 2.6.0
setClass("foo", "logical")
setMethod("!", "foo", function(e1) e1+NA)
selectMethod("!", "foo")
xx <- new("foo", FALSE)
!xx

## This fails in R versions earlier than 2.6.0:
setMethod("as.vector", "foo", function(x) unclass(x))
stopifnot(removeClass("foo"))

## stats4::AIC in R < 2.7.0 used to clobber stats::AIC
pfit <- function(data) {
    m <- mean(data)
    loglik <- sum(dpois(data, m))
    ans <- list(par = m, loglik = loglik)
    class(ans) <- "pfit"
    ans
}
AIC.pfit <- function(object, ..., k = 2) -2*object$loglik + k
AIC(pfit(1:10))
library(stats4) # and keep on search() for tests below
AIC(pfit(1:10)) # failed in R < 2.7.0

## For a few days (~ 2008-01-30), this failed to work without any notice:
setClass("Mat",  representation(Dim = "integer","VIRTUAL"))
setClass("dMat", representation(x = "numeric",  "VIRTUAL"), contains = "Mat")
setClass("CMat", representation(dnames = "list","VIRTUAL"), contains = "Mat")
setClass("dCMat", contains = c("dMat", "CMat"))
stopifnot(!isVirtualClass("dCMat"),
	  length(slotNames(new("dCMat"))) == 3)


## Passing "..." arguments in nested callGeneric()s
setClass("m1", contains="matrix")
setClass("m2", contains="m1")
setClass("m3", contains="m2")
##
setGeneric("foo", function(x, ...) standardGeneric("foo"))
setMethod("foo", signature(x = "m1"),
	  function(x, ...) cat(" <m1> ", format(match.call()),"\n"))
setMethod("foo", signature(x = "m2"),
	  function(x, ...) {
	      cat(" <m2> ", format(match.call()),"\n")
	      x <- as(x, "m1"); callGeneric()
	  })
setMethod("foo", signature(x = "m3"),
	  function(x, ...) {
	      cat(" <m3> ", format(match.call()),"\n")
	      x <- as(x, "m2"); callGeneric()
	  })
foo(new("m1"), bla = TRUE)
foo(new("m2"), bla = TRUE)
foo(new("m3"), bla = TRUE)
## The last one used to loose 'bla = TRUE' {the "..."} when it got to m1

## is() for S3 objects with multiple class strings
setClassUnion("OptionalPOSIXct",   c("POSIXct",   "NULL"))
stopifnot(is(Sys.time(), "OptionalPOSIXct"))
## failed in R 2.7.0

## getGeneric() / getGenerics() "problems" related to 'tools' usage:
e4 <- as.environment("package:stats4")
gg4 <- getGenerics(e4)
stopifnot(c("BIC", "coef", "confint", "logLik", "plot", "profile",
            "show", "summary", "update", "vcov") %in% gg4, # %in% : "future proof"
          unlist(lapply(gg4, function(g) !is.null(getGeneric(g, where = e4)))),
          unlist(lapply(gg4, function(g) !is.null(getGeneric(g)))))
em <- as.environment("package:methods")
ggm <- getGenerics(em)
gms <- c("addNextMethod", "body<-", "cbind2", "initialize",
	 "loadMethod", "Ops", "rbind2", "show")
stopifnot(unlist(lapply(ggm, function(g) !is.null(getGeneric(g, where = em)))),
	  unlist(lapply(ggm, function(g) !is.null(getGeneric(g)))),
	  gms %in% ggm,
	  gms %in% tools:::get_S4_generics_with_methods(em), # with "message"
	  ## all above worked in 2.7.0, however:
	  isGeneric("show",  where=e4),
	  hasMethods("show", where=e4), hasMethods("show", where=em),
	  identical(as.character(gg4), #gg4 has packages attr.; tools::: doesn't
		    tools:::get_S4_generics_with_methods(e4))
	  )
## the last failed in R 2.7.0 : was not showing  "show"

if(require("Matrix")) {
    D5. <- Diagonal(x = 5:1)
    D5N <- D5.; D5N[5,5] <- NA
    stopifnot(isGeneric("dim", where=as.environment("package:Matrix")),
	      identical(D5., pmin(D5.)),
	      identical(D5., pmax(D5.)),
	      identical(D5., pmax(D5., -1)),
	      identical(D5., pmin(D5., 7)),
	      inherits((D5.3 <- pmin(D5.+2, 3)), "Matrix"),
	      identical(as.matrix(pmin(D5.+2 , 3)),
			pmin(as.matrix(D5.+2), 3)),
	      identical(pmin(1, D5.), pmin(1, as.matrix(D5.))),
	      identical(D5N, pmax(D5N, -1)),
	      identical(D5N, pmin(D5N, 5)),
	      identical(unname(as.matrix(pmin(D5N+1, 3))),
			       pmin(as.matrix(D5N)+1, 3)),
	      ##
	      TRUE)
}


## containing "array" ("matrix", "ts", ..)
t. <- ts(1:10, frequency = 4, start = c(1959, 2))
setClass("Arr", contains= "array"); x <- new("Arr", cbind(17))
setClass("Ts",  contains= "ts");   tt <- new("Ts", t.); t2 <- as(t., "Ts")
setClass("ts2", representation(x = "Ts", y = "ts"))
tt2 <- new("ts2", x=t2, y=t.)
stopifnot(dim(x) == c(1,1), is(tt, "ts"), is(t2, "ts"),
          ## FIXME:  identical(tt, t2)
          length(tt) == length(t.),
          identical(tt2@x, t2), identical(tt2@y, t.))
## new(..) failed in R 2.7.0

## Method with wrong argument order :
setGeneric("test1", function(x, printit = TRUE, name = "tmp")
           standardGeneric("test1"))
tools::assertCondition(
setMethod("test1", "numeric", function(x, name, printit) match.call()),
"warning", "error")## did not warn or error in R 2.7.0 and earlier

library(stats4)
c1 <- getClass("mle", where = "stats4")
c2 <- getClass("mle", where = "package:stats4")
s1 <- getMethod("summary", "mle", where = "stats4")
s2 <- getMethod("summary", "mle", where = "package:stats4")
stopifnot(is(c1, "classRepresentation"),
	  is(s1, "MethodDefinition"),
	  identical(c1,c2), identical(s1,s2))
## failed at times in the past

## Extending "matrix", the .Data slot etc:
setClass("moo", representation("matrix"))
m <- matrix(1:4, 2, dimnames= list(NULL, c("A","B")))
nf <- new("moo", .Data = m)
n2 <- new("moo", 3:1, 3,2)
n3 <- new("moo", 1:6, ncol=2)
stopifnot(identical(m,			as(nf, "matrix")),
	  identical(matrix(3:1,3,2),	as(n2, "matrix")),
	  identical(matrix(1:6,ncol=2), as(n3, "matrix")))
## partly failed at times in pre-2.8.0

## From "Michael Lawrence" <....@fhcrc.org>  To r-devel@r-project, 25 Nov 2008:
## NB: setting a generic on order() is *not* the approved method
## -- set xtfrm() methods instead
setGeneric("order", signature="...",
	   function (..., na.last=TRUE, decreasing=FALSE)
	   standardGeneric("order"))
stopifnot(identical(rbind(1), matrix(1,1,1)))
setGeneric("rbind", function(..., deparse.level=1)
	   standardGeneric("rbind"), signature = "...")
stopifnot(identical(rbind(1), matrix(1,1,1)))
## gave Error in .Method( .... in R 2.8.0

## median( <simple S4> )
## FIXME: if we use "C" instead of "L", this fails because of caching
setClass("L", contains = "list")
## {simplistic, just for the sake of testing here} :
setMethod("Compare", signature(e1="L", e2="ANY"),
          function(e1,e2) sapply(e1, .Generic, e2=e2))
## note the next does *not* return an object of the class.
setMethod("Summary", "L",
	  function(x, ..., na.rm=FALSE) {x <- unlist(x); callNextMethod()})
setMethod("[", signature(x="L", i="ANY", j="missing",drop="missing"),
          function(x,i,j,drop) new(class(x), x@.Data[i]))
## defining S4 methods for sort() has no effect on calls to
## sort() from functions in a namespace; e.g., median.default.
## but setting an xtfrm() method works.
setMethod("xtfrm", "L", function(x) xtfrm(unlist(x@.Data)))
## median is documented to use mean(), so we need an S3 mean method:
## An S4 method will not do because of the long-standing S4 scoping bug.
mean.L <- function(x, ...) new("L", mean(unlist(x@.Data), ...))
x <- new("L", 1:3); x2 <- x[-2]
stopifnot(unlist(x2) == (1:3)[-2],
	  is(mx <- median(x), "L"), mx == 2,
	  ## median of two
	  median(x2) == x[2])
## NB: quantile() is not said to work on such an object, and only does so
## for order statistics (so should not be tested, but was in earlier versions).

## Buglet in as() generation for class without own slots
setClass("SIG", contains="signature")
stopifnot(packageSlot(class(S <- new("SIG"))) == ".GlobalEnv",
	  packageSlot(class(ss <- new("signature"))) == "methods",
	  packageSlot(class(as(S, "signature"))) == "methods")
## the 3rd did not have "methods"

## Invalid "factor"s -- now "caught" by  validity check :
 ok.f <- gl(3,5, labels = letters[1:3])
bad.f <- structure(rep(1:3, each=5), levels=c("a","a","b"), class="factor")
validObject(ok.f) ; assertError(validObject(bad.f))
setClass("myF", contains = "factor")
validObject(new("myF", ok.f))
assertError(validObject(new("myF", bad.f)))
removeClass("myF")
## no validity check in R <= 2.9.0

## as(x, .)   when x is from an "unregistered" S3 class :
as(structure(1:3, class = "foobar"), "vector")
## failed to work in R <= 2.9.0

## S4 dispatch in the internal generic xtfrm (added in 2.11.0)
setClass("numWithId", representation(id = "character"), contains = "numeric")
x <- new("numWithId", 1:3, id = "An Example")
xtfrm(x) # works as the base representation is numeric
setMethod('xtfrm', 'numWithId', function(x) x@.Data)
xtfrm(x)
stopifnot(identical(xtfrm(x), 1:3))# "integer" is "numeric"
## new in 2.11.0

## [-dispatch using callNextMethod()
setClass("C1", representation(a = "numeric"))
setClass("C2", contains = "C1")
setMethod("[", "C1", function(x,i,j,...,drop=TRUE)
	  cat("drop in C1-[ :", drop, "\n"))
setMethod("[", "C2", function(x,i,j,...,drop=TRUE) {
    cat("drop in C2-[ :", drop, "\n")
    callNextMethod()
})
x <- new("C1"); y <- new("C2")
x[1, drop=FALSE]
y[1, drop=FALSE]
## the last gave TRUE on C1-level in R 2.10.x;
## the value of drop was wrongly taken from the default.

## All slot names -- but "class" -- should work now
problNames <- c("names", "dimnames", "row.names",
                "class", "comment", "dim", "tsp")
myTry <- function(expr, ...) tryCatch(expr, error = function(e) e)
tstSlotname <- function(nm) {
    r <- myTry(setClass("foo", representation =
                        structure(list("character"), .Names = nm)))
    if(is(r, "error")) return(r$message)
    ## else
    ch <- LETTERS[1:5]
    ## instead of  new("foo", <...> = ch):
    x <- myTry(do.call(new, structure(list("foo", ch), .Names=c("", nm))))
    if(is(x, "error")) return(x$message)
    y <- myTry(new("foo"));		 if(is(y, "error")) return(y$message)
    r <- myTry(capture.output(show(x))); if(is(r, "error")) return(r$message)
    r <- myTry(capture.output(show(y))); if(is(r, "error")) return(r$message)
    ## else
    slot(y, nm) <- slot(x, nm)
    stopifnot(validObject(x), identical(x,y), identical(slot(x, nm), ch))
    return(TRUE)
}
R <- sapply(problNames, tstSlotname, simplify = FALSE)
str(R) # just so ...
stopifnot(is.character(R[["class"]]),
          sapply(R[names(R) != "class"], isTRUE))
## only "class" (and ".Data", ...) is reserved as slot name

## implicit generics ..
setMethod("sample", "C2",
          function(x, size, replace=FALSE, prob=NULL) {"sample.C2"})
stopifnot(is(sample,"standardGeneric"),
	  ## the signature must come from the implicit generic:
	  identical(sample@signature, c("x", "size")),
	  identical(packageSlot(sample), "base"),
	  ## default method must still work:
	  identical({set.seed(3); sample(3)}, 1:3))
## failed in R 2.11.0

## Still, signature is taken from "def"inition, if one is provided:
## (For test, qqplot must be a "simple" function:)
stopifnot(is.function(qqplot) && identical(class(qqplot), "function"))
setGeneric("qqplot", function(x, y, ...) standardGeneric("qqplot"))
stopifnot(is(qqplot, "standardGeneric"),
	  identical(qqplot@signature, c("x","y")))
## failed for a day ~ 2005-05-26, for R-devel only


##  'L$A@x <- ..'
setClass("foo", representation(x = "numeric"))
f <- new("foo", x = pi*1:2)
L <- list()
L$A <- f
L$A@x[] <- 7
if( identical(f, L$A) )
    stop("Oops! f is identical to L$A, even though not touched!")
## did not duplicate in 2.0.0 <= Rversion <= 2.11.1


## prototypes for virtual classes:  NULL if legal, otherwise 1st member
## OptionalPosixct above includes NULL
stopifnot(is.null(getClass("OptionalPOSIXct")@prototype))
## "IntOrChar" had invalid NULL prototype < 2.15.0
setClassUnion("IntOrChar", c("integer", "character"))
stopifnot(is.integer(getClass("IntOrChar")@prototype))
## produced an error < 2.15.0
stopifnot(identical(isGeneric("&&"), FALSE))


## mapply() on S4 objects with a "non-primitive" length() method
setClass("A", representation(aa="integer"))
aa <- 11:16
a <- new("A", aa=aa)
setMethod(length, "A", function(x) length(x@aa))
setMethod(`[[`,   "A", function(x, i, j, ...) x@aa[[i]])
setMethod(`[`,    "A", function(x, i, j, ...) new("A", aa = x@aa[i]))
setMethod("is.na","A", function(x) is.na(x@aa))
stopifnot(length(a) == 6, identical(a[[5]], aa[[5]]),
          identical(a, rev(rev(a))), # using '['
	  identical(mapply(`*`, aa, rep(1:3, 2)),
		    mapply(`*`, a,  rep(1:3, 2))))
## Up to R 2.15.2, internally 'a' is treated as if it was of length 1
## because internal dispatch did not work for length().

setMethod("is.unsorted", "A", function(x, na.rm, strictly)
    is.unsorted(x@aa, na.rm=na.rm, strictly=strictly))

stopifnot(!is.unsorted(a), # 11:16 *is* sorted
	  is.unsorted(rev(a)))

# getSrcref failed when rematchDefinition was used
text <- '
setClass("MyClass", representation(val = "numeric"))
setMethod("plot", signature(x = "MyClass"),
    function(x, y, ...) {
        # comment
	NULL
    })
setMethod("initialize", signature = "MyClass",
    function(.Object, value) {
	# comment
	.Object@val <- value
	return(.Object)
    })
'
source(textConnection(text), keep.source = TRUE)
getSrcref(getMethod("plot", "MyClass"))
getSrcref(getMethod("initialize", "MyClass"))


## PR#15691
setGeneric("fun", function(x, ...) standardGeneric("fun"))
setMethod("fun", "character", identity)
setMethod("fun", "numeric", function(x) {
  x <- as.character(x)
  callGeneric()
})

stopifnot(identical(fun(1), do.call(fun, list(1))))
## failed in R < 3.1.0


## PR#15680
setGeneric("f", function(x, y) standardGeneric("f"))
setMethod("f", c("numeric", "missing"), function(x, y) x)
try(?f(1))

## "..." is not handled
setGeneric("f", function(...) standardGeneric("f"))
setMethod("f", "numeric", function(...) c(...))
try(?f(1,2))

## defaults in the generic formal arguments are not considered
setGeneric("f", function(x, y=0) standardGeneric("f"))
setMethod("f", c("numeric", "numeric"), function(x, y) x+y)
try(?f(1))

## Objects with S3 classes fail earlier
setGeneric("f", function(x) standardGeneric("f"))
setMethod("f", "numeric", function(x) x)
setOldClass(c("foo", "numeric"))
n <- structure(1, class=c("foo", "numeric"))
try(?f(n))
## different failures in R < 3.1.0.


## identical() did not look at S4 bit:
a <- 1:5
b <- setClass("B", "integer")(a)
stopifnot(is.character(all.equal(a, b)))
attributes(a) <- attributes(b)
if(!isS4(a)) { # still (unfortunately)
    message("'a' is not S4 yet")
    if(identical(a,b)) stop("identical() not looking at S4 bit")
    ## set S4 bit manually:
    a <- asS4(a)
}
stopifnot(identical(a, b), isS4(a))
## failed in R <= 3.1.1


### cbind(), rbind() now work both via rbind2(), cbind2() and rbind.
##__ 1) __
setClass("A", representation(a = "matrix"))
setMethod("initialize", signature(.Object = "A"),
    function(.Object, y) {
      .Object@a <- y
      .Object
    })
setMethod("rbind2", signature(x = "A", y = "matrix"),
    function(x, y, ...) {
      cat("rbind2(<A>, <matrix>) : ")
      x@a <- rbind(x@a, y)
      cat(" x@a done\n")
      x
    })
setMethod("dim", "A", function(x) dim(x@a))
mat1 <- matrix(1:9, nrow = 3)
obj1 <- new("A", 10*mat1)
om1 <- rbind(obj1, mat1)## now does work {it does need a working "dim" method!}
stopifnot(identical(om1, rbind2(obj1, mat1)))
rm(obj1,om1); removeClass("A")
##
##
###__ 2) --- Matrix --- via cbind2(), rbind2()
## this has its output checked strictly, so test depending on Matrix
## has been moved to reg-tests-3.R
##
###__ 3) --- package 'its' like
setClass("its",representation("matrix", dates="POSIXt"))
m <- outer(1:3, setNames(1:5,LETTERS[1:5]))
im <- new("its", m, dates=as.POSIXct(Sys.Date()))
stopifnot(identical(m, im@.Data))
ii  <- rbind(im, im-1)
i.i <- cbind(im, im-7)
stopifnot(identical(m, rbind(im)),
          identical(m, cbind(im)),
          identical(ii , rbind(m, m-1)),
          identical(i.i, cbind(m, m-7)))
rm(im, ii, i.i)
removeClass("its")
##
##
###__ 4) --- pkg 'mondate' like --
setClass("mondate",
         slots = c(timeunits = "character"), contains = "numeric")
three <- 3
m1 <- new("mondate", 1:4, timeunits = "hrs")
m2 <- new("mondate", 7:8, timeunits = "min")
stopifnot(identical(colnames(cbind(m1+1, deparse.level=2)), "m1 + 1"),
          is.null  (colnames(cbind(m1+1, deparse.level=0))),
          is.null  (colnames(cbind(m1+1, deparse.level=1))),
          identical(colnames(cbind(m1)), "m1"),
          colnames(cbind(m1  , M2 = 2, deparse.level=0)) == c(""  , "M2"),
          colnames(cbind(m1  , M2 = 2))                  == c("m1", "M2"),
          colnames(cbind(m1  , M2 = 2, deparse.level=2)) == c("m1", "M2"),
          colnames(cbind(m1+1, M2 = 2, deparse.level=2)) == c("m1 + 1", "M2"),
          colnames(cbind(m1+1, M2 = 2, deparse.level=1)) == c("",       "M2"))
cbind(m1, three, m2)
cbind(m1, three, m2,   deparse.level = 0) # none
cbind(m1, three, m2+3, deparse.level = 1) # "m1" "three"
cbind(m1, three, m2+3, deparse.level = 2) -> m3
m3 #    ....  and "m2 + 3"
stopifnot(identical(t(m3), rbind(m1, three, m2+3, deparse.level = 2)),
          identical(cbind(m1, m2) -> m12,
                    cbind(m1=m1@.Data, m2=m2@.Data)),
          identical(rbind(m1, m2), t(m12)),
          identical(cbind(m1, m2, T=T, deparse.level=0),
                    cbind(m1@.Data, m2@.Data, T=T) -> mm),
          identical(colnames(mm), c("", "", "T")),
          identical(cbind(m1, m2, deparse.level=0),
                    cbind(m1@.Data, m2@.Data)))
##
## Cleanup all class definitions etc -- seems necessary for the following "re"-definitions:
invisible(lapply(getClasses(globalenv()), removeClass))
nn <- names(globalenv())
rm(list = c("nn", nn))

## Using "data.frame" in a slot -- all have worked for long:
setClass("A", representation(slot1="numeric", slot2="logical"))
setClass("D1", contains="A", representation(design="data.frame"))
setClass("D2", contains="D1")
validObject(a <- new("A", slot1=77, slot2=TRUE))
validObject(D. <- new("D2", a, design = data.frame(x = 1)))
## using "formula" in a slot -- from Hervé Pages :
setClass("B", contains="A", representation(design="formula"))
setClass("C", contains="B")
##
a <- new("A", slot1=77, slot2=TRUE)
validObject(C1 <- new("C", a, design = x ~ y))# failed for R <= 3.2.0
C2 <- new("C", slot1=a@slot1, slot2=a@slot2, design=x ~ y)
stopifnot(identical(C1, C2),
	  identical(formula(), formula(NULL)),
	  length(N <- new("formula")) == 0, inherits(N, "formula"),
	  length(N <- new("table")  ) == 0, is.table(N),
	  validObject(N <- new("summary.table")),
	  length(N <- new("ordered")) == 0, is.ordered(N))
## formula() and new("formula"), new("..") also failed  in R <= 3.2.0

require("stats4")# -> "mle" class
validObject(sig <- new("signature", obj = "mle"))
stopifnot(c("package", "names") %in% slotNames(sig))
str(sig) # failed, too

cl4 <- getClasses("package:stats4")
stopifnot(identical(getClasses(which(search() == "package:stats4")), cl4),
	  c("mle", "profile.mle", "summary.mle") %in% cl4)
## failed after an optimization patch

detach("package:methods", force=TRUE)
C1@slot1 <- pi
stopifnot(identical(C1@slot1, pi))
stopifnot(require("methods"))
## Slot assignment failed in R <= 3.2.2, C code calling checkAtAssignment()

## Error in argument evaluation of S4 generic - PR#16111
f <- function() {
    signal <- FALSE
    withCallingHandlers({ g(sqrt(-1)) }, warning = function(w) {
        signal <<- TRUE
        invokeRestart("muffleWarning")
    })
    signal
}
g <- function(x) x
op <- options(warn = 2)# warnings give errors
stopifnot(isTRUE( f() ))
setGeneric("g")
stopifnot(isTRUE( f() ))
options(op)
## the second  f()  gave a warning and FALSE in  R versions  2.12.0 <= . <= 3.2.3


stopifnot(
    identical(formals(getGeneric("as.vector")), formals(base::as.vector)),
    identical(formals(getGeneric("unlist")),    formals(base::unlist)))
## failed for a while in R-devel (3.3.0)

setClass("myInteger", contains=c("integer", "VIRTUAL"))
setClass("mySubInteger", contains="myInteger")
new("mySubInteger", 1L)
## caused infinite recursion in R 3.3.0

detach("package:methods", force=TRUE)
methods::setClass("test1", methods::representation(date="POSIXct"))
methods::setClass("test2", contains="test1")
test <- function(x) UseMethod('test', x)
test.test1 <- function(x) 'Hi'
test(methods::new("test2", date=as.POSIXct("2003-10-09")))
stopifnot(require("methods"))
## S3 dispatch to superclass methods failed on S4 objects when
## methods package was not attached


## Tests for class fetching and conflict resolution
setClass("htest1", slots=c(a="numeric",b="data.frame"), package="package1")
setClass("htest2", slots=c(a="logical"), package="package2")
class.list = list(
    package1=getClassDef("htest1", where=class_env1),
    package2=getClassDef("htest2", where=class_env2)
)

firstclass  <- methods:::.resolveClassList(class.list,.GlobalEnv,
                                           package="package1")
secondclass <- methods:::.resolveClassList(class.list,.GlobalEnv,
                                           package="package2")
alsofirstclass <- methods:::.resolveClassList(class.list,.GlobalEnv,
                                              package="package3")
stopifnot(!identical(firstclass, secondclass))
stopifnot(identical(firstclass, class.list[[1]]))
stopifnot(identical(secondclass, class.list[[2]]))
stopifnot(identical(alsofirstclass, class.list[[1]]))

## implicit coercion of S4 object to vector via as.vector() in sub-assignment
setClass("A", representation(stuff="numeric"))
as.vector.A <- function (x, mode="any") x@stuff
v <- c(3.5, 0.1)
a <- new("A", stuff=v)
x <- y <- numeric(10)
x[3:4] <- a
y[3:4] <- v
stopifnot(identical(x, y))

## callNextMethod() was broken when augmenting args of primitive generics
foo <- setClass("foo")
bar <- setClass("bar", contains = "foo")

setMethod("[", "foo",  function(x, i, j, ..., flag = FALSE, drop = FALSE) {
    flag
})

setMethod("[", "bar", function(x, i, j, ..., flag = FALSE, drop = FALSE) {
    callNextMethod()
})

BAR <- new("bar")
stopifnot(identical(BAR[1L], FALSE))
stopifnot(identical(BAR[1L, , flag=TRUE], TRUE))

## avoid infinite recursion on Ops,structure methods
setClass("MyInteger",
         representation("integer")
         )
i <- new("MyInteger", 1L)
m <- matrix(rnorm(300), 30,10)
stopifnot(identical(i*m, m))

## when rematching, do not drop arg with NULL default
setGeneric("genericExtraArg",
           function(x, y, extra) standardGeneric("genericExtraArg"),
           signature="x")

setMethod("genericExtraArg", "ANY", function(x, y=NULL) y)

stopifnot(identical(genericExtraArg("foo", 1L), 1L))

## callNextMethod() was broken for ... dispatch
f <- function(...) length(list(...))
setGeneric("f")
setMethod("f", "character", function(...){ callNextMethod() })
stopifnot(identical(f(1, 2, 3), 3L))
stopifnot(identical(f("a", "b", "c"), 3L))

## ... dispatch was evaluating missing arguments in the generic frame
f <- function(x, ..., a = b) {
    b <- "a"
    a
}
setGeneric("f", signature = "...")
stopifnot(identical(f(a=1), 1))
stopifnot(identical(f(), "a"))

## ensure forwarding works correctly for dots dispatch
f2 <- function(...) f(...)
stopifnot(identical(f2(a=1), 1))


## R's internal C  R_check_class_and_super()  was not good enough
if(require("Matrix")) withAutoprint({
    setClass("Z", representation(zz = "list"))
    setClass("C", contains = c("Z", "dgCMatrix"))
    setClass("C2", contains = "C")
    setClass("C3", contains = "C2")
    m <- matrix(c(0,0,2:0), 3,5, dimnames = list(NULL,NULL))
    (mC <- as(m, "dgCMatrix"))
    (cc <- as(mC, "C"))
     c2 <- as(mC, "C2")
     c3 <- as(mC, "C3")
    stopifnot(
        identical(capture.output(c2),
                  sub("C3","C2", capture.output(c3)))
      , identical(as(cc, "matrix"), m)
      , identical(as(c2, "matrix"), m)
      , identical(as(c3, "matrix"), m)
    )
    invisible(lapply(c("Z","C","C2","C3"), removeClass))
})


## Automatic coerce method creation: 
setClass("A", slots = c(foo = "numeric"))
setClass("Ap", contains = "A", slots = c(p = "character"))
cd <- getClassDef("Ap")
body(cd@contains[["A"]]@coerce)[[2]] ## >>   value <- new("A")
## was ... <-  new(structure("A", package = ".GlobalEnv"))
## for a few days in R-devel (Nov.2017)

