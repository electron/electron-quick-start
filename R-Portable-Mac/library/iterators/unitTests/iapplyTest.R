library(iterators)

# test iapply on 3D arrays
test01 <- function() {
  test <- function(actual, it) {
    expected <- nextElem(it)
    checkEquals(expected, actual)
    NULL
  }

  a <- array(1:24, c(2,3,4))

  margins <- list(1, 2, 3,
                  c(1, 2), c(1, 3), c(2, 1), c(2, 3), c(3, 1), c(3, 2),
                  c(1, 2, 3), c(1, 3, 2), c(2, 1, 3), c(2, 3, 1),
                  c(3, 1, 2), c(3, 2, 1))
  for(MARGIN in margins) {
    # cat(sprintf('testing %s\n', paste(MARGIN, collapse=', ')))
    it <- iapply(a, MARGIN)
    apply(a, MARGIN, test, it)
  }
}

# test iapply on matrices
test02 <- function() {
  test <- function(actual, it) {
    expected <- nextElem(it)
    checkEquals(expected, actual)
    NULL
  }

  m <- matrix(1:24, c(6,4))

  margins <- list(1, 2, c(1, 2), c(2, 1))
  for(MARGIN in margins) {
    # cat(sprintf('testing %s\n', paste(MARGIN, collapse=', ')))
    it <- iapply(m, MARGIN)
    apply(m, MARGIN, test, it)
  }
}
