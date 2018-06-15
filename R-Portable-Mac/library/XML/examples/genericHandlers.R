# This illustrates using the new naming scheme for generic handlers
# that use a . prefix.

h =
  list(.text = function(content) cat("text:", xmlValue(content), "\n"),
       .comment = function(node) cat("##", xmlValue(node), "\n"),
       .processingInstruction = function(target, content) cat("PI: [", target, "]", content, "\n"),
       .startElement = function(node, attrs) { cat("New node:", xmlName(node), paste(names(xmlAttrs(node)), collapse = ", "), "\n")},
       .endElement = function(node) { cat("end node:", node, "\n")},
       .startDocument = function(...) cat("start of document\n"),
       .endDocument = function(...) cat("end of document\n"),
       .cdata = function(node) cat("CDATA:", xmlValue(node), "\n")
      )

xmlTreeParse("test.xml", handlers = h, asTree = TRUE, useDotNames = TRUE)
