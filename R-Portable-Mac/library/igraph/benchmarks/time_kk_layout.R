
time_group("Kamada-Kawai layout")

time_that("KK layout is fast, connected", replications=10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- sample_pa(400) },
          { layout_with_kk(g, maxiter=500) })

time_that("KK layout is fast, unconnected", replications=10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- sample_gnm(400, 400) },
          { layout_with_kk(g, maxiter=500) })

time_that("KK layout is fast for large graphs", replications=10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- sample_pa(3000) },
          { layout_with_kk(g, maxiter=500) })
