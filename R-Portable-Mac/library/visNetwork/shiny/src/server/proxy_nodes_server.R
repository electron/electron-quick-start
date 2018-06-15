output$network_proxy_nodes <- renderVisNetwork({
  # minimal example
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(from = c(1,2), to = c(1,3))
  
  visNetwork(nodes, edges)%>%
    visNodes(color = "blue", size = 20)
})

observe({
  visNetworkProxy("network_proxy_nodes") %>%
    visNodes(color = input$color, size = input$size, shadow = input$shadow) %>%
    visEdges(dashes = input$dashes, smooth = input$smooth)
})

# observe({
#   visNetworkProxy("network_proxy_nodes") %>%
#     visSetOptions(options = list(nodes = list(color = input$color, size = input$size, shadow = input$shadow),
#     edges = list(dashes = input$dashes, smooth = input$smooth)))
# })

output$code_proxy_nodes  <- renderText({
  '
output$network_proxy_nodes <- renderVisNetwork({
  # minimal example
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(from = c(1,2), to = c(1,3))
  
  visNetwork(nodes, edges)
})
  
observe({
  visNetworkProxy("network_proxy_nodes") %>%
  visNodes(color = input$color, size = input$size, shadow = input$shadow) %>%
  visEdges(dashes = input$dashes, smooth = input$smooth)
})

# same directly with visSetOptions :
observe({
  visNetworkProxy("network_proxy_nodes") %>%
  visSetOptions(options = list(nodes = list(color = input$color, size = input$size, shadow = input$shadow),
  edges = list(dashes = input$dashes, smooth = input$smooth)))
})
 '
})