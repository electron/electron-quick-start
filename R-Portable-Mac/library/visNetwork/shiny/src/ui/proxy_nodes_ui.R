shiny::tabPanel(
  title = "Update nodes/edges properties",
  fluidRow(
    column(
      width = 4,
      selectInput("color", "Nodes Color :",
                    c("blue", "red", "green")),
      checkboxInput("shadow", "Shadow", FALSE),
      sliderInput("size", "Size : ", min = 10, max = 100, value = 20),
      checkboxInput("dashes", "Dashes", FALSE),
      checkboxInput("smooth", "Smooth", TRUE)
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_nodes", height = "400px")
    )
  ),
  verbatimTextOutput("code_proxy_nodes")
  
)

