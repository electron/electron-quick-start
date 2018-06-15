#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(visNetwork)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  actionButton("goCol", "Collapsed !"),
  actionButton("goUC", "uncollapse!"),
  actionButton("goRm", "remove event!"),
  actionButton("goAdd", "add event!"),
  fluidRow(column(4, div(id = "conf")), 
           column(8,   visNetworkOutput("distPlot")))

      
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
   
   output$distPlot <- renderVisNetwork({
     set.seed(125)
     nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                         group = sample(LETTERS[1:3], 15, replace = TRUE))
     
     edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                         to = trunc(runif(15)*(15-1))+1)

     visNetwork(nodes, edges) %>% visOptions(highlightNearest = T, collapse = T) %>% 
       visEdges(arrows = "to") %>% visConfigure(container = "conf")
     
   })
   
   observe({
     if(input$goCol > 0){
       visNetworkProxy("distPlot") %>% visCollapse(nodes = c(10,3), clusterOptions = list( shape ="square", label = "and so ?"))
     }
   })
   
   observe({
     if(input$goUC > 0){
       visNetworkProxy("distPlot") %>% visUncollapse()
     }
   })
   
   observe({
     if(input$goRm > 0){
       visNetworkProxy("distPlot") %>% visEvents(type = "off", doubleClick = "networkOpenCluster")
     }
   })
   
   observe({
     if(input$goAdd > 0){
       visNetworkProxy("distPlot") %>% visEvents(type = "on", doubleClick = "networkOpenCluster")
     }
   })
   
})

# Run the application 
shinyApp(ui = ui, server = server)

