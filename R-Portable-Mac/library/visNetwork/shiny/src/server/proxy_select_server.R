datass <- reactive({
  set.seed(2)
  nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                      group = sample(LETTERS[1:3], 15, replace = TRUE))
  
  edges <- data.frame(id = 1:15, from = trunc(runif(15)*(15-1))+1,
                      to = trunc(runif(15)*(15-1))+1)
  list(nodes = nodes, edges = edges)
})

output$network_proxy_select <- renderVisNetwork({
  visNetwork(datass()$nodes, datass()$edges) %>% visLegend()
})

observe({
  nodes_selection <- input$selnodes
  visNetworkProxy("network_proxy_select") %>%
    visSelectNodes(id = nodes_selection)
})

observe({
  edges_selection <- input$seledges
  visNetworkProxy("network_proxy_select") %>%
    visSelectEdges(id = edges_selection)
})

# observe({
#   nodes_selection <- input$selnodes
#   edges_selection <- input$seledges
#   visNetworkProxy("network_proxy_select") %>%
#     visSetSelection(nodesId = nodes_selection, edgesId = edges_selection)
# })



output$code_proxy_select  <- renderText({
  '
observe({
  nodes_selection <- input$selnodes
  visNetworkProxy("network_proxy_select") %>%
  visSelectNodes(id = nodes_selection)
})
  
observe({
  edges_selection <- input$seledges
  visNetworkProxy("network_proxy_select") %>%
    visSelectEdges(id = edges_selection)
})

# or with visSetSelection : 
observe({
  nodes_selection <- input$selnodes
  edges_selection <- input$seledges
  visNetworkProxy("network_proxy_select") %>%
    visSetSelection(nodesId = nodes_selection, edgesId = edges_selection)
})
 '
})