#
# Should turn this into a data frame rather than a matrix.
# This would allow us to preserve different data types across
# columns/variables. Of course, there isn't an exact one-to-one
# correspondence between spreadsheets and data frames.


gnumericHandler <- 
function(fileName)
{

    # read the XML tree from the file.
  d <- xmlTreeParse(fileName)
    #  Get the Sheet
  sh <- d$doc$children[["Workbook"]]$children[["Sheets"]]$children[["Sheet"]]$children

  mat <- matrix(0, as.integer(sh$MaxRow$children[[1]]$value)+1,  as.integer(sh$MaxCol$children[[1]]$value)+1)
  vals <- sh$Cells$children


  gnumericCellEntry <- function(x)
   {
     atts <- sapply(x$attributes, as.integer)
     val <- x$children$Content$children$text$value

     tmp <-  switch(atts[["Style"]], "1"= as.numeric(val), "2"=as.numeric(val), "3"=val)
     mat[atts[["Row"]]+1, atts[["Col"]]+1] <<- tmp
     tmp
  }

  sapply(vals, gnumericCellEntry)


 return(mat)
}
