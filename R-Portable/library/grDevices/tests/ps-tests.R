## tests of the fonts in the postscript() device.

testit <- function(family, encoding="default")
{ 
    postscript("ps-tests.ps", height=7, width=7, family=family,
               encoding=encoding)
    plot(1:10, type="n")
    text(5, 9, "Some text")
    text(5, 8 , expression(italic("italic")))
    text(5, 7 , expression(bold("bold")))
    text(5, 6 , expression(bolditalic("bold & italic")))
    text(8, 3, expression(paste(frac(1, sigma*sqrt(2*pi)), " ",
        plain(e)^{frac(-(x-mu)^2, 2*sigma^2)})))
    dev.off()
}

testit("Helvetica")
testit("AvantGarde")
testit("Bookman")
testit("Courier")
testit("Helvetica-Narrow")
testit("NewCenturySchoolbook")
testit("Palatino")
testit("Times")

testit("URWGothic")
testit("URWBookman")
testit("NimbusMon")
testit("NimbusSan")
testit("NimbusSanCond")
testit("CenturySch")
testit("URWPalladio")
testit("NimbusRom")
testit("URWHelvetica")
testit("URWTimes")

testit("ComputerModern", "TeXtext.enc")

unlink("ps-tests.ps")
