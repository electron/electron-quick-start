shiny::tabPanel(
  title = "Manipulation in shiny",
  fluidRow(
    column(
      width = 12,
      visNetworkOutput("network_manip",height = "600px"),
      fluidRow(
        column(
          width = 6,
          verbatimTextOutput("code_network_manip")
        ),
        column(
          width = 3,
          HTML("Using manipulation option, you can view current action in shiny
               with input$networkid_graphChange")
          ),
        column(
          width = 3,
          verbatimTextOutput('view_manip')
        )
      )
    )
  )
)
