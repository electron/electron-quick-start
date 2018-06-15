library(iterators)

# Returns a filtering iterator
ifilter <- function(it, FUN, ...) {
  it <- iter(it)

  nextEl <- function() {
    repeat {
      x <- nextElem(it)
      if (FUN(x, ...))
        break
    }
    x
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('ifilter', 'abstractiter', 'iter')
  obj
}

# Simple example use
it <- irnorm(1, count=10)
is.positive <- function(x) x > 0
print(as.list(ifilter(it, is.positive)))

# Example using a function with an additional argument
it <- irnorm(1, count=10)
greater.than <- function(x, y) x > y
print(as.list(ifilter(it, greater.than, 1.0)))
