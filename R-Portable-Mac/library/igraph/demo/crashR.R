
pause <- function() {}

### R objects, (real) numbers
a <- 3
a
b <- 4
b
a+b

pause()

### Case sensitive
A <- 16
a
A

pause()

### Vector objects
a <- c(1,2,3,4,5,6,7,8,9,10)
a
b <- 1:100
b
a[1]
b[1:5]
a[1] <- 10
a
a[1:4] <- 2
a

pause()

### Vector arithmetic
a * 2 + 1

pause()

### Functions
ls()
length(a)
mean(a)
sd(a)
sd
c

pause()

### Getting help
# ?sd
# ??"standard deviation"
# RSiteSearch("network betweenness")

pause()

### Classes
class(2)
class(1:10)
class(sd)

pause()

### Character vectors
char.vec <- c("this", "is", "a", "vector", "of", "characters")
char_vec <- char.vec
char.vec[1]

pause()

### Index vectors
age <- c(45, 36, 65, 21, 52, 19)
age[1]
age[1:5]
age[c(2,5,6)]

b[ seq(1,100,by=2) ]

pause()

### Named vectors
names(age) <- c("Alice", "Bob", "Cecil", "David", "Eve", "Fiona")
age
age["Bob"]
age[c("Eve", "David", "David")]

pause()

### Indexing with logical vectors
age[c(FALSE, TRUE, FALSE, TRUE, FALSE, TRUE)]
names(age)[ age>40 ]
age > 40

pause()

### Matrices
M <- matrix(1:20, 10, 2)
M
M2 <- matrix(1:20, 10, 2, byrow=TRUE)   ## Named argument!
M2
M[1,1]
M[1,]
M[,1]
M[1:5,2]

pause()

### Generic functions
sd(a)
sd(M)
class(a)
class(M)

pause()

### Lists
l <- list(1:10, "Hello!", diag(5))
l
l[[1]]
l[2:3]
l
l2 <- list(A=1:10, H="Hello!", M=diag(5))
l2
l2$A
l2$M

pause()

### Factors
countries <- c("SUI", "USA", "GBR", "GER", "SUI",
               "SUI", "GBR", "GER", "FRA", "GER")
countries
fcountries <- factor(countries)
fcountries
levels(fcountries)

pause()

### Data frames
survey <- data.frame(row.names=c("Alice", "Bob", "Cecil", "David", "Eve"),
                     Sex=c("F","M","F","F","F"),
                     Age=c(45,36,65,21,52),
                     Country=c("SUI", "USA", "SUI", "GBR", "USA"),
                     Married=c(TRUE, FALSE, FALSE, TRUE, TRUE),
                     Salary=c(70, 65, 200, 45, 100))
survey
survey$Sex
plot(survey$Age, survey$Salary)
AS.model <- lm(Salary ~ Age, data=survey)
AS.model
summary(AS.model)
abline(AS.model)

tapply(survey$Salary, survey$Country, mean)

pause()

### Packages
# install.packages("igraph")
# library(help="igraph")
library(igraph)
sessionInfo()

pause()

### Graphs
## Create a small graph, A->B, A->C, B->C, C->E, D
## A=1, B=2, C=3, D=4, E=5
g <- graph( c(1,2, 1,3, 2,3, 3,5), n=5 )

pause()

### Print a graph to the screen
g

pause()

### Create an undirected graph as well
## A--B, A--C, B--C, C--E, D
g2 <- graph( c(1,2, 1,3, 2,3, 3,5), n=5, dir=FALSE )
g2

pause()

### Is this object an igraph graph?
is_igraph(g)
is_igraph(1:10)

pause()

### Summary, number of vertices, edges
summary(g)
vcount(g)
ecount(g)

pause()

### Is the graph directed?
is_directed(g)
is_directed(g2)

pause()

### Convert from directed to undirected
as.undirected(g)

pause()

### And back
as.directed(as.undirected(g))

pause()

### Multiple edges
g <- graph( c(1,2,1,2, 1,3, 2,3, 4,5), n=5 )
g

is_simple(g)
which_multiple(g)

pause()

### Remove multiple edges
g <- simplify(g)
is_simple(g)

pause()

### Loop edges
g <- graph( c(1,1,1,2, 1,3, 2,3, 4,5), n=5 )
g

is_simple(g)
which_loop(g)

pause()

### Remove loop edges
g <- simplify(g)
is_simple(g)

pause()

### Naming vertices
g <- make_ring(10)
V(g)$name <- letters[1:10]
V(g)$name
g
print(g, v=T)

pause()

### Create undirected example graph
g2 <- graph_from_literal(Alice-Bob:Cecil:Daniel, 
                Cecil:Daniel-Eugene:Gordon )
print(g2, v=T)

pause()

### Remove Alice
g3 <- delete_vertices(g2, match("Alice", V(g2)$name))

pause()

### Add three new vertices
g4 <- add_vertices(g3, 3)
print(g4, v=T)
igraph_options(print.vertex.attributes=TRUE, 
               plot.layout=layout_with_fr)
g4
plot(g4)                      

pause()

### Add three new vertices, with names this time
g4 <- add_vertices(g3, 3, attr=list(name=c("Helen", "Ike", "Jane")))
g4

pause()

### Add some edges as well
g4 <- add_edges(g4, match(c("Helen", "Jane", "Ike", "Jane"), V(g4)$name ))
g4

pause()

### Edge sequences, first create a directed example graph
g2 <- graph_from_literal(Alice -+ Bob:Cecil:Daniel, 
                Cecil:Daniel +-+ Eugene:Gordon )
print(g2, v=T)
plot(g2, layout=layout_with_kk, vertex.label=V(g2)$name)

pause()

### Sequence of all edges
E(g2)

pause()

### Edge from a vertex to another
E(g2, P=c(1,2))

pause()

### Delete this edge
g3 <- delete_edges(g2, E(g2, P=c(1,2)))
g3

pause()

### Get the id of the edge
as.vector(E(g2, P=c(1,2)))

pause()

### All adjacent edges of a vertex
E(g2)[ adj(3) ]

pause()

### Or multiple vertices
E(g2)[ adj(c(3,1)) ]

pause()

### Outgoing edges
E(g2)[ from(3) ]

pause()

### Incoming edges
E(g2)[ to(3) ]

pause()

### Edges along a path
E(g2, path=c(1,4,5))

