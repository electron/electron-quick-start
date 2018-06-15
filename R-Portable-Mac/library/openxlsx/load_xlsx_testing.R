
require('openxlsx')

unzip_xlsx <- function(fl){
  
  wd <- getwd()
  d <- file.path(tempdir(), paste(sample(LETTERS, 10), collapse = ""))
  unlink(d, recursive = TRUE, force = TRUE)
  dir.create(d)
  
  new_fl <- file.path(d, basename(fl))
  file.copy(from = fl, to = new_fl)
  
  setwd(d)
  unzip(zipfile = new_fl, junkpaths = FALSE)
  cmd <- paste("start", d)
  shell(cmd)
  
  unlink(new_fl)
  
  setwd(wd)
  
  return(d)
  
}


zip_xlsx <- function(d){
  
  wd <- getwd()
  setwd(d)
  
  zipfile = "a.xlsx"
  files <- list.files()
  flags = "-r1"
  extras = ""
  zip = Sys.getenv("R_ZIPCMD", "zip")
  
  ## code from utils::zip function (modified to not print)
  args <- c(flags, shQuote(path.expand(zipfile)), shQuote(files), extras)
  res <- invisible(suppressWarnings(system2(zip, args, stdout = NULL)))
  setwd(wd)
  
  
}

## Get loading files
# devtools::install_github("awalker89/openxlsx_testing_files", force = TRUE)

## To install from CRAN
# detach("package:openxlsx", unload=TRUE)
# install.packages("openxlsx")


test_file_dir <- system.file(package = "openxlsx.testing.files")

################################################################################################################
## All Features
wb <- loadWorkbook(file.path(test_file_dir, "All_Features.xlsx"))
openXL(wb)


################################################################################################################
## Budget Template
wb <- loadWorkbook(file.path(test_file_dir, "Budget.xlsx"))
openXL(wb)
openXL(file.path(test_file_dir, "Budget.xlsx"))




################################################################################################################
## Chart Sheet
wb <- loadWorkbook(file.path(test_file_dir, "Chart_Sheet_Test.xlsx"))
openXL(wb)



################################################################################################################
## Chineses Characters
wb <- loadWorkbook(file.path(test_file_dir, "Chinese_Characters.xlsx"))
openXL(wb)


################################################################################################################
## Excel Diet Template
wb <- loadWorkbook(file.path(test_file_dir, "Diet.xlsx"))
openXL(wb)

################################################################################################################
## Empty Workbook
wb <- loadWorkbook(file.path(test_file_dir, "empty.xlsx"))
openXL(wb)


################################################################################################################
## Encoding Test
wb <- loadWorkbook(file.path(test_file_dir, "Encoding_Test.xlsx"))
openXL(wb)
openXL(file.path(test_file_dir, "Encoding_Test.xlsx"))

################################################################################################################
## Libre Office Test File
wb <- loadWorkbook(file.path(test_file_dir, "libre_test.xlsx"))
openXL(wb)

wb <- loadWorkbook(file.path(test_file_dir, "libre_test2.xlsx"))
openXL(wb)


################################################################################################################
## Load Example Workbook
wb <- loadWorkbook(system.file("loadExample.xlsx", package = "openxlsx"))
openXL(wb)


################################################################################################################
## Loading Pivot Tables
wb <- loadWorkbook(file.path(test_file_dir, "pivotTest.xlsx"))
openXL(wb)

wb <- loadWorkbook(file.path(test_file_dir, "pivotTest2.xlsx"))
openXL(wb)

wb <- loadWorkbook(file.path(test_file_dir, "pivotTest3.xlsx"))
openXL(wb)


################################################################################################################
## Excel Template (Sales call log and organizer1.xlsx)
wb <- loadWorkbook(file.path(test_file_dir, "Sales call log and organizer1.xlsx"))
openXL(wb)


################################################################################################################
## Whitespace - maintain whitespace
wb <- loadWorkbook(file.path(test_file_dir, "Whitespace_Test.xlsx"))
openXL(wb)


################################################################################################################
## Weight Tracket Excel Template
wb <- loadWorkbook(file.path(test_file_dir, "WeightTrackerTemplate.xlsx"))
openXL(wb)

################################################################################################################
## Schedule Excel Template
wb <- loadWorkbook(file = file.path(test_file_dir, "Schedule Template.xlsx"))
openXL(wb)


################################################################################################################
## package Example File
wb <- loadWorkbook(file = system.file("loadExample.xlsx", package = "openxlsx"))
openXL(wb)




## write jsuts a date
wb <- createWorkbook()
addWorksheet(wb, "Sheet 1")
writeData(wb, 1, as.Date('2014-01-01'))
openXL(wb)

wb <- loadWorkbook(file.path(test_file_dir, "pivotTest.xlsx"))
writeData(wb, 1, iris[,1:3]*100, colNames = FALSE, startRow = 2)
openXL(wb)

openXL(file.path(test_file_dir, "pivotTest.xlsx"))






