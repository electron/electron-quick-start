################################################################################
# Demo of gexf function - Dynamic network with:
#                               nodes and edges attributes, 
#                               and attributes for visualizations,
#                               images instead of standard nodes,
#                               shapes of nodes and,
#                               color attributes for nodes and edges
# Author: Jorge Fabrega
################################################################################

pause <- function() {  
  invisible(readline("\nPress <return> to continue: ")) 
}

pause()
## Demos for rgexf - Nodes and edges with attributes.
## 1. A matrix of nodes 
## 2. A matrix of edges
## 3. A matrix of nodes attributes
## 4. A matrix of edges attributes
## 5. A matrix indicating the active period of each node 
## 6. A matrix indicating the active period of each edge

# Defining a matrix of nodes
people <- matrix(c(1:4, 'juan', 'pedro', 'matthew', 'carlos'),ncol=2)
people

# Defining a matrix of edges
relations <- matrix(c(1,4,1,2,1,3,2,3,3,4,4,2,2,4,4,1,4,1), ncol=2, byrow=T)
relations

# Defining two dataframes with attributes for nodes and edges, respectively.
node.att <- data.frame(attributes=c(letters[1:3],"a word"), numbers=1:4, stringsAsFactors=F)
node.att

edge.att <- data.frame(attributes=letters[1:9], numbers=1:9, stringsAsFactors=F)
edge.att

# Defining a matrix of dynamics (start, end) for nodes and edges
time.nodes<-matrix(c(10.0,13.0,2.0,2.0,12.0,rep(NA,3)), nrow=4, ncol=2)
time.edges<-matrix(c(10.0,13.0,2.0,2.0,12.0,1,5,rep(NA,5),rep(c(0,1),3)), ncol=2)

# In this example, the active period of each node is:
time.nodes

# And for the edges are:
time.edges

# Images instead of stardard nodes
imagee <- data.frame(image=rbind(
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png",
  "Yellow_solid_sphere.png"), stringsAsFactors=F)

# Shapes
shapes<-c("rectangle", "square", "triangle", "diamond")

# position
pos<-matrix(1:12,nrow=4)

#colors
color<-cbind(t(col2rgb(1:4)), 1)

#Edges thickness
thick<-1:9

################################################################################
# Dynamic network with nodes and edges attributes

# you create a .gexf archive by adding the expression:
#
#                       ,output="yourgraph.gexf" 
#
# before the last closing 
# parenthesis in the following function

pause()

write.gexf(nodes=people, edgesWeight=thick, edges=relations,
           edgeDynamic=time.edges, edgesAtt=edge.att, nodeDynamic=time.nodes,
           nodesAtt=node.att,
           nodesVizAtt = list(
             shape=shapes, 
             position=pos, 
             image=imagee, 
             color=color)
           )
