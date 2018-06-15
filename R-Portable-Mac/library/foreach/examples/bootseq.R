# for-loop version from Wikipedia
# http://en.wikipedia.org/wiki/Bootstrapping_(statistics)
data(iris)
x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000
intercept1 <- rep(0, trials)
slope1 <- rep(0, trials)

print(system.time(
for (B in 1:trials) {
  ind <- sample(100, 100, replace=TRUE)
  result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
  intercept1[B] <- coefficients(result1)[1]
  slope1[B] <- coefficients(result1)[2]
}
))

hist(intercept1, breaks=40)
dev.new()
hist(slope1, breaks=40)
