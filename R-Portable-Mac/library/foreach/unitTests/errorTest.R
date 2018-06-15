test01 <- function() {
  x <- 1:3
  checkException(foreach(i=x) %do% if (i == 2) stop('error') else i)
  checkException(
    foreach(i=x, .errorhandling='stop') %do%
      if (i == 2) stop('error') else i)
}

test02 <- function() {
  x <- 1:3
  actual <- foreach(i=x, .errorhandling='remove') %do%
    if (i == 2) stop('error') else i
  checkEquals(actual, list(1L, 3L))

  actual <- foreach(i=x, .errorhandling='remove') %do% stop('remove')
  checkEquals(actual, list())
}

test03 <- function() {
  x <- 1:3
  actual <- foreach(i=x, .errorhandling='pass') %do%
    if (i == 2) stop('error') else i
  checkEquals(1L, actual[[1]])
  checkTrue(inherits(actual[[2]], 'simpleError'))
  checkEquals(3L, actual[[3]])
}

test04 <- function() {
  n <- 3
  actual <- foreach(icount(n)) %:%
    foreach(icount(10), .errorhandling='remove') %do%
      stop('hello')
  checkEquals(actual, lapply(1:n, function(i) list()))
}
