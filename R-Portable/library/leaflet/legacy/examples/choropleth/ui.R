library(leaflet)

shinyUI(fluidPage(
  
  # Add a little CSS to make the map background pure white
  tags$head(tags$style("
    #showcase-code-position-toggle, #showcase-sxs-code { display: none; }
    .floater { background-color: white; padding: 8px; opacity: 0.7; border-radius: 6px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }
  ")),

  leafletMap(
    "map", "100%", 500,
    # By default OpenStreetMap tiles are used; we want nothing in this case
    #initialTileLayer = NULL,
    #initialTileLayerAttribution = NULL,
    options=list(
      center = c(40, -98.85),
      zoom = 4,
      maxBounds = list(list(17, -180), list(59, 180))
    )
  ),
  
  absolutePanel(
    right = 30, top = 10, width = 200, class = "floater",
    
    h4("US Population Density"),
    uiOutput("stateInfo")
  ),
  
  absolutePanel(
    right = 30, top = 280, style = "", class = "floater",
    tags$table(
      mapply(function(from, to, color) {
        tags$tr(
          tags$td(tags$div(
            style = sprintf("width: 16px; height: 16px; background-color: %s;", color)
          )),
          tags$td(from, "-", to)
        )
      }, densityRanges$from, densityRanges$to, palette, SIMPLIFY=FALSE)
    )
  )
))
