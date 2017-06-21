#  File src/library/utils/tests/Sweave-tst.R
#  Part of the R package, https://www.R-project.org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

## Testing Sweave

.proctime00 <- proc.time()
library(utils)
options(digits = 5) # to avoid trivial printed differences
options(show.signif.stars = FALSE) # avoid fancy quotes in o/p

SweaveTeX <- function(file, ...) {
    if(!file.exists(file))
        stop("File", file, "does not exist in", getwd())
    texF <- sub("\\.[RSrs]nw$", ".tex", file)
    Sweave(file, ...)
    if(!file.exists(texF))
        stop("File", texF, "does not exist in", getwd())
    readLines(texF)
}

p0 <- paste0
latexEnv <- function(lines, name) {
    stopifnot(is.character(lines), is.character(name),
	      length(lines) >= 2, length(name) == 1)
    beg <- p0("\\begin{",name,"}")
    end <- p0("\\end{",name,"}")
    i <- grep(beg, lines, fixed=TRUE)
    j <- grep(end, lines, fixed=TRUE)
    if((n <- length(i)) != length(j))
	stop(sprintf("different number of %s / %s", beg,end))
    if(any(j-1 < i+1))
	stop(sprintf("positionally mismatched %s / %s", beg,end))
    lapply(mapply(seq, i+1,j-1, SIMPLIFY=FALSE),
	   function(ind) lines[ind])
}

## now, Sweave() and check  *.Rnw  examples :

### ------------------------------------ 1 ----------------------------------
t1 <- SweaveTeX("swv-keepSrc-1.Rnw")
if(FALSE)## look at it
writeLines(t1)

inp <- latexEnv(t1, "Sinput")
out <- latexEnv(t1, "Soutput")
## This may have to be updated when the *.Rnw changes:
stopifnot(length(inp) == 5,
	  grepl("#", inp[[2]]), length(inp[[3]]) == 1,
	  length(out) == 1,
	  any(grepl("\\includegraphics", t1)))

### ------------------------------------ 2 ----------------------------------
## Sweave() comments with  keep.source=TRUE
t2 <- SweaveTeX("keepsource.Rnw")
comml <- grep("##", t2, value=TRUE)
stopifnot(length(comml) == 2,
	  grepl("initial comment line", comml[1]),
	  grepl("last comment", comml[2]))
## the first was lost in 2.12.0;  the last in most/all previous versions of R

### ------------------------------------ 3 ----------------------------------
## custom graphics devices
Sweave("customgraphics.Rnw")

### ------------------------------------ 4 ----------------------------------
## SweaveOpts + \Sexpr --> \verb... output
Sweave(f <- "Sexpr-verb-ex.Rnw")
tools::texi2pdf(sub("Rnw$","tex", f))# used to fail


cat('Time elapsed: ', proc.time() - .proctime00,'\n')
