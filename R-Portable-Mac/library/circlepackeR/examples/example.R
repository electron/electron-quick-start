library(circlepackeR)

# using json
circlepackeR( "http://bl.ocks.org/mbostock/raw/7607535/flare.json" )

# using data.tree
\dontrun{
  library(data.tree)
  data(acme)
  circlepackeR(acme, size = "cost" )

}

# using a data frame with data.tree
\dontrun{
  library(data.tree)
  library(treemap)
  data(GNI2010)
  GNI2010$pathString <- paste("world",
                              GNI2010$continent,
                              GNI2010$country,
                              sep = "/")

  population <- as.Node(GNI2010)
  circlepackeR(population, size = "population" )

}
