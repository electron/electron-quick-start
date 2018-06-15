# simple test of recycle
test01 <- function() {
  if (require(foreach, quietly=TRUE)) {
    nr <- 21
    nc <- 17
    x <- rnorm(nr)
    it <- iter(x, recycle=TRUE)
    actual <- foreach(y=it, icount(nr*nc), .combine='c') %do% y
    dim(actual) <- c(nr, nc)
    expected <- matrix(x, nr, nc)
    checkEquals(actual, expected)
  }
}
