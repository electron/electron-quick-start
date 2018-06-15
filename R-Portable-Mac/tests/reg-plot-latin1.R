pdf(file = "reg-plot-latin1.pdf", encoding = "ISOLatin1",
    width = 7, height = 7, paper = "a4r", compress = FALSE)
library(graphics) # to be sure
example(text)     # has examples that need to he plotted in latin-1
q("no")
