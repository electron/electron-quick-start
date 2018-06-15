#####################################################################
# Test Issue 2
# Columns of data (as formulas) are being read in as NA
# CLOSED
.test.issue2 <- function()
{
  cat(".test.issue2 ")
  require(xlsx)
  file <- "resources/xlxs2Test.xlsx"
  res <- read.xlsx2(file, sheetName="data", startRow=2, endRow=10,
      colIndex=c(1,3:5,7:9), colClasses=c("character",rep("numeric",6)) )
  
  #head(res)
  if (!any(is.na(res))) {
    cat("PASSED\n")
  } else {
    cat("FAILED\n")
  }

  invisible()
}


#####################################################################
# Test Issue 6
# setCellValue writes an NA as "#N/A", add an argument to make it an 
# empty cell.  This behavior is is visible with write.xlsx.
#
.test.issue6 <- function()
{
  cat(".test.issue6 ")
  require(xlsx)
  tfile <- tempfile(fileext=".xlsx")

  wb <- createWorkbook()
  sheet <- createSheet(wb)
  rows <- createRow(sheet, rowIndex=1:5)
  cells <- createCell(rows)
  mapply(setCellValue, cells[,1], c(1,2,NA,4,5))
  setCellValue(cells[[2,2]], "Hello")
  mapply(setCellValue, cells[,3], c(1,2,NA,4,5), showNA=FALSE)
  setCellValue(cells[[3,3]], NA, showNA=FALSE)  
  saveWorkbook(wb, tfile)
  
  aux <- data.frame(x=c(1,2,NA,4,5))
  write.xlsx(aux, file=tfile, showNA=FALSE)
    
  if ( TRUE ) {
    cat("PASSED\n")
  } else {
    cat("FAILED\n")
  }
}


#####################################################################
# Test Issue 7
# #N/A values are imported as FALSE  by read.xlsx
# Let's see if the new version of POI fixes this!
# Not something I can fix!
#
.test.issue7 <- function()
{
  cat(".test.issue7 ")
  require(xlsx)
  file <- "resources/issue7.xlsx"
  res <- read.xlsx(file, sheetIndex=1, rowIndex=2:5, colIndex=2:3)

  wb <- loadWorkbook(file)
  sheet <- getSheets(wb)[[1]]
  rows  <- getRows(sheet)   # get all the rows

  cells <- getCells(rows["4"])   # returns all non empty cells
  cell  <- cells[["4.2"]]
  value <- getCellValue(cell)

  # value should be NA, but it is FALSE!
  if (is.na(value)) {
    cat("PASSED\n")
  } else {
    cat("FAILED -- OK (known issue!)\n")
  }
  
  # read.xlsx2 imports correctly!
  invisible()
}



#####################################################################
# Test Issue 9
# Problems with read.xlsx for tables that start in the middle of the
# sheet.  I used to get an NPE.
#
.test.issue9 <- function()
{
  cat(".test.issue9 ")
  require(xlsx)
  file <- system.file("tests", "test_import.xlsx", package="xlsx")
  
  #source(paste(DIR, "rexcel/trunk/R/read.xlsx.R", sep=""))
  try(res <- read.xlsx(file, sheetName="issue9", rowIndex=3:5, colIndex=3:5))

  if (class(res) != "try-error") {
    cat("PASSED\n")
  } else {
    cat("FAILED\n")
  }
}


#####################################################################
# Test Issue 11
# Get an NPE when reading .xls files when they are not properly constructed
# and return more rows than they actually exist. 
# fixed in java, with rexcel_0.5.1.jar
#
.test.issue11 <- function()
{
  cat(".test.issue11 ")
  require(xlsx)
  file <-"resources/read_xlsx2_example.xlsx"
  res <- read.xlsx(file, sheetIndex=1, header=FALSE)

  if (class(res) != "try-error") {
    cat("PASSED\n")
  } else {
    cat("FAILED\n")
  }
  
}


#####################################################################
# Test Issue 12
# read.xlsx2 doesn't evaluate formulas - values are NA
# Not an issue if you specify the colClasses!
#
.test.issue12 <- function(  )
{
  cat(".test.issue12 ")
  require(xlsx)
  file <- system.file("tests", "test_import.xlsx", package="xlsx")
  try(res <- read.xlsx2(file, sheetName="formulas",  
    colClasses=list("numeric", "numeric", "character")))
  if ( is.na(res[1,3]) ) {
    cat("FAILED\n")
  } else {
    cat("PASSED\n")
  }
}


#####################################################################
# Test Issue 16
# Get an NPE when reading .xls files when they are not properly constructed
# and return more rows than they actually exist. 
#
.test.issue16 <- function(  )
{
  cat(".test.issue16 ")
  require(xlsx)
  file <- "resources/issue12.xlsx"
  try(res <- read.xlsx2(file, sheetIndex=1, colIndex=1:3, startRow=3))

  if (class(res) != "try-error") {
    cat("PASSED\n")
  } else {
    cat("FAILED\n")
  }
}


#####################################################################
# Test Issue 19
# CB.setMatrixData only accepts numeric matrices.  It should accept
# character matrices too.
#
.test.issue19 <- function(  )
{
  cat(".test.issue19 ")
  require(xlsx)

  wb <- createWorkbook()
  sheet <- createSheet(wb)
  mtx <- matrix(c("hello", "world", "check1", "check2"), ncol=2)
  cb <- CellBlock(sheet, 1, 1, 2, 2)
  CB.setMatrixData(cb, mtx, 1, 1)
  fileName <- "out/issue19.xlsx"
  saveWorkbook(wb, fileName)

  
  cat("PASSED\n")
}


#####################################################################
# Test Issue 21
# Color black not set properly in Font
#
.test.issue21 <- function(  )
{
  cat(".test.issue21 ")
  require(xlsx)

  wb <- createWorkbook()
  tmp <- Font(wb, color="black")

  tmp2 <- Font(wb, color=NULL)
  
  cat("FAILED\n")
}


#####################################################################
# Test Issue 22
# Preserve existing formats when you write data to the xlsx with
# CellBlock construct
#
.test.issue22 <- function()
{
  cat(".test.issue22 ")
  require(xlsx)
  fileIn  <- "resources/issue22.xlsx"
  fileOut <- "out/issue22_out.xlsx"

  wb <- loadWorkbook(fileIn)
  sheets <- getSheets(wb)

  mat <- matrix(1:9, 3, 3)
  for (sheet in sheets) {
    if (sheet$getSheetName() == "Sheet1" ){
      # need to create the rows for Sheet1 as it is empty!  
      cb <- CellBlock(sheet, 1, 1, 3, 3, create = TRUE)   
    } else {
      cb <- CellBlock(sheet, 1, 1, 3, 3, create = FALSE) 
    }  
    CB.setMatrixData(cb, mat, 1, 1)
  }
  saveWorkbook(wb, fileOut)
  
  cat("PASSED\n")
}



#####################################################################
# Test Issue 23
# add an emf picture
#
.test.issue23 <- function()
{
  cat(".test.issue23 ")
  fileName <- "out/test_emf.emf"
  require(devEMF)
  emf(file=fileName, bg="white")
  boxplot(rnorm(100))
  dev.off()  

  require(xlsx)
  wb <- createWorkbook()
  sheet <- createSheet(wb, "EMF_Sheet")
  
  addPicture(file=fileName, sheet)
  saveWorkbook(wb, file="out/issue23_out.xlsx")  

  # the spreadsheet saves but the emf picture is not there
  # used to work in previous versions of POI, not sure why not anymore
  cat("FAILED -- (known issue with 3.9)\n")
  
}


#####################################################################
# Test Issue 25.  Integers cells read as characters are not read
# "cleanly" with RInterface, e.g. "12.0" instead of "12".
#
.test.issue25 <- function(out="FAILED\n")
{
  cat(".test.issue25 ")
  require(xlsx)
  file <- "resources/issue25.xlsx"

  # reads element [35,1] as a double and then transforms it to a factor
  res1 <- read.xlsx2(file, sheetIndex=1, header=TRUE, startRow=1,
    colClasses=c("character", rep("numeric", 5)), stringsAsFactors=FALSE)
  
  if (res1[35,2] == "250829")  
    out <- "PASSED\n"
      
  # reads element [34,1] correctly, how?!  - R magic
  # res2 <- read.xlsx(file, sheetIndex=1, header=TRUE, startRow=1)

  cat(out)
  
}


#####################################################################
# Test Issue 26.  Customize the format of datetimes in the output
#
.test.issue26 <- function(out="FAILED\n")
{
  cat(".test.issue26 ")
  require(xlsx)

  wb <- createWorkbook()
  sheet <- createSheet(wb, "Sheet1")
  
  days <- seq(as.Date("2013-01-01"), by="1 day", length.out=5)
  # use the default
  addDataFrame(data.frame(days=days), sheet, startColumn=1,
               col.names=FALSE, row.names=FALSE)

  # change the options temporarily
  oldOpt <- options()
  options(xlsx.date.format="dd MMM, yyyy")
  addDataFrame(data.frame(days=days), sheet, startColumn=2,
               col.names=FALSE, row.names=FALSE)
  options(oldOpt)
  
  
  saveWorkbook(wb, file="out/issue26_out.xlsx")  
  cat("PASSED\n")
}


#####################################################################
# Test Issue 28.  Don't fail with read.xlsx on empty sheets.
#
.test.issue28 <- function( out="FAILED\n" )
{
  cat(".test.issue28 ")
  require(xlsx)
  file <- "resources/issue25.xlsx"

  # reads Sheet2 which is empty
  res <- read.xlsx(file, sheetIndex=2)
  res2 <- read.xlsx2(file, sheetIndex=2)
  
  if (is.null(res) && is.null(res2))  
    out <- "PASSED\n"

  cat(out)
}


#####################################################################
# Test Issue 31.  Don't fail when you have zero columns data.frames
#
.test.issue31 <- function( out="FAILED\n")
{
  cat(".test.issue31 ")
  require(xlsx)
  file <- "resources/issue31.xlsx"

  wb <- createWorkbook()
  sheet <- createSheet(wb)
  df <- data.frame(x = 1:5)[,FALSE] #Data frame with some rows, no columns.
  
  #source(paste(SOURCEDIR, "rexcel/trunk/R/addDataFrame.R", sep=""))
  res <- try(addDataFrame(df, sheet))
  #saveWorkbook(wb, file=paste(OUTDIR, "issue31_out.xlsx", sep=""))
  
  if (class(res) == "CellBlock")  
    out <- "PASSED\n"

  cat(out)
}


#####################################################################
# Test Issue 32.  Formating applied to whole columns get lost 
# when additional formatting is done with cellBlock. 
#
.test.issue32 <- function( out="FAILED\n")
{
  cat(".test.issue32 ")
  require(xlsx)
  
  #using formatting on entire columns (A to L)
  wb <- loadWorkbook("resources/issue32_bad.xlsx") 
  sh <- getSheets(wb)
  s1 <- sh[[1]]

  cb <- CellBlock(sheet = s1, startRow = 1, startCol = 1,
                  noRows = 11, noColumns = 50, create = FALSE)
  # some of the formatting is lost (col I to L, rows 1 to 11)
  saveWorkbook(wb, "out/issue32_format_lost.xlsx") 

  # the formatting is kept
  # using cells formatting only (columns A to L rows 1 to 10,000)
  wb <- loadWorkbook("resources/issues32_good.xlsx") 
  sh <- getSheets(wb)
  s1 <- sh[[1]]

  cb <- CellBlock(sheet = s1, startRow = 1, startCol = 1,
                  noRows = 11, noColumns = 50, create = FALSE)
  saveWorkbook(wb, "out/issue32_format_kept.xlsx") 
  
  #out <- "PASSED\n"

  cat(out)
}



#####################################################################
# Test Issue 35.  readColumns, read.xlx2 don't read columns with formulas
# correctly.  They are read as NA's.  Not an issue (user did not specify
# colClasses as suggested)
#
.test.issue35 <- function( out="FAILED\n" )
{
  cat(".test.issue35 ")
  require(xlsx)
  file <- "resources/issue35.xlsx"

  wb <- loadWorkbook(file)
  sheets <- getSheets(wb)
  sheet <- sheets[["Sheet1"]]

  x1 <- readColumns(sheet, startColumn=1, endColumn=3, startRow=1,
                    colClasses=c("character", "numeric", "numeric"))
  x0 <- readColumns(sheet, startColumn=1, endColumn=3, startRow=1)  
  x2 <- read.xlsx(file, 1)
  x3 <- read.xlsx2(file, 1,
          colClasses=c("character", "numeric", "numeric"))

  if (as.character(x1[1,3]) != "NA") {
     out <- "PASSED\n"
  }
  

  cat(out)
}



#####################################################################
# Test Issue 41.  Font + Fill did not set the font
#
#
.test.issue41 <- function( out="FAILED\n" )
{
  cat(".test.issue41 ")
  require(xlsx)

  wb <- createWorkbook()
  cs <- CellStyle(wb) +
    Font(wb, heightInPoints=25, isBold=TRUE, isItalic=TRUE, color="red", name="Arial") + 
    Fill(backgroundColor="lavender", foregroundColor="lavender", pattern="SOLID_FOREGROUND") +
    Alignment(h="ALIGN_RIGHT")


  if (!is.null(cs$font$ref))
      out <- "PASSED\n"
  
  cat(out)
}


#####################################################################
# Test Issue 43.  set cell height
#
#
.test.issue43 <- function( out="FAILED\n" )
{
  cat(".test.issue43 ")
  require(xlsx)

  wb <- createWorkbook()
  sheet  <- createSheet(wb, sheetName="Sheet1")
  rows  <- createRow(sheet, rowIndex=1:5)
  cells <- createCell(rows, colIndex=1:5) 
  setRowHeight( rows, multiplier=3)
  
  saveWorkbook(wb, "out/issue43.xlsx")  
  out <- "PASSED.  Check out/issue43.xlsx by hand.\n"


  cat(out)    
}

#####################################################################
# Test Issue 45.  Issue when testing for DateTime classes in
# write.xlsx.
# 
#
.test.issue45 <- function( out="FAILED\n" )
{
  cat(".test.issue45 ")
  require(xlsx)
   
  #source("R/write.xlsx.R")
  hours <- seq(as.POSIXct("2011-01-01 01:00:00", tz="GMT"),
      as.POSIXct("2011-01-01 10:00:00", tz="GMT"), by="1 hour")
  df <- data.frame(x=1:10, datetime=hours)

  write.xlsx(df, "out/issue45.xlsx")
  
  df.in <- read.xlsx2("out/issue45.xlsx", sheetIndex=1,
   colClasses=c("numeric", "numeric", "POSIXct"))
  df.in$datetime <- round(df.in$datetime)

  if (identical(as.numeric(df.in$datetime), as.numeric(hours)))
    out <- "PASSED.\n"

  
  cat(out)        
}


#####################################################################
# Test Issue 47.  Add auto filter
# 
#
.test.issue47 <- function( out="FAILED\n" )
{
  cat(".test.issue47 ")
  require(xlsx)

  hours <- seq(as.POSIXct("2011-01-01 01:00:00", tz="GMT"),
      as.POSIXct("2011-01-01 10:00:00", tz="GMT"), by="1 hour")
  data <- data.frame(x=1:10, type=rep(c("A", "B"), 5), datetime=hours)
  
  
  wb <- createWorkbook(type="xlsx")
  sheet  <- createSheet(wb, sheetName="Sheet1")
  addDataFrame(data, sheet, startRow=3, startColumn=2)
  addAutoFilter(sheet, "C3:E3")
  saveWorkbook(wb, "out/issue47.xlsx")
  out <- "PASSED.\n"                 
  
  cat(out)         
}


#####################################################################
# Register and run the specific tests
#
.run_test_issues <- function()
{
  library(xlsx)  
  source("inst/tests/lib_test_issues.R")
  file.remove(list.files("out", full.names=TRUE))
  
  .test.issue2()
  .test.issue6()  
  .test.issue7()  
  .test.issue9()  
  .test.issue11()  
  .test.issue12()
  .test.issue16()
  .test.issue19()
  .test.issue22()
  .test.issue23()
  .test.issue25()
  .test.issue26()
  .test.issue28()
  .test.issue31()
  #.test.issue32()
  .test.issue35()
  .test.issue41()
  .test.issue43()
  .test.issue45()
  .test.issue47()

  
}







## #####################################################################
## # Test Issue 3X
## # richTextFormat
## #
## .test.issue3x <- function(out="FAILED\n" )
## {
##   cat(".test.issue3x ")
 
##   require(xlsx)
##   wb <- createWorkbook()
##   sheet <- createSheet(wb, "Sheet1")

##   rows   <- createRow(sheet, rowIndex=1:24)         
##   cells  <- createCell(rows, colIndex=1:8)      

##   # see https://poi.apache.org/apidocs/index.html?org/apache/poi/xssf/usermodel/XSSFRichTextString.html 
##   rs <- .jnew("org/apache/poi/xssf/usermodel/XSSFRichTextString",
##      "test red bold words." )
##   .jcall(rs, "V", "applyFont", 5L, 13L, Font(wb, color="red", isBold=TRUE)$ref)
  
##   .jcall(cells[[2,1]], "V", "setCellValue",
##          .jcast(rs, "org/apache/poi/ss/usermodel/RichTextString"))
  
##   fileOut <- paste(OUTDIR, "issue3x_out.xlsx", sep="")
##   saveWorkbook(wb, file=fileOut)  

##   cat("PASSED\n")
## }
