## failed in bkfe with exaxt powers of 2 prior to 2.23-5
library(KernSmooth)
x <- 1:100
dpik(x, gridsize = 256)
## and for bkde for some x.
x <- c(0.036, 0.042, 0.052, 0.216, 0.368, 0.511, 0.705, 0.753, 0.776, 0.84)
bkde(x, gridsize = 256, range.x = range(x))

