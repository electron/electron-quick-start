library(shiny)

fluidPage(

  title = 'Manipulate an Existing Table',

  sidebarLayout(
    sidebarPanel(
      selectizeInput('rows', 'Row IDs', choices = seq_len(nrow(iris)), multiple = TRUE),
      actionButton('select1', 'Select Rows'),
      actionButton('clear1', 'Clear Rows'),
      numericInput('col', 'Column ID', 1, min = 1, max = ncol(iris), step = 1),
      actionButton('select2', 'Select Column'),
      actionButton('clear2', 'Clear Columns'),
      hr(),
      actionButton('add', 'Add Row'),
      hr(),
      textInput('cap', 'Table Caption')
    ),
    mainPanel(
      DT::dataTableOutput('foo'),
      verbatimTextOutput('info')
    )
  )
)
