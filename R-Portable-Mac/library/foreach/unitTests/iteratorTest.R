# test matrix iterator with foreach
test01 <- function() {
  m <- matrix(rnorm(25 * 16), 25)

  x <- foreach(col=iter(m, by='col'), .combine='cbind') %do% col
  checkEquals(m, x)

  x <- foreach(col=iter(m, by='col'), .combine='cbind') %dopar% col
  checkEquals(m, x)

  x <- foreach(row=iter(m, by='row'), .combine='rbind') %do% row
  checkEquals(m, x)

  x <- foreach(row=iter(m, by='row'), .combine='rbind') %dopar% row
  checkEquals(m, x)
}

# test data.frame iterator with foreach
test02 <- function() {
  d <- data.frame(a=1:10,b=11:20,c=21:30)
  ed <- data.matrix(d)

  x <- foreach(col=iter(d, by='col'), .combine='cbind') %do% col
  colnames(x) <- colnames(ed)
  checkEquals(ed, x)

  x <- foreach(col=iter(d, by='col'), .combine='cbind') %dopar% col
  colnames(x) <- colnames(ed)
  checkEquals(ed, x)

  x <- foreach(row=iter(d, by='row'), .combine='rbind') %do% row
  checkEquals(d, x)

  x <- foreach(row=iter(d, by='row'), .combine='rbind') %dopar% row
  checkEquals(d, x)
}

# test function iterator with foreach and %do%
test03 <- function() {
  
  func <- function() {
    y = NULL
    repeat {
      x = rnorm(1)
      if (x < -3.0) stop('StopIteration')
      if (10 == length(y))
        break
      else
        if (0 < x) y = c(y, x)
    }
    y
  }

  ## XXX mean is not a reasonable combine function
  ## XXX removed this for the moment - sbw
  ## r <- foreach(v=iter(func), .combine='mean') %do% mean(v)
  ## 'r' is NULL if iteration stops early.
  ## checkTrue(is.null(r) || 0 < r)
}

# test function iterator with foreach and %dopar%
test04 <- function() {

  func <- function() {
    y = NULL
    repeat {
      x = rnorm(1)
      if (x < -3.0) stop('StopIteration')
      if (10 == length(y))
        break
      else
        if (0 < x) y = c(y, x)
    }
    y
  }

  ## XXX mean is not a reasonable combine function
  ## XXX removed this for the moment - sbw
  ## r <- foreach(v=iter(func), .combine='mean') %dopar% mean(v)
  ## 'r' is NULL if iteration stops early.
  ## checkTrue(is.null(r) || 0 < r)
}
