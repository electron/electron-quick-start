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

electric.s  <- read.spss("electric.sav",TRUE,TRUE)
electric.p  <- read.spss("electric.por",TRUE,TRUE)
electric.s4 <- read.spss("electric.sav",TRUE,TRUE,max.value.labels = 4)
summary(electric.s)
ii <- c(2,10)
vl <- list(FIRSTCHD = c("OTHER   CHD"= 6, "FATAL   MI"= 5, "NONFATALMI"= 3,
			"SUDDEN  DEATH" = 2, "NO CHD" = 1),
	   DAYOFWK = c(SATURDAY=7, FRIDAY=6, THURSDAY=5,
		       WEDNSDAY=4, TUESDAY=3, MONDAY=2, SUNDAY=1))
stopifnot(identical(electric.s,	     electric.p),
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
