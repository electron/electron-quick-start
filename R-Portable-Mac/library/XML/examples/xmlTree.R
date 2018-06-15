tt = xmlTree("doc")

# Shows that we can create the children within the call to create
# a parent.

tt$addTag("a",
           tt$addTag("b", tt$addTag("c")),
           tt$addTag("d", tt$addTag("e")))

           
           
