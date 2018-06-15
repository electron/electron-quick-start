output$network_hello <- renderVisNetwork({
  # minimal example
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(from = c(1,2), to = c(1,3))
  
  visNetwork(nodes, edges)
})


output$code_network_hello <- renderText({
  '
  # in server.R : 
  output$network_hello <- renderVisNetwork({
    # minimal example
    nodes <- data.frame(id = 1:3)
    edges <- data.frame(from = c(1,2), to = c(1,3))
  
    visNetwork(nodes, edges)
  })

  # in ui.R
  visNetworkOutput("network_hello",height = "200px")
 '
})

output$network_icon <- renderVisNetwork({
  
  nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
  edges <- data.frame(from = c(1,2), to = c(2,3))
  
  visNetwork(nodes, edges) %>%
    visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
    visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
    addFontAwesome() %>%
    visLegend(addNodes = data.frame(label = c("A", "B"), shape = "icon", 
                                    icon.code = c("f0c0", "f007"), 
                                    icon.size = c(25,50), 
                                    icon.color = c(NA, "red")),
      addEdges = data.frame(label = "link"), useGroups = FALSE)
})

output$code_network_icon <- renderText({
  '
  nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
  edges <- data.frame(from = c(1,2), to = c(2,3))
  
  visNetwork(nodes, edges) %>%
    visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
    visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
    addFontAwesome() %>%
    visLegend(addNodes = data.frame(label = c("A", "B"), shape = "icon", 
                                    icon.code = c("f0c0", "f007"), 
                                    icon.size = c(25,50), 
                                    icon.color = c(NA, "red")),
            addEdges = data.frame(label = "link"), useGroups = FALSE)
 '
})