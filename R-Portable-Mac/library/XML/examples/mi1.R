system.time(z <- xmlTreeParse("~/mi1.xml", useInternal = TRUE))

nn = getNodeSet(z, "/*/molecule/name")
length(nn)

ids = sapply(nn,function(x) xmlValue(x[[1]]))

