output$network_id <- renderVisNetwork({
  nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                      group = sample(LETTERS[1:3], 15, replace = TRUE))
  
  edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                      to = trunc(runif(15)*(15-1))+1)
  
  # visNetwork(nodes, edges, main = "Title", submain = "Subtitle", footer = "footer") %>%
  #   visExport()
  
  visNetwork(nodes, edges, main = "Title", submain = "Subtitle") %>%
    visExport() %>%
    visOptions(highlightNearest = TRUE,
               nodesIdSelection = list(enabled = TRUE, selected = "1"))
  
})

output$view_id <- renderText({
  paste("Current node selection : ", input$network_id_selected)
})

output$code_network_id <- renderText({
  '
  visNetwork(nodes, edges, main = "Title", submain = "Subtitle") %>%
    visExport() %>%
    visOptions(highlightNearest = TRUE,
      nodesIdSelection = list(enabled = TRUE, selected = "1"))
 '
})

output$network_group <- renderVisNetwork({
  nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                      group = sample(LETTERS[1:3], 15, replace = TRUE))
  
  edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                      to = trunc(runif(15)*(15-1))+1)
  
  visNetwork(nodes, edges) %>%
    visOptions(selectedBy = list(variable = "group", selected = "A"))
})

output$view_group <- renderText({
  paste("Current variable selection : ", input$network_group_selectedBy)
})

output$code_network_group  <- renderText({
  '
  visNetwork(nodes, edges) %>%
    visOptions(selectedBy = list(variable = "group", selected = "A"))
 '
})