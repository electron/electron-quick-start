test01 <- function() {
  m <- 1000  # number of vectors
  for (n in c(100, 1000, 4000, 10000)) {
    r <- foreach(x=irnorm(n, mean=1000, count=m), .combine='+') %dopar% sqrt(x)
    checkTrue(is.atomic(r))
    checkTrue(inherits(r, 'numeric'))
    checkTrue(length(r) == n)
  }
}
