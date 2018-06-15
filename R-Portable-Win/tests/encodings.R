## from iconv.Rd
(x <- "fa\xE7ile")
charToRaw(xx <- iconv(x, "latin1", "UTF-8"))

iconv(x, "latin1", "ASCII")          #   NA
iconv(x, "latin1", "ASCII", "?")     # "fa?ile"
iconv(x, "latin1", "ASCII", "")      # "faile"
iconv(x, "latin1", "ASCII", "byte")  # "fa<e7>ile"

# Extracts from R help files
(x <- c("Ekstr\xf8m", "J\xf6reskog", "bi\xdfchen Z\xfcrcher"))
iconv(x, "latin1", "ASCII//TRANSLIT")
iconv(x, "latin1", "ASCII", sub="byte")

## tests of re-encoding in .C
require("tools")
x <- "fa\xE7ile"
.C("Renctest", x, PACKAGE="tools")[[1]]
.C("Renctest", x, PACKAGE="tools", ENCODING="latin1")[[1]]
xx <- iconv(x, "latin1", "UTF-8")
.C("Renctest", xx, PACKAGE="tools", ENCODING="UTF-8")[[1]]

## tests of match length in delimMatch
x <- c("a{bc}d", "{a\xE7b}")
delimMatch(x)
xx <- iconv(x, "latin1", "UTF-8")
delimMatch(xx) ## 5 6 in latin1, 5 5 in UTF-8
