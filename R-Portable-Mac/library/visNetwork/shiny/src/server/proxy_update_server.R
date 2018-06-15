n = 20
dataup <- reactive({
  set.seed(2)
  nodes <- data.frame(id = 1:n, label = paste("Label", 1:n),
                      group = sample(LETTERS[1:3], n, replace = TRUE))
  
  edges <- data.frame(id = 1:n, from = trunc(runif(n)*(n-1))+1,
                      to = trunc(runif(n)*(n-1))+1)
  list(nodes = nodes, edges = edges)
})

output$network_proxy_update <- renderVisNetwork({
  visNetwork(dataup()$nodes, dataup()$edges) %>% visLegend() %>% 
    visOptions(selectedBy = "group", highlightNearest = TRUE) 
})

observe({
  input$goUpdate
  nodes <- data.frame(id = 1:(n+10), 
                      group = sample(LETTERS[1:5], n+10, replace = TRUE))
  edges <- dataup()$edges
  
  edges$color <- sample(c("red", "blue", "yellow"), 1)
  
  visNetworkProxy("network_proxy_update") %>%
    visUpdateNodes(nodes = nodes) %>%
    visUpdateEdges(edges = edges) %>%
    visEvents(type = "on", dragEnd = "function(properties) {
     alert('finsih to drag');}")
})

observe({
  input$goRemove
  visNetworkProxy("network_proxy_update") %>%
    visRemoveNodes(id = c(1:5)) %>%
    visRemoveEdges(id = c(1:5)) %>%
    visEvents(type = "off", dragEnd = "function(properties) {
              alert('finsih to drag');}")
})


output$code_proxy_update  <- renderText({
  '
observe({
  input$goUpdate
  nodes <- data.frame(id = 1:15, 
  group = sample(LETTERS[1:5], 15, replace = TRUE))
  edges <- data()$edges
  edges$color <- sample(c("red", "blue", "yellow"), 1)
  
  visNetworkProxy("network_proxy_update") %>%
  visUpdateNodes(nodes = nodes) %>%
  visUpdateEdges(edges = edges)
})
  
observe({
  input$goRemove
  visNetworkProxy("network_proxy_update") %>%
  visRemoveNodes(id = c(1:5)) %>%
  visRemoveEdges(id = c(1:5))
})
 '
})