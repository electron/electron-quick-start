
library(Rcpp)

sourceCpp("Export.cpp")
fibonacci(5)


sourceCpp("Depends.cpp")
fastLm(c(1,2,3), matrix(3,3))

