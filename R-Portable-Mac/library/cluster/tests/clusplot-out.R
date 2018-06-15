library(cluster)

### clusplot() & pam() RESULT checking ...

## plotting votes.diss(dissimilarity) in a bivariate plot and
## partitioning into 2 clusters
data(votes.repub)
votes.diss <- daisy(votes.repub)
for(k in 2:4) {
    votes.clus <- pam(votes.diss, k, diss = TRUE)$clustering
    print(clusplot(votes.diss, votes.clus, diss = TRUE, shade = TRUE))
}

## plotting iris (dataframe) in a 2-dimensional plot and partitioning
## into 3 clusters.
data(iris)
iris.x <- iris[, 1:4]

for(k in 2:5)
    print(clusplot(iris.x, pam(iris.x, k)$clustering, diss = FALSE))


.Random.seed <- c(0L,rep(7654L,3))
## generate 25 objects, divided into 2 clusters.
x <- rbind(cbind(rnorm(10,0,0.5), rnorm(10,0,0.5)),
           cbind(rnorm(15,5,0.5), rnorm(15,5,0.5)))
print.default(clusplot(px2 <- pam(x, 2)))

clusplot(px2, labels = 2, col.p = 1 + px2$clustering)
