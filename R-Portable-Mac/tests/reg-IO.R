## NB: this file must be a DOS (CRLF) format file

## Keep comments and original formatting
options(keep.source=TRUE)

## simple tests that multiple lines are read correctly
print(2+3)
print(4+5)

## generate some files to source

z <- c("# line 1", "2+3", "ls()", "pi", "# last line")

## ========  LF file
cat(z, file="testIO.R", sep="\n")
readLines("testIO.R")
source("testIO.R", echo=TRUE)
unlink("testIO.R")

## ======== LF file, incomplete final line
zz <- file("testIO.R", "wt")
cat(z, file=zz, sep="\n")
cat("5+6", file=zz)
close(zz)
readLines("testIO.R")
source("testIO.R", echo=TRUE)
unlink("testIO.R")

## ======== CRLF file
cat(z, file="testIO.R", sep="\r\n")
source("testIO.R", echo=TRUE)
readLines("testIO.R")
unlink("testIO.R")

## ======== CRLF file, incomplete final line
zz <- file("testIO.R", "wt")
cat(z, file=zz, sep="\r\n")
cat("5+6", file=zz)
close(zz)
readLines("testIO.R")
source("testIO.R", echo=TRUE)
unlink("testIO.R")

## ======== CR file
cat(z, file="testIO.R", sep="\r")
readLines("testIO.R")
source("testIO.R", echo=TRUE)
unlink("testIO.R")

## ======== CR file, incomplete final line
zz <- file("testIO.R", "wt")
cat(z, file=zz, sep="\r")
cat("\r5+6", file=zz)
close(zz)
readLines("testIO.R")
source("testIO.R", echo=TRUE)
unlink("testIO.R")

## end of reg-IO.R: the next line has no EOL chars
2 + 2
