library(shiny)

shinyUI(fluidPage(
  title = 'Column Filters on the Server Side',
  fluidRow(
    DT::dataTableOutput('tbl')
  )
))
