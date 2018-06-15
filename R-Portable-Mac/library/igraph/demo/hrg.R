
pause <- function() {}

### Download the Zachary Karate Club network from Nexus

karate <- nexus.get("karate")
karate

pause()

### Optimalize modularity

optcom <- cluster_optimal(karate)
V(karate)$comm <- membership(optcom)
plot(optcom, karate)

pause()

### Fit a HRG model to the network

hrg <- fit_hrg(karate)
hrg

pause()

### The fitted model, more details

print(hrg, level=5)

pause()

### Plot the full hierarchy, as an igraph graph

ihrg <- as.igraph(hrg)
ihrg$layout <- layout.reingold.tilford
plot(ihrg, vertex.size=10, edge.arrow.size=0.2)

pause()

### Customize the plot a bit, show probabilities and communities

vn <- sub("Actor ", "", V(ihrg)$name)
colbar <- rainbow(length(optcom))
vc <- ifelse(is.na(V(ihrg)$prob), colbar[V(karate)$comm], "darkblue")
V(ihrg)$label <- ifelse(is.na(V(ihrg)$prob), vn, round(V(ihrg)$prob, 2))
par(mar=c(0,0,3,0))
plot(ihrg, vertex.size=10, edge.arrow.size=0.2,
     vertex.shape="none", vertex.label.color=vc,
     main="Hierarchical network model of the Karate Club")

pause()

### Plot it as a dendrogram, looks better if the 'ape' package is installed

plot_dendrogram(hrg)

pause()

### Make a very hierarchical graph

g1 <- make_full_graph(5)
g2 <- make_ring(5)

g <- g1 + g2
g <- g + edge(1, vcount(g1)+1)

plot(g)

pause()

### Fit HRG

ghrg <- fit_hrg(g)
plot_dendrogram(ghrg)

pause()

### Create a consensus dendrogram from multiple samples, takes longer...

hcons <- consensus_tree(g)
hcons$consensus

pause()

### Predict missing edges

pred <- predict_edges(g)
pred

pause()

### Add some the top 5 predicted edges to the graph, colored red

E(g)$color <- "grey"
lay <- layout_nicely(g)
g2 <- add_edges(g, t(pred$edges[1:5,]), color="red")
plot(g2, layout=lay)

pause()

### Add four more predicted edges, colored orange

g3 <- add_edges(g2, t(pred$edges[6:9,]), color="orange")
plot(g3, layout=lay)

