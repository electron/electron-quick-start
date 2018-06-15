test01 <- function() {
  actual <-
    foreach(i=1:5) %:%
      when(i %% 2 == 1) %:%
        foreach(j=1:5) %:%
          when(j %% 2 == 1 && i != j) %do%
            c(i, j)
  expected <- list(list(c(1, 3), c(1, 5)),
                   list(c(3, 1), c(3, 5)),
                   list(c(5, 1), c(5, 3)))
  checkEquals(actual, expected)

  actual <-
    foreach(i=1:5, .combine='c') %:%
      when(i %% 2 == 1) %:%
        foreach(j=1:5) %:%
          when(j %% 2 == 1 && i != j) %do%
            c(i, j)
  expected <- list(c(1, 3), c(1, 5),
                   c(3, 1), c(3, 5),
                   c(5, 1), c(5, 3))
  checkEquals(actual, expected)
}

test02 <- function() {
  qsort <- function(x) {
    n <- length(x)
    if (n == 0) {
      x
    } else {
      p <- sample(n, 1)
      smaller <- foreach(y=x[-p], .combine=c) %:% when(y <= x[p]) %do% y
      larger  <- foreach(y=x[-p], .combine=c) %:% when(y >  x[p]) %do% y
      c(qsort(smaller), x[p], qsort(larger))
    }
  }

  x <- runif(100)
  a <- qsort(x)
  b <- sort(x)
  checkEquals(a, b)
}
