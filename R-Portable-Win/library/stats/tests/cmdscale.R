## regression tests on cmdscale from R 2.13.0

cmdsE <- cmdscale(eurodist, k = 20, eig = TRUE, x.ret = TRUE)
utils::str(cmdsE)
cmdsE2 <- cmdscale(eurodist, k = 20, add = TRUE, eig = TRUE, x.ret = TRUE)
utils::str(cmdsE2)
stopifnot(identical(rownames(cmdsE2$points), attr(eurodist, "Labels")))

## the exact answers diff by platform, since eigenvalue calculations are
## involved
