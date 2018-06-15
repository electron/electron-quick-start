# simple nodes, passing some information individually
nodes <- data.frame(id = 1:5, color = c("blue", NA, "green", NA, NA))

edges <- data.frame(from = trunc(runif(5)*(5-1))+1,
                    to = trunc(runif(5)*(5-1))+1)

visNetwork(nodes, edges) %>% 
  visOptions(highlightNearest = list(enabled = T, degree = 1, hover = F))


# simple nodes, passing some information individually
nodes <- data.frame(id = 1:5, 
                    color.highlight = c(NA,"purple", "black", NA, NA))

edges <- data.frame(from = trunc(runif(5)*(5-1))+1,
                    to = trunc(runif(5)*(5-1))+1)

nodes <- data.frame(id = 1:5, group = "A")

visNetwork(nodes, edges) %>% 
  visNodes(color = "red")%>% 
  visGroups(groupname = "A", color = "yellow")%>%
  visOptions(highlightNearest = list(enabled = T, degree = 10, hover = F), collapse = T)

# simple nodes, passing some information individually
nodes <- data.frame(id = 1:5, 
                    group = c("B", "B", "A", "C", "A"))

edges <- data.frame(from = trunc(runif(5)*(5-1))+1,
                    to = trunc(runif(5)*(5-1))+1)

visNetwork(nodes, edges) %>% 
  visGroups(groupname = "A", shape = "ellipse", color = list(background = "green", highlight = "red")) %>%
  visGroups(groupname = "B", shape = "square", color = list(border = "blue", highlight = "purple")) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 10, hover = T), selectedBy = "group")

# simple nodes unsing visNodes
nodes <- data.frame(id = 1:5, color.border = c("red","purple", "black", NA, NA))

edges <- data.frame(from = trunc(runif(5)*(5-1))+1,
                    to = trunc(runif(5)*(5-1))+1)

visNetwork(nodes, edges) %>% 
  visNodes(shape = "square", color = "green")  %>% 
  visOptions(highlightNearest = list(enabled = T, degree = 10, hover = T))

# simple nodes individually + visNodes
nodes <- data.frame(id = 1:5, color = c(NA, NA, "blue", NA, "red"))

edges <- data.frame(from = trunc(runif(5)*(5-1))+1,
                    to = trunc(runif(5)*(5-1))+1)

visNetwork(nodes, edges) %>% 
  visNodes(shape = "square", color = list(background = "green", border = "purple"))  %>% 
  visOptions(highlightNearest = list(enabled = T, degree = 10, hover = T))

# icons in group only
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome() %>% visOptions(highlightNearest = list(enabled = T, hover = T), selectedBy = "group")

# icons individually only
?addFontAwesome
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"), 
                    shape = "icon", 
                    icon.code = c("f0c0", "f007", "f007"),
                    icon.color = c("red", NA, "orange"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  addFontAwesome() %>% visOptions(highlightNearest = list(enabled = T, hover = T), selectedBy = "group")

# icons in group and individually
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"), 
                    shape = "icon", 
                    icon.code = c("f0c0", NA, NA),
                    icon.color = c(NA, NA, "orange"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visNodes(icon = list(code = "f0c0", color = "purple")) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome() %>% visOptions(highlightNearest = list(enabled = T, hover = T), selectedBy = "group")

# test passing shape information globally
nodes <- data.frame(id = 1:3, icon.code = c("f0c0", "f0c0","f007"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visNodes(shape = "icon", icon = list(color = "red")) %>%
  addFontAwesome() %>% visOptions(highlightNearest = T, selectedBy = "id")

nodes <- data.frame(id = 1:3, icon.code = c("f0c0", "f0c0","f007"),
                    icon.color = c("orange", NA, NA))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visNodes(shape = "icon", icon = list(color = "red")) %>%
  addFontAwesome() %>% visOptions(highlightNearest = T, selectedBy = "id")

# with image
path_to_images <- "https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/img/indonesia/"

nodes <- data.frame(id = 1:4, group = c("A", "B"),
                    shape = c("image", "circularImage"),
                    image = paste0(path_to_images, 1:4, ".png"),
                    label = "I'm an image")

edges <- data.frame(from = c(2,4,3,3), to = c(1,2,4,2))

visNetwork(nodes, edges, width = "100%") %>% 
  visNodes(shapeProperties = list(useBorderWithImage = TRUE)) %>%
  visLayout(randomSeed = 2) %>% visOptions(highlightNearest = T, selectedBy = "group")

# with image, passing globally
nodes <- data.frame(id = 1:4, color.border = c("red",NA, NA, "blue"),
                    image = paste0(path_to_images, 1:4, ".png"),
                    label = "I'm an image")

edges <- data.frame(from = c(2,4,3,3), to = c(1,2,4,2))

visNetwork(nodes, edges, width = "100%") %>% 
  visNodes(shapeProperties = list(useBorderWithImage = TRUE, useImageSize=TRUE), shape = "image", color = "orange") %>%
  visLayout(randomSeed = 2) %>% visOptions(highlightNearest = list(enabled = TRUE, hover= T))


# test on legend passing icons in a list
nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

# using a list
visNetwork(nodes, edges, main = "Use fonAwesome icons") %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome() %>%
  visLegend(main = "Legend", addNodes = list(
    list(label = "Group", shape = "icon", icon = list(code = "f0c0", size = 25)),
    list(label = "User", shape = "icon", icon = list(code = "f007", size = 50, color = "red"))
  ),
  addEdges = data.frame(label = "link"), useGroups = FALSE)   