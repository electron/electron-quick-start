# foreach version based on for-loop version from Wikipedia
# http://en.wikipedia.org/wiki/Bootstrapping_(statistics)
library(foreach)
data(iris)
x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000
nwsopts <- list(chunkSize=150)

# Can use the following "final" function instead of
# using cbind as the "combine" function.
final <- function(a) do.call('cbind', a)

print(system.time(
r <- foreach(icount(trials), .final=final, .options.nws=nwsopts) %dopar% {
  ind <- sample(100, 100, replace=TRUE)
  result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
  coefficients(result1)
}
))

hist(r[1,], breaks=40)
dev.new()
hist(r[2,], breaks=40)
