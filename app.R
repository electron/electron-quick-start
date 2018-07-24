library(shiny)


shinyApp(
 shinyUI(
# Define UI for application that draws a histogram

fluidPage(



  # Application title

  titlePanel("Hello Shiny!"),



  # Sidebar with a slider input for the number of bins

  sidebarLayout(

    sidebarPanel(

      sliderInput("bins",

                  "Number of bins:",

                  min = 1,

                  max = 50,

                  value = 30)

    ),



    # Show a plot of the generated distribution

    mainPanel(
      plotOutput("distPlot"),
      h4(".libPaths::"),
      p(.libPaths()),
      h4("R.Version()::"),
      p(R.Version()),
      h4("R.home()::"),
      p(R.home()),
      h4("getwd()::"),
      p(getwd()), 
      h4("sessionInfo()::"),
      p(sessionInfo()),
      h4("Sys.getenv('DYLD_FALLBACK_LIBRARY_PATH')"),
      p(Sys.getenv("DYLD_FALLBACK_LIBRARY_PATH"))

    )

  )

)

),
shinyServer(

function(input, output) {



  # Expression that generates a histogram. The expression is

  # wrapped in a call to renderPlot to indicate that:

  #

  #  1) It is "reactive" and therefore should be automatically

  #     re-executed when inputs change

  #  2) Its output type is a plot



  output$distPlot <- renderPlot({

    x    <- faithful[, 2]  # Old Faithful Geyser data

    bins <- seq(min(x), max(x), length.out = input$bins + 1)



    # draw the histogram with the specified number of bins

    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })
  



}

)

)