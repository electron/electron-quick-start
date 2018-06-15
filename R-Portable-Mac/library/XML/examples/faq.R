# Getting the question text from a FAQ.
doc = xmlParse("FAQ.xml")
q = getNodeSet(doc, "//question")
sapply(q, function(x) paste(sapply(xmlChildren(x)[names(x) == "text"], xmlValue), collapse = "\n"))
