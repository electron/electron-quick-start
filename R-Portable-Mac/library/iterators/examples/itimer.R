library(iterators)

# Returns an iterator that limits another iterator based on time
itimer <- function(it, time) {
  it <- iter(it)
  start <- proc.time()[[3]]

  nextEl <- function() {
    current <- proc.time()[[3]]
    if (current - start >= time)
      stop('StopIteration')

    nextElem(it)
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('itimer', 'abstractiter', 'iter')
  obj
}

# Create a iterator that counts for one second
it <- itimer(icount(Inf), 1)
tryCatch({
  repeat {
    print(nextElem(it))
  }
},
error=function(e) {
  cat('timer expired\n')
})
