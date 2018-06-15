datatitle <- reactive({
  set.seed(2)
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(from = c(1,2), to = c(1,3))
  
  list(nodes = nodes, edges = edges)
})

output$network_proxy_set_title <- renderVisNetwork({
  visNetwork(datatitle()$nodes, datatitle()$edges) %>% visExport()
})

observe({
  visNetworkProxy("network_proxy_set_title") %>%
    visSetTitle(main = list(text = input$input_main, hidden = input$hidden_main),
                submain = list(text = input$input_submain, hidden = input$hidden_submain),
                footer =list(text = input$input_footer, hidden = input$hidden_footer))
})

output$code_proxy_set_title <- renderText({
  '
  observe({
    visNetworkProxy("network_proxy_set_title") %>%
    visSetTitle(main = list(text = input$input_main, hidden = input$hidden_main),
    submain = list(text = input$input_submain, hidden = input$hidden_submain),
    footer =list(text = input$input_footer, hidden = input$hidden_footer))
  })
'
})