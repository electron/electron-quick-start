gexf1 <- read.gexf(system.file("gexf-graphs/lesmiserables.gexf", package="rgexf"))
igraph1 <- gexf.to.igraph(gexf1)
gexf2 <- igraph.to.gexf(igraph1)