xsd = xmlTreeParse("examples/author.xsd", isSchema =TRUE, useInternal = TRUE)
doc = xmlInternalTreeParse("examples/author.xml")
#h = schemaValidationErrorHandler()
#.Call("RS_XML_xmlSchemaValidateDoc", xsd@ref, doc, 0L, h)
xmlSchemaValidate(xsd, doc)

