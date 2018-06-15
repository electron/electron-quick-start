# Try loading thye package splines and running a function from it.

test01 <- function() {

# First unload the package if it is already loaded.
# eachWorker(getSleigh(),
#              function() {
# 	          pkg <- "package:splines"
#                  if(pkg %in% search()) detach(pkg)})

  d <- foreach(1:10, .packages='splines', .combine='c') %dopar%
               xyVector(c(1:3),c(4:6))[[1]]
  checkTrue(all(c(1:3)==d))
}

