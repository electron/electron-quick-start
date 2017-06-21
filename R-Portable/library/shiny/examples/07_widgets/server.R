library(shiny)
library(datasets)

# Define server logic required to summarize and view the
# selected dataset
function(input, output) {

  # Return the requested dataset. Note that we use `eventReactive()`
  # here, which takes a dependency on input$update (the action
  # button), so that the output is only updated when the user
  # clicks the button.
  datasetInput <- eventReactive(input$update, {
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  }, ignoreNULL = FALSE)

  # Generate a summary of the dataset
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })

  # Show the first "n" observations. The use of `isolate()` here
  # is necessary because we don't want the table to update
  # whenever input$obs changes (only when the user clicks the
  # action button).
  output$view <- renderTable({
    head(datasetInput(), n = isolate(input$obs))
  })
}
