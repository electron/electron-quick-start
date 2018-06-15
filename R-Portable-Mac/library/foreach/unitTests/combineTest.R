# test cbind and rbind via .combine option
test01 <- function() {
  m <- matrix(rnorm(25 * 16), 25)

  x <- foreach(i=1:ncol(m), .combine='cbind') %do% m[,i]
  dimnames(x) <- NULL
  checkEquals(m, x)

  x <- foreach(i=1:ncol(m), .combine='cbind') %dopar% m[,i]
  dimnames(x) <- NULL
  checkEquals(m, x)

  x <- foreach(i=1:nrow(m), .combine='rbind') %do% m[i,]
  dimnames(x) <- NULL
  checkEquals(m, x)

  x <- foreach(i=1:nrow(m), .combine='rbind') %dopar% m[i,]
  dimnames(x) <- NULL
  checkEquals(m, x)
}

# test arithmetic operations via .combine option
test02 <- function() {
  x <- rnorm(100)

  d <- foreach(i=x, .combine='+') %do% i
  checkEquals(d, sum(x))

  d <- foreach(i=x, .combine='+') %dopar% i
  checkEquals(d, sum(x))

  d <- foreach(i=x, .combine='*') %do% i
  checkEquals(d, prod(x))

  d <- foreach(i=x, .combine='*') %dopar% i
  checkEquals(d, prod(x))
}

test03 <- function() {
  x <- 1:10
  adder <- function(...) {
    sum(...)
  }

  d <- foreach(i=x, .combine=adder, .multicombine=TRUE) %dopar% i
  checkEquals(d, sum(x))

  d <- foreach(i=x, .combine=adder, .multicombine=FALSE) %dopar% i
  checkEquals(d, sum(x))

  d <- foreach(i=x, .combine=adder, .multicombine=TRUE) %do% i
  checkEquals(d, sum(x))

  d <- foreach(i=x, .combine=adder, .multicombine=FALSE) %do% i
  checkEquals(d, sum(x))
}
