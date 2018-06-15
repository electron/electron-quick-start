
time_group("correlated E-R graphs, v1")

time_that("sample_correlated_gnp is fast", replications=10,
          init={ library(igraph) },
          { sample_correlated_gnp_pair(100, corr=.8, p=5/100) })


