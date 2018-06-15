library(iterators)

# return an iterator that returns the specified value forever
iforever <- function(x) {
  nextEl <- function() x
  obj <- list(nextElem=nextEl)
  class(obj) <- c('iforever', 'abstractiter', 'iter')
  obj
}

# create an iterator that returns 42 forever
it <- iforever(42)

# call it three times
for (i in 1:3)
  print(nextElem(it))
