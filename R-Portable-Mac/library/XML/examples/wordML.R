library(XML)
      #tt = xmlTree("w:wordDocument", namespaces = c(w = "http://schemas.microsoft.com/office/word/2003/wordml"))
tt = xmlTree(namespaces = c(w = "http://schemas.microsoft.com/office/word/2003/wordml"))

tt$addPI("mso-application", "progid='Word.Document'")
tt$addTag("wordDocument", namespace = "w", close = FALSE)
# XXX if we put this first, we don't get the body. Need to then add the body
# as a sibling of the PI.

v = tt$addTag("w:body",
              tt$addTag("w:p",
                         tt$addTag("w:r",
                                    tt$addTag("w:t", "Hello World!"))))

tt$closeTag()

cat(saveXML(tt))



