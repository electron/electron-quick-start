library(leaflet)

shinyUI(fluidPage(
  leafletMap("map", 600, 400, options = list(
    center = c(47.6659641734893, -122.376078869215),
    zoom = 13
  )),
  htmlOutput("details")
))
