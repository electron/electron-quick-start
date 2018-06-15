


require('openxlsx')


wb <- createWorkbook()
addWorksheet(wb, "Sheet 1")
writeData(wb, 1, head(iris))

## What we expect
# yellow fill and bold test rows 1:2 cols 1:5
addStyle(wb, sheet = 1, style = createStyle(fgFill = "yellow", textDecoration = "bold"), rows = 1:2, cols = 1:5, gridExpand = TRUE, stack = TRUE)

# yellow fill and bold test rows 1:2 cols 1:5
# red fill for row 1 and italic
addStyle(wb, sheet = 1, style = createStyle(fgFill =  "red", textDecoration = "italic"), rows = 1, cols = 1:5, gridExpand = TRUE, stack = TRUE)

# ## add a bluw line at row 5
addStyle(wb, sheet = 1, style = createStyle(fgFill =  "blue"), rows = 5, cols = 1:5, gridExpand = TRUE, stack = TRUE) ## non-intersecting

# ## Now borders and underlined around rows 1:3 for columns 1 and 5
addStyle(wb, sheet = 1, style = createStyle(border = "topbottomleftright", textDecoration = "underline"), rows = 2:3, cols = c(1, 5), gridExpand = TRUE, stack = TRUE)
# 
# ## Now blue border only on top for rows 1:3, column 1
addStyle(wb, sheet = 1, style = createStyle(border = "top", borderColour = "blue"), rows = 1:3, cols = 1, gridExpand = TRUE, stack = TRUE)

# 
# ## no stack! Wipe all formatting and put all black borders rows 1:4, col 3
# addStyle(wb, sheet = 1, style = createStyle(border = "topbottomleftright"), rows = 1:4, cols = c(3,3,3,3), stack = FALSE)
# 
# ## cell 3,3 red bottom border
# addStyle(wb, sheet = 1, style = createStyle(border = "bottom", borderColour = "red"), rows = 2:10, cols = 3, gridExpand = TRUE, stack = TRUE)


openXL(wb)

wb$addStyle







## Now not stacking
addWorksheet(wb, "Sheet 2")
writeData(wb, 2, matrix("abc", nrow = 4, ncol = 5))
addStyle(wb, 2, createStyle(halign = "center", border = "TopBottomLeftRight"), 1:5, 1:5, gridExpand = TRUE)
addStyle(wb, 2, createStyle(textDecoration = "bold", fgFill = "salmon"), 2:4, 2:4,gridExpand = F, stack = TRUE)

## STACk == TRUE
addWorksheet(wb, "Sheet 3")
writeData(wb, 3, matrix("abc", nrow = 4, ncol = 5))
addStyle(wb, 3, createStyle(halign = "center", border = "TopBottomLeftRight"), 1:5, 1:5, gridExpand = TRUE)
addStyle(wb, 3, createStyle(textDecoration = "bold", fgFill = "salmon"), 2:4, 2:4,gridExpand = F, stack = TRUE)



openXL(wb)

















## TEST NUMBER 2 - BUG REPORT #203

wb <- createWorkbook()
addWorksheet(wb, "Sheet 1")
writeData(wb, 1, head(iris))



## Make a red block
addStyle(wb, sheet = 1, style = createStyle(fgFill =  "red", textDecoration = "italic"), rows = c(2, 3, 4), cols = 2:5, gridExpand = TRUE, stack = TRUE)

## Draw a yellow L around it
addStyle(wb, sheet = 1, style = createStyle(fgFill = "yellow", textDecoration = "bold"), rows = c(1,2,3,4,5,5,5,5,5), cols = c(1,1,1,1,1,2,3,4,5), gridExpand = FALSE, stack = TRUE)
# addStyle(wb, sheet = 1, style = createStyle(fgFill = "yellow", textDecoration = "bold"), rows = 5, cols = 1:5, gridExpand = TRUE, stack = TRUE)


## Now borders and underlined around rows 1:3 for columns 1 and 5
addStyle(wb, sheet = 1, style = createStyle(border = "topbottomleftright", textDecoration = "underline"), rows = 1:3, cols = c(1, 5), gridExpand = TRUE, stack = TRUE)

## Now blue border only on top for rows 1:3, column 1
addStyle(wb, sheet = 1, style = createStyle(border = "top", borderColour = "blue"), rows = 1:3, cols = 1, gridExpand = TRUE, stack = TRUE)


## no stack! Wipe all formatting and put all black borders rows 1:4, col 3
addStyle(wb, sheet = 1, style = createStyle(border = "topbottomleftright"), rows = 1:4, cols = c(3,3,3,3))

## cell 3,3 red bottom border
addStyle(wb, sheet = 1, style = createStyle(border = "bottom", borderColour = "red"), rows = 2:10, cols = 3, gridExpand = TRUE, stack = TRUE)




## Now not stacking
addWorksheet(wb, "Sheet 2")
writeData(wb, 2, matrix("abc", nrow = 4, ncol = 5))
addStyle(wb, 2, createStyle(halign = "center", border = "TopBottomLeftRight"), 1:5, 1:5, gridExpand = TRUE)
addStyle(wb, 2, createStyle(textDecoration = "bold", fgFill = "salmon"), 2:4, 2:4,gridExpand = F, stack = TRUE)

## STACk == TRUE
addWorksheet(wb, "Sheet 3")
writeData(wb, 3, matrix("abc", nrow = 4, ncol = 5))
addStyle(wb, 3, createStyle(halign = "center", border = "TopBottomLeftRight"), 1:5, 1:5, gridExpand = TRUE)
addStyle(wb, 3, createStyle(textDecoration = "bold", fgFill = "salmon"), 2:4, 2:4,gridExpand = F, stack = TRUE)



openXL(wb)

















