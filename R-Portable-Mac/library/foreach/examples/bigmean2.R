library(foreach)

# Define a combine function for the partial results
comb <- function(...) {
  n <- foreach(a=list(...), .combine='+') %do% a$n
  means <- foreach(a=list(...), .combine='+') %do% ((a$n / n) * a$means)
  list(n=n, means=means)
}

# initialize some parameters
datafile <- 'germandata.txt'
nrows <- 100  # germandata.txt only has 1000 rows of data

# create an iterator over the data in the file
it <- iread.table(datafile, nrows=nrows, header=FALSE, row.names=NULL)

# Compute the mean of each of those fields, nrows records at a time
print(system.time(
  r <- foreach(d=it, .combine=comb, .multicombine=TRUE, .final=function(a) a$mean) %do%
    list(n=nrow(d), means=mean(d))
))
print(r)

# This is faster for small problems (when it may not matter),
# but becomes slower (or fails) for big problems
print(system.time({
  d <- read.table(datafile)
  r <- mean(d)
}))
print(r)
