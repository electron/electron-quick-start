library(cluster)

## Kind of a bootstrap -- calling many diana()s
dianaBoot <- function(data, B = 500, frac.sub = c(0.7, min = 0.2),
                      digits = 4)
{
    stopifnot((n <- nrow(data)) >= 10, B >= 10, frac.sub > 0,
              (m <- round(frac.sub[["min"]]*n)) >= 2,
              (mm <- round(frac.sub[1]*n)) > m)
    for(b in 1:B) {
        d.r <- data[sample(n, max(m, min(n, rpois(1, lambda = mm)))) ,]
        dia. <- diana(d.r, keep.diss=FALSE, keep.data=FALSE)
        print(dia.[1:3], digits = digits)
    }
}

.p0 <- proc.time()
data(ruspini)
set.seed(134)
dianaBoot(ruspini)
cat('Time elapsed: ', (.p1 <- proc.time()) - .p0,'\n')

data(agriculture)
set.seed(707)
dianaBoot(agriculture)
cat('Time elapsed: ', (.p2 <- proc.time()) - .p1,'\n')

data(swiss); swiss.x <- as.matrix(swiss[,-1])
set.seed(312)
dianaBoot(swiss.x)
cat('Time elapsed: ', (.p3 <- proc.time()) - .p2,'\n')
