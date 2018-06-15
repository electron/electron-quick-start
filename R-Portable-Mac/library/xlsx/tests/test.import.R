#
#
#

test.import <- function(outdir="C:/Temp/", type="xlsx",
                        speedtest=FALSE)
{
  cat("##################################################\n")
  cat("Test reading xlsx files into R\n")
  cat("##################################################\n")
  filename <- paste("test_import.", type, sep="")
  file <- system.file("tests", filename, package="xlsx")
  
  cat("Load test_import.xlsx ... ")
  wb <- loadWorkbook(file)
  cat("OK\n")
  sheets <- getSheets(wb)

  cat("Get the second sheet with mixedTypes ... ")
  sheet  <- sheets[[2]]
  rows   <- getRows(sheet)
  cells  <- getCells(rows)
  values <- lapply(cells, getCellValue)

  cat("Extract cell [5,2] and see if == 'Apr' ...")
  stopifnot(values[["5.2"]] == "Apr")
  cat("OK\n")

  orig <- getOption("stringsAsFactors")
  options(stringsAsFactors=FALSE)
  cat("Test high level import\n")
  cat("Read data in second sheet ...\n")
  res <- read.xlsx(file, 2)
  cat("First column is of class Dates ... ")
  stopifnot(class(res[,1])=="Date")
  cat("OK\n")    
  cat("Second column is of class character ... ")
  stopifnot(class(res[,2])=="character")
  cat("OK\n")    
  cat("Third column is of class numeric ... ")
  stopifnot(class(res[,3])=="numeric")
  cat("OK\n")    
  cat("Fourth column is of class logical ... ")
  stopifnot(class(res[,4])=="logical")
  cat("OK\n")    
  cat("Sixth column is of class POSIXct ... ")
  stopifnot(inherits(res[,6], "POSIXct"))
  cat("OK\n\n")    
  options(stringsAsFactors=orig)
  
  cat("Some cells are errors because of wrong formulas\n")
  print(res)   # some cells are errors because of wrong formulas
  cat("OK\n")    
  
  cat("Test high level import keeping formulas... \n")
  res <- read.xlsx(file, 2, keepFormulas=TRUE)
  cat("Now showing the formulas explicitly\n")
  print(res)
  cat("OK\n")    
  
  cat("Test high level import with colClasses.\n")
  cat("Force conversion of 5th column to numeric.\n")
  colClasses <- rep(NA, length=6); colClasses[5] <- "numeric"
  res <- read.xlsx(file, 2, colClasses=colClasses)
  print(res)   # force convesion to numeric
  cat("OK\n")    

  cat("Test you can import sheet one column... \n")
  res <- read.xlsx(file, "oneColumn", keepFormulas=TRUE)
  if (ncol(res)==1) {cat("OK\n")} else {cat("FAILED!\n")}

  cat("Check that you can import String formulas ... \n")
  res <- read.xlsx(file, "formulas", keepFormulas=FALSE)
  if (res[1,3]=="2010-1") {cat("OK\n")} else {cat("FAILED!\n")}

  if (speedtest){
    require(xlsx)
    colClasses <- c("numeric", rep("character", 76))
    res <- read.xlsx2("C:/Temp/ModelList.xlsx", sheetName="Models",
                      colClasses=colClasses)
    
  }
  
  cat("######################################################\n")
  cat("Test read.xlsx2  ...\n")
  cat("######################################################\n")  

  res <- read.xlsx2(file, sheetName="mixedTypes")
  res <- read.xlsx2(file, sheetName="mixedTypes", colClasses=c(
    "numeric", "character", rep("numeric", 4)))

  res <- read.xlsx2(file, sheetName="mixedTypes", startRow=2, noRows=3)
 
  
  
  
  cat("######################################################\n")
  cat("Test low level import ...\n")
  cat("######################################################\n")  
  file <- system.file("tests", filename, package="xlsx")

  wb <- loadWorkbook(file)
  sheets <- getSheets(wb)
  sheet  <- sheets[['deletedFields']]

  cat("Check that you can extract only some rows (say 5) ...")
  rows   <- getRows(sheet, rowIndex=1:5)
  cells  <- getCells(rows)
  res <- lapply(cells, getCellValue)
  rr <- unique(sapply(strsplit(names(res), "\\."), "[[", 1))
  stopifnot(identical(rr, c("1","2","3","4", "5")))
  cat("OK\n")    
  
  cat("Check that you can extract only some columns (say 4) ...")
  rows   <- getRows(sheet)
  cells  <- getCells(rows, colIndex=1:4)
  res <- lapply(cells, getCellValue)
  cols <- unique(sapply(strsplit(names(res), "\\."), "[[", 2))
  stopifnot(identical(cols, c("1","2","3","4")))
  cat("OK\n")    
    
  cat("Check that you can extract a matrix (say 2:3, 1:3) ... \n")
  sheet  <- sheets[['mixedTypes']]  
  vv <- getMatrixValues(sheet, 2:3, 1:3)
  print(vv)
  cat("OK\n")    
      
  
}










