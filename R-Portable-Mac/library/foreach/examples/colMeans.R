# compute the mean of the columns and the rows of a matrix

library(foreach)

# generate the input matrix
x <- matrix(rnorm(100 * 100), 100)

# compute the mean of each column of x
cmeans <- foreach(i=1:ncol(x), .combine=c) %do% mean(x[,i])

# check the results
expected <- colMeans(x)
print(all.equal(cmeans, expected))

# compute the mean of each row of x
rmeans <- foreach(i=1:nrow(x), .combine=c) %do% mean(x[i,])

# check the results
expected <- rowMeans(x)
print(all.equal(rmeans, expected))
