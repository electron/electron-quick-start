library(iterators)

# test isplit with a single factor
test01 <- function() {
  x <- rnorm(200)
  f <- factor(sample(1:10, length(x), replace=TRUE))

  it <- isplit(x, f)
  expected <- split(x, f)

  for (i in expected) {
    actual <- nextElem(it)
    checkEquals(actual$value, i)
  }

  it <- isplit(x, f, drop=TRUE)
  expected <- split(x, f, drop=TRUE)

  for (i in expected) {
    actual <- nextElem(it)
    checkEquals(actual$value, i)
  }
}

# test isplit with two factors
test02 <- function() {
  x <- rnorm(200)
  f <- list(factor(sample(1:10, length(x), replace=TRUE)),
            factor(sample(1:10, length(x), replace=TRUE)))

  it <- isplit(x, f)
  expected <- split(x, f)

  for (i in expected) {
    actual <- nextElem(it)
    checkEquals(actual$value, i)
  }

  it <- isplit(x, f, drop=TRUE)
  expected <- split(x, f, drop=TRUE)

  for (i in expected) {
    actual <- nextElem(it)
    checkEquals(actual$value, i)
  }
}
