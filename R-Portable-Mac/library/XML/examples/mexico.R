# An example posed by Herve Richard at INRIA.
variable = function(node) {
   # Get the values.
  vals = scan(textConnection(xmlValue(node)))
   # Need the name attribute
  structure(list(vals),
            names = xmlGetAttr(node, "name"))
}

handlers = list(variable = variable)
ans = xmlRoot(xmlTreeParse("mexico.xml", handlers = handlers, asTree = TRUE))
as.data.frame(xmlChildren(ans[["date"]]))
