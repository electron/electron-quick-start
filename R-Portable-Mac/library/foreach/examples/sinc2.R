library(foreach)

# Define a function that creates an iterator that returns subvectors
ivector <- function(x, chunks) {
  n <- length(x)
  i <- 1

  nextEl <- function() {
    if (chunks <= 0 || n <= 0) stop('StopIteration')
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    chunks <<- chunks - 1
    x[r]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# Define the coordinate grid and figure out how to split up the work
x <- seq(-10, 10, by=0.1)
nw <- getDoParWorkers()
cat(sprintf('Running with %d worker(s)\n', nw))

# Compute the value of the sinc function at each point in the grid
z <- foreach(y=ivector(x, nw), .combine=cbind) %dopar% {
  y <- rep(y, each=length(x))
  r <- sqrt(x ^ 2 + y ^ 2)
  matrix(10 * sin(r) / r, length(x))
}

# Plot the results as a perspective plot
persp(x, x, z, ylab='y', theta=30, phi=30, expand=0.5, col="lightblue")
