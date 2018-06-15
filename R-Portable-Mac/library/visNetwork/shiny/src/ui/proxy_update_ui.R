shiny::tabPanel(
  title = "Update nodes/edges data",
  fluidRow(
    column(
      width = 4,
      actionButton("goUpdate", "Update data"),
      actionButton("goRemove", "Remove data")
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_update", height = "400px")
    )
  ),
  verbatimTextOutput("code_proxy_update")
)

