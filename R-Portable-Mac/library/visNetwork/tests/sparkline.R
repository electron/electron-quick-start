library(visNetwork)
library(sparkline)
library(pipeR)
sparkline <- spk_chr(runif(10,0,10), type="bar")

sparkline(runif(10,0,10), type="bar")

node <- data.frame(id = 1, title = as.character(as.tags(
    sparkline(rnorm(10), type="box", chartRangeMin=0, chartRangeMax=400)
   )))
visNetwork(node, edges = data.frame(from = 1, to = 1, title = spk_chr(runif(10,0,10)))) %>% spk_add_deps()


d <- spk_chr(runif(10,0,10))
d

node <- data.frame(id = 1, title = paste0('<p>My mother has <span style="color:blue">blue</span> eyes.</p>', d))
visNetwork(node, edges = data.frame()) %>% spk_add_deps()

Bar1 <- gvisBarChart(df, xvar="country", yvar=c("val1", "val2"))

node <- data.frame(id = 1, title = as.character(Bar1))
visNetwork(node, edges = data.frame()) %>% spk_add_deps()


node <- data.frame(id = 1, title = c('<p>My mother has <span style="color:blue">blue</span> eyes.</p>
  <script type="text/javascript">
    console.info("la")
    $(function() {
        $(".inlinesparkline").sparkline(); 
    });
    </script>
    <span class="inlinesparkline">1,4,4,7,5,9,10</span>'))

visNetwork(node, edges = data.frame())%>%spk_add_deps()

library(leaflet)
data(quakes)

# Show first 20 rows from the `quakes` dataset
leaflet(data = quakes[1:20,]) %>% addTiles() %>%
  addMarkers(~long, ~lat, popup = spk_chr(runif(10,0,10), type="bar"))
