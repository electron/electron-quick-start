 tt = xmlHashTree()

 top = addNode("top", , tt)
  addNode(xmlNode("a"), top, tt)
  b = addNode(xmlNode("b"), top, tt)
  c = addNode(xmlNode("c"), b, tt)
  addNode(xmlNode("c"), top, tt)
  addNode(xmlNode("c"), b, tt)    
  addNode(xmlTextNode("Some text"), c, tt)

  xmlElementsByTagName(tt$top, "c")
