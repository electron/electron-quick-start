library(iterators)

# This functions returns an iterator that recycles the values of
# the specified iterator
irecycle <- function(it) {
  values <- as.list(iter(it))
  i <- length(values)
  if (i == 0) stop('iterator must have at least one value')

  nextEl <- function() {
    i <<- i + 1
    if (i > length(values))
      i <<- 1
    values[[i]]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('irecycle', 'abstractiter', 'iter')
  obj
}

it <- irecycle(icount(3))
for (i in 1:9)
  print(nextElem(it))
