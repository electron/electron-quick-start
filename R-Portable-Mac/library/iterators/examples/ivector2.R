library(iterators)

# return an iterator that returns subvectors of a vector.
# can specify either "chunks" or "chunkSize" arguments
# since that is what the "idiv" function supports.
ivector <- function(x, ...) {
  # don't evaluate x if is specified using the ':' operator
  q <- substitute(x)
  if (identical(q[[1]], as.name(':'))) {
    rm(list='x')  # being paranoid: don't want to evaluate promise
    lower <- as.integer(eval.parent(q[[2]]))
    upper <- as.integer(eval.parent(q[[3]]))
    inc <- if (upper >= lower) 1L else -1L
    len <- abs(upper - lower) + 1L
    it <- idiv(len, ...)

    nextEl <- function() {
      n <- nextElem(it)
      y <- seq(lower, by=inc, length=n)
      lower <<- lower + (inc * n)
      y
    }
  } else {
    i <- 1
    it <- idiv(length(x), ...)

    nextEl <- function() {
      n <- nextElem(it)
      ix <- seq(i, length=n)
      i <<- i + n
      x[ix]
    }
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('ivector', 'abstractiter', 'iter')
  obj
}

# create a vector iterator that returns three subvectors
it <- ivector(1:25, chunks=3)
print(as.list(it))

# create a vector iterator that returns subvectors
# with a maximum length of 10
it <- ivector(25:1, chunkSize=10)
print(as.list(it))
