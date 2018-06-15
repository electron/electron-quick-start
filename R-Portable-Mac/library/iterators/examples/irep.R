library(iterators)

# return an iterator that returns the specified value
# a limited number of times
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

# create an iterator that returns a 7 exactly 6 times
it <- irep(7, 6)

# convert the iterator into a list, which gets all of its values
print(unlist(as.list(it)))
