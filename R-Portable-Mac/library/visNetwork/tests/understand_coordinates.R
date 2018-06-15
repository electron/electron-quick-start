require(shiny)
server <- function(input, output) {
  data <- reactive({
    input$go
    isolate({
      nnodes <- input$nnodes
      nnedges <- input$nedges
      
      nodes <- data.frame(id = 1:nnodes, value = 1)
      edges <- data.frame(from = sample(1:nnodes, nnedges, replace = T), 
                          to = sample(1:nnodes, nnedges, replace = T))
      list(nodes = nodes, edges = edges)
    })

  })

  output$base_network <- renderVisNetwork({
    visNetwork(data()$nodes, data()$edges) %>% visPhysics(stabilization = FALSE)
  })
  
  output$igraph_network <- renderVisNetwork({
    visNetwork(data()$nodes, data()$edges)%>%
      visIgraphLayout()
  })
  
  vals <- reactiveValues(coords_base=NULL, coords_igraph=NULL)
  
  output$base_c <- renderPrint({
    vals$coords_base
  })
  
  output$igraph_c <- renderPrint({
    vals$coords_igraph
  })
  
  observe({
    input$getcoord
    visNetworkProxy("base_network") %>% visGetPositions()
    vals$coords_base <- if (!is.null(input$base_network_positions))
      do.call(rbind, input$base_network_positions)
    
    print(diff(range(vals$coords_base))/600)
    visNetworkProxy("igraph_network") %>% visGetPositions()
    vals$coords_igraph <- if (!is.null(input$igraph_network_positions))
      do.call(rbind, input$igraph_network_positions)
  })
}

ui <- fluidPage(
  fluidRow(
    column(4, sliderInput("nnodes", "nodes :", 2, 200, value = 2, step = 10)),
    column(4, sliderInput("nedges", "edges :", 2, 200, value = 2, step = 10)),
    column(2, actionButton("go", "Go !")),
    column(2, actionButton("getcoord", "Get Coordinates"))
  ),
  visNetworkOutput("base_network", height = "800px"),
  verbatimTextOutput("base_c"),
  visNetworkOutput("igraph_network", height = "800px"),
  verbatimTextOutput("igraph_c")
)

shinyApp(ui = ui, server = server)
