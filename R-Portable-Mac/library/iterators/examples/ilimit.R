library(iterators)

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

it <- ilimit(icount(Inf), 3)
print(nextElem(it))
print(nextElem(it))
print(nextElem(it))
print(tryCatch(nextElem(it), error=function(e) e))
