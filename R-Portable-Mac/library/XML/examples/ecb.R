# Reading European bank exchange rates.

history = "~/eurofxref-hist.xml"
daily = "~/eurofxref-daily.xml"
# f = "http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"

f = history

d = xmlTreeParse(f, useInternalNodes = TRUE)
getNodeSet(d, "/gesmes:Envelope//Cube[@currency='SIT']", c(gesmes="http://www.gesmes.org/xml/2002-08-01"))
getNodeSet(d, "//gesmes:Envelope", c(gesmes="http://www.gesmes.org/xml/2002-08-01"))

namespaces = c(ns = "http://www.ecb.int/vocabulary/2002-08-01/eurofxref")



namespaces <- c(ns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref")


# Get the data for Slovenian currency for all time periods.
# Find all the nodes of the form <Cube currency="SIT"...>

slovenia = getNodeSet(d, "//ns:Cube[@currency='SIT']", namespaces )
# Now we have a list of such nodes, loop over them and get the rate  
# attribute

rates = as.numeric( sapply(slovenia, xmlGetAttr, "rate") )
# Now put the date on each element
# find nodes of the form <Cube time=".." ... >
# and extract the time attribute
names(rates) = sapply(getNodeSet(d, "//ns:Cube[@time]", namespaces ), 
                      xmlGetAttr, "time")

#  Or we could turn these into dates with strptime().
