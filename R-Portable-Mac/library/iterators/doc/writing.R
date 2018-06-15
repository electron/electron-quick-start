### R code from vignette source 'writing.Rnw'

###################################################
### code chunk number 1: loadLibs
###################################################
library(iterators)


###################################################
### code chunk number 2: iterable1
###################################################
it <- iter(list(1:2, 3:4))


###################################################
### code chunk number 3: iterable2
###################################################
nextElem(it)
nextElem(it)
tryCatch(nextElem(it), error=function(e) e)


###################################################
### code chunk number 4: nextElem.abstractiter
###################################################
iterators:::iter.iter
iterators:::nextElem.abstractiter


###################################################
### code chunk number 5: iter1
###################################################
iforever <- function(x) {
  nextEl <- function() x
  obj <- list(nextElem=nextEl)
  class(obj) <- c('iforever', 'abstractiter', 'iter')
  obj
}


###################################################
### code chunk number 6: runiter1
###################################################
it <- iforever(42)
nextElem(it)
nextElem(it)


###################################################
### code chunk number 7: runiter1.part2
###################################################
unlist(as.list(it, n=6))


###################################################
### code chunk number 8: iter2
###################################################
irep <- function(x, times) {
  nextEl <- function() {
    if (times > 0)
      times <<- times - 1
    else
      stop('StopIteration')

    x
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('irep', 'abstractiter', 'iter')
  obj
}


###################################################
### code chunk number 9: runiter2
###################################################
it <- irep(7, 6)
unlist(as.list(it))


###################################################
### code chunk number 10: iter3
###################################################
ivector <- function(x, ...) {
 i <- 1
 it <- idiv(length(x), ...)

 nextEl <- function() {
   n <- nextElem(it)
   ix <- seq(i, length=n)
   i <<- i + n
   x[ix]
 }

 obj <- list(nextElem=nextEl)
 class(obj) <- c('ivector', 'abstractiter', 'iter')
 obj
}


###################################################
### code chunk number 11: runiter3
###################################################
it <- ivector(1:25, chunks=3)
as.list(it)


###################################################
### code chunk number 12: generichasnext
###################################################
hasNext <- function(obj, ...) {
  UseMethod('hasNext')
}


###################################################
### code chunk number 13: hasnextmethod
###################################################
hasNext.ihasNext <- function(obj, ...) {
  obj$hasNext()
}


###################################################
### code chunk number 14: ihasnext
###################################################
ihasNext <- function(it) {
  if (!is.null(it$hasNext)) return(it)
  cache <- NULL
  has_next <- NA

  nextEl <- function() {
    if (!hasNx())
      stop('StopIteration', call.=FALSE)
    has_next <<- NA
    cache
  }

  hasNx <- function() {
    if (!is.na(has_next)) return(has_next)
    tryCatch({
      cache <<- nextElem(it)
      has_next <<- TRUE
    },
    error=function(e) {
      if (identical(conditionMessage(e), 'StopIteration')) {
        has_next <<- FALSE
      } else {
        stop(e)
      }
    })
    has_next
  }

  obj <- list(nextElem=nextEl, hasNext=hasNx)
  class(obj) <- c('ihasNext', 'abstractiter', 'iter')
  obj
}


###################################################
### code chunk number 15: hasnextexample
###################################################
it <- ihasNext(icount(3))
while (hasNext(it)) {
  print(nextElem(it))
}


###################################################
### code chunk number 16: recyle
###################################################
irecycle <- function(it) {
  values <- as.list(iter(it))
  i <- length(values)

  nextEl <- function() {
    i <<- i + 1
    if (i > length(values)) i <<- 1
    values[[i]]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('irecycle', 'abstractiter', 'iter')
  obj
}


###################################################
### code chunk number 17: recyleexample
###################################################
it <- irecycle(icount(3))
unlist(as.list(it, n=9))


###################################################
### code chunk number 18: ilimit
###################################################
ilimit <- function(it, times) {
  it <- iter(it)

  nextEl <- function() {
    if (times > 0)
      times <<- times - 1
    else
      stop('StopIteration')

    nextElem(it)
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('ilimit', 'abstractiter', 'iter')
  obj
}


###################################################
### code chunk number 19: irep2
###################################################
irep2 <- function(x, times)
  ilimit(iforever(x), times)


###################################################
### code chunk number 20: testirep2
###################################################
it <- ihasNext(irep2('foo', 3))
while (hasNext(it)) {
  print(nextElem(it))
}


###################################################
### code chunk number 21: testirecycle
###################################################
iterable <- 1:3
n <- 3
it <- ilimit(irecycle(iterable), n * length(iterable))
unlist(as.list(it))


###################################################
### code chunk number 22: rep
###################################################
rep(iterable, n)


