
pause <- function() {}

### A modular graph has dense subgraphs
mod <- make_full_graph(10) %du% make_full_graph(10) %du% make_full_graph(10)
perfect <- c(rep(1,10), rep(2,10), rep(3,10))
perfect

pause()

### Plot it with community (=component) colors
plot(mod, vertex.color=perfect, layout=layout_with_fr)

pause()

### Modularity of the perfect division
modularity(mod, perfect)

pause()

### Modularity of the trivial partition, quite bad
modularity(mod, rep(1, 30))

pause()

### Modularity of a good partition with two communities
modularity(mod, c(rep(1, 10), rep(2,20)))

pause()

### A real little network, Zachary's karate club data
karate <- make_graph("Zachary")
karate$layout <- layout_with_kk(karate, niter=1000)

pause()

### Greedy algorithm
fc <- cluster_fast_greedy(karate)
memb <- membership(fc)
plot(karate, vertex.color=memb)
  
pause()

### Greedy algorithm, easier plotting
plot(fc, karate)

pause()

### Spinglass algorithm, create a hierarchical network
pref.mat <- matrix(0, 16, 16)
pref.mat[1:4,1:4] <- pref.mat[5:8,5:8] <-
  pref.mat[9:12,9:12] <- pref.mat[13:16,13:16] <- 7.5/127
pref.mat[ pref.mat==0 ] <- 5/(3*128)
diag(pref.mat) <- diag(pref.mat) + 10/31

pause()

### Create the network with the given vertex preferences
G <- sample_pref(128*4, types=16, pref.matrix=pref.mat)

pause()

### Run spinglass community detection with two gamma parameters
sc1 <- cluster_spinglass(G, spins=4, gamma=1.0)
sc2.2 <- cluster_spinglass(G, spins=16, gamma=2.2)

pause()

### Plot the adjacency matrix, use the Matrix package if available
if (require(Matrix)) {
  myimage <- function(...) image(Matrix(...))
} else {
  myimage <- image
}
A <- as_adj(G)
myimage(A)

pause()

### Ordering according to (big) communities
ord1 <- order(membership(sc1))
myimage(A[ord1,ord1])

pause()

### Ordering according to (small) communities
ord2.2 <- order(membership(sc2.2))
myimage(A[ord2.2,ord2.2])

pause()

### Consensus ordering
ord <- order(membership(sc1), membership(sc2.2))
myimage(A[ord,ord])

pause()

### Comparision of algorithms
communities <- list()

pause()

### cluster_edge_betweenness
ebc <- cluster_edge_betweenness(karate)
communities$`Edge betweenness` <- ebc

pause()

### cluster_fast_greedy
fc <- cluster_fast_greedy(karate)
communities$`Fast greedy` <- fc

pause()

### cluster_leading_eigen
lec <- cluster_leading_eigen(karate)
communities$`Leading eigenvector` <- lec

pause()

### cluster_spinglass
sc <- cluster_spinglass(karate, spins=10)
communities$`Spinglass` <- sc

pause()

### cluster_walktrap
wt <- cluster_walktrap(karate)
communities$`Walktrap` <- wt

pause()

### cluster_label_prop
labprop <- cluster_label_prop(karate)
communities$`Label propagation` <- labprop

pause()

### Plot everything
layout(rbind(1:3, 4:6))
coords <- layout_with_kk(karate)
lapply(seq_along(communities), function(x) {
  m <- modularity(communities[[x]])
  par(mar=c(1,1,3,1))
  plot(communities[[x]], karate, layout=coords,
       main=paste(names(communities)[x], "\n",
         "Modularity:", round(m, 3)))
})

pause()

### Function to calculate clique communities
clique.community <- function(graph, k) {
  clq <- cliques(graph, min=k, max=k)
  edges <- c()
  for (i in seq(along=clq)) {
    for (j in seq(along=clq)) {
      if ( length(unique(c(clq[[i]], 
             clq[[j]]))) == k+1 ) {
        edges <- c(edges, c(i,j))
      }
    }
  }
  clq.graph <- simplify(graph(edges))
  V(clq.graph)$name <- 
    seq(length=vcount(clq.graph))
  comps <- decompose(clq.graph)
  
  lapply(comps, function(x) {
    unique(unlist(clq[ V(x)$name ]))
  })
}

pause()

### Apply it to a graph, this is the example graph from
##  the original publication
g <- graph_from_literal(A-B:F:C:E:D, B-A:D:C:E:F:G, C-A:B:F:E:D, D-A:B:C:F:E,
               E-D:A:C:B:F:V:W:U, F-H:B:A:C:D:E, G-B:J:K:L:H,
               H-F:G:I:J:K:L, I-J:L:H, J-I:G:H:L, K-G:H:L:M,
               L-H:G:I:J:K:M, M-K:L:Q:R:S:P:O:N, N-M:Q:R:P:S:O,
               O-N:M:P, P-Q:M:N:O:S, Q-M:N:P:V:U:W:R, R-M:N:V:W:Q,
               S-N:P:M:U:W:T, T-S:V:W:U, U-E:V:Q:S:W:T,
               V-E:U:W:T:R:Q, W-U:E:V:Q:R:S:T)

pause()

### Hand-made layout to make it look like the original in the paper
lay <- c(387.0763, 306.6947, 354.0305, 421.0153, 483.5344, 512.1145, 
         148.6107, 392.4351, 524.6183, 541.5878, 240.6031, 20, 
         65.54962, 228.0992, 61.9771, 152.1832, 334.3817, 371.8931, 
         421.9084, 265.6107, 106.6336, 57.51145, 605, 20, 124.8780, 
         273.6585, 160.2439, 241.9512, 132.1951, 123.6585, 343.1707, 
         465.1220, 317.561, 216.3415, 226.0976, 343.1707, 306.5854, 
         123.6585, 360.2439, 444.3902, 532.1951, 720, 571.2195, 
         639.5122, 505.3659, 644.3902)
lay <- matrix(lay, nc=2)
lay[,2] <- max(lay[,2])-lay[,2]

pause()

### Take a look at it
layout(1)
plot(g, layout=lay, vertex.label=V(g)$name)

pause()

### Calculate communities
res <- clique.community(g, k=4)

pause()

### Paint them to different colors
colbar <- rainbow( length(res)+1 )
for (i in seq(along=res)) {
  V(g)[ res[[i]] ]$color <- colbar[i+1]
}

pause()

### Paint the vertices in multiple communities to red
V(g)[ unlist(res)[ duplicated(unlist(res)) ] ]$color <- "red"

pause()

### Plot with the new colors
plot(g, layout=lay, vertex.label=V(g)$name)

