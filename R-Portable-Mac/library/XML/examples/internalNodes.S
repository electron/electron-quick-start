library(XML)
tr <- xmlTree("Duncan")
tr$addTag("name", attrs=c(a=1,b="xyz"), close=FALSE)
tr$addTag("first", "Larry")
tr$addTag("last", "User")
tr$closeTag()

o = xmlRoot(tr$value())
as(o, "XMLNode")
