# test the package
#
# test.addOnExistingWorkbook
# test.evalFormulasOnOpen
# test.addDataFrame
# test.basicFunctions
# test.cellStyles
# test.cellBlock
# test.comments
# test.dataFormats
# test.evalFormulasOnOpen
# test.otherEffects
# test.picture
# test.ranges
# test.Issue9
#
# .main_highlevel_export
# .main_lowlevel_export
# .main




#####################################################################
# Test adding a df to an existing workbook using addDataFrame 
# 
test.addOnExistingWorkbook <- function(ext="xlsx")
{
  cat("Test adding a df to an existing workbook ... ")

  src <- system.file("tests", paste("test_import.", ext, sep=""),
                     package="xlsx")
  wb  <- loadWorkbook( src )
  sheets <- getSheets( wb )

  dat <- data.frame(a=LETTERS, b=1:26)

  addDataFrame(dat, sheets$mixedTypes, startColumn=20, startRow=5)
  #saveWorkbook(wb, paste(OUTDIR, "addOnExistingWorkbook.xlsx", sep=""))
  
  cat("Done.\n")
}

#####################################################################
# Test add 
# 
test.addDataFrame <- function(wb)
{
  cat("Testing addDataFrame ... \n")
  
  cat("  custom styles\n")
  sheet1 <- createSheet(wb, sheetName="addDataFrame1")
  data0 <- data.frame(mon=month.abb[1:10], day=1:10, year=2000:2009,
    date=seq(as.Date("1999-01-01"), by="1 year", length.out=10),
    bool=ifelse(1:10 %% 2, TRUE, FALSE), log=log(1:10),
    rnorm=10000*rnorm(10),
    datetime=seq(as.POSIXct("2011-11-06 00:00:00", tz="GMT"), by="1 hour",
      length.out=10))
  cs1 <- CellStyle(wb) + Font(wb, isItalic=TRUE)
  cs2 <- CellStyle(wb) + Font(wb, color="blue")
  cs3 <- CellStyle(wb) + Font(wb, isBold=TRUE) + Border()
  addDataFrame(data0, sheet1, startRow=3, startColumn=2, colnamesStyle=cs3,
    rownamesStyle=cs1, colStyle=list(`2`=cs2, `3`=cs2))
  
  cat("  NA treatment, with defaults\n")
  sheet2 <- createSheet(wb, sheetName="addDataFrame2")  
  data <- data.frame(mon=month.abb, index=1:12, double=seq(1.23, by=1,
    length.out=12), stringsAsFactors=FALSE)
  data$mon[3:4] <- NA; data$mon[12] <- "defaults, showNA=FALSE"
  data$index[c(1, 7, 11)] <- NA
  data$double[3:4] <- NA
  addDataFrame(data, sheet2, row.names=FALSE)

  cat("  NA treatment, with showNA=TRUE\n")
  sheet3 <- createSheet(wb, sheetName="addDataFrame3")
  data$mon[12] <- "showNA=TRUE, characterNA=NotAvailable"
  addDataFrame(data, sheet3, row.names=FALSE, showNA=TRUE,
    characterNA="NotAvailable")
  row <- getRows(sheet3, 1)
  cells <- getCells(row)
  c1.10 <- createCell(row, 10)
  setCellValue(c1.10[[1,1]], "rbind and cbind some df with addDataFrame")
  
  cat("  stack another data.frame on a sheet\n")
  addDataFrame(data0, sheet3, startRow=17, startColumn=5)

  cat("  put another data.frame on a sheet side by side\n")
  addDataFrame(data0, sheet3, startRow=17, startColumn=17)
  
  cat("Done.\n")
}

#####################################################################
# 
# 
test.basicFunctions <- function(ext)
{
  cat("Testing basic workbook functions\n")
  cat("Create an empty workbook ... ") 
  wb <- createWorkbook(type=ext)

  cat("  create a sheet called 'Sheet1'\n")
  sheet1 <- createSheet(wb, sheetName="Sheet1")

  cat("  create another sheet called 'Sheet2'\n")
  sheet2 <- createSheet(wb, sheetName="Sheet2")
  
  cat("  get sheets\n")
  sheets <- getSheets(wb)
  stopifnot(length(sheets) == 2)

  cat("  remove sheet named 'Sheet2'\n")
  removeSheet(wb, sheetName="Sheet2")
  sheets <- getSheets(wb)  
  stopifnot(length(sheets) == 1)
 
  cat("  add rows 6:10 on Sheet1\n")
  rows <- createRow(sheet1, 6:10)
  stopifnot(length(rows) == 5)

  cat("  remove rows 1:10 on Sheet1 of test_import.xlsx\n")
  filename <- paste("test_import.", ext, sep="")
  file <- system.file("tests", filename, package="xlsx")
  wb <- loadWorkbook(file)  
  sheets <- getSheets(wb)
  sheet <- sheets[[1]]  
  rows  <- getRows(sheet)           # get all the rows
  removeRow(sheet, rows[1:10])
  rows  <- getRows(sheet)           # get all the rows
  stopifnot(length(rows) == 41)

  cat("Done.\n")
}

#####################################################################
# Test Borders, Fonts, Colors, etc. 
# 
test.cellStyles <- function(wb)
{
  cat("Testing cell styles ...\n")
  sheet  <- createSheet(wb, sheetName="cellStyles")
  rows   <- createRow(sheet, rowIndex=1:12)         
  cells  <- createCell(rows, colIndex=1:8)      

  mapply(setCellValue, cells[,1], month.name)

  cat("  Check borders of different colors.\n")
  setCellValue(cells[[2,2]], paste("<-- Thick red bottom border,",
                                   "thin blue top border."))
  borders <- Border(color=c("red","blue"), position=c("BOTTOM", "TOP"),
                    pen=c("BORDER_THICK", "BORDER_THIN"))
  cs1 <- CellStyle(wb) + borders
  setCellStyle(cells[[2,1]], cs1)   

  
  cat("  Check fills.\n")
  setCellValue(cells[[4,2]], "<-- Solid lavender fill.")
  cs2 <- CellStyle(wb) + Fill(backgroundColor="lavender",
    foregroundColor="lavender", pattern="SOLID_FOREGROUND")
  setCellStyle(cells[[4,1]], cs2) 

    
  cat("  Check fonts.\n") 
  setCellValue(cells[[6,2]], "<-- Courier New, Italicised, in orange, size 20 and bold")
  font <- Font(wb, heightInPoints=20, isBold=TRUE, isItalic=TRUE,
    name="Courier New", color="orange")
  cs3 <- CellStyle(wb) + font
  setCellStyle(cells[[6,1]], cs3)   

  
  cat("  Check alignment.\n")
  setCellValue(cells[[8,2]], "<-- Right aligned")
  cs4 <- CellStyle(wb) + Alignment(h="ALIGN_RIGHT")
  setCellStyle(cells[[8,1]], cs4)


  cat("  Check dataFormat.\n")
  setCellValue(cells[[10,1]], -12345.6789)
  setCellValue(cells[[10,2]], "<-- Format -12345.6789 in accounting style.")
  cs5 <- CellStyle(wb) + DataFormat("#,##0.00_);[Red](#,##0.00)")
  setCellStyle(cells[[10,1]], cs5)

  
  cat("  Autosize first, second column.\n") 
  autoSizeColumn(sheet, 1)
  autoSizeColumn(sheet, 2)
  setCellValue(cells[[1,4]], "First and second columns are autosized.")

  cat("Done.\n")
}


test.cellBlock2 <- function()
{
  ext <- "xls"
  outfile <- paste("out/test_cellBlock.", ext, sep="")
  if (file.exists(outfile)) unlink(outfile)
   
  wb <- createWorkbook(type=ext)

  sheet  <- createSheet(wb, sheetName="CellBlock")

  cat("  Add a cell block to sheet CellBlock")
  cb <- CellBlock(sheet, 7, 3, 50, 60)
  CB.setColData(cb, 1:50, 1)    # set a column
  CB.setRowData(cb, 1:50, 1)     # set a row

  # add a matrix, and style it
  cs <- CellStyle(wb) + DataFormat("#,##0.00")
  x  <- matrix(rnorm(40*45), nrow=40)
  CB.setMatrixData(cb, x, 10, 4, cellStyle=cs)  

  # highlight the negative numbers in red 
  fill <- Fill(foregroundColor = "red", backgroundColor="red")
  ind  <- which(x < 0, arr.ind=TRUE)
  CB.setFill(cb, fill, ind[,1]+9, ind[,2]+3)  # note the indices offset

  # set the border on the top row of the Cell Block
  border <-  Border(color="blue", position=c("TOP", "BOTTOM"),
    pen=c("BORDER_THIN", "BORDER_THICK"))
  CB.setBorder(cb, border, 1:50, 1)

  saveWorkbook(wb, outfile)  
  cat("Wrote file", outfile, "\n\n")
}



#####################################################################
# Test CellBlock
# 
test.cellBlock <- function(wb)
{
  cat("Testing the CellBlock functionality ...\n")
  sheet  <- createSheet(wb, sheetName="CellBlock")

  cat("  Add a cell block to sheet CellBlock\n")
  cb <- CellBlock(sheet, 7, 3, 1000, 60)
  CB.setColData(cb, 1:100, 1)    # set a column
  CB.setRowData(cb, 1:50, 1)     # set a row

  # add a matrix, and style it
  cs <- CellStyle(wb) + DataFormat("#,##0.00")
  x  <- matrix(rnorm(900*45), nrow=900)
  CB.setMatrixData(cb, x, 10, 4, cellStyle=cs)  

  # highlight the negative numbers in red 
  fill <- Fill(foregroundColor = "red", backgroundColor="red")
  ind  <- which(x < 0, arr.ind=TRUE)
  CB.setFill(cb, fill, ind[,1]+9, ind[,2]+3)  # note the indices offset

  # set the border on the top row of the Cell Block
  border <-  Border(color="blue", position=c("TOP", "BOTTOM"),
    pen=c("BORDER_THIN", "BORDER_THICK"))
  CB.setBorder(cb, border, 1:1000, 1)

  cat("  Modify the cell styles of existing cells on sheet dataFormats\n")
  sheets <- getSheets(wb)
  sheet  <- sheets[["dataFormats"]]
  cb <- CellBlock(sheet, 1, 1, 5, 5, create=FALSE)
  font <- Font(wb, color="red", isItalic=TRUE)
  CB.setBorder(cb, border, 1:5, 1)
  ind <- expand.grid(1:5, 1:5)
  CB.setFont(cb, font, ind[,1], ind[,2])

  
  cat("Done.\n")
}


#####################################################################
# Test comments
# 
test.comments <- function(wb)
{
  cat("Testing comments ... ")
  sheet <- createSheet(wb, "Comments")
  rows  <- createRow(sheet, rowIndex=1:10)      # 10 rows
  cells <- createCell(rows, colIndex=1:8)       # 8 columns

  cell1 <- cells[[1,1]]
  setCellValue(cell1, 1)   # add value 1 to cell A1

  createCellComment(cell1, "Cogito", author="Descartes")

  comment <- getCellComment(cell1)
  stopifnot(comment$getAuthor()=="Descartes")
  stopifnot(comment$getString()$toString()=="Cogito")

  cat("Done.\n")
}


#####################################################################
# Test dataFormats
# 
test.dataFormats <- function(wb)
{
  cat("Testing dataFormats ... ")

  # create a test data.frame
  data <- data.frame(mon=month.abb[1:10], day=1:10, year=2000:2009,
    date=seq(as.Date("1999-01-01"), by="1 year", length.out=10),
    bool=ifelse(1:10 %% 2, TRUE, FALSE), log=log(1:10),
    rnorm=10000*rnorm(10),
    datetime=seq(as.POSIXct("2011-11-06 00:00:00", tz="GMT"), by="1 hour",
      length.out=10))

  sheet <- createSheet(wb, "dataFormats")
  rows  <- createRow(sheet, rowIndex=1:10)       # 10 rows
  cells <- createCell(rows, colIndex=1:10)       # 10 columns

  # or do them all by looping over columns
  for (ic in 1:ncol(data))
    mapply(setCellValue, cells[,ic], data[,ic]) 

  setCellValue(cells[[1,10]], 'format "log" column with two decimals')
  cellStyle1 <- CellStyle(wb) + DataFormat("#,##0.00")
  lapply(cells[,6], setCellStyle, cellStyle1)

  setCellValue(cells[[2,10]], 'format date column')
  cellStyle2 <- CellStyle(wb) + DataFormat("m/d/yyyy")
  lapply(cells[,4], setCellStyle, cellStyle2)

  setCellValue(cells[[3,10]], paste('format datetime column (tz=GMT only),',
    'should start from 2011-11-06 00:00:00 with hour increments.'))
  cellStyle3 <- CellStyle(wb) + DataFormat("m/d/yyyy h:mm:ss;@")
  #cellStyle2$getDataFormat()
  lapply(cells[,8], setCellStyle, cellStyle3)

  setCellValue(cells[[4,10]], 
    'format "rnorm" column with two decimals, comma separator, red')
  cellStyle4 <- CellStyle(wb) + DataFormat("#,##0.00_);[Red](#,##0.00)")
  lapply(cells[,7], setCellStyle, cellStyle4)

  cat("Done.\n")
}

#####################################################################
# Test other effects
# 
test.evalFormulasOnOpen <- function()
{
  require(xlsx)
  filename <- "C:/Temp/formulaRevalueOnOpen.xlsx"
  wb <- loadWorkbook(filename)
  sheets <- getSheets(wb)

  sheet <- sheets[[1]]
  rows <- getRows(sheet)
  cells <- getCells(rows)

  setCellValue(cells[["2.1"]], 2)

  #wb$getCreationHelper()$createFormulaEvaluator()$evaluateAll()
  
  wb$setForceFormulaRecalculation(TRUE)
  
  saveWorkbook(wb, "C:/temp/junk.xlsx")
  
}

#####################################################################
# Test other effects
# 
test.otherEffects <- function(wb)
{
  cat("Testing other effects ... \n")

  sheet1 <- createSheet(wb, "otherEffects1")
  rows   <- createRow(sheet1, 1:10)              # 10 rows
  cells  <- createCell(rows, colIndex=1:8)       # 8 columns

  cat("  merge cells\n")
  setCellValue(cells[[1,1]], "<-- a title that spans 3 columns")
  addMergedRegion(sheet1, 1, 1, 1, 3)

  cat("  set column width\n")
  setColumnWidth(sheet1, 1, 25)
  setCellValue(cells[[5,1]], paste("<-- the width of this column",
    "is 20 characters wide."))
  
  cat("  set zoom\n")
  setCellValue(cells[[3,1]], "<-- the zoom on this sheet is 2:1.")
  setZoom(sheet1, 200, 100)

  sheet2 <- createSheet(wb, "otherEffects2")
  rows  <- createRow(sheet2, 1:10)              # 10 rows
  cells <- createCell(rows, colIndex=1:8)       # 8 columns
  #createFreezePane(sheet2, 1, 1, 1, 1)
  createFreezePane(sheet2, 5, 5, 8, 8)
  setCellValue(cells[[3,3]], "<-- a freeze pane")

  cat("  add hyperlinks to a cell\n")
  address <- "http://poi.apache.org/"
  setCellValue(cells[[1,1]], "click me!")  
  addHyperlink(cells[[1,1]], address)
  
  sheet3 <- createSheet(wb, "otherEffects3")
  rows  <- createRow(sheet3, 1:10)              # 10 rows
  cells <- createCell(rows, colIndex=1:8)       # 8 columns
  createSplitPane(sheet3, 2000, 2000, 1, 1, "PANE_LOWER_LEFT")
  setCellValue(cells[[3,3]], "<-- a split pane")
  
  cat("Done.\n")
}

  
#####################################################################
# Test pictures
# 
test.picture <- function(wb)
{
  cat("Test embedding an R picture ...\n")

  cat("Add log_plot.jpeg to a new xlsx...")
  picname <- system.file("tests", "log_plot.jpeg", package="xlsx")
  sheet <- createSheet(wb, "picture")

  addPicture(picname, sheet)

  xlsx:::.write_block(wb, sheet, iris)
  cat("Done.\n")  
}

  
#####################################################################
# Test Ranges
# 
test.ranges <- function(wb)
{
  cat("Testing ranges ... ")
  sheets <- getSheets(wb)
  sheet <- sheets[["dataFormats"]]
  
  cat("  make a new range")
  firstCell <- sheet$getRow(2L)$getCell(2L)
  lastCell  <- sheet$getRow(6L)$getCell(5L)
  rangeName <- "Test2"
  createRange(rangeName, firstCell, lastCell)
  
  ranges <- getRanges(wb)
  range <- ranges[[1]]
  res <- readRange(range, sheet, colClasses="numeric")

  cat("Done.\n")
}



#####################################################################
# Test imports
# 
.main_highlevel_import <- function(ext="xlsx")
{
  fname <- paste("test_import.", ext, sep="")
  file <- paste("inst/tests/", fname, sep="")

  cat("Testing high level import read.xls\n")
  cat("  read data from mixedTypes\n")
  orig <- getOption("stringsAsFactors")
  options(stringsAsFactors=FALSE)
  res <- read.xlsx(file, sheetName="mixedTypes")
  stopifnot(class(res[,1])=="Date")
  stopifnot(class(res[,2])=="character")
  stopifnot(class(res[,3])=="numeric")
  stopifnot(class(res[,4])=="logical")
  stopifnot(inherits(res[,6], "POSIXct"))
  options(stringsAsFactors=orig)

  cat("  import keeping formulas\n")
  res <- read.xlsx(file, sheetName="mixedTypes", keepFormulas=TRUE)
  stopifnot(res$Double[4]=="SQRT(2)")
  
  cat("  import with colClasses\n")
  cat("  force conversion of boolean column to numeric\n")
  colClasses <- rep(NA, length=6); colClasses[4] <- "numeric"
  res <- read.xlsx(file, sheetName="mixedTypes", colClasses=colClasses)
  stopifnot(class(res[,4])=="numeric")

  cat("Test you can read sheet oneColumn\n")
  res <- read.xlsx(file, sheetName="oneColumn", keepFormulas=TRUE)
  stopifnot(ncol(res)==1)

  cat("Test you can read string formulas ... \n")
  res <- read.xlsx(file, "formulas", keepFormulas=FALSE)
  stopifnot(res[1,3]=="2010-1") 

  cat("Test you can read #N/A's ... \n")
  res <- read.xlsx(file, "NAs")
  stopifnot(all.equal(which(is.na(res)), c(6,28,29,59,69))) 

  cat("Test read.xlsx2 ... \n")
  res <- read.xlsx2(file, sheetName="all", startRow=3)
  
  cat("  read more columns than on the spreadsheet")
  res <- read.xlsx2(file, sheetName="all", startRow=3, noRows=6, colIndex=3:14)

  cat("  pass in some colClasses\n")
  res <- read.xlsx2(file, sheetName="all", startRow=3, colIndex=3:10,
    colClasses=c("character", rep("numeric", 2), "Date", "character",
      "numeric", "numeric", "POSIXct"))
  stopifnot(class(res[,4])=="Date", class(res[,8])=="POSIXct")
    
  cat("  read non contiguos blocks\n") 
  res <- read.xlsx2(file, sheetName="all", startRow=3,
    colIndex=c(3,4,6,8,9,10))
  stopifnot(ncol(res) == 6)

  cat("  read ragged data\n") 
  res2 <- read.xlsx2(file, sheetName="ragged")
  res  <- read.xlsx(file, sheetName="ragged", colIndex=1:4)  

  cat("  read rowIndex with read.xlsx\n")
  # reported bug in 0.5.1, fixed on 6/20/2013
  res <- read.xlsx(file, sheetName="all", colIndex=3:6, rowIndex=3:7)
  if (nrow(res) != 4) stop("read rowIndex with read.xlsx failed")

  
  cat("Done.\n")
}

#####################################################################
# test highlevel export
# 
.main_highlevel_export <- function(ext="xlsx")
{
  outfile <- paste("out/test_highlevel_export.", ext, sep="")
  if (file.exists(outfile)) unlink(outfile)  
  
  cat("Testing high level export ... \n")  
  x <- data.frame(mon=month.abb[1:10], day=1:10, year=2000:2009,
    date=seq(as.Date("2009-01-01"), by="1 month", length.out=10),
    bool=ifelse(1:10 %% 2, TRUE, FALSE))

  file <- paste("out/test_highlevel_export.", ext, sep="")
  cat("  write an xlsx file with char, int, double, date, bool columns ...\n")
  write.xlsx(x, file, sheetName="writexlsx")
  
  write.xlsx2(x, file, sheetName="writexlsx2", append=TRUE, row.names=FALSE) 

  cat("  test the append argument by adding another sheet ... \n")
  file <- paste("out/test_highlevel_export.", ext, sep="")
  write.xlsx(USArrests, file, sheetName="usarrests", append=TRUE)
  cat("Wrote file ", file, "\n\n")

  cat("  test writing/reading data.frames with NA values ... \n") 
  file <- paste("out/test_writeread_NA.", ext, sep="")
  x <- data.frame(matrix(c(1.0, 2.0, 3.0, NA), 2, 2))
  write.xlsx(x, file, row.names=FALSE)
  xx <- read.xlsx(file, 1)
  if (!identical(x,xx)) 
    stop("Fix me!")

  cat("Done.\n")
}


#####################################################################
#
.main_lowlevel_import <- function(ext="xlsx")
{
  cat("Testing low level import ...\n")
  fname  <- paste("test_import.", ext, sep="")
  file   <- paste("inst/tests/", fname, sep="")
  wb     <- loadWorkbook(file)
  sheets <- getSheets(wb)

  cat("  readColumns on all sheet\n")
  sheet <- sheets[["all"]]
  res <- readColumns(sheet, startColumn=3, endColumn=10, startRow=3,
    endRow=7)
  stopifnot(nrow(res)==4)

  ## cat("  readColumns for more cols than data\n")
  ## res <- readColumns(sheet, startColumn=1, endColumn=14, startRow=3)
  ## stopifnot(ncol(res)==14)

  cat("  readColumns for formulas and NAs\n")
  sheet <- sheets[["NAs"]]
  res <- readColumns(sheet, 1, 6, 1,  colClasses=c("Date", "character",
    "integer", rep("numeric", 2),  "POSIXct"))
  stopifnot(length(which(is.nan(res[,5])))==4)

  cat("  readColumns for ragged sheets\n")
  sheet <- sheets[["ragged"]]
  res <- readColumns(sheet, 1, 4, 1,  colClasses=c(rep("character", 3),
                                        "numeric"))
  stopifnot(res[1,1]=="")

  cat("  readRows\n")
  sheet <- sheets[["all"]]
  res <- readRows(sheet, startRow=3, endRow=7, startColumn=2, endColumn=15)
  
  cat("Done.\n")
}


#####################################################################
# a spreadsheet with many sheets
#
.main_lowlevel_export <- function(ext="xlsx")
{
  outfile <- paste("out/test_export.", ext, sep="")
  if (file.exists(outfile)) unlink(outfile)
   
  wb <- createWorkbook(type=ext)

  test.cellStyles(wb)
  test.comments(wb)
  test.dataFormats(wb)
  test.ranges(wb)
  test.otherEffects(wb)
  test.picture(wb)
  test.addDataFrame(wb)
  #test.pageBreaks(wb)    # not working with 3.7, fixed in 3.8
  test.cellBlock(wb)
   
  saveWorkbook(wb, outfile)
  
  cat("Wrote file", outfile, "\n\n")
}

#####################################################################
# Speed Test export
# Ubuntu desktop, 85s & 3s.
#
.main_speedtest_export <- function(ext="xlsx")
{
  cat("Speed test export ... \n")  

  file <- paste("out/test_exportSpeed.", ext, sep="")
  x <- expand.grid(ind=1:60, letters=letters, months=month.abb)
  x <- cbind(x, val=runif(nrow(x)))
  cat("  writing a data.frame with dim", nrow(x), "x", ncol(x), "\n")
  cat("  timing write.xlsx:", system.time(write.xlsx(x, file)), "\n")   # 99s
  cat("  timing write.xlsx2:", system.time(write.xlsx2(x, file)), "\n") #  9s
  cat("  wrote file ", file, "\n")
  
  cat("Done.\n")
}



#####################################################################
#####################################################################
#
.main <- function()
{
  # best viewed with M-x hs-minor-mode

  options(width=400)
  require(xlsx)

  #source("R/utilities.R")
  #source("R/addDataFrame.R")
  source("inst/tests/lib_tests_xlsx.R")


  source("inst/tests/lib_test_issues.R")
  .run_test_issues()

  
  test.basicFunctions(ext="xlsx")
  test.addOnExistingWorkbook(ext="xlsx")  
  .main_lowlevel_export(ext="xlsx")
  .main_highlevel_export(ext="xlsx")
  .main_highlevel_import(ext="xlsx")
  .main_lowlevel_import(ext="xlsx")  # readColumns, readRows
#  .main_speedtest_export(ext="xlsx")
  
  test.basicFunctions(ext="xls")
  test.addOnExistingWorkbook(ext="xls")
  .main_lowlevel_export(ext="xls")  
  .main_highlevel_export(ext="xls")  
  .main_highlevel_import(ext="xls")
  .main_lowlevel_import(ext="xls")
#  .main_speedtest_export(ext="xls")
 

  ## allF <- list.files(paste(SOURCEDIR,"rexcel/trunk/R/", sep=""),
  ##                    full.names=TRUE)
  ## lapply(allF, function(fname){cat(fname); source(fname)})

  

}








##   cat("Test memory ...\n")
##   file <- paste(outdir, "test_exportMemory.xlsx", sep="")
##   x <- expand.grid(ind=1:1000, letters=letters, months=month.abb)
##   cat("Writing object size: ", object.size(x), " uses all Java heap space\n")
##   (time <- system.time(write.xlsx2(x, file)))
##   cat("Wrote file ", file, "\n\n")






## #####################################################################
## # Test basic Java POI functionality - a bit redundant now
## # 
## test.basicJavaPOI <- function(wb)
## {
##   cat("Create an empty workbook ...\n") 
##   wb <- .jnew("org/apache/poi/xssf/usermodel/XSSFWorkbook")
##   #if (class(wb)=="jobjRef") cat("OK.\n")
##   #.jmethods(wb)

##   cat("Create a sheet called 'Sheet2' ...\n")
##   sheet2 <- .jcall(wb, "Lorg/apache/poi/ss/usermodel/Sheet;",
##     "createSheet", "Sheet2")
##   #if (.jinstanceof(sheet2, "org.apache.poi.ss.usermodel.Sheet"))
##   #  cat("OK.\n")  
##   #.jmethods(sheet2)

##   cat("Create row 1 ...\n")
##   row <- .jcall(sheet2, "Lorg/apache/poi/ss/usermodel/Row;",
##     "createRow", as.integer(0))
##   #.jmethods(row)

##   cat("Create cell [1,1] ...\n")
##   cell <- .jcall(row, "Lorg/apache/poi/ss/usermodel/Cell;",
##     "createCell", as.integer(0))

##   cat("Put a value in cell [1,1] ... ")
##   cell$setCellValue(1.23)

##   cat("Add cell [1,2] and put a numeric value ... \n")
##   .jcall(row, "Lorg/apache/poi/ss/usermodel/Cell;",
##     "createCell", as.integer(1))$setCellValue(3.1415)

##   cat("Add cell [1,3] and put a stringvalue ... \n")
##   .jcall(row, "Lorg/apache/poi/ss/usermodel/Cell;",
##     "createCell", as.integer(2))$setCellValue("A string")

##   cat("Add cell [1,4] and put a boolean value ... \n")
##   .jcall(row, "Lorg/apache/poi/ss/usermodel/Cell;",
##     "createCell", as.integer(3))$setCellValue(TRUE)

##   cat("Done.\n")




#####################################################################
# Test mixture.  You cannot convert one hssf to xssf on the fly. 
# 
## test.mixtureHSSFXSSF <- function(wb)
## {
##   cat("Test mixture of HSSF and XSSF")
  
##   fname <- "test_import.xls"
##   file <- paste(SOURCEDIR, "rexcel/trunk/inst/tests/", fname, sep="")

##   wb <- loadWorkbook(file)
##   sheets <- getSheets(wb)

##   sheet <- sheets[["all"]]

##   wb2 <- .jcast(wb, "org/apache/poi/ss/usermodel/Workbook")

##   saveWorkbook(wb2, paste(OUTDIR, "modify_existing_hssf.xlsx", sep=""))  
## }








