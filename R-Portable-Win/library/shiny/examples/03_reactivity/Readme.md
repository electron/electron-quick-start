This example demonstrates a core feature of Shiny: **reactivity**. In the `server` function, a reactive called `datasetInput` is declared. 

Notice that the reactive expression depends on the input expression `input$dataset`, and that it's used by two output expressions: `output$summary` and `output$view`. Try changing the dataset (using *Choose a dataset*) while looking at the reactive and then at the outputs; you will see first the reactive and then its dependencies flash. 

Notice also that the reactive expression doesn't just update whenever anything changes--only the inputs it depends on will trigger an update. Change the "Caption" field and notice how only the `output$caption` expression is re-evaluated; the reactive and its dependents are left alone.
