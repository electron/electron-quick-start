require(visNetwork)

###################
# visNetwork
###################

# minimal example
nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges)

# customization adding more variables (see visNodes and visEdges)
nodes <- data.frame(id = 1:10,
                    label = paste("Node", 1:10),                                 # labels
                    group = c("GrA", "GrB"),                                     # groups
                    value = 1:10,                                                # size
                    shape = c("square", "triangle", "box", "circle", "dot", "star",
                              "ellipse", "database", "text", "diamond"),         # shape
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),         # tooltip
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),# color
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))                  # shadow

edges <- data.frame(from = sample(1:10,8), to = sample(1:10, 8),
                    label = paste("Edge", 1:8),                                 # labels
                    length = c(100,500),                                        # length
                    arrows = c("to", "from", "middle", "middle;to"),            # arrows
                    dashes = c(TRUE, FALSE),                                    # dashes
                    title = paste("Edge", 1:8),                                 # tooltip
                    smooth = c(FALSE, TRUE),                                    # smooth
                    shadow = c(FALSE, TRUE, FALSE, TRUE))                       # shadow

visNetwork(nodes, edges)

# highlight nearest
nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                    group = sample(LETTERS[1:3], 15, replace = TRUE))

edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                    to = trunc(runif(15)*(15-1))+1)

###################
# highlight nearest
###################

visNetwork(nodes, edges) %>% visOptions(highlightNearest = TRUE)
visNetwork(nodes, edges) %>% visOptions(highlightNearest = list(enabled = TRUE, degree = 0))

##########################
# nodesIdSelection
##########################

visNetwork(nodes, edges) %>%
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)

# add a default selected node ?
visNetwork(nodes, edges) %>%
  visOptions(highlightNearest = TRUE,
             nodesIdSelection = list(enabled = TRUE, selected = "1"))

##########################
# selectedBy
##########################

visNetwork(nodes, edges) %>%
  visOptions(selectedBy = "group")

# add a default value ?
visNetwork(nodes, edges) %>%
  visOptions(selectedBy = list(variable = "group", selected = "A"))

# can also be on new column
nodes$sample <- sample(c("sample 1", "sample 2"), nrow(nodes), replace = TRUE)
visNetwork(nodes, edges) %>%
  visOptions(selectedBy = "sample")

# add legend
visNetwork(nodes, edges) %>% visLegend()

# directed network
visNetwork(nodes, edges) %>%
  visEdges(arrow = 'from', scaling = list(min = 2, max = 2))

# custom navigation
visNetwork(nodes, edges) %>%
  visInteraction(navigationButtons = TRUE)

# data Manipulation
visNetwork(nodes, edges) %>% visOptions(manipulation = TRUE)

# Hierarchical Layout
visNetwork(nodes, edges) %>% visHierarchicalLayout()

# freeze network
visNetwork(nodes, edges) %>%
  visInteraction(dragNodes = FALSE, dragView = FALSE, zoomView = FALSE)

# use fontAwesome icons using groups or nodes options
# font-awesome is not part of dependencies. use addFontAwesome() if needed
# http://fortawesome.github.io/Font-Awesome

nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome()

nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges) %>%
  visNodes(shape = "icon", icon = list( face ='FontAwesome', code = "f0c0")) %>%
  addFontAwesome()

## End(Not run)
# DOT language
visNetwork(dot = 'dinetwork {1 -> 1 -> 2; 2 -> 3; 2 -- 4; 2 -> 1 }')

###################
# visEdges
###################

nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges) %>% visEdges(arrows = 'from')

visNetwork(nodes, edges) %>% visEdges(arrows = 'to, from')

visNetwork(nodes, edges) %>% visEdges(arrows =list(to = list(enabled = TRUE, scaleFactor = 2)))

visNetwork(nodes, edges) %>% visEdges(smooth = FALSE)

visNetwork(nodes, edges) %>% visEdges(smooth = list(enabled = TRUE, type = "diagonalCross"))

visNetwork(nodes, edges) %>% visEdges(width = 10)

visNetwork(nodes, edges) %>% visEdges(color = list(hover = "green")) %>%
  visInteraction(hover = TRUE)

visNetwork(nodes, edges) %>% visEdges(color = "red")

visNetwork(nodes, edges) %>% visEdges(color = list(color = "red", highlight = "yellow"))

visNetwork(nodes, edges) %>% visEdges(shadow = TRUE)

visNetwork(nodes, edges) %>% visEdges(shadow = list(enabled = TRUE, size = 5))

###################
# visNodes
###################

nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges) %>% visNodes(shape = "square", title = "I'm a node", borderWidth = 3)

visNetwork(nodes, edges) %>% visNodes(color = list(hover = "green")) %>%
  visInteraction(hover = TRUE)

visNetwork(nodes, edges) %>% visNodes(color = "red")

visNetwork(nodes, edges) %>% visNodes(color = list(background = "red", border = "blue",
                                                   highlight = "yellow"))

visNetwork(nodes, edges) %>% visNodes(shadow = TRUE)

visNetwork(nodes, edges) %>% visNodes(shadow = list(enabled = TRUE, size = 50))

#################
# visLegend
#################

# minimal example
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

# default, on group
visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", color = "red") %>%
  visGroups(groupname = "B", color = "lightblue") %>%
  visLegend()

# default, on group, adjust width + change position
visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", color = "red") %>%
  visGroups(groupname = "B", color = "lightblue") %>%
  visLegend(width = 0.05, position = "right")

# passing custom nodes and/or edges
lnodes <- data.frame(label = c("Group A", "Group B"),
                     shape = c( "ellipse"), color = c("red", "lightblue"),
                     title = "Informations", id = 1:2)

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", color = "red") %>%
  visGroups(groupname = "B", color = "lightblue") %>%
  visLegend(addNodes = lnodes, useGroups = FALSE)

ledges <- data.frame(color = c("lightblue", "red"),
                     label = c("reverse", "depends"), arrows =c("to", "from"))

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", color = "lightblue") %>%
  visGroups(groupname = "B", color = "red") %>%
  visLegend(addEdges = ledges)

# for more complex option, you can use a list(of list...)
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome() %>%
  visLegend(addNodes = list(
    list(label = "Group", shape = "icon", icon = list(code = "f0c0", size = 25)),
    list(label = "User", shape = "icon", icon = list(code = "f007", size = 50, color = "red"))
  ),
  addEdges = data.frame(label = "link"), useGroups = FALSE)
