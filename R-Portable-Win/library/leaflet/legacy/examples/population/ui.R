library(leaflet)
library(ShinyDash)

shinyUI(fluidPage(
  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  leafletMap(
    "map", "100%", 400,
    initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(37.45, -93.85),
      zoom = 4,
      maxBounds = list(list(17, -180), list(59, 180))
    )
  ),
  fluidRow(
    column(8, offset=3,
      h2('Population of US cities'),
      htmlWidgetOutput(
        outputId = 'desc',
        HTML(paste(
          'The map is centered at <span id="lat"></span>, <span id="lng"></span>',
          'with a zoom level of <span id="zoom"></span>.<br/>',
          'Top <span id="shownCities"></span> out of <span id="totalCities"></span> visible cities are displayed.'
        ))
      )
    )
  ),
  hr(),
  fluidRow(
    column(3,
      selectInput('year', 'Year', c(2000:2010), 2010),
      selectInput('maxCities', 'Maximum cities to display', choices=c(
        5, 25, 50, 100, 200, 500, 2000, 5000, 10000, All = 100000
      ), selected = 100)
    ),
    column(4,
      h4('Visible cities'),
      tableOutput('data')
    ),
    column(5,
      h4(id='cityTimeSeriesLabel', class='shiny-text-output'),
      plotOutput('cityTimeSeries', width='100%', height='250px')
    )
  )
))