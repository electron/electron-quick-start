
# See http://www.dmg.org/v3-0/GeneralStructure.html

setOldClass("rpart")
setClass("PMMLTree", contains = "XMLInternalNode")

setGeneric("getPMMLArrayType", function(x) standardGeneric("getPMMLArrayType"))

PMMLArrayTypes = c("integer" = "int",
                   "numeric" = "real",
                   "logical" = "int",
                   "character" = "string")

setMethod("getPMMLArrayType", "vector",
           function(x) {
             as.character(PMMLArrayTypes[class(x)])
           })

setAs("vector", "PMMLTree",
      function(from) {
        type = getPMMLArrayType(from)
          # put quotes around strings
        text = if(is.character(from)) paste('"', from, '"', sep = "", collapse = " ") else paste(from, collapse = " ")
        newXMLNode("Array", text, attrs = c(type = type, n = length(from)))
      })

setAs("logical", "PMMLTree",
      function(from) {
        as(as.integer(from), "PMMLTree")
      })


setAs("rpart", "PMMLTree",
      function(from) {

        tt = xmlTree("PMML", attrs = c(version = "3.0"), namespaces = "http://www.dmg.org/PMML-3_0")
        tt$addNode("Header", attrs = c(copyright = "?"),
                    tt$addNode("Application", attrs = c(name = "R", version = paste(version$major, version$minor, sep = "."))),
                    tt$addNode("Annotation", "Generated via the XML package"),
                    tt$addNode("Timestamp", date()))

        tt$addNode("DataDictionary")

        xmlRoot(tt$value())
      })


library(rpart)
fit <- rpart(Kyphosis ~ Age + Number + Start, data=kyphosis)
cat(saveXML( as(fit, "PMMLTree") ))
