library(leaflet)
library(RColorBrewer)
library(maps)

shinyServer(function(input, output, session) {
  values <- reactiveValues(highlight = c())

  map <- createLeafletMap(session, "map")

  # Draw the given states, with or without highlighting
  drawStates <- function(stateNames, highlight = FALSE) {
    states <- map("state", stateNames, plot = FALSE, fill = TRUE)
    map$addPolygon(I(states$y), I(states$x), I(states$names),
      I(lapply(states$names, function(x) {
        x <- strsplit(x, ":")[[1]][1]
        list(fillColor = colors[[x]])
      })),
      I(list(fill = TRUE, fillOpacity = 0.7,
        stroke = TRUE, opacity = 1, color = "white", weight = ifelse(highlight, 4, 1)
      ))
    )
  }

  observe({
    print(input$map_zoom)
    map$clearShapes()
    if (!is.null(input$map_zoom) && input$map_zoom > 6) {
      # Get shapes from the maps package
      drawStates(names(density))
    }
  })

  # input$map_shape_mouseover gets updated a lot, even if the id doesn't change.
  # We don't want to update the polygons and stateInfo except when the id
  # changes, so use values$highlight to insulate the downstream reactives (as
  # writing to values$highlight doesn't trigger reactivity unless the new value
  # is different than the previous value).
  observe({
    values$highlight <- input$map_shape_mouseover$id
  })

  # Dynamically render the box in the upper-right
  output$stateInfo <- renderUI({
    if (is.null(values$highlight)) {
      return(tags$div("Hover over a state"))
    } else {
      # Get a properly formatted state name
      stateName <- names(density)[getStateName(values$highlight) == tolower(names(density))]
      return(tags$div(
        tags$strong(stateName),
        tags$div(density[stateName], HTML("people/m<sup>2</sup>"))
      ))
    }
  })

  lastHighlighted <- c()
  # When values$highlight changes, unhighlight the old state (if any) and
  # highlight the new state
  observe({
    if (length(lastHighlighted) > 0)
      drawStates(getStateName(lastHighlighted), FALSE)
    lastHighlighted <<- values$highlight

    if (is.null(values$highlight))
      return()

    isolate({
      drawStates(getStateName(values$highlight), TRUE)
    })
  })
})
