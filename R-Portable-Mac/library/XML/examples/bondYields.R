
uri = "http://www.treas.gov/offices/domestic-finance/debt-management/interest-rate/yield.xml"

h = 
function() {

  tables = list()

  tb = function(node) {
      # this will drop any NULL values from empty nodes.
    els = unlist(xmlApply(node, xmlValue))
    vals = as.numeric(els)
    names(vals) = gsub("BC_", "", names(els))
    tables[[length(tables) + 1]] <<- vals
    NULL
  }

  list("G_BC_CAT" = tb, getTables = function() tables)
}

xmlTreeParse(uri, handlers = h())$getTables()
