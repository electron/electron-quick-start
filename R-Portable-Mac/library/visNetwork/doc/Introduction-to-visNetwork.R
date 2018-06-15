## ------------------------------------------------------------------------
require(visNetwork, quietly = TRUE)
# minimal example
nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))
visNetwork(nodes, edges, width = "100%")

## ---- eval = FALSE-------------------------------------------------------
#  visDocumentation()
#  vignette("Introduction-to-visNetwork") # with CRAN version
#  # shiny ?
#  shiny::runApp(system.file("shiny", package = "visNetwork"))

## ------------------------------------------------------------------------
nodes <- data.frame(id = 1:10, 
                    label = paste("Node", 1:10),                                 # add labels on nodes
                    group = c("GrA", "GrB"),                                     # add groups on nodes 
                    value = 1:10,                                                # size adding value
                    shape = c("square", "triangle", "box", "circle", "dot", "star",
                    "ellipse", "database", "text", "diamond"),                   # control shape of nodes
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),         # tooltip (html or character)
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),# color
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))                  # shadow

head(nodes)

## ------------------------------------------------------------------------
edges <- data.frame(from = sample(1:10, 8), to = sample(1:10, 8),
                    label = paste("Edge", 1:8),                                 # add labels on edges
                    length = c(100,500),                                        # length
                    arrows = c("to", "from", "middle", "middle;to"),            # arrows
                    dashes = c(TRUE, FALSE),                                    # dashes
                    title = paste("Edge", 1:8),                                 # tooltip (html or character)
                    smooth = c(FALSE, TRUE),                                    # smooth
                    shadow = c(FALSE, TRUE, FALSE, TRUE))                       # shadow
head(edges)

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%")

## ------------------------------------------------------------------------
nodes <- data.frame(id = 1:5, group = c(rep("A", 2), rep("B", 3)))
edges <- data.frame(from = c(2,5,3,3), to = c(1,2,4,2))

visNetwork(nodes, edges, width = "100%") %>% 
  visNodes(shape = "square") %>%                        # square for all nodes
  visEdges(arrows ="to") %>%                            # arrow "to" for all edges
  visGroups(groupname = "A", color = "darkblue") %>%    # darkblue for group "A"
  visGroups(groupname = "B", color = "red")             # red for group "B"

## ---- echo=TRUE----------------------------------------------------------
nb <- 10
nodes <- data.frame(id = 1:nb, label = paste("Label", 1:nb),
 group = sample(LETTERS[1:3], nb, replace = TRUE), value = 1:nb,
 title = paste0("<p>", 1:nb,"<br>Tooltip !</p>"), stringsAsFactors = FALSE)

edges <- data.frame(from = trunc(runif(nb)*(nb-1))+1,
 to = trunc(runif(nb)*(nb-1))+1,
 value = rnorm(nb, 10), label = paste("Edge", 1:nb),
 title = paste0("<p>", 1:nb,"<br>Edge Tooltip !</p>"))

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% visLegend()

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visLegend(useGroups = FALSE, addNodes = data.frame(label = "Nodes", shape = "circle"), 
            addEdges = data.frame(label = "link", color = "black"))

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visOptions(highlightNearest = TRUE)

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visOptions(highlightNearest = list(enabled =TRUE, degree = 2))

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)

## ------------------------------------------------------------------------
# can be the column you want
nodes$sel <- sample(c("sel1", "sel2"), nrow(nodes), replace = TRUE)
visNetwork(nodes, edges, width = "100%") %>%
 visOptions(selectedBy = "sel")

## ---- echo = FALSE-------------------------------------------------------
nodes <- data.frame(id = 1:nb, label = paste("Label", 1:nb),
 group = sample(1:nb, nb, replace = TRUE), value = 1:nb,
 title = paste0("<p>", 1:nb,"<br>Tooltip !</p>"), stringsAsFactors = FALSE)

edges <- data.frame(from = trunc(runif(nb)*(nb-1))+1,
 to = trunc(runif(nb)*(nb-1))+1,
 title = paste0("<p>", 1:nb,"<br>Edge Tooltip !</p>"))

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visEdges(arrows = 'from')

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visInteraction(navigationButtons = TRUE)

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visOptions(manipulation = TRUE)

## ---- echo = TRUE--------------------------------------------------------
nodes <- data.frame(id = 1:7)

edges <- data.frame(
  from = c(1,2,2,2,3,3),
  to = c(2,3,4,5,6,7)
)

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visEdges(arrows = "from") %>% 
  visHierarchicalLayout() 
# same as   visLayout(hierarchical = TRUE) 

visNetwork(nodes, edges, width = "100%") %>% 
  visEdges(arrows = "from") %>% 
  visHierarchicalLayout(direction = "LR")

## ------------------------------------------------------------------------
visNetwork(nodes, edges, width = "100%") %>% 
  visInteraction(dragNodes = FALSE, dragView = FALSE, zoomView = FALSE)

## ------------------------------------------------------------------------
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges, width = "100%") %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  visLegend() %>%
  addFontAwesome()

## ---- eval = T-----------------------------------------------------------
library(rpart)
# Complex tree
data("solder")
res <- rpart(Opening~., data = solder, control = rpart.control(cp = 0.00005))
visTree(res, height = "800px", nodesPopSize = TRUE, minNodeSize = 10, maxNodeSize = 30)


## ---- eval = FALSE-------------------------------------------------------
#  output$mynetwork <- renderVisNetwork({... visOptions(nodesIdSelection = TRUE)}) # created input$mynetwork_selected
#  

## ---- eval = FALSE-------------------------------------------------------
#  network <- visNetwork(nodes, edges, width = "100%")
#  visSave(network, file = "network.html")

## ------------------------------------------------------------------------
visNetwork(dot = 'dinetwork {1 -> 1 -> 2; 2 -> 3; 2 -- 4; 2 -> 1 }', width = "100%")

## ---- eval = FALSE-------------------------------------------------------
#  # don't run here
#  visNetwork(gephi = 'WorldCup2014.json')

