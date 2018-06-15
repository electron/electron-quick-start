shiny::tabPanel(
  title = "Shiny custom options",
  fluidRow(
    column(
      width = 12,
      visNetworkOutput("network_id",height = "400px"),
      fluidRow(
        column(
          width = 6,
          verbatimTextOutput("code_network_id")
        ),
        column(
          width = 3,
          HTML("Using nodesIdSelection option, you can view current node selection in shiny
               with input$networkid_selected")
          ),
        column(
          width = 3,
          verbatimTextOutput('view_id')
        )
      )
    )
  ),
  hr(),
  fluidRow(
    column(
      width = 12,
      visNetworkOutput("network_group",height = "600px"),
      fluidRow(
        column(
          width = 6,
          verbatimTextOutput("code_network_group")
        ),
        column(
          width = 3,
          HTML("Using selectedBy option, you can view current variable selection in shiny
               with input$networkid_selectedBy")
        ),
        column(
          width = 3,
          verbatimTextOutput('view_group')
        )
      )
    )
  )
)
