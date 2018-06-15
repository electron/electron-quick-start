# simple foreach example that plots the sinc function

library(foreach)

# Define the coordinate grid to use
x <- seq(-10, 10, by=0.1)

# Compute starting indices for each task
nw <- getDoParWorkers()
cat(sprintf('Running with %d worker(s)\n', nw))
n <- ceiling(length(x) / nw)
ind <- seq(by=n, length=nw)

# Compute the value of the sinc function at each point in the grid
z <- foreach(i=ind, .combine=cbind) %dopar% {
  j <- min(i + n - 1, length(x))
  d <- expand.grid(x=x, y=x[i:j])
  r <- sqrt(d$x^2 + d$y^2)
  matrix(10 * sin(r) / r, length(x))
}

# Plot the results as a perspective plot
persp(x, x, z, ylab='y', theta=30, phi=30, expand=0.5, col="lightblue")
