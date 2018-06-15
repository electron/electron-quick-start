library(foreach)

feapply <- function(X, MARGIN, FUN, ...) {
  FUN <- match.fun(FUN)

  r <- foreach(x=iapply(X, MARGIN)) %do% {
    x <- FUN(x, ...)
    dim(x) <- NULL
    x
  }

  n <- unlist(lapply(r, length))
  if (all(n[1] == n)) {
    r <- unlist(r)
    dim(r) <- if (n[1] == 1) dim(X)[MARGIN] else c(n[1], dim(X)[MARGIN])
  } else if (length(MARGIN) > 1) {
    dim(r) <- dim(X)[MARGIN]
  }
  r
}

a <- array(rnorm(24), c(2, 3, 4))
m <- diag(2, 3, 2)
MARGIN <- 3
fun <- function(x, m) x %*% m
expected <- apply(a, MARGIN, fun, m)
actual <- feapply(a, MARGIN, fun, m)

print(identical(expected, actual))
