k <- defineClass("LiterateXMLHandler")

k$defineFields(chunks = "list")

k$defineMethod("startElement", function(node) {
    id <- xmlGetAttr(node, "id")
   
   if(!is.null(id))
     chunks[[id]] <<- node     

   node
  })


k$defineMethod("chunk", function(node) {
  if(is.null(name <- xmlGetAttr(node, "name")))
     stop("Chunk with no name")

   if(is.na(match(name, names(chunks))))
      stop("No chunk defined named", name,". Is it a forward chunk reference?")

   nnode <- chunks[[name]]

   if(xmlName(nnode) == "code")
     code(nnode, FALSE)
  })

k$defineMethod("code", function(node, checkId = TRUE) {
                  if(checkId)
                     startElement(node)

                  node
               })



oopXMLHandlers <-
function(obj)
{
  startElement <-
    function(node) {
       m <- findOOPMethod(OOPClassDef(obj), xmlName(node), mustFind = FALSE)
       
       if(is.null(m)) {
         m <- findOOPMethod(OOPClassDef(obj), "startElement", mustFind = FALSE)
         name <- "startElement"
       } else
         name <- xmlName(node)


       if(!is.null(m)) {
         m <- completeForObject(obj, name, FALSE)
         m(node)
       } else
         node
    }

  list(startElement = startElement, value = function() obj)
}

