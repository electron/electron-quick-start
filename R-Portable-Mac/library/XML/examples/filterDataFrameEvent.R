# A closure for use with xmlEventParse
# and for reading a data frame using the DatasetByRecord.dtd
# DTD in $OMEGA_HOME/XML/DTDs.
# To test
#  xmlEventParse("mtcars.xml", handler())
# 
 dataFrameFilter <- function(desiredRowNames) {
 
  data <- NULL

    # Private or local variables used to store information across 
    # method calls from the event parser
  numRecords <- 0
  varNames <- NULL
  meta <- NULL
  currentRecord <- 0
  expectingVariableName <- F
  rowNames <- NULL  
  currentColumn <- 1

  processRow <- T

   # read the attributes from the dataset
  dataset <- function(x, atts) {
    numRecords <<- length(desiredRowNames) # as.integer(atts[["numRecords"]])
      # store these so that we can put these as attributes
      # on data when we create it.
    meta <<- atts
  }

  variables <- function(x, atts) {
      # From the DTD, we expect a count attribute telling us the number
      # of variables.
#cat("Creating matrix",numRecords, as.integer(atts[["count"]]),"\n")
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
   if(is.na(match(atts[["id"]], desiredRowNames))) {
      # discard this entry
     cat("Discarding", atts[["id"]],"\n")
     return()
   }

   processRow <<- T

      # advance the current record index.
    currentRecord <<- currentRecord + 1
    rowNames <<- c(rowNames, atts[["id"]])
  }

  text <- function(x,...) {
   if(x == "")
     return(NULL)

  if(expectingVariableName == FALSE && processRow == FALSE)  {
    cat("Ignoring",x,"\n")
    return()
  }


   if(expectingVariableName) {
     varNames <<- c(varNames, x)  
     if(length(varNames) >= ncol(data)) {
         expectingVariableName <<- F
         dimnames(data) <<- list(NULL, varNames)
     }
   } else {
      e <- gsub("[ \t]*",",",x)
      els <- strsplit(e,",")[[1]]
      for(i in els) {
        data[currentRecord, currentColumn] <<- as.numeric(i)
        currentColumn <<- currentColumn + 1
      }
   }
  }

  endElement <- function(x,...) {
    if(x == "dataset") {
  	dimnames(data)[[1]]  <<- rowNames 
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
