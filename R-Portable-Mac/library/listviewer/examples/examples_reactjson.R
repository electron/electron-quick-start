\dontrun{

library(listviewer)

# use reactR for React dependencies
# devtools::install_github("timelyportfolio/reactR")
library(reactR)

reactjson()

reactjson(head(mtcars,4))
reactjson(I(jsonlite::toJSON(head(mtcars,5))))

library(shiny)

shinyApp(
  ui = reactjson(
    list(x=1,msg="react+r+shiny",opts=list(use_react=FALSE)),
    elementId = "json1"
  ),
  server = function(input, output, session){
    observeEvent(
      input$json1_change,
      str(input$json1_change)
    )
  }
)


# gadget to use as editor
library(miniUI)
ui <- miniUI::miniPage(
  miniUI::miniContentPanel(
    reactjson(
      list(x=1,msg="react+r+shiny",opts=list(use_react=FALSE)),
      elementId = "rjeditor"
    )
  ),
  miniUI::gadgetTitleBar(
    "Edit",
    right = miniUI::miniTitleBarButton("done", "Done", primary = TRUE)
  )
)

server <- function(input, output, session) {
  shiny::observeEvent(input$done, {
    shiny::stopApp(
      input$rjeditor_change
    )
  })

  shiny::observeEvent(input$cancel, { shiny::stopApp (NULL) })
}

runGadget(
  ui,
  server,
  viewer = shiny::paneViewer()
)

}
