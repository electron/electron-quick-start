h =
  list(.text = function(content) cat("text:", content, "\n"),
       .comment = function(content) cat("##", content, "\n"),
       .processingInstruction = function(target, content) cat("PI: [", target, "]", content, "\n"),
       .startElement = function(node, attrs) { cat("New node:", node, paste(names(attrs), collapse = ", "), "\n")},
       .endElement = function(node) { cat("end node:", node, "\n")},
       .startDocument = function(...) cat("start of document\n"),
       .endDocument = function(...) cat("end of document\n"),
       .cdata = function(content) cat("CDATA:", content, "\n"),
       .entityDeclaration = function(...) {cat("Defining an entity\n"); print(list(...))},
       .getEntity = function(name) { cat("Getting entity", name, "\n") ; "x"}
       #entity, isStandalone
      )


xmlEventParse("test.xml", h, useDotNames = TRUE)

