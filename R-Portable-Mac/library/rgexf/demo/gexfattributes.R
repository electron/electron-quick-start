################################################################################
# Demo of gexf function - Network with nodes and edges attributes
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

################################################################################
# Network with nodes attributes
# you create a .gexf archive by adding the expression:
#
#                       ,output="yourgraph.gexf" 
#
# before the last closing 
# parenthesis in the following function

write.gexf(nodes=people, edges=relations, nodesAtt=node.att, edgesAtt=edge.att)

################################################################################