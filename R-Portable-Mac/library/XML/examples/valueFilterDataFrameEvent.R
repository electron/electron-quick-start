#
# A closure for use with xmlEventParse
# and for reading a data frame using the DatasetByRecord.dtd
# DTD in $OMEGA_HOME/XML/DTDs.
# To test
#  xmlEventParse("mtcars.xml", handler())
# 
 valueDataFrameFilter <- function(accept) {
 
  data <- NULL

    # Private or local variables used to store information across 
    # method calls from the event parser
  numRecords <- 0
  varNames <- NULL
  meta <- NULL
  expectingVariableName <- F
  rowNames <- NULL  
  currentColumn <- 1
  currentRowName <- NULL
  numCols <- 1


   # read the attributes from the dataset
  dataset <- function(x, atts) {
    numRecords <<- as.integer(atts[["numRecords"]])
      # store these so that we can put these as attributes
      # on data when we create it.
    meta <<- atts
  }

  variables <- function(x, atts) {
      # From the DTD, we expect a count attribute telling us the number
      # of variables.
#    data <<- matrix(0., numRecords, as.integer(atts[["count"]]))
     data <<- list()
     numCols <- as.integer(atts[["count"]])
      #  set the XML attributes from the dataset element as R
      #  attributes of the data.
#    attributes(data) <<- meta
  }

  # when we see the start of a variable tag, then we are expecting
  # its name next, so handle text accordingly.
  variable <- function(x,...) {
     expectingVariableName <<- T
  }

  record <- function(x,atts) {
    currentRowName <<- atts[["id"]]
  }

  text <- function(x,...) {
   if(x == "")
     return(NULL)

   if(expectingVariableName) {
     varNames <<- c(varNames, x)  
     if(length(varNames) >= numCols) {
         expectingVariableName <<- F
         #dimnames(data) <<- list(NULL, varNames)
     }
   } else {
      e <- gsub("[ \t]*",",",x)
      els <- strsplit(e,",")[[1]]
      names(els) <- varNames
      if(accept(els)) {
        data[[length(data)+1]] <<- els
        rowNames <<- c(rowNames, currentRowName)
      }
   }
  }

  endElement <- function(x,...) {
     if(x == "dataset") {
       data <<- data.frame(matrix(unlist(data),length(data),length(varNames), byrow=T))
       names(data) <<- varNames 
       dimnames(data)[[1]] <<- rowNames
      } else if(x == "record") {
  	currentColumn <<- 1
      }
  }

   return(list(variable = variable,
               variables = variables,
               dataset=dataset,
               text  = text,
               record= record,
               endElement = endElement,
               data = function() {data },
               rowNames = function() rowNames
              ))
 }
