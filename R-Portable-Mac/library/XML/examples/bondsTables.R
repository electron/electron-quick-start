library(XML)

doc = htmlTreeParse("http://finance.yahoo.com/bonds/composite_bond_rates?bypass=true", useInternalNodes = TRUE)

# Use XPath expression to find the nodes 
#  <div><table class="yfirttbl">..
# as these are the ones we want.

o = getNodeSet(doc, "//div/table[@class='yfirttbl']")

# Write a function that will extract the information out of a given table node.
readHTMLTable =
function(tb)
{
  # get the header information.
  colNames = sapply(tb[["thead"]][["tr"]]["th"], xmlValue)
  vals = sapply(tb[["tbody"]]["tr"],  function(x) sapply(x["td"], xmlValue))
  matrix(as.numeric(vals[-1,]),
             nrow = ncol(vals),
             dimnames = list(vals[1,], colNames[-1]),
             byrow = TRUE
         )
}  


# Now process each of the table nodes in the o list.
tables = lapply(o, readHTMLTable)
names(tables) = lapply(o, function(x) xmlValue(x[["caption"]]))


