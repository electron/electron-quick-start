## example from PR#13571: should fail, not crash.

require("stats")
bad <- as.matrix(read.csv("ppr_test.csv"))
try(ppr(bad[,-3], bad[, 3], nterms=1))

