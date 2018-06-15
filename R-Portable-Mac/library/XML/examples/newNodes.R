b = newXMLNode("k:bob", namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.net", ""))
addAttributes(b, a = 1, b = "xyz", "r:efg" = "2.4.1", "omg:len" = 3)

xmlName(b)
xmlName(b) <- "jane"

saveXML(b)

removeAttributes(b, "r:efg")

removeAttributes(b, "a", "b")  # or .attrs = c("a", "b")
saveXML(b)
