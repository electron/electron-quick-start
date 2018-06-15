
time_group("SIR epidemics models on networks")

time_that("SIR is fast", replications=10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- sample_gnm(40, 40) },
          { sir(g, beta=5, gamma=1, no.sim=100) })
