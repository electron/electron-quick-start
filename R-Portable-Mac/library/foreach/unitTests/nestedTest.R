# Test nesting of "%do% and %dopar% in 01, 02, 03, and 04.

test01 <- function() {
  y <- foreach(j=seq(0,90,by=10), .combine='c', .packages='foreach') %do% {
    foreach(k=seq(1,10), .combine='c') %do% {
      (j+k)
    }
  }
  checkEquals(y,1:100)
}
test02 <- function() {
  y <- foreach(j=seq(0,90,by=10), .combine='c', .packages='foreach') %do% {
    foreach(k=seq(1,10), .combine='c') %dopar% {
      (j+k)
    }
  }
  checkEquals(y,1:100)
}
test03 <- function() {
  y <- foreach(j=seq(0,90,by=10), .combine='c', .packages='foreach') %dopar% {
    foreach(k=seq(1,10), .combine='c') %do% {
      (j+k)
    }
  }
  checkEquals(y,1:100)
}
test04 <- function() {
  y <- foreach(j=seq(0,90,by=10), .combine='c', .packages='foreach') %dopar% {
    foreach(k=seq(1,10), .combine='c') %dopar% {
      (j+k)
    }
  }
  checkEquals(y,1:100)
}

# test05 <- function() {
#   s <- getSleigh()
#   y <- eachWorker(s, eo=list(closure=TRUE),
#                   function() {
#                     library('foreach')
#                      foreach(j=seq(0,90,by=10), .combine='c') %do% {
#                        foreach(k=seq(1,10), .combine='c') %do% {
#                          (j+k)
#                        }
#                      }
#                    })
#   wc <- workerCount(s)
#   checkEquals(length(y), wc)
#   foreach(i=1:wc) %do% checkEquals(y[[i]],1:100)
# }
# test06 <- function() {
#   s <- getSleigh()
#   y <- eachWorker(s, eo=list(closure=TRUE),
#                   function() {
#                     library('foreach')
#                      foreach(j=seq(0,90,by=10), .combine='c') %do% {
#                        foreach(k=seq(1,10), .combine='c') %dopar% {
#                          (j+k)
#                        }
#                      }
#                    })
#   wc <- workerCount(s)
#   checkEquals(length(y), wc)
#   foreach(i=1:wc) %do% checkEquals(y[[i]],1:100)
# }
# test07 <- function() {
#   s <- getSleigh()
#   y <- eachWorker(s, eo=list(closure=TRUE),
#                   function() {
#                     library('foreach')
#                      foreach(j=seq(0,90,by=10), .combine='c', .packages='foreach') %dopar% {
#                        foreach(k=seq(1,10), .combine='c') %do% {
#                          (j+k)
#                        }
#                      }
#                    })
#   wc <- workerCount(s)
#   checkEquals(length(y), wc)
#   foreach(i=1:wc) %do% checkEquals(y[[i]],1:100)
# }
