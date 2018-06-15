shiny::tabPanel(
  title = "Set / update main, submain, footer",
  fluidRow(
    column(
      width = 4,
      h4("main :"),
      textInput("input_main", "Main : ", ""),
      checkboxInput("hidden_main", "Hidden ?", FALSE),
      hr(),
      h4("submain :"),
      textInput("input_submain", "Submain : ", ""),
      checkboxInput("hidden_submain", "Hidden ?", FALSE),
      hr(),
      h4("footer :"),
      textInput("input_footer", "Footer : ", ""),
      checkboxInput("hidden_footer", "Hidden ?", FALSE),
      hr()
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_set_title", height = "400px")
    )
  ),
  verbatimTextOutput("code_proxy_set_title")
)

