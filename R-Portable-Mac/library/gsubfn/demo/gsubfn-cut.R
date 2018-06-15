
# produce plot of data with horizontal arrows representing
# certain grouping data.  Get info by using strapply to extract
# it from the labels of cut
# based on
# https://www.stat.math.ethz.ch/pipermail/r-help/2006-May/106042.html
# with various iterations by G. Grothendieck, Berwin Turlach and Gavin Simpson

set.seed(1)
dat <- seq(4, 7, by = 0.05)
x <- sample(dat, 30)
y <- sample(dat, 30)

## residuals
error <- x - y
## break range of x into 10 groups

groups <- cut(x, breaks = 10)

##calculate bias (mean) per group
max.bias <- tapply(error, groups, mean)

## convert cut intervals into numeric matrix
library(gsubfn)
interv <- strapply(levels(groups), "[[:digit:].]+", as.numeric, simplify = TRUE)

## plot the residuals vs observed
plot(x, error, type = "n")
abline(h = 0, col = "grey")
panel.smooth(x, error)

## add bias indicators per group
arrows(interv[1,], max.bias, interv[2,], max.bias,
      length = 0.05, angle = 90, code = 3)

