
time_group("dimensionality selection")

time_that("dimensionaility selection is fast", replications=10,
          init = { library(igraph) },
          reinit = { sv <- c(rnorm(2000), rnorm(2000)/5) },
          { dim_select(sv) })
