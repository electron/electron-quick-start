## examples for a simple class with two numeric slots.
## (Run example(setMethod) to see the class and function definitions)

  setClass("track", slots = c(x="numeric", y = "numeric"))

  cumdist <- function(x, y) c(0., cumsum(sqrt(diff(x)^2 + diff(y)^2)))
  setClass("trackMultiCurve", slots = c(x="numeric", y="matrix", smooth="matrix"),
          prototype = list(x=numeric(), y=matrix(0,0,0), smooth= matrix(0,0,0)))

require(graphics)


## methods for plotting track objects
##
## First, with only one object as argument, plot the two slots
##  y must be included in the signature, it would default to "ANY"
setMethod("plot", signature(x="track", y="missing"),
  function(x,  y, ...) plot(x@x, x@y, ...)
)

## plot numeric data on either axis against a track object
## (reducing the track object to the cumulative distance along the track)
## Using a short form for the signature, which matches like formal arguments
setMethod("plot", c("track", "numeric"),
 function(x, y, ...) plot(cumdist(x@x, x@y), y,  xlab = "Distance",...)
)

## and similarly for the other axis
setMethod("plot", c("numeric", "track"),
 function(x, y, ...) plot(x, cumdist(y@x, y@y),  ylab = "Distance",...)
)

t1 <- new("track", x=1:20, y=(1:20)^2)
plot(t1)
plot(qnorm(ppoints(20)), t1)

## Now a class that inherits from "track", with a vector for data at
## the points
  setClass("trackData", contains = c("numeric", "track"))


tc1 <- new("trackData", t1, rnorm(20))


## a method for plotting the object
## This method has an extra argument, allowed because ... is an
## argument to the generic function.
setMethod("plot", c("trackData", "missing"),
function(x, y, maxRadius = max(par("cin")), ...) {
  plot(x@x, x@y, type = "n", ...)
  symbols(x@x, x@y, circles = abs(x), inches = maxRadius)
  }
)
plot(tc1)

## Without other methods for "trackData", methods for "track"
## will be selected by inheritance

plot(qnorm(ppoints(20)), tc1)

## defining methods for primitive functions.
## Although "[" and "length" are not ordinary functions
## methods can be defined for them.
setMethod("[", "track",
  function(x, i, j, ..., drop) {
    x@x <- x@x[i]; x@y <- x@y[i]
    x
  })
plot(t1[1:15])

setMethod("length", "track", function(x)length(x@y))
length(t1)


setMethod("summary", "missing", function() "<No Object>")

stopifnot(identical(summary(), "<No Object>"))

removeMethods("summary")

## for the primitives
## inherited methods

length(tc1)
tc1[-1]

## make sure old-style methods still work.
t11 <- t1[1:15]
identical(t1@y[1:15], t11@y)

## S3 methods, with nextMethod
form <- y ~ x
form[1]

## S3 arithmetic methods
ISOdate(1990, 12, 1)- ISOdate(1980, 12, 1)

## group methods

setMethod("Arith", c("track", "numeric"), function(e1, e2){e1@y <-
  callGeneric(e1@y , e2); e1})

t1  - 100.
t1/2

## check it hasn't screwed up S3 methods
ISOdate(1990, 12, 1)- ISOdate(1980, 12, 1)

## test the .Generic mechanism

setMethod("Compare", signature("track", "track"),
  function(e1,e2) {
  switch(.Generic,
   "==" = e1@y == e2@y,
  NA)
 })

#stopifnot(all(t1==t1))
#stopifnot(identical(t1<t1, NA))


## A test of nested calls to "[" with matrix-style arguments
## applied to data.frames (S3 methods)

setMethod("[", c("trackMultiCurve", "numeric", "numeric"), function(x, i, j, ..., drop) {
### FIXME:  a better version has only 1st arg in signature
### and uses callNextMethod, when this works with primitives.
    x@y <- x@y[i, j, drop=FALSE]
    x@x <- x@x[i]
    x
})


"testFunc" <-
function(cur) {
    sorted <- cur[order(cur[,1]),]
    sorted[ !is.na(sorted[,1]), ]
}

Nrow <- 1000 # at one time, values this large triggered a bug in gc/protect
## the loop here was a trigger for the bug
Niter <- 10
for(i in 1:Niter)  {
    yy <- matrix(stats::rnorm(10*Nrow), 10, Nrow)
    tDF <- as.data.frame(yy)
    testFunc(tDF)
}


tMC <- new("trackMultiCurve", x=seq_len(Nrow), y = yy)
## not enough functions have methods for this class to use testFunc

stopifnot(identical(tMC[1:10, 1:10]@y, yy[1:10, 1:10]))


## verify we can remove methods and generic

removeMethods("-")
removeMethod("length", "track")
removeMethods("Arith")
removeMethods("Compare")

## repeat the test one more time on the primitives

length(ISOdate(1990, 12, 1)- ISOdate(1980, 12, 1))

removeMethods("length")

## methods for %*%, which isn't done by the same C code as other ops

setClass("foo", slots = c(m="matrix"))
m1 <- matrix(1:12,3,4)
f1 = new("foo", m=m1)
f2 = new("foo", m=t(m1))

setMethod("%*%", c("foo", "foo"),
          function(x,y) callGeneric(x@m, y@m))

stopifnot(identical(f1%*%f2, m1%*% t(m1)))

removeMethods("%*%")
removeMethods("plot")

if(FALSE) ## Hold until removeMethods revised:
  stopifnot(existsFunction("plot", FALSE) && !isGeneric("plot", 1))

## methods for plotData
plotData <- function(x, y, ...) plot(x, y, ...)

setGeneric("plotData")

setMethod("plotData", signature(x="track", y="missing"),
          function(x,  y, ...) plot(slot(x, "x"), slot(x, "y"), ...))

## and now remove the whole generic
removeGeneric("plotData")

stopifnot(!exists("plotData", 1))

##  Tests of method inheritance & multiple dispatch
setClass("A0", slots = c(a0 = "numeric"))
setClass("A1", contains = "A0", slots = c(a1 = "character"))

setClass("B0", slots = c(b0 = "numeric"))
setClass("B1", "B0") # (meaning 'contains = *')
setClass("B2", contains = "B1", slots = c(b2 = "logical"))

setClass("AB0", contains = c("A1", "B2"), slots = c(ab0 = "matrix"))

f1 <- function(x,  y)"ANY"

setGeneric("f1")

setMethod("f1", c("A0", "B1"), function(x, y)"A0 B1")
setMethod("f1", c("B1", "A0"), function(x, y)"B1 A0")

a0 <- new("A0")
a1 <- new("A1")
b0 <- new("B0")
b1 <- new("B1")
b2 <- new("B2")

deparseText <- function(expr)
    paste(deparse(expr), collapse = " ")

mustEqual <- function(e1, e2){
    if(!identical(e1, e2))
        stop(paste("!identical(", deparseText(substitute(e1)),
                   ", ", deparseText(substitute(e2)), ")", sep=""))
}

mustEqual(f1(a0, b0), "ANY")
mustEqual(f1(a1,b0), "ANY")
mustEqual(f1(a1,b1), "A0 B1")
mustEqual(f1(b1,a1), "B1 A0")
mustEqual(f1(b1,b1), "ANY")

## remove classes:  order matters so as not to undefine earlier classes
for(.cl in c("AB0", "A1", "A0", "B2", "B1", "B0"))
    removeClass(.cl)

removeGeneric("f1")

## test of nonstandard generic definition

setGeneric("doubleAnything", function(x) {
  methodValue <- standardGeneric("doubleAnything")
  c(methodValue, methodValue)
})

setMethod("doubleAnything", "ANY", function(x)x)

setMethod("doubleAnything", "character",
          function(x) paste("<",x,">",sep=""))

mustEqual(doubleAnything(1:10), c(1:10, 1:10))
mustEqual(doubleAnything("junk"), rep("<junk>",2))

removeGeneric("doubleAnything")

### From setOldClass.Rd
## Examples of S3 classes with guaranteed attributes
## an S3 class "stamped" with a vector and  a "date" attribute
## Here is a generator function and an S3 print method.
## NOTE:  it's essential that the generator checks the attribute classes
stamped <- function(x, date = Sys.time()) {
    if(!inherits(date, "POSIXt"))
      stop("bad date argument")
    if(!is.vector(x))
      stop("x must be a vector")
    attr(x, "date") <- date
    class(x) <- "stamped"
    x
}

print.stamped <- function(x, ...) {
    print(as.vector(x))
    cat("Date: ",  format(attr(x,"date")), "\n")
}

## Now, an S4 class with the same structure:
setClass("stamped4", contains = "vector", slots = c(date = "POSIXt"))

## We can use the S4 class to register "stamped", with its attributes:
setOldClass("stamped", S4Class = "stamped4")
selectMethod("show", "stamped")
## and then remove "stamped4" to clean up
removeClass("stamped4")

set.seed(113)
someLetters <- stamped(sample(letters, 10),
                       ISOdatetime(2008, 10, 15, 12, 0, 0))

st <- new("stamped", someLetters)
st
# show() method prints the object's class, then calls the S3 print method.

stopifnot(identical(S3Part(st, TRUE), someLetters))

# creating the S4 object directly from its data part and slots
new("stamped", 1:10, date = ISOdatetime(1976, 5, 5, 15, 10, 0))


  removeClass("stamped")
  rm(someLetters, st)

### from S3Part.Rd

## extending S3 class "lm", "xlm" directly
## and "ylm" indirectly
xlm <- setClass("xlm", slots = c(eps = "numeric"), contains = "lm")
ylm <- setClass("ylm", slots = c(header = "character"), contains = "xlm")

ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2,10,20, labels=c("Ctl","Trt"))
weight <- c(ctl, trt)
lm.D9 <- lm(weight ~ group)

## lm.D9 is as computed in the example for stats::lm
y1 <-ylm(lm.D9, header = "test", eps = .1)
xx <- xlm(lm.D9, eps =.1)
y2 <- ylm(xx, header = "test")
stopifnot(inherits(y2, "lm"))
stopifnot(identical(y1, y2))
stopifnot(identical(S3Part(y1, strict = TRUE), lm.D9))

## note the these classes can insert an S3 subclass of "lm" as the S3 part:
myData <- data.frame(time = 1:10, y = (1:10)^.5)
myLm <- lm(cbind(y, y^3)  ~ time, myData) # S3 class: c("mlm", "lm")
ym1 <- new("ylm", myLm, header = "Example", eps = 0.)

##similar classes to "xlm" and "ylm", but extending S3 class c("mlm", "lm")
setClass("xmm", slots = c(eps = "numeric"), contains = "mlm")
setClass("ymm", slots = c(header="character"), contains = "xmm")

ym2 <- new("ymm", myLm, header = "Example2", eps = .001)

# but for class "ymm", an S3 part of class "lm" is an error:
try(new("ymm", lm.D9, header = "Example2", eps = .001))
tools::assertError(
    new("ymm", lm.D9, header = "Example2", eps = .001))

setClass("dataFrameD", slots = c(date = "Date"),
         contains = "data.frame")
myDD <- new("dataFrameD", myData, date = Sys.Date())

## S3Part() applied to classes with a data part (.Data slot)

setClass("NumX", contains="numeric", slots = c(id="character"))
nn <- new("NumX", 1:10, id="test")
stopifnot(identical(1:10, S3Part(nn, strict = TRUE)))

m1 <- cbind(group, weight)
setClass("MatX", contains = "matrix", slots = c(date = "Date"))
mx1 <- new("MatX", m1, date = Sys.Date())
stopifnot(identical(m1, S3Part(mx1, strict = TRUE)))
