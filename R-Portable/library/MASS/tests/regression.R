### regression tests

library(MASS)

contr.sdif(6)
contr.sdif(6, sparse=TRUE)
stopifnot(all(contr.sdif(6) == contr.sdif(6, sparse=TRUE)))

