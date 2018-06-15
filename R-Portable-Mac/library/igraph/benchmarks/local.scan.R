
time_group("local scan v1")

init   <- expression({library(igraph); set.seed(42) })
reinit <- expression({g  <- random.graph.game(1000, p=.1)
                      E(g)$weight <- sample(ecount(g))
                      gp <- random.graph.game(1000, p=.1)
                      E(gp)$weight <- sample(ecount(gp))
                    })

time_that("us, scan-0, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=0) })

time_that("us, scan-0, weighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=0, weighted=TRUE) })

time_that("us, scan-1, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=1) })

time_that("us, scan-1, weighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=1, weighted=TRUE) })

time_that("us, scan-2, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=2) })

time_that("us, scan-2, weighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, k=2, weighted=TRUE) })

time_that("them, scan-0, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=0) })

time_that("them, scan-0, weighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=0, weighted=TRUE) })

time_that("them, scan-1, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=1)} )

time_that("them, scan-1, weighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=1, weighted=TRUE) })

time_that("them, scan-2, unweighted",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=2) })

time_that("them, scan-2, weigthed",
          replications=10, init=init, reinit=reinit,
          { local_scan(g, gp, k=2, weighted=TRUE) })
