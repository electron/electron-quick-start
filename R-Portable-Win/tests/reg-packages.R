.R_LIBS <- function(libp = .libPaths()) { # (>> in utils?)
    libp <- libp[! libp %in% .Library]
    if(length(libp))
        paste(libp, collapse = .Platform$path.sep)
    else "" # character(0) is invalid for Sys.setenv()
}
Sys.setenv(R_LIBS = .R_LIBS() # for build.pkg() & install.packages()
         , R_BUILD_ENVIRON = "nothing" # avoid ~/.R/build.environ which might set R_LIBS
         , R_ENVIRON = "none"
         , R_PROFILE = "none"
           )

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
    stopifnot(dir.exists(dir), file.exists(DESC <- file.path(dir, "DESCRIPTION")))
    pkgName <- sub("^[A-Za-z]+: ", "", grep("^Package: ", readLines(DESC), value=TRUE))
    patt <- paste(pkgName, ".*tar\\.gz$", sep="_")
    unlink(dir('.', pattern = patt))
    Rcmd <- paste(shQuote(file.path(R.home("bin"), "R")), "CMD")
    r <- system(paste(Rcmd, "build --keep-empty-dirs", shQuote(dir)),
                intern = TRUE)
    ## return name of tar file built
    structure(dir('.', pattern = patt), log3 = r)
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
isWIN <- .Platform$OS.type == "windows"
has.symlink <- !isWIN
## Installing "on to" a package existing as symlink in the lib.loc
## -- used to fail with misleading error message (#PR 16725):

if(has.symlink && !unlink("myLib_2", recursive=TRUE) && dir.create("myLib_2") &&
   file.rename("myLib/myTst", "myLib_2/myTst") &&
   file.symlink("../myLib_2/myTst", "myLib/myTst"))
    install.packages("myTst", lib = "myLib", repos=NULL, type = "source")
## In R <= 3.3.2 gave error with *misleading* error message:
## ERROR: ‘myTst’ is not a legal package name

if(isWIN) { # (has no symlinks anyway)
    file.copy(pkgSrcPath, tempdir(), recursive = TRUE)
} else { # above file.copy() not useful as it replaces symlink by copy
    system(paste('cp -R', shQuote(pkgSrcPath), shQuote(tempdir())))
}
pkgPath <- file.path(tempdir(), "Pkgs")
if(!dir.exists(pkgPath))  {
    message("No valid 'pkgPath' (from 'pkgSrcPath') - exit this test")
    if(!interactive()) q("no")
}

## pkgB tests an empty R directory
dir.create(file.path(pkgPath, "pkgB", "R"), recursive = TRUE,
	   showWarnings = FALSE)
p.lis <- c(if("Matrix" %in% row.names(installed.packages(.Library)))
               c("pkgA", "pkgB", "pkgC"),
           "exNSS4", "exSexpr")
InstOpts <- list("exSexpr" = "--html")
pkgApath <- file.path(pkgPath, "pkgA")
if("pkgA" %in% p.lis && !dir.exists(d <- pkgApath)) {
    cat("symlink 'pkgA' does not exist as directory ",d,"; copying it\n", sep='')
    file.copy(file.path(pkgPath, "xDir", "pkg"), to = d, recursive=TRUE)
    ## if even the copy failed (NB: pkgB, pkgC depend on pkgA)
    if(!dir.exists(d)) p.lis <- p.lis[!(p.lis %in% c("pkgA", "pkgB", "pkgC"))]
}
dir2pkg <- function(dir) ifelse(dir == "pkgC", "PkgC", dir)
if(is.na(match("myLib", .lP <- .libPaths()))) {
    .libPaths(c("myLib", .lP)) # PkgC needs pkgA from there
    .lP <- .libPaths()
}
Sys.setenv(R_LIBS = .R_LIBS(.lP)) # for build.pkg() & install.packages()
for(p in p.lis) {
    p. <- dir2pkg(p) # 'p' is sub directory name;  'p.' is package name
    cat("building package", p., "...\n")
    r <- build.pkg(file.path(pkgPath, p))
    if(!length(r)) # so some sort of failure, show log
        cat(attr(r, "log3"), sep = "\n")
    if(!isTRUE(file.exists(r)))
        stop("R CMD build failed (no tarball) for package ", p)
    ## otherwise install the tar file:
    cat("installing package", p., "using built file", r, "...\n")
    ## "FIXME": want to catch warnings in the "console output" of this:
    install.packages(r, lib = "myLib", repos=NULL, type = "source",
                     INSTALL_opts = InstOpts[[p.]])
    stopifnot(require(p., lib = "myLib", character.only=TRUE))
    detach(pos = match(p., sub("^package:","", search())))
}
(res <- installed.packages(lib.loc = "myLib", priority = "NA"))
(p.lis <- dir2pkg(p.lis)) # so from now, it contains package names
stopifnot(exprs = {
    identical(res[,"Package"], setNames(, sort(c(p.lis, "myTst"))))
    res[,"LibPath"] == "myLib"
})
### Specific Tests on our "special" packages: ------------------------------

## These used to fail because of the sym.link in pkgA
if("pkgA" %in% p.lis && dir.exists(pkgApath)) {
    cat("undoc(pkgA):\n"); print(uA <- tools::undoc(dir = pkgApath))
    cat("codoc(pkgA):\n"); print(cA <- tools::codoc(dir = pkgApath))
    cat("extends(\"classApp\"):\n"); print(ext.cA <- extends("classApp"))
    stopifnot(exprs = {
	identical(uA$`code objects`, c("nil", "search"))
	identical(uA$`data sets`,    "nilData")
	## pkgC's class union is now (after loading pkgC) also visible in the "classApp" subclass
	## (which gave warning). ==> warning "wrong": somehow it *did* get updated:
	"numericA" %in% ext.cA
    })
} else message("'pkgA' not available")

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
} else message("'pkgA' not in 'myLib'")

## Check error from invalid logical field in DESCRIPTION:
(okA <- dir.exists(pkgApath) &&
     file.exists(DN <- file.path(pkgApath, "DESCRIPTION")))
if(okA) {
  Dlns <- readLines(DN); i <- grep("^LazyData:", Dlns)
  Dlns[i] <- paste0(Dlns[i], ",") ## adding a ","
  writeLines(Dlns, con = DN)
  instEXPR <- quote(
      tools:::.install_packages(c("--clean", "--library=myLib", pkgApath), no.q = TRUE)
  )   ##      -----------------                                 ----
  if(interactive()) { ## << "FIXME!"  This (sink(.) ..) fails, when run via 'make'.
    ## install.packages() should give "the correct" error but we cannot catch it
    ## One level lower is not much better, needing sink() as capture.output() fails
    ftf <- file(tf <- tempfile("inst_pkg"), open = "wt")
    sink(ftf); sink(ftf, type = "message")# "message" should be sufficient
    eval(instEXPR)
    sink(type="message"); sink()## ; close(ftf); rm(ftf)# end sink()
    writeLines(paste(" ", msgs <- readLines(tf)))
    message(err <- grep("^ERROR:", msgs, value=TRUE))
    stopifnot(exprs = {
        length(err) > 0
        grepl("invalid .*LazyData .*DESCRIPTION", err)
    })
  } else {
      message("non-interactive -- tools:::.install_packages(..) : ")
      try( eval(instEXPR) ) # showing the error message in the *.Rout file
  }
} else message("pkgA/DESCRIPTION  not available")

## R CMD check should *not* warn about \Sexpr{} built sections in Rd (PR#17479):
msg <- capture.output(
    tools:::.check_package_parseRd(dir=file.path(pkgPath, "exSexpr")))
if(length(msg))
    stop(".check_package_parseRd() gave message\n",msg)
## in R <= 3.5.1, gave
##  "prepare_Rd: foo.Rd:14: Section \\Sexpr is unrecognized and will be dropped"


if(dir.exists(file.path("myLib", "exNSS4"))) {
  require("exNSS4", lib="myLib")
  validObject(dd <- new("ddiM"))
  print(is(dd))  #  5 of them ..
  stopifnot(exprs = {
            is(dd, "mM")
      inherits(dd, "mM")
  })
  ## tests here should *NOT* assume recommended packages,
  ## let alone where they are installed
  if(dir.exists(file.path(.Library, "Matrix"))) {
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
}

## clean up
rmL <- c("myLib", if(has.symlink) "myLib_2", "myTst", file.path(pkgPath))
if(do.cleanup) {
    for(nm in rmL) unlink(nm, recursive = TRUE)
} else {
    cat("Not cleaning, i.e., keeping ", paste(rmL, collapse=", "), "\n")
}

proc.time()
