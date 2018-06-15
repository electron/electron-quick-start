# a simple parallel random forest

library(foreach)
library(randomForest)

# generate the inputs
nr <- 1000
x <- matrix(runif(100000), nr)
y <- gl(2, nr/2)

# split the total number of trees by the number of parallel execution workers
nw <- getDoParWorkers()
cat(sprintf('Running with %d worker(s)\n', nw))
it <- idiv(1000, chunks=nw)

# run the randomForest jobs, and combine the results
print(system.time({
rf <- foreach(ntree=it, .combine=combine, .multicombine=TRUE,
              .inorder=FALSE, .packages='randomForest') %dopar% {
  randomForest(x, y, ntree=ntree, importance=TRUE)
}
}))

# print the result
print(rf)
