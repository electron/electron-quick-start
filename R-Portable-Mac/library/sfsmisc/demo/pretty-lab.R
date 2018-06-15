## Original from David Seifert (ETHZ Basel, c/o Beerenwinkel)
## https://github.com/mmaechler/sfsmisc/pull/2

### Example showing how  eaxis() / pretty10exp()   lab.type = "latex"
### can be used together  with LaTeX package "tikz" and
stopifnot(require("tikzDevice"))
### to produce LaTeX math labels
require("sfsmisc")

x <- (-3:10) * 10^10
y <-  abs(x / 1e9)

(t.file <- tempfile("tikz-eaxis", fileext = ".tex"))
tikz(file = t.file, standAlone=TRUE)
plot(x, y, axes=FALSE, type = "b")
eaxis(1, at=x, lab.type="latex")
eaxis(2,       lab.type="latex")
dev.off()# i.e. finish and close file 't.file'

## Now add two lines to (the preamble of the latex file
## such that all axis tick labels are in latex math if requested by lab.type="latex".
##   {Note : "\" (backslash) must be doubled in R strings}
helvet.lns <- c("\\renewcommand{\\familydefault}{\\sfdefault}",
                "\\usepackage{helvet}")
str(ll <- readLines(t.file))
writeLines(c(ll[1:4], "", "%% Added from R (pkg 'sfsmisc', demo 'pretty-lab'):",
             helvet.lns, "", ll[-(1:5)]), t.file)

## Produce PDF from LaTeX
system(paste(paste0("pdflatex -output-directory=", dirname(t.file)),
             t.file))

## and view it
if(file.exists(p.file <- sub("tex$", "pdf", t.file)) && interactive())
    system(paste(getOption("pdfviewer"), p.file),  wait=FALSE)
