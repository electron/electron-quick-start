#  File share/R/REMOVE.R
#  Part of the R package, http://www.R-project.org
#
#  Copyright (C) 1995-2012 The R Core Team
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
#  http://www.r-project.org/Licenses/

Usage <- function() {
    cat("Usage: R CMD REMOVE [options] pkgs",
        "",
        "Remove the add-on packages specified by pkgs.  The library tree to",
        "remove from can be specified via '--library'.  By default, packages are",
        "removed from the library tree rooted at the first directory in",
        ".libPaths() for an R session run in the current environment.",
        "",
        "Options:",
        "  -h, --help		print short help message and exit",
        "  -v, --version		print REMOVE version info and exit",
        "  -l, --library=LIB	remove packages from library tree LIB",
        "",
        "Report bugs at <https://bugs.R-project.org>.", sep="\n")
}

options(showErrorCalls=FALSE)
pkgs <- character(0)
lib <- ""
args <- commandArgs(TRUE)
while(length(args)) {
    a <- args[1]
    if(a %in% c("-h", "--help")) {
        Usage()
        q("no")
    }
    else if(a %in% c("-v", "--version")) {
        cat("R add-on package remover: ",
            R.version[["major"]], ".",  R.version[["minor"]],
            " (r", R.version[["svn rev"]], ")\n", sep = "")
        cat("",
            "Copyright (C) 2000-2009 The R Core Team.",
            "This is free software; see the GNU General Public License version 2",
            "or later for copying conditions.  There is NO warranty.",
            sep="\n")
        q("no")
    }
    else if(a == "-l") {
        if(length(args) >= 2) {lib <- args[2]; args <- args[-1]}
        else stop("-l option without value", call. = FALSE)
    } else if(substr(a, 1, 10) == "--library=")
        lib <- substr(a, 11, 1000)
    else pkgs <- c(pkgs, a)
    args <- args[-1]
}
if(!length(pkgs))
    stop("ERROR: no packages specified", call.=FALSE)
if(!nzchar(lib)) {
    lib <- .libPaths()[1]
    message("Removing from library ", sQuote(lib))
} else {
    ## lib is allowed to be a relative path.
    ## should be OK below, but be sure.
    cwd <- try(setwd(path.expand(lib)), silent = TRUE)
    if(inherits(cwd, "try-error"))
        stop("ERROR: cannot cd to directory ", sQuote(lib), call. = FALSE)
    lib <- getwd()
    setwd(cwd)
}
if(!utils::file_test("-d", lib) || file.access(lib, 2L))
    stop("ERROR: no permission to remove from directory ", sQuote(lib),
         call. = FALSE)
utils::remove.packages(pkgs, lib)
q("no")
