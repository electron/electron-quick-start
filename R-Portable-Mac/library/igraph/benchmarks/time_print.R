
time_group("Printing graphs to the screen")

time_that("Print large graphs without attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000)) },
          { print(g) })

time_that("Summarize large graphs without attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000)) },
          { summary(g) })

time_that("Print large graphs with large graph attributes",
          replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_graph_attr(g, "foo", 1:1000000) },
          { print(g) })

time_that("Summarize large graphs with large graph attributes",
          replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_graph_attr(g, "foo", 1:1000000) },
          { summary(g) })

time_that("Print large graphs with vertex attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_vertex_attr(g, 'foo',
                             value = as.character(seq_len(gorder(g)))) },
          { print(g) })

time_that("Summarize large graphs with vertex attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_vertex_attr(g, 'foo',
                             value = as.character(seq_len(gorder(g)))) },
          { print(g) })

time_that("Print large graphs with edge attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_edge_attr(g, 'foo',
                             value = as.character(seq_len(gsize(g)))) },
          { print(g) })

time_that("Summarize large graphs with edge attributes", replications = 10,
          init = { library(igraph); set.seed(42) },
          reinit = { g <- make_lattice(c(1000, 1000));
                     g <- set_edge_attr(g, 'foo',
                             value = as.character(seq_len(gsize(g)))) },
          { print(g) })
