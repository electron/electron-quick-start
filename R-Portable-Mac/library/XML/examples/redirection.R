# This is an example of downloading data that is accessible via a text file
# that is identified via a link in an HTML document that is returned from
# a form submission.
# The original form is available via the SWISSPROT site which is redirected
# to www.expasy.org.
#
#  This example illustrates the use of the FOLLOWLOCATION options in libcurl and hence
#  RCurl.
#
# The example was raised  by Linda Tran at UC Davis.
# Works as of May 12, 2006
#

tt = getForm("http://www.expasy.org/cgi-bin/search",
               db = "sptrde", SEARCH = "fmod_bovin",
              .opts = list("FOLLOWLOCATION" = TRUE))

# Then, find the link node <a> which has "raw text"
# in the text of the link

h = function() {
   link = ""
   a = function(node, ...) {
     v = xmlValue(node)
     if(length(grep("raw text", v)))
       link <<- xmlGetAttr(node, "href")

     node
   }
   list(a = a, .link = function() link)
}

a = h()
htmlTreeParse(tt, asText = TRUE, handlers = a)
a$.link()

u = paste("http://www.expasy.org", a$.link(), sep = "")

getURL(u)
