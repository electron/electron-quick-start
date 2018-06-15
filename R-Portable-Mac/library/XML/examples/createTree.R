doc <- xmlTree()
doc$addTag("EXAMPLE", close= FALSE, attrs=c("prop1" = "gnome is great", prop2 = "& linux too"))
  doc$addComment("A comment")
  doc$addTag("head", close= FALSE)
   doc$addTag("title", "Welcome to Gnome")
   doc$addTag("chapter", close= FALSE)
     doc$addTag("title", "The Linux Adventure")
     doc$addTag("p")

     doc$addTag("image", attrs=c(href="linux.gif"))
   doc$closeTag()  
  doc$closeTag()  

  doc$addTag("foot")

doc$closeTag()
