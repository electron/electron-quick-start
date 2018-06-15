# The following illustrates how we can get the text
# Michael Conklin.

# Also see ./foo.html as an example with javascript content
# and a pseudo/fake css node.

doc = htmlParse("http://www.omegahat.net/")
txt = xpathSApply(doc, "//body//text()", xmlValue)

#The result is a character vector that contains all the text.

#By limiting the nodes to the body, we avoid the content in <head>
#such as inlined JavaScript or CSS.

#It is also possible that a document may have <script> elements
#in the document containing JavaScript that you don't want.
#You can omit these

  txt = xpathSApply(doc, "//body//text()[not(ancestor::script)]", xmlValue)

# And if there were other elements we wanted to ignore, then you could use

 txt = xpathSApply(doc,
                   "//body//text()[not(ancestor::script) and not(ancestor::otherElement)]",
                   xmlValue)



