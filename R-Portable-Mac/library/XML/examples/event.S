#
# Code for reading Chris (Volinsky)'s event data from XML into a dataframe.
#
#

# This is the top-level function that you call to read the file and convert it
# into a data frame.
# You can call the eventHandlers() function manually and pass the result
# as the argument to the handlers argument if you want to override the
# RowConverters or verbose argument.
#

readXMLEventDataFrame = 
function(fileName = "event.xml", handlers = eventHandlers(), ...)
{
  xmlEventParse(fileName, handlers = handlers, ...)$result()
}


#
# The verbose argument prints out information about the different
# events the parser observes.
#
# RowConverters is a named list of functions that convert the specified/name
# variable's values.
#

# In the current implementation, we first build up a matrix of strings
# and then at the very end, we convert the columns to variables and
# form a data.frame().  If we were smarter (i.e. could assume more),
# we could create the data.frame() first and then add rows to it.
# Ideally, the XML dataset would tell us the number of records
# (i.e. <dialog> elements) it contains and we could populate the
# data.frame() from its "declared" types.  
#
#

eventHandlers =
function(RowConverters = list(Date=I, f2 = as.integer, f3 = as.numeric), verbose = TRUE)
{
#  dataset = data.frame()
  dataset = matrix("", 1, length(RowConverters), dimnames = list(NULL, names(RowConverters)))
  dataName = ""
  date = ""
  recordNum = 1
  var = ""
  record <- character()
  textString <- character(0)
  
    # This is called when we encounter the start of an XML element/tag.
    # For <event>, we grab the id and date and store them to name the
    # dataset.
    # For <feature>, we grab the name attribute and use that as the name
    # of the current variable when we get its value from the (end of the) text
    #
  start = function(name, atts) {
    if(name == "event") {
      dataName <<- atts[["id"]]
      date <<- atts[["date"]]
      if(verbose)
        cat("Data name", dataName, ", date", date, "\n", sep="")
    } else if(name == "feature") {
      var <<- atts[["name"]]
      if(verbose)
        cat("Variable", var, "\n")
    } 
  }

  text = function(val) {
      # We should have a converter here to get the right type.
    if(var != "") {
      if(verbose)
        cat("Text", val, "\n")
      textString <<- c(textString, val)
    }
  }

   # this is called when we get the close of a tag (i.e. </element> )
   # In the case of a dialog, we assume we have the end of a record
   # and we put it into the dataset by adding the record/row.
   # In our case, record is a character vector with names.
   # This is a character vector. We'll convert the columns at the end.
  end = function(name) {
    if(name == "dialog") {
       dataset <<- rbind(dataset, record)
       recordNum <<- recordNum + 1
       if(verbose)
         cat("Next record\n")
    } else if(name == "feature")
      record[var] <<- paste(textString, collapse="")
      textString <<- character(0)
      var <<- ""
  }
   # This handler is the one we call at the end to
   # post-process the result
  result = function() {
     dataset = dataset[-1,]
     ans = as.data.frame(lapply(names(RowConverters), function(x) RowConverters[[x]](dataset[,x])))
     names(ans) = names(RowConverters)

     ans = list(ans)
     names(ans) = dataName
     ans
  }

  list(result = result, text = text, endElement = end, startElement = start)
}


#
#
# How to call: data is in the file named event.xml 
#
# v = readXMLEventDataFrame()[[1]]
# v
#        Date f2 f3
#1 2003-05-23  1  3
# 2 2003-05-24 17 24
# > sapply(v, class)
#     Date        f2        f3 
#   "AsIs" "integer" "numeric" 
# > 
#
