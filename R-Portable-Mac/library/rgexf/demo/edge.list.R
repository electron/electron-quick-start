################################################################################
# Demo of gexf function - Input: a list of edges  
# Author: Jorge Fabrega
################################################################################
pause <- function() {  
  invisible(readline("\nPress <return> to continue: ")) 
}

pause()
## Demos for rgexf - Nodes and edges with attributes.
## Input: A matrix of edges 

# Defining a matrix of edges
relations <- matrix(c("Juan","Carlos",
                      "Juan","Pedro",
                      "Juan","Matthew",
                      "Pedro","Matthew",
                      "Matthew","Carlos",
                      "Carlos","Pedro",
                      "Pedro","Carlos",
                      "Carlos","Juan",
                      "Carlos","Juan"),
                    ncol=2, byrow=T)
relations

# Now, with processEdgeList you can transform your edge list into a gexf file

pause()

edge.list(relations)

