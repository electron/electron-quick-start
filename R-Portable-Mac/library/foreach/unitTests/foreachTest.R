test01 <- function() {
  x <- 1:3
  actual <- foreach(i=x) %do% i
  checkEquals(actual, as.list(x))
  actual <- foreach(i=x, .combine='c') %do% i
  checkEquals(actual, x)
}

test02 <- function() {
  x <- 1:101
  actual <- foreach(i=x, .combine='+') %dopar% i
  checkEquals(actual, sum(x))
}

test03 <- function() {
  x <- 1:3
  y <- 2:0
  for (i in 1:3) {
    actual <- foreach(i=x, .combine='c', .inorder=TRUE) %dopar% {
      Sys.sleep(y[i])
      i
    }
    checkEquals(actual, x)
  }
}
