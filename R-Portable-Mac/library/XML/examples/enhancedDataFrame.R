 handler <- function() {
  data <- NULL

    # Private or local variables used to store information across 
    # method calls from the event parser
  numRecords <- 0
  varNames <- NULL
  meta <- NULL
  currentRecord <- 0
  expectingVariableName <- F
  rowNames <- NULL

   # read the attributes from the dataset
  dataset <- function(x,atts) {
    numRecords <<- as.integer(atts[["numRecords"]])
      # store these so that we can put these as attributes
      # on data when we create it.
    meta <<- atts
  }

  variables <- function(x, atts) {
      # From the DTD, we expect a count attribute telling us the number
      # of variables.
    data <<- matrix(0., numRecords, as.integer(atts[["count"]]))
      #  set the XML attributes from the dataset element as R
      #  attributes of the data.
    attributes(data) <<- c(attributes(data),meta)
  }

  # when we see the start of a variable tag, then we are expecting
  # its name next, so handle text accordingly.
  variable <- function(x,...) {
     expectingVariableName <<- T
  }

  record <- function(x,atts) {
      # advance the current record index.
    currentRecord <<- currentRecord + 1
    rowNames <<- c(rowNames, atts[["id"]])
  }

  text <- function(x,...) {
   if(x == "")
     return(NULL)

   if(expectingVariableName) {
     varNames <<- c(varNames, x)  
     if(length(varNames) >= ncol(data)) {
         expectingVariableName <<- F
         dimnames(data) <<- list(NULL, varNames)
     }
   } else {
      e <- gsub("[ \t]*",",",x)
      vals <- sapply(strsplit(e,",")[[1]], as.numeric)
      data[currentRecord,] <<- vals
   }
  }

  endElement <- function(x,...) {
   if(x == "dataset") {
       dimnames(data)[[1]]  <<- rowNames
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
