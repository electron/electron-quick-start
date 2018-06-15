## simple call, only field names
fg <- setRefClass("foo", c("bar", "flag"))
f0 <- new("foo")  # deprecated, but should still work
f1 <- fg(flag = "testing")
f1$bar <- 1
stopifnot(identical(f1$bar, 1))
## add method
fg$methods(showAll = function() c(bar, flag))
stopifnot(all.equal(f1$showAll(), c(1, "testing")))
str(f1)

fg <- setRefClass("foo", list(bar = "numeric", flag = "character",
                              tag = "ANY"),
                  methods = list(addToBar = function(incr) {
                      b <- bar + incr
                      bar <<- b
                      b
                  } )
                  )
fg$lock("flag")
stopifnot(identical(fg$lock(), "flag"))

ff <- new("foo", bar = 1.5)
stopifnot(identical(ff$bar, 1.5))
ff$bar <- pi
stopifnot(identical(ff$bar, pi))
## flag has not yet been set
ff$flag <- "flag test"
stopifnot(identical(ff$flag, "flag test"))
## but no second assign
stopifnot(is(tryCatch(ff$flag <- "new", error = function(e)e), "error"))

## test against generator

f2 <- fg(bar = pi, flag = "flag test")
## identical does not return TRUE if *contents* of env are identical
stopifnot(identical(ff$bar, f2$bar), identical(ff$flag, f2$flag))
## but flag was now assigned once
stopifnot(is(tryCatch(f2$flag <- "new", error = function(e)e), "error"))

str(f2)


## add some accessor methods
fg$accessors("bar")

ff$setBar(1:3)
stopifnot(identical(ff$getBar(), 1:3))

ff$getBar()
stopifnot(all.equal(ff$addToBar(1), 2:4))


## Add a method
fg$methods(barTimes = function(x) {
    "This method multiples field bar by argument x
and this string is self-documentation"
    setBar(getBar() * x)})

ffbar <- ff$getBar()
ff$barTimes(10)
stopifnot(all.equal(ffbar * 10, ff$getBar()))
ff$barTimes(.1)

## inheritance.  redefines flag so should fail:
stopifnot(is(tryCatch(setRefClass("foo2", list(b2 = "numeric",
					       flag = "complex"),
            contains = "foo",
            refMethods = list(addBoth = function(incr) {
                addToBar(incr) #uses inherited class method
                setB2(getB2() + incr)
                })),
          error = function(e)e), "error"))
## but with flag as a subclass of "characters", should work
## Also subclasses "tag" which had class "ANY before
setClass("ratedChar", contains = "character",
         representation(score = "numeric"))
foo2 <- setRefClass("foo2", list(b2 = "numeric", flag = "ratedChar",
				 tag = "numeric"),
	    contains = "foo",
	    methods = list(addBoth = function(incr) {
                addToBar(incr) #uses inherited class method
                b2 <<- b2 + incr
                }))
## now lock the flag field; should still allow one write
foo2$lock("flag")
f2 <- foo2(bar = -3, flag = as("ANY", "ratedChar"),
               b2 = ff$bar, tag = 1.5)
## but not a second one
stopifnot(is(tryCatch(f2$flag <- "Try again",
         error = function(e)e), "error"))
str(f2)
f22 <- foo2(bar = f2$bar)
## same story if assignment follows the initialization
f22$flag <- f2$flag
stopifnot(is(tryCatch(f22$flag <- "Try again",
         error = function(e)e), "error"))
## Exporting superclass object
f22 <- fg(bar = f2$bar, flag = f2$flag)
f2e <- f2$export("foo")
stopifnot(identical(f2e$bar, f22$bar), identical(f2e$flag, f22$flag),
          identical(class(f2e), class(f22)))
stopifnot(identical(f2$flag,  as("ANY", "ratedChar")),
          identical(f2$bar, -3),
          all.equal(f2$b2, 2:4+0))
f2$addBoth(-1)
stopifnot(all.equal(f2$bar, -4), all.equal(f2$b2, 1:3+0))

## test callSuper()
foo3 <- setRefClass("foo3", fields = list(flag2 = "ratedChar"),
            contains = "foo2",
	    methods = list(addBoth = function(incr) {
		callSuper(incr)
		flag2 <<- as(paste(flag, paste(incr, collapse = ", "),
				   sep = "; "),
                             "ratedChar")
                incr
            }))

f2 <- foo2(bar = -3, flag = as("ANY", "ratedChar"), b2 =  1:3)
f3 <- foo3()
f3$import(f2)
stopifnot(all.equal(f3$b2, f2$b2), all.equal(f3$bar, f2$bar),
          all.equal(f3$flag, f2$flag))
f3$addBoth(1)
stopifnot(all.equal(f3$bar, -2), all.equal(f3$b2, 2:4+0),
          all.equal(f3$flag2, as("ANY; 1", "ratedChar")))

## but the import should have used up the one write for $flag
stopifnot(is(tryCatch(f3$flag <- "Try again",
         error = function(e)e), "error"))
str(f3)

## importing the same class (not very useful but documented to work)
f3 <- foo3()
f4 <- foo3(bar = -3, flag = as("More", "ratedChar"), b2 =  1:3, flag2 = f2$flag)
f3$import(f4)
stopifnot(identical(f3$bar, f4$bar),
          identical(f3$flag, f4$flag),
          identical(f3$b2, f4$b2),
          identical(f3$flag2, f4$flag2))

## similar to $import() but using superclass object in the generator call
## The explicitly supplied flag= should override and be allowed
## by the default $initialize()
f3b <- foo3(f2, flag = as("Other", "ratedChar"),
                flag2 = as("More", "ratedChar"))
## check that inherited and direct field assignments worked
stopifnot(identical(f3b$tag, f2$tag),
          identical(f3b$flag, as("Other", "ratedChar")),
          identical(f3b$flag2, as("More", "ratedChar")))
## the $new() method should match the generator function
f3b <- foo3$new(f2, flag = as("Other", "ratedChar"),
                flag2 = as("More", "ratedChar"))
stopifnot(identical(f3b$tag, f2$tag),
          identical(f3b$flag, as("Other", "ratedChar")),
          identical(f3b$flag2, as("More", "ratedChar")))
## a class with an initialize method, and an extra slot (legal, not a good idea)
setOldClass(c("simple.list", "list"))
fg4 <- setRefClass("foo4",
            contains = "foo2",
            methods = list(
              initialize = function(...) {
                  .self$initFields(...)
                  .self@made <<- R.version
                  .self
              }),
            representation = list(made = "simple.list")
            )

f4 <- new("foo4", flag = as("another test", "ratedChar"), bar = 1:3)
stopifnot(identical(f4@made, R.version))

## a trivial class with no fields, using fields = list(), failed up to rev 56035
foo5 <- setRefClass("foo5", fields = list(),
                    methods = list(bar = function(test)
                    paste("*",test,"*")))

f5 <- foo5()
stopifnot(identical( f5$bar("xxx"), paste("*","xxx", "*")))


## simple active binding test
abGen <- setRefClass("ab",
                  fields = list(a = "ANY",
                  b = function(x) if(missing(x)) a else {a <<- x; x}))

ab1 <- abGen(a = 1)

stopifnot(identical(ab1$a, 1), identical(ab1$b, 1))

ab1$b <- 2

stopifnot(identical(ab1$a, 2), identical(ab1$b, 2))

## a simple editor for matrix objects.  Method  $edit() changes some
## range of values; method $undo() undoes the last edit.
mEditor <- setRefClass("matrixEditor",
        fields = list(data = "matrix",
		     edits = "list"),
       methods = list(
     edit = function(i, j, value) {
       ## the following string documents the edit method
       'Replaces the range [i, j] of the
	object by value.
        '
         backup <-
             list(i, j, data[i,j])
         data[i,j] <<- value
         edits <<- c(list(backup),
                     edits)
         invisible(value)
     },
     undo = function() {
       'Undoes the last edit() operation
        and update the edits field accordingly.
        '
         prev <- edits
         if(length(prev)) prev <- prev[[1]]
         else stop("No more edits to undo")
         edit(prev[[1]], prev[[2]], prev[[3]])
         ## trim the edits list
         length(edits) <<- length(edits) - 2
         invisible(prev)
     }
     ))
xMat <- matrix(1:12,4,3)
xx <- mEditor(data = xMat)
xx$edit(2, 2, 0)
xx$data
xx$undo()
mEditor$help("undo")
stopifnot(all.equal(xx$data, xMat))

## add a method to save the object
mEditor$methods(
     save = function(file) {
       'Save the current object on the file
 in R external object format.
'
         base::save(.self, file = file)
     },
     counter = function(i) {
         'The number of items in the i-th edit.
 (Used to test usingMethods())
'
         if(i > 0 && i <= length(edits))
             length(edits[[i]][[3]])
         else
             0L
     }
)

tf <- tempfile()
xx$save(tf) #$
load(tf)
unlink(tf)
stopifnot(identical(xx$data, .self$data))

## tests of $trace() methods
## debugging an object
xx$trace(edit, quote(xxTrace <<- TRUE))

## debugging all objects from class mEditor in method $undo()
mEditor$trace(undo, quote(mETrace <<- TRUE))

xxTrace <- mETrace <- FALSE
xx$edit(2,3,100)
xx$undo()

## will not have changed the xx$undo() method (already used)
stopifnot(identical(xxTrace, TRUE), identical(mETrace, FALSE))

## but a new object works the other way around
xxTrace <- mETrace <- FALSE
xx <- mEditor(data = xMat)
xx$edit(2,3,100)
xx$undo()
stopifnot(identical(xxTrace, FALSE), identical(mETrace, TRUE))



markViewer <- ""
setMarkViewer <- function(what)
    markViewer <<- what

## Inheriting a reference class:  a matrix viewer
mv <- setRefClass("matrixViewer",
    fields = c("viewerDevice", "viewerFile"),
    contains = "matrixEditor",
    methods = list( view = function() {
        dd <- dev.cur(); dev.set(viewerDevice)
        devAskNewPage(FALSE)
        matplot(data, main = paste("After",length(edits),"edits"))
        dev.set(dd)},
        edit = # invoke previous method, then replot
          function(i, j, value) {
            callSuper(i, j, value)
            view()
          }))

## initialize and finalize methods
mv$methods( initialize = function(file = "./matrixView.pdf", ...) {
    viewerFile <<- file
    pdf(viewerFile)
    viewerDevice <<- dev.cur()
    message("Plotting to ", viewerFile)
    dev.set(dev.prev())
    setMarkViewer("ON")
    initFields(...)
  },
  finalize = function() {
    dev.off(viewerDevice)
    setMarkViewer("OFF")
  })

## a counts method to test usingMethods()
mv$methods( counts = function() {
    usingMethods("counter")
    sapply(seq_along(edits), "counter")
})


ff <- mv( data = xMat)
stopifnot(identical(markViewer, "ON")) # check initialize
ff$edit(2,2,0)
ff$data
if(methods:::.hasCodeTools())  # otherwise 'counter' is not visible
    stopifnot(identical(ff$counts(), length(ff$edits[[1]][[3]])))
ff$undo()
stopifnot(all.equal(ff$data, xMat))
rm(ff)
gc()
stopifnot(identical(markViewer, "OFF")) #check finalize

## tests of copying
viewerPlus <- setRefClass("viewerPlus",
                   fields = list( text = "character",
                      viewer = "matrixViewer"))
ff <- mv( data = xMat)
v1 <- viewerPlus(text = letters, viewer = ff)
v2 <- v1$copy()
v3 <- v1$copy(TRUE)
v2$text <- "Hello, world"
v2$viewer$data <- t(xMat) # change a field in v2$viewer
v3$text <- LETTERS
v3$viewer <- mv( data = matrix(nrow=1,ncol=1))
## with a deep copy all is protected, with a shallow copy
## the environment of a copied field remains the same,
## but replacing the whole field should be local
stopifnot(identical(v1$text, letters),
          identical(v1$viewer, ff),
          identical(v2$text, "Hello, world"))
v3 <- v1$copy(TRUE)
v3$viewer$data <- t(xMat) # should modify v1$viewer as well
stopifnot(identical(v1$viewer$data, t(xMat)))

## the field() method
stopifnot(identical(v1$text, v1$field("text")))
v1$field("text", "Now is the time")
stopifnot(identical(v1$field("text"), "Now is the time"))

## setting a non-existent field, or a method, should throw an error
stopifnot(is(tryCatch(v1$field("foobar", 0), error = function(e)e), "error"),
         is(tryCatch(v1$field("copy", 0), error = function(e)e), "error") )

## the methods to extract class definition and generator
stopifnot(identical(v3$getRefClass()$def, getRefClass("viewerPlus")$def),
          identical(v3$getClass(), getClass("viewerPlus")))

## deal correctly with inherited methods and overriding existing
## methods from $methods(...)
refClassA <- setRefClass("refClassA", methods=list(foo=function() "A"))
refClassB <- setRefClass("refClassB", contains="refClassA")
mnames <- objects(getClass("refClassB")@refMethods)
refClassB$methods(foo=function() callSuper())
stopifnot(identical(refClassB()$foo(), "A"))
mnames2 <- objects(getClass("refClassB")@refMethods)
stopifnot(identical(mnames2[is.na(match(mnames2,mnames))], "foo#refClassA"))
refClassB$methods(foo=function() paste(callSuper(), "Version 2"))
stopifnot(identical(refClassB()$foo(), "A Version 2"))
stopifnot(identical(mnames2, objects(getClass("refClassB")@refMethods)))

if(methods:::.hasCodeTools()) {
    ## code warnings assigning locally to field names
    stopifnot(is(tryCatch(mv$methods(test = function(x)
                                 { data <- x[!is.na(x)]; mean(data)}),
                          warning = function(e)e), "warning"))

    ## warnings for nonlocal assignment that is not a field
    stopifnot(is(tryCatch(mv$methods(test2 = function(x) {something <<- data[!is.na(x)]}), warning = function(e)e), "warning"))

    ## error for trying to assign to a method name
    stopifnot(is(tryCatch(mv$methods(test3 = function(x) {edit <<- data[!is.na(x)]}), error = function(e)e), "error"))
} else
    warning("Can't run some tests:  recommended package codetools is not available")

## tests (fragmentary by necessity) of promptClass for reference class
ccon <- textConnection("ctxt", "w")
suppressMessages(promptClass("refClassB", filename = ccon))
## look for a method, inheritance, inherited method
stopifnot(length(c(grep("foo.*refClassA", ctxt),
                   grep("code{foo()}", ctxt, fixed = TRUE),
                   grep("linkS4class{refClassA", ctxt, fixed = TRUE))) >= 3)
close(ccon)
rm(ctxt)


## tests related to subclassing environments.  These really test code in the core, viz. builtin.c
a <- refClassA()
ev <- new.env(parent = a) # parent= arg
stopifnot(is.environment(ev))
foo <- function()"A"; environment(foo) <- a # environment of function
stopifnot(identical(as.environment(a), environment(foo)))
xx <- 1:10; environment(xx) <- a # environment attribute
stopifnot(identical(as.environment(a), environment(xx)))


## tests of [[<- and $<- for subclasses of environment.  At one point
## methods for these assignments were defined and caused
## inf. recursion when the arguments to the [[<- case were changed in base.
setClass("myEnv", contains = "environment")
m <- new("myEnv", a="test")
m2 <- new("myEnv"); m3 <- new("myEnv")
## test that new.env() is called for each new object
stopifnot(!identical(as.environment(m), as.environment(m2)),
          !identical(as.environment(m3), as.environment(m2)))
m[["x"]] <- 1; m$y <- 2
stopifnot(identical(c(m[["x"]], m$y), c(1,2)), is(m, "myEnv"))
rm(x, envir = m) # check rm() works, does not clobber class
stopifnot(identical(sort(objects(m)), sort(c("a", "y"))),
          is(m, "myEnv"))

## tests of binding & environment tools with subclases of environment
lockBinding("y", m)
stopifnot(bindingIsLocked("y", m))
unlockBinding("y", m)
stopifnot(!bindingIsLocked("y", m))

makeActiveBinding("z", function(value) {
    if(missing(value))
        "dummy"
    else
        "dummy assignment"
}, m)
stopifnot(identical(get("z", m),"dummy"))
## assignment will return the value but do nothing
stopifnot(identical(assign("z","other", m), "other"),
          identical(get("z", m),"dummy"))


## this has to be last--Seems no way to unlock an environment!
lockEnvironment(m)
stopifnot(environmentIsLocked(m))

rm(m)
m <- new("myEnv")
stopifnot(length(ls(m)) == 0)
## used to contain the previous content


## test of callSuper() to a hidden default method for initialize() (== initFields)
TestClass <- setRefClass ("TestClass",
     fields = list (text = "character"),
     methods = list(
       print = function ()  {cat(text)},
       initialize = function(text = "", ...) callSuper(text = paste(text, ":", sep=""),...)
  ))
tt <- TestClass("hello world")
stopifnot(identical(tt$text, "hello world:"))
## now a subclass with another field & another layer of callSuper()
TestClass2 <- setRefClass("TestClass2",
        contains = "TestClass",
        fields = list( version = "integer"),
        methods = list(
          initialize = function(..., version = 0L)
              callSuper(..., version = version+1L))
  )
tt <- TestClass2("test", version = 1L)
stopifnot(identical(tt$text, "test:"), identical(tt$version, as.integer(2)))
tt <- TestClass2(version=3L) # default text
stopifnot(identical(tt$text, ":"), identical(tt$version, as.integer(4)))


## test some capabilities but read-only for .self
.changeAllFields <- function(replacement) {
    fields <- names(.refClassDef@fieldClasses)
    for(field in fields)
        eval(substitute(.self$FIELD <- replacement$FIELD,
                        list(FIELD = field)))
}

mEditor$methods(change = .changeAllFields)
xx <- mEditor(data = xMat)
xx$edit(2, 2, 0)

yy <- mEditor(data = xMat+1)
yy$change(xx)
stopifnot(identical(yy$data, xx$data), identical(yy$edits, xx$edits))

## but don't allow assigment
if(methods:::.hasCodeTools())
        stopifnot(is(tryCatch(yy$.self$data <- xMat, error = function(e)e), "error"))

## the locked binding of refGeneratorSlot class should prevent modifying
## methods, locking fields or setting accessor methods
## Nothing special about refGeneratorSlot in this test -- the point is just
## to use a standard reference class known to be defined in a package
evr <- getRefClass("refGeneratorSlot") # in methods
stopifnot(is(tryCatch(evr$methods(foo = function()"..."), error = function(e)e), "error"),
         is(tryCatch(evr$lock("def"), error = function(e)e), "error"),
         is(tryCatch(evr$accessors("def"), error = function(e)e), "error"))

##getRefClass() method and function should work with either
## a class name or a class representation (bug report 14600)
tg <- setRefClass("tg", fields = "a")
t1 <- tg(a=1)
tgg <- t1$getRefClass()
tggg <- getRefClass("tg")
stopifnot(identical(tgg$def, tggg$def),
          identical(tg$def, tgg$def))

## this used to fail in initFieldArgs() from partial matching "self"
selfClass <- setRefClass("selfClass",
        fields=list(
            self="character", super="character", sub="character"
        )
    )

stopifnot(identical(selfClass(self="B", super="A", sub="C")$self, "B"))
