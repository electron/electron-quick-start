test01 <- function() {
  x <- c(1,10, 100, 1000, 10000)
  y <- c(1,10, 100, 1000, 10000)
  d <- expand.grid(x=x, y=y)

  foreach (i=seq_along(d$x), .combine='c') %do% {
    r <- foreach(icount(10), .combine='c') %do% (3 + 8)
    foreach(i=seq_along(r)) %do% checkEquals(r[i], 11L)
  }
  foreach (i=seq_along(d$x), .combine='c') %do% {
    r <- foreach(icount(10), .combine='c') %dopar% (3 + 8)
    foreach(i=seq_along(r)) %do% checkEquals(r[i], 11L)
  }
}
