library(foreach)

w <- getDoParWorkers()
n <- 10000000
h <- 1 / n

pi <- foreach(i=1:w, .combine='+') %dopar% {
  x <- h * (seq(i, n, by=w) - 0.5)
  h * sum(4 / (1 + x * x))
}

cat(sprintf('pi = %f\n', pi))
