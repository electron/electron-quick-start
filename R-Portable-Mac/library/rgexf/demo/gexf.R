################################################################################
# Demo of gexf function
# Author: Jorge Fabrega
################################################################################
pause <- function() {  
  invisible(readline("\nPress <return> to continue: ")) 
}
pause()

# Defining a matrix of nodes
pause()
people <- data.frame(id=1:4, label=c("juan", "pedro", "matthew", "carlos"))
people

# Defining a matrix of edges
pause()

relations <- data.frame(source=c(1,1,1,2,3,4,2,4,4), 
                        target=c(4,2,3,3,4,2,4,1,1))
relations

# Defining a matrix of dynamics (start, end) for nodes and edges
pause()

time.nodes <- data.frame(matrix(c(10.0,13.0,2.0,2.0,12.0,rep(NA,3)),
                                nrow=4, ncol=2))
time.nodes

time.edges<- data.frame(matrix(c(10.0,13.0,2.0,2.0,12.0,1,5,rep(NA,5),
                                 rep(c(0,1),3)), ncol=2))
time.edges

# Defining a data frame of attributes for nodes and edges
pause()

node.att <- data.frame(letrafavorita=c(letters[1:3],"hola"), numbers=1:4)
node.att

edge.att <- data.frame(letrafavorita=letters[1:9], numbers=1:9)
edge.att

################################################################################
# First example: a simple net
pause()
write.gexf(nodes=people, edges=relations)

################################################################################
# Second example: a simple net with nodes attributes
pause()
write.gexf(nodes=people, edges=relations, nodesAtt=node.att)

################################################################################
# Third example: a simple net with dynamic nodes
pause()
write.gexf(nodes=people, edges=relations, nodeDynamic=time.nodes)

################################################################################
# Fourth example: a simple net with dynamic nodes with attributes
pause()
write.gexf(nodes=people, edges=relations, nodeDynamic=time.nodes, nodesAtt=node.att)

################################################################################
# Fifth example: a simple net with dynamic edges with attributes
pause()
write.gexf(nodes=people, edges=relations, edgeDynamic=time.edges, edgesAtt=edge.att)

################################################################################
# Sixth example: a simple net with dynamic edges and nodes with attributes
pause()
write.gexf(nodes=people, edges=relations, edgeDynamic=time.edges, edgesAtt=edge.att,
     nodeDynamic=time.nodes, nodesAtt=node.att)

################################################################################
# Seventh example: a simple net with dynamic edges and nodes with attributes
pause()
imagee <- data.frame(image=rbind(
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png"), stringsAsFactors=F)

# Colors
nodecolors <- cbind(t(col2rgb(topo.colors(nrow(people)))),alpha=1)
colnames(nodecolors) <- c("r", "b", "g", "a")

edgecolors <- cbind(t(col2rgb(cm.colors(nrow(relations)))),alpha=1)
colnames(edgecolors) <- c("r", "b", "g", "a")

# TRUE/FALSE attributes
nodetruefalse <- data.frame(nodetrue=rnorm(NROW(people)) > 0)
edgetruefalse <- data.frame(edgetrue=rnorm(NROW(relations)) > 0)

grafo <- write.gexf(nodes=people, edges=relations, 
              nodesAtt=cbind(imagee,nodetruefalse),
              nodesVizAtt=list(
                shape=c("rectangle", "square", "triangle", "diamond"),
                position=matrix(1:12,nrow=4),
                image=imagee, 
                color=nodecolors,
                size=c(1,4,10,30)
                ), 
              edgesVizAtt=list(
                size=1:9, 
                color=edgecolors
                ), 
              edgesAtt=edgetruefalse)

print(grafo)