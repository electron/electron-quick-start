shiny::tabPanel(
  title = "Use focus & fit methods",
  fluidRow(
    column(
      width = 4,
      selectInput("Focus", "Focus on node :",
                    c(1:15)),
      sliderInput("scale_id", "Focus scale : ", min = 1, max = 4, value = 2),
      selectInput("Group", "Focus on group :",
                  c("ALL", "A", "B", "C"))
    ),
    column(
      width = 8,
      visNetworkOutput("network_proxy_focus", height = "400px")
    )
  ),
  verbatimTextOutput("code_proxy_focus")
  
)

