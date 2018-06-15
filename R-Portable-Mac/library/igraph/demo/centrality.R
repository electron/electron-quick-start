
pause <- function() {}

### Traditional approaches: degree, closeness, betweenness
g <- graph_from_literal(Andre----Beverly:Diane:Fernando:Carol,
               Beverly--Andre:Diane:Garth:Ed,
               Carol----Andre:Diane:Fernando,
               Diane----Andre:Carol:Fernando:Garth:Ed:Beverly,
               Ed-------Beverly:Diane:Garth,
               Fernando-Carol:Andre:Diane:Garth:Heather,
               Garth----Ed:Beverly:Diane:Fernando:Heather,
               Heather--Fernando:Garth:Ike,
               Ike------Heather:Jane,
               Jane-----Ike )

pause()

### Hand-drawn coordinates
coords <- c(5,5,119,256,119,256,120,340,478,
            622,116,330,231,116,5,330,451,231,231,231)
coords <- matrix(coords, nc=2)

pause()

### Labels the same as names
V(g)$label <- V(g)$name
g$layout <- coords # $

pause()

### Take a look at it
plotG <- function(g) {
  plot(g, asp=FALSE, vertex.label.color="blue", vertex.label.cex=1.5,
       vertex.label.font=2, vertex.size=25, vertex.color="white",
       vertex.frame.color="white", edge.color="black")
}
plotG(g)

pause()

### Add degree centrality to labels
V(g)$label <- paste(sep="\n", V(g)$name, degree(g))

pause()

### And plot again
plotG(g)

pause()

### Betweenness
V(g)$label <- paste(sep="\n", V(g)$name, round(betweenness(g), 2))
plotG(g)

pause()

### Closeness
V(g)$label <- paste(sep="\n", V(g)$name, round(closeness(g), 2))
plotG(g)

pause()

### Eigenvector centrality
V(g)$label <- paste(sep="\n", V(g)$name, round(eigen_centrality(g)$vector, 2))
plotG(g)

pause()

### PageRank
V(g)$label <- paste(sep="\n", V(g)$name, round(page_rank(g)$vector, 2))
plotG(g)

pause()

### Correlation between centrality measures
karate <- make_graph("Zachary")
cent <- list(`Degree`=degree(g),
             `Closeness`=closeness(g),
             `Betweenness`=betweenness(g),
             `Eigenvector`=eigen_centrality(g)$vector,
             `PageRank`=page_rank(g)$vector)

pause()

### Pairs plot
pairs(cent, lower.panel=function(x,y) {
  usr <- par("usr")
  text(mean(usr[1:2]), mean(usr[3:4]), round(cor(x,y), 3), cex=2, col="blue")
} )

pause()

## ### A real network, US supreme court citations
## ##  You will need internet connection for this to work
## vertices <- read.csv("http://jhfowler.ucsd.edu/data/judicial.csv")
## edges <- read.table("http://jhfowler.ucsd.edu/data/allcites.txt")
## jg <- graph.data.frame(edges, vertices=vertices, dir=TRUE)

## pause()

## ### Basic data
## summary(jg)

## pause()

## ### Is it a simple graph?
## is_simple(jg)

## pause()

## ### Is it connected?
## is_connected(jg)

## pause()

## ### How many components?
## count_components(jg)

## pause()

## ### How big are these?
## table(components(jg)$csize)

## pause()

## ### In-degree distribution
## plot(degree_distribution(jg, mode="in"), log="xy")

## pause()

## ### Out-degree distribution
## plot(degree_distribution(jg, mode="out"), log="xy")

## pause()

## ### Largest in- and out-degree, total degree
## c(max(degree(jg, mode="in")),
##   max(degree(jg, mode="out")),
##   max(degree(jg, mode="all")))

## pause()

## ### Density
## density(jg)

## pause()

## ### Transitivity
## transitivity(jg)

## pause()

## ### Transitivity of a random graph of the same size
## g <- sample_gnm(vcount(jg), ecount(jg))
## transitivity(g)

## pause()

## ### Transitivity of a random graph with the same degree distribution
## g <- sample_degseq(degree(jg, mode="out"), degree(jg, mode="in"),
##                           method="simple")
## transitivity(g)

## pause()

## ### Authority and Hub scores
## AS <- authority_score(jg)$vector
## HS <- hub_score(jg)$vector

## pause()

## ### Time evolution of authority scores
## AS <- authority_score(jg)$vector
## center <- which.max(AS)
## startyear <- V(jg)[center]$year

## pause()

## ### Function to go back in time
## auth.year <- function(y) {
##   print(y)
##   keep <- which(V(jg)$year <= y)
##   g2 <- subgraph(jg, keep)
##   as <- abs(authority_score(g2, scale=FALSE)$vector)
##   w <- match(V(jg)[center]$usid, V(g2)$usid)
##   as[w]
## }

## pause()

## ### Go back in time for the top authority, do a plot
## AS2 <- sapply(startyear:2005, auth.year)
## plot(startyear:2005, AS2, type="b", xlab="year", ylab="authority score")

## pause()

## ### Check another case
## center <- "22US1"
## startyear <- V(jg)[center]$year

## pause()

## ### Calculate past authority scores & plot them
## AS3 <- sapply(startyear:2005, auth.year)
## plot(startyear:2005, AS3, type="b", xlab="year", ylab="authority score")
