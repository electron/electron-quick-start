# Less inefficient parallel matrix multiply using custom matrix iterator

library(foreach)

iblkcol <- function(a, chunks) {
  n <- ncol(a)
  i <- 1

  nextEl <- function() {
    if (chunks <= 0 || n <= 0) stop('StopIteration')
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    chunks <<- chunks - 1
    a[,r, drop=FALSE]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# generate the input matrices
x <- matrix(rnorm(100), 10)
y <- matrix(rnorm(100), 10)

# multiply the matrices
nw <- getDoParWorkers()
cat(sprintf('Running with %d worker(s)\n', nw))
mit <- iblkcol(y, nw)
z <- foreach(y=mit, .combine=cbind) %dopar% (x %*% y)

# print the results
print(z)

# check the results
print(all.equal(z, x %*% y))
