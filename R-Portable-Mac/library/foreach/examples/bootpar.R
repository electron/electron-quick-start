# foreach version based on for-loop version from Wikipedia
# http://en.wikipedia.org/wiki/Bootstrapping_(statistics)
library(foreach)
data(iris)
x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000
opts <- list(chunkSize=150)

print(system.time(
r <- foreach(icount(trials), .combine=cbind,
             .options.nws=opts, .options.smp=opts) %dopar% {
  ind <- sample(100, 100, replace=TRUE)
  result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
  coefficients(result1)
}
))

hist(r[1,], breaks=40)
dev.new()
hist(r[2,], breaks=40)
