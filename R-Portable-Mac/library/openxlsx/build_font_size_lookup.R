
options("scipen" = 10000)

## loop through all fonts
fontDir <- "C:\\Users\\Alex\\Desktop\\font_workbooks"
files <- list.files(fontDir, patter = "\\.xlsx$", full.names = TRUE)
files <- files[!grepl("-bold.xlsx", files)]

files2 <- list.files(fontDir, patter = "\\.xlsx$", full.names = FALSE)
files2 <- files2[!grepl("-bold.xlsx", files2)]

font <- tolower(gsub(" ", ".", gsub("\\.xlsx", "", files2)))


strs <- "openxlsxFontSizeLookupTable <- \ndata.frame("
allWidths <- rep(8.43, 29)
names(allWidths) <- 1:29
for(i in 1:length(files)){
  
  f <- font[[i]]
  widths <- round(as.numeric(read.xlsx(files[[i]])[2,]), 6)
  strs <- c(strs, sprintf('"%s"= c(%s),\n', f, paste(widths, collapse = ", ")))
  
}

strs[length(strs)] <- gsub(",\n", ")", strs[length(strs)])


## bold ones

## loop through all fonts
fontDir <- "C:\\Users\\Alex\\Desktop\\font_workbooks"
files <- list.files(fontDir, patter = "\\.xlsx$", full.names = TRUE)
files <- files[grepl("-bold.xlsx", files)]

files2 <- list.files(fontDir, patter = "\\.xlsx$", full.names = FALSE)
files2 <- files2[grepl("-bold.xlsx", files2)]

font <- tolower(gsub(" ", ".", gsub("\\-bold.xlsx", "", files2)))


strsBold <- "openxlsxFontSizeLookupTableBold <- \ndata.frame("
allWidths <- rep(8.43, 29)
names(allWidths) <- 1:29
for(i in 1:length(files)){
  
  f <- font[[i]]
  widths <- round(as.numeric(read.xlsx(files[[i]])[2,]), 6)
  strsBold <- c(strsBold, sprintf('"%s"= c(%s),\n', f, paste(widths, collapse = ", ")))
  
}

strsBold[length(strsBold)] <- gsub(",\n", ")", strsBold[length(strsBold)])


allStrs <- c(strs, "\n\n\n", strsBold)
cat(allStrs)





