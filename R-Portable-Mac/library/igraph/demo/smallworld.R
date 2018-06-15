
pause <- function() {}

### Create a star-like graph
t1 <- graph_from_literal(A-B:C:D:E)
t1

pause()

### Define its plotting properties
t1$layout <- layout_in_circle
V(t1)$color <- "white"
V(t1)[name=="A"]$color <- "orange"
V(t1)$size <- 40
V(t1)$label.cex <- 3
V(t1)$label <- V(t1)$name
E(t1)$color <- "black"
E(t1)$width <- 3

pause()

### Plot 't1' and A's transitivity
tr <- transitivity(t1, type="local")[1]
plot(t1, main=paste("Transitivity of 'A':", tr))

pause()

### Add an edge and recalculate transitivity
t2 <- add_edges(t1, V(t1)[name %in% c("C","D")], color="red", width=3)
tr <- transitivity(t2, type="local")[1]
plot(t2, main=paste("Transitivity of 'A':", round(tr,4)))

pause()

### Add two more edges
newe <- match(c("B", "C", "B", "E"), V(t2)$name)-1
t3 <- add_edges(t2, newe, color="red", width=3)
tr <- transitivity(t3, type="local")[1]
plot(t3, main=paste("Transitivity of 'A':", round(tr,4)))

pause()

### A one dimensional, circular lattice
ring <- make_ring(50)
ring$layout <- layout_in_circle
V(ring)$size <- 3
plot(ring, vertex.label=NA, main="Ring graph")

pause()

### Watts-Strogatz model
ws1 <- sample_smallworld(1, 50, 3, p=0)
ws1$layout <- layout_in_circle
V(ws1)$size <- 3
E(ws1)$curved <- 1
plot(ws1, vertex.label=NA, main="regular graph")

pause()

### Zoom in to this part
axis(1)
axis(2)
abline(h=c(0.8, 1.1))
abline(v=c(-0.2,0.2))

pause()

### Zoom in to this part
plot(ws1, vertex.label=NA, xlim=c(-0.2, 0.2), ylim=c(0.8,1.1))

pause()

### Transitivity of the ring graph
transitivity(ws1)

pause()

### Path lengths, regular graph
mean_distance(ws1)

pause()

### Function to test regular graph with given size
try.ring.pl <- function(n) {
  g <- sample_smallworld(1, n, 3, p=0)
  mean_distance(g)
}
try.ring.pl(10)
try.ring.pl(100)

pause()

### Test a number of regular graphs
ring.size <- seq(100, 1000, by=100)
ring.pl <- sapply(ring.size, try.ring.pl)
plot(ring.size, ring.pl, type="b")

pause()

### Path lengths, random graph
rg <- sample_gnm(50, 50 * 3)
rg$layout <- layout_in_circle
V(rg)$size <- 3
plot(rg, vertex.label=NA, main="Random graph")
mean_distance(rg)

pause()

### Path length of random graphs
try.random.pl <- function(n) {
  g <- sample_gnm(n, n*3)
  mean_distance(g)
}
try.random.pl(100)

pause()

### Plot network size vs. average path length
random.pl <- sapply(ring.size, try.random.pl)
plot(ring.size, random.pl, type="b")

pause()

### Plot again, logarithmic 'x' axis
plot(ring.size, random.pl, type="b", log="x")

pause()

### Transitivity, random graph, by definition
ecount(rg) / (vcount(rg)*(vcount(rg)-1)/2)
transitivity(rg, type="localaverage")

pause()

### Rewiring
ws2 <- sample_smallworld(1, 50, 3, p=0.1)
ws2$layout <- layout_in_circle
V(ws2)$size <- 3
plot(ws2, vertex.label=NA)
mean_distance(ws2)

pause()

### Path lengths in randomized lattices
try.rr.pl <- function(n, p) {
  g <- sample_smallworld(1, n, 3, p=p)
  mean_distance(g)
}
rr.pl.0.1 <- sapply(ring.size, try.rr.pl, p=0.1)
plot(ring.size, rr.pl.0.1, type="b")

pause()

### Logarithmic 'x' axis 
plot(ring.size, rr.pl.0.1, type="b", log="x")

pause()

### Create the graph in the Watts-Strogatz paper
ws.paper <- function(p, n=1000) {
  g <- sample_smallworld(1, n, 10, p=p)
  tr <- transitivity(g, type="localaverage")
  pl <- mean_distance(g)
  c(tr, pl)
}

pause()

### Do the simulation for a number of 'p' values
rewire.prob <- ((1:10)^4)/(10^4)
ws.result <- sapply(rewire.prob, ws.paper)
dim(ws.result)

pause()

### Plot it
plot(rewire.prob, ws.result[1,]/ws.result[1,1], log="x", pch=22,
     xlab="p", ylab="")
points(rewire.prob, ws.result[2,]/ws.result[2,1], pch=20)
legend("bottomleft", c(expression(C(p)/C(0)), expression(L(p)/L(0))),
       pch=c(22, 20))

