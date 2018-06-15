shiny::tabPanel(
  title = "Select nodes/edges data",
  fluidRow(
    column(
      width = 4,
      selectInput(inputId = "selnodes", label = "Nodes selection", choices = 1:15, multiple = TRUE),
      selectInput(inputId = "seledges", label = "Edges selection", choices = 1:15, multiple = TRUE)
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_select", height = "400px")
    )
  ),
  verbatimTextOutput("code_proxy_select")
)

