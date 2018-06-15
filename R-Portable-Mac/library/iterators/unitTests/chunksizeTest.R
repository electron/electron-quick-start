library(iterators)

# test that various values of chunksize
test01 <- function() {
  nr <- 13
  nc <- 21
  mat <- matrix(rnorm(nr * nc), nr)

  for (n in 1:(nc+2)) {
    it <- iter(mat, by='col', chunksize=n)
    bcols <- as.list(it)
    for (bcol in bcols) {
      checkTrue(nrow(bcol) == nr)
      checkTrue(ncol(bcol) <= n && ncol(bcol) >= 1)
    }
    actual <- do.call('cbind', bcols)
    checkEquals(mat, actual)
  }

  for (n in 1:(nr+2)) {
    it <- iter(mat, by='row', chunksize=n)
    brows <- as.list(it)
    for (brow in brows) {
      checkTrue(ncol(bcol) == nc)
      checkTrue(nrow(brow) <= n && nrow(brow) >= 1)
    }
    actual <- do.call('rbind', brows)
    checkEquals(mat, actual)
  }
}
