# Examples of manipulating the catalog for resolving URIs.



# Get this from catalog.xml
catalogResolve("http://www.omegahat.net/XSL/")

loadCatalogs("~/Classes/StatComputing/XDynDocs/inst/XML/catalog.xml")

# Found in the first/original catalog, not IDynDocs.
catalogResolve("http://docbook.sourceforge.net/release/xsl/current/foo")

catalogResolve("http://www.statdocs.org/foo")


catalogAdd(c("http://www.r-project.org/XSL/" = "/Users/duncan/R/XSL"))
catalogResolve("http://www.r-project.org/XSL/bob.xsl")
