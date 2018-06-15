# tuning random forest over mtry parameter in parallel

library(foreach)
library(randomForest)

# a simple iterator over different values for the mtry argument
mtryiter <- function(from, to, stepFactor=2) {
  nextEl <- function() {
    if (from > to) stop('StopIteration')
    i <- from
    from <<- ceiling(from * stepFactor)
    i
  }
  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# vector of ntree values that we're interested in
vntree <- c(25, 50, 100, 200, 500, 1000)

# function that gets random forest error information for different values of mtry
tune <- function(x, y, ntree=vntree, mtry=NULL, keep.forest=FALSE, ...) {
  comb <- if (is.factor(y))
    function(a, b) rbind(a, data.frame(ntree=ntree, mtry=b$mtry, error=b$err.rate[ntree, 1]))
  else
    function(a, b) rbind(a, data.frame(ntree=ntree, mtry=b$mtry, error=b$mse[ntree]))

  foreach(mtry=mtryiter(1, ncol(x)), .combine=comb, .init=NULL,
          .packages='randomForest') %dopar% {
    randomForest(x, y, ntree=max(ntree), mtry=mtry, keep.forest=FALSE, ...)
  }
}

# generate the inputs
x <- matrix(runif(2000), 100)
y <- gl(2, 50)

# execute randomForest
results <- tune(x, y)

# print the result
print(results)
