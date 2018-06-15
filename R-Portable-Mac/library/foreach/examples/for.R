library(foreach)

n <- 10
nrows <- 5
ncols <- 5

# vector example
set.seed(17)
x <- numeric(n)
for (i in seq(along=x))
  x[i] <- rnorm(1)

set.seed(17)
y <- foreach(icount(n), .combine='c') %do%
  rnorm(1)

cat('results of vector example:\n')
print(identical(x, y))

# list example
set.seed(17)
x <- vector('list', length=n)
for (i in seq(length=n))
  x[i] <- list(rnorm(10))

set.seed(17)
y <- foreach(icount(n)) %do%
  rnorm(10)

cat('results of list example:\n')
print(identical(x, y))

# matrix example
set.seed(17)
cols <- vector('list', length=ncols)
for (i in seq(along=cols))
  cols[i] <- list(rnorm(nrows))
x <- do.call('cbind', cols)

set.seed(17)
y <- foreach(icount(ncols), .combine='cbind') %do%
  rnorm(nrows)

cat('results of matrix example:\n')
dimnames(y) <- NULL
print(identical(x, y))

# another matrix example
set.seed(17)
cols <- vector('list', length=ncols)
for (i in seq(along=cols)) {
  r <- numeric(nrows)
  for (j in seq(along=r))
    r[j] <- rnorm(1)
  cols[i] <- list(r)
}
x <- do.call('cbind', cols)

set.seed(17)
y <- foreach(icount(ncols), .combine='cbind') %:%
  foreach(icount(nrows), .combine='c') %do%
    rnorm(1)

cat('results of another matrix example:\n')
dimnames(y) <- NULL
print(identical(x, y))

# ragged matrix example
set.seed(17)
x <- vector('list', length=ncols)
for (i in seq(along=x))
  x[i] <- list(rnorm(i))

set.seed(17)
y <- foreach(i=icount(ncols)) %do%
  rnorm(i)

cat('results of ragged matrix example:\n')
print(identical(x, y))

# another ragged matrix example
set.seed(17)
x <- vector('list', length=ncols)
for (i in seq(along=x)) {
  r <- numeric(i)
  for (j in seq(along=r))
    r[j] <- rnorm(1)
  x[i] <- list(r)
}

set.seed(17)
y <- foreach(i=icount(ncols)) %:%
  foreach(icount(i), .combine='c') %do%
    rnorm(1)

cat('results of another ragged matrix example:\n')
print(identical(x, y))

# filtering example
set.seed(17)
a <- rnorm(10)

# C-style approach
x <- numeric(length(a))
n <- 0
for (i in a) {
  if (i > 0) {
    n <- n + 1
    x[n] <- i
  }
}
length(x) <- n

# Vector approach
y <- a[a > 0]

# foreach approach
z <- foreach(i=a, .combine='c') %:% when(i > 0) %do% i

cat('results of filtering example:\n')
print(identical(x, y))
print(identical(x, z))

# Define a function that creates an iterator that returns chunks of a vecto
ivector <- function(x, chunksize) {
  n <- length(x)
  i <- 1

  nextEl <- function() {
    if (n <= 0) stop('StopIteration')
    chunks <- ceiling(n / chunksize)
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    x[r]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# another filtering example
set.seed(17)
a <- rnorm(10000)

# Vector approach
x <- a[a > 0]

# foreach with vectorization, limiting vector lengths to 1000
y <- foreach(a=ivector(a, 1000), .combine='c') %do%
  a[a > 0]

cat('results of another filtering example:\n')
print(identical(x, y))
