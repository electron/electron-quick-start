# simple (and inefficient) parallel matrix multiply

library(foreach)

# generate the input matrices
x <- matrix(rnorm(16), 4)
y <- matrix(rnorm(16), 4)

# multiply the matrices
z <- foreach(y=iter(y, by='col'), .combine=cbind) %dopar% (x %*% y)

# print the results
print(z)

# check the results
print(all.equal(z, x %*% y))
