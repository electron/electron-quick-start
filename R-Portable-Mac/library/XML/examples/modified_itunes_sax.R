# Read XML data using a low-level streaming model to be able to handle
# very large data.

#  We'll just pick out Total Time

# Use a modified version if iTunes format to make it a less generic format.

#Need a state machine

#Whenever we see the start of an XML element named Total_Time,
#prepare to store the next pieces of text
#Then when we see the end of the Total_Time, stop collecting.

create =
function(verbose = FALSE)
{  
  times <- character()

  inTotalTimeElement = FALSE

   # called for start of <Total_Time> element,
   # so always set inTotalTime to TRUE
  tt = function(name, ...)  {

     if(verbose) cat("In tt\n")

     inTotalTimeElement <<- TRUE
  }

       # If we are in a Total_Time element,
       # put the x into the times vector
  collect =  function(x) {
     if(verbose) cat("in collect\n")

     if(inTotalTimeElement)
         times <<- c(times, x)
  }

      # Need to turn inTotalTimeElement off if it is on.
  endElement = function(name, ...) {
#     if(name == "Total_Time")
      if(verbose) cat("end Total_Time\n")    
       inTotalTimeElement <<- FALSE
  }  

     # return a list of functions which are used by the SAX parser
     # and also .result which gives us the values
  list("Total_Time" = tt,
       "/Total_Time" = endElement,
       .text = collect,
       .result = function()
                   as.numeric(times))
}


 #
if(FALSE) {
h = create(verbose = TRUE)
o = xmlEventParse("http://eeyore.ucdavis.edu/itunes-short.xml", handlers = h, saxVersion = 2)
h$.result()
}
