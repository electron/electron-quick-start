
time_group(".Call from R")

time_that("Redefining .Call does not have much overhead #1", replications=10,
          init = { library(igraph) ; g <- graph.ring(100) },
          { for (i in 1:20000) {
            .Call(C_R_igraph_vcount, g)
          }  })

time_that("Redefining .Call does not have much overhead #1", replications=10,
          init = { library(igraph) ; g <- graph.ring(100) },
          { for (i in 1:20000) {
            igraph:::.Call(C_R_igraph_vcount, g)
          }  })
