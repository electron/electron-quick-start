
options(java.parameters="-Xmx4096m")  
require(xlsx)

N <- 500    # crash with N=5000, at sheet 20

x <- as.data.frame(matrix(1:N, nrow=N, ncol=59))

wb <- createWorkbook()
for (k in 1:100) {
  cat("On sheet", k, "\n")
  sheetName <- paste("Sheet", k, sep="")
  sheet <- createSheet(wb, sheetName)

  addDataFrame(x, sheet)
}

saveWorkbook(wb, "/tmp/junk.xlsx")
 



