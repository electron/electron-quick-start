library(XML)
url <- "http://iobis.marine.rutgers.edu/digir2/DiGIR.php"
doc <- "<request
   xmlns='http://digir.net/schema/protocol/2003/1.0'
   xmlns:xsd='http://www.w3.org/2001/XMLSchema'
   xmlns:digir='http://digir.net/schema/protocol/2003/1.0'>
 <header>
   <version>1.0.0</version>
   <sendTime>20030421T170441.431Z</sendTime>
   <source>127.0.0.1</source>
   <destination
resource='ECNASAP'>http://localhost/digir/DiGIR.php</destination>
   <type>inventory</type>
 </header>
 <inventory xmlns:dwc='http://digir.net/schema/conceptual/darwin/2003/1.0'>
   <dwc:Scientificname />
   <count>true</count>
 </inventory>
</request>"

u = paste(url, paste("doc", doc, sep = "="), sep = "?")
r = xmlTreeParse(u)

# Alternatively,
library(RCurl)
txt = getForm(url, doc = doc)
r = xmlTreeParse(txt, asText = TRUE)

#######

r = xmlTreeParse(u, useInternal = TRUE)
science.names = xpathSApply(r,"//x:record", xmlValue, namespaces = "x")

