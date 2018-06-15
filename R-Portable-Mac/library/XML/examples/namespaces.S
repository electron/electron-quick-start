
library(XML)

gg <- xmlTree("abc", dtd = "ggobi.dtd", namespaces = list(ggobi="http://www.ggobi.org",
                                                          r = "http://www.r-project.org"))

gg$addTag("ggobidata", attrs = c(count=1), namespace = "ggobi", close = FALSE)
gg$addTag("data", attrs = c(name="cube6"), close = FALSE)
gg$addTag("description", "A simple dataset")
gg$addTag("variables", attrs = c(count="2"), close = FALSE)
gg$addTag("realvariable", attrs = c(name="D1"), namespace = "r")
gg$addTag("realvariable", attrs = c(name="D2"), namespace = "r")
gg$closeTag() # variables
gg$closeTag() # data
gg$closeTag() # ggobidata

# or gg$closeTag(3)
# or gg$closeTag("ggobidata")

cat(saveXML(gg))
