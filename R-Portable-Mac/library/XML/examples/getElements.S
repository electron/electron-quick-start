getElements =
function(elementNames)
{
 els = list()

 startElement = function(node, ...) {

  if(xmlName(node) %in% elementNames)
     els[[length(els) + 1]] <<- node

   node
 }

  list(startElement = startElement, els = function() els)
}

#
h =  getElements("a")
htmlTreeParse("http://www.omegahat.net/RSXML/index.html", handlers = h)

links = sapply(h$els(), function(x) xmlGetAttr(x, "href"))

# Of course, we could do these two steps in one with a handler
# function like
#

getLinks = function() {
  links = character()

  list(a = function(x) links <<- c(links, xmlGetAttr(x, "href")), 
       links = function() links)
}

# h = getLinks()
# htmlTreeParse("http://www.omegahat.net/RSXML/index.html", handlers = h)
# h$links()

# If we want the nodes, we can use getElements. Otherwise, we 
# can use a specialize handler that converts the information on the
# fly into the data structures we want at the end.



