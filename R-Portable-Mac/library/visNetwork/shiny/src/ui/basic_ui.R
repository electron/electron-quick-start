shiny::tabPanel(
  title = "Basic",
  fluidRow(
    column(
      width = 6,
      verbatimTextOutput("code_network_hello")
    ),
    column(
      width = 6,
      visNetworkOutput("network_hello",height = "300px")
    )
  ),
  hr(),
  fluidRow(
    column(
      width = 12,
      div(h3("Second network with icons"), align = "center"),
      visNetworkOutput("network_icon"),
      verbatimTextOutput("code_network_icon")
    )
  )
)
