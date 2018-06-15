tr <- xmlTree("Duncan")
tr$addTag("name", attrs=c(a=1,b="xyz"), close=F)
 tr$addTag("first", "Duncan")
 tr$addTag("last", "Temple Lang")
tr$closeTag()
tr$value()

cat(saveXML(tr$value()))
# <?xml version="1.0"?>
# <name a="1" b="xyz"><first>Duncan</first><last>Temple Lang</last></name>
