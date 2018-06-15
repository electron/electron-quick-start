## PR 1271  detach("package:base") crashes R.
tools::assertError(detach("package:base"))


## invalid 'lib.loc'
stopifnot(length(installed.packages("mgcv")) == 0)
## gave a low-level error message


## package.skeleton() with metadata-only code
## work in current (= ./tests/ directory):
tmp <- tempfile()
writeLines(c('setClass("foo", contains="numeric")',
             'setMethod("show", "foo",',
             '          function(object) cat("I am a \\"foo\\"\\n"))'),
           tmp)
if(file.exists("myTst")) unlink("myTst", recursive=TRUE)
package.skeleton("myTst", code_files = tmp)# with a file name warning
file.copy(tmp, (tm2 <- paste(tmp,".R", sep="")))
unlink("myTst", recursive=TRUE)
op <- options(warn=2) # *NO* "invalid file name" warning {failed in 2.7.[01]}:
package.skeleton("myTst", code_files = tm2)
options(op)
##_2_ only a class, no generics/methods:
writeLines(c('setClass("DocLink",',
             'representation(name="character",',
             '               desc="character"))'), tmp)
if(file.exists("myTst2")) unlink("myTst2", recursive=TRUE)
package.skeleton("myTst2", code_files = tmp)
##- end_2_ # failed in R 2.11.0
stopifnot(1 == grep("setClass",
	  readLines(list.files("myTst/R", full.names=TRUE))),
	  c("foo-class.Rd","show-methods.Rd") %in% list.files("myTst/man"))
## failed for several reasons in R < 2.7.0
##
## Part 2: -- build, install, load and "inspect" the package:
build.pkg <- function(dir) {
    stopifnot(dir.exists(dir))
    patt <- paste(basename(dir), ".*tar\\.gz$", sep="_")
    unlink(dir('.', pattern = patt))
    Rcmd <- paste(file.path(R.home("bin"), "R"), "CMD")
    r <- tail(system(paste(Rcmd, "build --keep-empty-dirs", shQuote(dir)),
                     intern = TRUE), 3)
    ## return name of tar file built
    dir('.', pattern = patt)
}
build.pkg("myTst")
## clean up any previous attempt (which might have left a 00LOCK)
unlink("myLib", recursive = TRUE)
dir.create("myLib")
install.packages("myTst", lib = "myLib", repos=NULL, type = "source") # with warnings
print(installed.packages(lib.loc= "myLib", priority= "NA"))## (PR#13332)
stopifnot(require("myTst",lib = "myLib"))
sm <- findMethods(show, where= as.environment("package:myTst"))
stopifnot(names(sm@names) == "foo")
unlink("myTst_*")

## getPackageName()  for "package:foo":
require('methods')
library(tools)
oo <- options(warn=2)
detach("package:tools", unload=TRUE)
options(oo)
## gave warning (-> Error) about creating package name

## --- keep this at end --- so we do not need a large if(.) { .. }
## More building & installing packages
## NB: tests were added here for 2.11.0.
## NB^2: do not do this in the R sources (but in a build != src directory!)
## and this testdir is not installed.
if(interactive() && Sys.getenv("USER") == "maechler")
    Sys.setenv(SRCDIR = normalizePath("~/R/D/r-devel/R/tests"))
(pkgSrcPath <- file.path(Sys.getenv("SRCDIR"), "Pkgs"))# e.g., -> "../../R/tests/Pkgs"
if(!file_test("-d", pkgSrcPath) && !interactive()) {
    unlink("myTst", recursive=TRUE)
    print(proc.time())
    q("no")
}
## else w/o clause:

do.cleanup <- !nzchar(Sys.getenv("R_TESTS_NO_CLEAN"))
has.symlink <- (.Platform$OS.type != "windows")
## Installing "on to" a package existing as symlink in the lib.loc
## -- used to fail with misleading error message (#PR 16725):
if(has.symlink && dir.create("myLib_2") &&
   file.rename("myLib/myTst", "myLib_2/myTst") &&
   file.symlink("../myLib_2/myTst", "myLib/myTst"))
    install.packages("myTst", lib = "myLib", repos=NULL, type = "source")
## In R <= 3.3.2 gave error with *misleading* error message:
## ERROR: ‘myTst’ is not a legal package name


## file.copy(pkgSrcPath, tempdir(), recursive = TRUE) - not ok: replaces symlink by copy
system(paste('cp -R', shQuote(pkgSrcPath), shQuote(tempdir())))
pkgPath <- file.path(tempdir(), "Pkgs")
## pkgB tests an empty R directory
dir.create(file.path(pkgPath, "pkgB", "R"), recursive = TRUE,
	   showWarnings = FALSE)
p.lis <- if("Matrix" %in% row.names(installed.packages(.Library)))
	     c("pkgA", "pkgB", "exNSS4") else "exNSS4"
pkgApath <- file.path(pkgPath, "pkgA")
if("pkgA" %in% p.lis && !dir.exists(d <- pkgApath)) {
    cat("symlink 'pkgA' does not exist as directory ",d,"; copying it\n", sep='')
    file.copy(file.path(pkgPath, "xDir", "pkg"), to = d, recursive=TRUE)
    ## if even the copy failed (NB: pkgB depends on pkgA)
    if(!dir.exists(d)) p.lis <- p.lis[!(p.lis %in% c("pkgA", "pkgB"))]
}
for(p. in p.lis) {
    cat("building package", p., "...\n")
    r <- build.pkg(file.path(pkgPath, p.))
    cat("installing package", p., "using file", r, "...\n")
    ## we could install the tar file ... (see build.pkg()'s definition)
    install.packages(r, lib = "myLib", repos=NULL, type = "source")
    stopifnot(require(p.,lib = "myLib", character.only=TRUE))
    detach(pos = match(p., sub("^package:","", search())))
}
(res <- installed.packages(lib.loc = "myLib", priority = "NA"))
stopifnot(identical(res[,"Package"], setNames(,sort(c(p.lis, "myTst")))),
	  res[,"LibPath"] == "myLib")
### Specific Tests on our "special" packages: ------------------------------

## These used to fail because of the sym.link in pkgA
if("pkgA" %in% p.lis && dir.exists(pkgApath)) {
    cat("undoc(pkgA):\n"); print(uA <- tools::undoc(dir = pkgApath))
    cat("codoc(pkgA):\n"); print(cA <- tools::codoc(dir = pkgApath))
    stopifnot(identical(uA$`code objects`, c("nil", "search")),
              identical(uA$`data sets`,    "nilData"))
}

## - Check conflict message.
## - Find objects which are NULL via "::" -- not to be expected often
##   we have one in our pkgA, but only if Matrix is present.
if(dir.exists(file.path("myLib", "pkgA"))) {
  msgs <- capture.output(require(pkgA, lib="myLib"), type = "message")
  writeLines(msgs)
  stopifnot(length(msgs) > 2,
            length(grep("The following object is masked.*package:base", msgs)) > 0,
            length(grep("\\bsearch\\b", msgs)) > 0)
  data(package = "pkgA") # -> nilData
  stopifnot(is.null( pkgA::  nil),
	    is.null( pkgA::: nil),
	    is.null( pkgA::  nilData)) # <-
  ## R-devel (pre 3.2.0) wrongly errored for NULL lazy data
  ## ::: does not apply to data sets:
  tools::assertError(is.null(pkgA:::nilData))
}

## tests here should *NOT* assume recommended packages,
## let alone where they are installed
if(dir.exists(file.path("myLib", "exNSS4")) &&
   dir.exists(file.path(.Library, "Matrix"))) {
    for(ns in c(rev(p.lis), "Matrix")) unloadNamespace(ns)
    ## Both exNSS4 and Matrix define "atomicVector" *the same*,
    ## but  'exNSS4'  has it extended - and hence *both* are registered in cache -> "conflicts"
    requireNamespace("exNSS4", lib= "myLib")
    ## Found in cache, since there is only one definition.
    ## Might confuse users.
    stopifnot(isVirtualClass(getClass("atomicVector")))
    requireNamespace("Matrix", lib= .Library)
    ## Throws an error, because there is ambiguity in the cache,
    ## and the dynamic search will not find anything, since the packages
    ## are not attached.
    tools::assertCondition(
        acl <- getClass("atomicVector")
        )
    ## Once Matrix is attached, we find a unique definition.
    library(Matrix)
    stopifnot(isVirtualClass(getClass("atomicVector")))
}

## clean up
rmL <- c("myLib", if(has.symlink) "myLib_2", "myTst", file.path(pkgPath))
if(do.cleanup) {
    for(nm in rmL) unlink(nm, recursive = TRUE)
} else {
    cat("Not cleaning, i.e., keeping ", paste(rmL, collapse=", "), "\n")
}

proc.time()
