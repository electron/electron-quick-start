library(foreign)

sample100 <- read.spss("sample100.sav",FALSE)
summary(sample100)
str(sample100)
d.sample100 <- data.frame(sample100)
summary(d.sample100)
s100 <- sample100
sample100 <- read.spss("sample100.por",FALSE)
stopifnot(identical(s100, sample100)) # no need for further summary() etc

pbc <- read.spss("pbc.sav",FALSE)
summary(pbc)
str(pbc)
d.pbc <- data.frame(pbc)
summary(d.pbc)
pbco <- read.spss("pbcold.sav",FALSE)
stopifnot(identical(pbc, pbco))
## summary(pbco)
## str(pbco)
## d.pbco <- data.frame(pbco)
## summary(d.pbco)
pbc. <- read.spss("pbc.por",FALSE)
summary(pbc.)
str(pbc.) # has variable.labels
stopifnot(all.equal(d.pbc, data.frame(pbc.), tolerance = 1e-15))

electric.s  <- read.spss(system.file("files", "electric.sav", package = "foreign"), TRUE, TRUE)
electric.p  <- read.spss("electric.por",TRUE,TRUE)
electric.s4 <- read.spss(system.file("files", "electric.sav", package = "foreign"), TRUE, TRUE, max.value.labels = 4)
summary(electric.s)
ii <- c(2,10)
vl <- list(FIRSTCHD = c("OTHER   CHD"= 6, "FATAL   MI"= 5, "NONFATALMI"= 3,
            "SUDDEN  DEATH" = 2, "NO CHD" = 1),
       DAYOFWK = c(SATURDAY=7, FRIDAY=6, THURSDAY=5,
               WEDNSDAY=4, TUESDAY=3, MONDAY=2, SUNDAY=1))
stopifnot(identical(electric.s,      electric.p),
      identical(electric.s[-ii], electric.s4[-ii]),
      identical(vl, lapply(electric.s4[ii], attr, "value.labels")),
      identical(lapply(vl, names),
            lapply(electric.s[ii], function(.) rev(levels(.)))))


## after "long label patch":

invisible(Sys.setlocale (locale="C")) ## to resolve locale problem
ldat <- read.spss("spss_long.sav", to.data.frame=TRUE)
ldat
nnms <- nms <- names(ldat)
names(nnms) <- nms
stopifnot(identical(nms,  c("variable1", "variable2")),
      identical(nnms, attr(ldat, "variable.labels")))


## some new arkward testcases for problems found in foreign <= 0.8-68 and duplicated value labels in general:

## Expect lots of warnings as value labels (corresponding to R factor labels) are uncomplete, 
## and an unsupported long string variable is present in the data

setwd(system.file("files", package = "foreign"))
sav <- "testdata.sav"

x.nodat <- read.spss(file=sav, to.data.frame = FALSE, reencode="UTF-8")
str(x.nodat)

x.sort <- read.spss(file=sav, to.data.frame = TRUE, reencode="UTF-8")
str(x.sort)
x.append <- read.spss(file=sav, to.data.frame = TRUE, 
    add.undeclared.levels = "append", reencode="UTF-8")
x.no <- read.spss(file=sav, to.data.frame = TRUE, 
    add.undeclared.levels = "no", reencode="UTF-8")

levels(x.sort$factor_n_undeclared)
levels(x.append$factor_n_undeclared)
str(x.no$factor_n_undeclared)


### Examples for duplicated.value.labels:
## duplicated.value.labels = "append" (default)
x.append <- read.spss(file=sav, to.data.frame=TRUE, reencode="UTF-8")
## duplicated.value.labels = "condense"
x.condense <- read.spss(file=sav, to.data.frame=TRUE, 
    duplicated.value.labels = "condense", reencode="UTF-8")

levels(x.append$factor_n_duplicated)
levels(x.condense$factor_n_duplicated)

as.numeric(x.append$factor_n_duplicated)
as.numeric(x.condense$factor_n_duplicated)

### ToDo:    
## Long Strings (>255 chars) are imported in consecutive separate variables 
## (see warning about subtype 14)
## we should get that right in the import function in future versions
x <- read.spss(file=sav, to.data.frame=TRUE, stringsAsFactors=FALSE, reencode="UTF-8")

cat.long.string <- function(x, w=70) cat(paste(strwrap(x, width=w), "\n"))

## first part: x$string_500:
cat.long.string(x$string_500)
## second part: x$STRIN0:
cat.long.string(x$STRIN0)
## complete long string:
long.string <- apply(x[,c("string_500", "STRIN0")], 1, paste, collapse="")
cat.long.string(long.string)
