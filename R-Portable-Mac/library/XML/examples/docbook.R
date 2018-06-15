# Find the elements used in the collection of chapters of the SVN book.
# The approach works for any set of XML documents.
# The SVN book can be downloaded from 
#      http://svnbook.red-bean.com/trac/changeset/3082/tags/en-1.4-final/src/en/book?old_path=%2F&format=zip


if(FALSE) {
   # Find the nodes and attributes used in the SVN book.
 files = list.files("SVN-book", "\\.xml$", full.names = TRUE)
 svn.book = xmlElementSummary(files)
}


if(FALSE) {
   # Process the XSL files in IDynDocs, OmegahatXSL and docbook-xsl
 h = xmlElementSummaryHandlers()
 dir = "~/Classes/StatComputing/XDynDocs/inst/XSL"
 invisible(
  lapply(c("", "OmegahatXSL", "docbook-xsl-1.73.2/html", "docbook-xsl-1.73.2/fo"),
        function(sub) {
          files = list.files(paste(dir, sub, sep = .Platform$file.sep), "\\.xsl$", full.names = TRUE)
          invisible(sapply(files, xmlEventParse, handlers = h, replaceEntities = FALSE))          
        }))
 h$result() 
}


