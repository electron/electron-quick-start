## For examples skipped in testing because they are 'random'

set.seed(1)
if(.Platform$OS.type == "windows") options(pager = "console")

pdf("reg-examples-1.pdf", encoding = "ISOLatin1.enc")


## base
example(Cstack_info, run.donttest = TRUE)
example(DateTimeClasses, run.donttest = TRUE)
example(Dates, run.donttest = TRUE)
example(Ops.Date, run.donttest = TRUE)
example(Random, run.donttest = TRUE)
example(Sys.getpid, run.donttest = TRUE)
example(Sys.sleep, run.donttest = TRUE)
example(Sys.time, run.donttest = TRUE)
example(as.POSIXlt, run.donttest = TRUE)
example(difftime, run.donttest = TRUE)
example(format.Date, run.donttest = TRUE)
example(Reduce, run.donttest = TRUE) # funprog.Rd
example(gc, run.donttest = TRUE)
example(memory.profile, run.donttest = TRUE)
paste("Today is", date()) # from paste.Rd
trunc(Sys.time(), "day") # from round.POSIXt.Rd
example(srcref, run.donttest = TRUE)
example(strptime, run.donttest = TRUE)
example(sys.parent, run.donttest = TRUE)
example(system.time, run.donttest = TRUE)
example(tempfile, run.donttest = TRUE)
example(weekdays, run.donttest = TRUE)
library(help = "splines")

## for example(NA)
if(require("microbenchmark")) {
  x <- c(NaN, 1:10000)
  print(microbenchmark(any(is.na(x)), anyNA(x)))
} else { ## much less accurate
  x <- c(NaN, 1e6)
  nSim <- 2^13
  print(rbind(is.na = system.time(replicate(nSim, any(is.na(x)))),
              anyNA = system.time(replicate(nSim, anyNA(x)))))
}

## utils
example(news, run.donttest = TRUE)
example(sessionInfo, run.donttest = TRUE)

## datasets
example(JohnsonJohnson, run.donttest = TRUE)
example(ability.cov, run.donttest = TRUE)
example(npk, run.donttest = TRUE)

## grDevices
example(grSoftVersion, run.donttest = TRUE)
if(.Platform$OS.type == "windows") {
    example(windowsFonts, run.donttest = TRUE)
} else {
    example(X11Fonts, run.donttest = TRUE)
    example(quartzFonts, run.donttest = TRUE)
}

library(tools)
example(Rdutils, run.donttest = TRUE)
example(fileutils, run.donttest = TRUE)
example(makevars_user, run.donttest = TRUE)
## results are location- and OS-specific
example(parseLatex, run.donttest = TRUE) # charset-specific
example(loadRdMacros, run.donttest = TRUE) # collation-specific

## part of example(buildVignettes) at one time
gVigns <- pkgVignettes("grid")
str(gVigns) # contains paths

vind <- system.file(package = "grid", "doc", "index.html")
if(nzchar(vind)) { # so vignettes have been installed
    `%=f=%` <- function(a, b) normalizePath(a) == normalizePath(b)
    with(gVigns,
         stopifnot(engines == "utils::Sweave",
                   pkgdir %=f=% system.file(package="grid"),
                   dir    %=f=% system.file(package = "grid", "doc"),
                   (n. <- length(docs)) >= 12, # have 13
                   n. == length(names), n. == length(engines),
                   length(msg) == 0) ) # as it is a 'base' package
    stopifnot("grid" %in% gVigns$names, inherits(gVigns, "pkgVignettes"))
}

## This might leave collation changed, so do not put other things after it.
example(icuSetCollate, run.donttest = TRUE)
proc.time()
