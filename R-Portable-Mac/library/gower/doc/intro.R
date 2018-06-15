## ------------------------------------------------------------------------
library(gower)
dat1 <- iris[1:10,]
dat2 <- iris[6:15,]
gower_dist(dat1, dat2)

## ------------------------------------------------------------------------
gower_dist(iris[1,], dat1)

## ------------------------------------------------------------------------
dat1 <- dat2 <- iris[1:10,]
names(dat2) <- tolower(names(dat2))
gower_dist(dat1, dat2)
# tell gower_dist to match columns 1..5 in dat1 with column 1..5 in dat2
gower_dist(dat1, dat2, pair_y=1:5)

## ------------------------------------------------------------------------
dat1 <- iris[1:10,]
L <- gower_topn(x=dat1, y=iris, n=3)
L

