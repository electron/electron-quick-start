# Tests reading from a connection.
# Trying to get the newlines.

library(XML)
ReadLines =
  function(con, n) {
    x = readLines(con, 1)

#This works, but tagging the new line doesn't.    
  return(x)

    if(length(x))
      x = paste(x, "<!-- comment -->", sep="")
print(x)
    x
}

handlers =
function() {
  tags = character(0)
  atts = character(0)
  text = character(0)
  startElement = function(x, attrs) {
   tags <<- append(tags, x)
   atts <<- append(atts, attrs)
  }
  addText = function(txt, ...) {
   text <<- append(text, txt) 
  }

  list(startElement = startElement, text = addText, .value = function() { list(tags, atts, text)},
       cdata = function(x) addText(x))
}

h = handlers()
invisible(xmlEventParse(file(system.file("exampleData", "cdata.xml", package = "XML"), "r"), handlers = h))

h$.value()

