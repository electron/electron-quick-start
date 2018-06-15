shiny::tabPanel(
  title = "Get nodes/edges data",
  fluidRow(
    column(
      width = 4,
      actionButton("getEdges", "Get edges data"),
      actionButton("getNodes", "Get nodes data"),
      actionButton("updateGet", "Update data")
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_get", height = "400px")
    )
  ),
  verbatimTextOutput("edges_data_from_shiny"),
  verbatimTextOutput("nodes_data_from_shiny"),
  verbatimTextOutput("code_proxy_get")
)

