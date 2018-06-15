test01 <- function() {
  if (require(foreach, quietly=TRUE)) {
    xcountn <- function(x) {
      iter(do.call('expand.grid', lapply(x, seq_len)), by='row')
    }

    vv <- list(0, 1, 2, 10, 100,
               c(0, 1), c(0, 2), c(3, 0),
               c(1, 1), c(1, 2), c(1, 3),
               c(2, 1), c(2, 2), c(2, 3),
               c(10, 10, 0, 10),
               c(1, 1, 2, 1, 1, 3, 1, 1, 1, 2, 1, 1, 1),
               c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
               c(10, 10, 10, 10))
    for (v in vv) {
      ait <- icountn(v)
      xit <- xcountn(v)
      foreach(actual=ait, expected=xit) %do% {
        checkEquals(actual, unname(unlist(expected)))
      }
    }
  }
}
