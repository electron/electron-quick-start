dataan <- reactive({
  set.seed(2)
  nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                      group = sample(LETTERS[1:3], 15, replace = TRUE))
  
  edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                      to = trunc(runif(15)*(15-1))+1)
  list(nodes = nodes, edges = edges)
})

output$network_proxy_focus <- renderVisNetwork({
  visNetwork(dataan()$nodes, dataan()$edges) %>% visLegend()
})

observe({
  visNetworkProxy("network_proxy_focus") %>%
    visFocus(id = input$Focus, scale = input$scale_id)
    # visRemoveNodes(id = input$Focus)
    # visFit(nodes = input$Focus)
})

observe({
  gr <- input$Group
  isolate({
    if(gr != "ALL"){
      nodes <- dataan()$nodes
      id <- nodes$id[nodes$group%in%gr]
    }else{
      id <- NULL
    }
    visNetworkProxy("network_proxy_focus") %>%
      visFit(nodes = id)
  })
})

output$code_proxy_focus  <- renderText({
  '
observe({
  visNetworkProxy("network_proxy_focus") %>%
    visFocus(id = input$Focus, scale = input$scale_id)
})

observe({
  gr <- input$Group
  isolate({
    if(gr != "ALL"){
      nodes <- dataan()$nodes
      id <- nodes$id[nodes$group%in%gr]
    }else{
      id <- NULL
    }
    visNetworkProxy("network_proxy_focus") %>%
      visFit(nodes = id)
  })
})
 '
})