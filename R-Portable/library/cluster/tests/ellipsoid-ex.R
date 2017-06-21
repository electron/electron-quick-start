library(cluster)

eh <- ellipsoidhull(cbind(x=1:4, y = 1:4)) #singular
eh ## center ok, shape "0 volume" --> Warning

set.seed(157)
for(n in 4:10) { ## n=2 and 3 still differ -- platform dependently!
    cat("n = ",n,"\n")
    x2 <- rnorm(n)
    print(ellipsoidhull(cbind(1:n, x2)))
    print(ellipsoidhull(cbind(1:n, x2, 4*x2 + rnorm(n))))
}

set.seed(1)
x <- rt(100, df = 4)
y <- 100 + 5 * x + rnorm(100)
ellipsoidhull(cbind(x,y))
z <- 10  - 8 * x + y + rnorm(100)
(e3 <- ellipsoidhull(cbind(x,y,z)))
d3o <- cbind(x,y + rt(100,3), 2 * x^2 + rt(100, 2))
(e. <- ellipsoidhull(d3o, ret.sq = TRUE))
stopifnot(all.equal(e.$sqdist,
		    with(e., mahalanobis(d3o, center=loc, cov=cov)),
		    tol = 1e-13))
d5 <- cbind(d3o, 2*abs(y)^1.5 + rt(100,3), 3*x - sqrt(abs(y)))
(e5 <- ellipsoidhull(d5, ret.sq = TRUE))
tail(sort(e5$sqdist)) ## 4 values 5.00039 ... 5.0099
