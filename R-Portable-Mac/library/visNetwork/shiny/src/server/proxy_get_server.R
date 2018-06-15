dataget <- reactive({
  set.seed(2)
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(from = c(1,2), to = c(1,3))
  
  list(nodes = nodes, edges = edges)
})

output$network_proxy_get <- renderVisNetwork({
  visNetwork(dataget()$nodes, dataget()$edges) %>% visLegend()
})

observe({
  input$getEdges
  visNetworkProxy("network_proxy_get") %>%
    visGetEdges()
})

observe({
  input$getNodes
  visNetworkProxy("network_proxy_get") %>%
    visGetNodes()
})

output$edges_data_from_shiny <- renderPrint({
  if(!is.null(input$network_proxy_get_edges)){
    input$network_proxy_get_edges
  }
})

output$nodes_data_from_shiny <- renderPrint({
  if(!is.null(input$network_proxy_get_nodes)){
    input$network_proxy_get_nodes
  }
})

observe({
  input$updateGet
  nodes <- data.frame(id = 4, color = "red")
  edges <- edges <- data.frame(id = "newedges", from = c(4), to = c(1))
  visNetworkProxy("network_proxy_get") %>%
    visUpdateNodes(nodes = nodes) %>%
    visUpdateEdges(edges = edges)
})

output$code_proxy_get  <- renderText({
  '
  observe({
    input$getEdges
    visNetworkProxy("network_proxy_get") %>%
    visGetEdges()
  })
  
  observe({
    input$getNodes
    visNetworkProxy("network_proxy_get") %>%
    visGetNodes()
  })
  
  output$edges_data_from_shiny <- renderPrint({
    if(!is.null(input$network_proxy_get_edges)){
    input$network_proxy_get_edges
    }
  })
  
  output$nodes_data_from_shiny <- renderPrint({
    if(!is.null(input$network_proxy_get_nodes)){
    input$network_proxy_get_nodes
    }
  })
 '
})