library(iterators)

# This example was originally written and contributed
# by Hadley Wickham, with minor modifications by
# Revolution Analytics

# Define a hasNext generic function
hasNext <- function(obj, ...) {
  UseMethod('hasNext')
}

# Define a hasNext method for the "ihasNext" class
hasNext.ihasNext <- function(obj, ...) {
  obj$hasNext()
}

# This function takes an iterator and returns an iterator that supports
# the "hasNext" method.  This simplifies manually calling the "nextElem"
# method of the iterator, since you don't have to worry about catching
# the "StopIteration" exception.
ihasNext <- function(it) {
  it <- iter(it)

  # If "it" already has a hasNext function, return it unchanged
  if (!is.null(it$hasNext))
    return(it)

  cache <- NULL
  has_next <- NA

  nextEl <- function() {
    if (!hasNx())
      stop('StopIteration', call.=FALSE)

    # Reset the "has_next" flag and return the value
    has_next <<- NA
    cache
  }

  hasNx <- function() {
    # Check if you already know the answer
    if (!is.na(has_next))
      return(has_next)

    # Try to get the next element
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

# Create a "counting" iterator that has a hasNext method
it <- ihasNext(icount(3))

# Print the values of the iterator without the need for error handling
while (hasNext(it))
  print(nextElem(it))
