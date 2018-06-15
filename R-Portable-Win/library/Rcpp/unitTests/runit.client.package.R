#!/usr/bin/env r
#
# Copyright (C) 2010 - 2014  Dirk Eddelbuettel and Romain Francois
#
# This file is part of Rcpp.
#
# Rcpp is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Rcpp is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rcpp.  If not, see <http://www.gnu.org/licenses/>.

## This now (Dec 2011) appears to fail on Windows
.onWindows <- .Platform$OS.type == "windows"

.runThisTest <- Sys.getenv("RunAllRcppTests") == "yes"

.client.package <- function(pkg = "testRcppPackage") {
    td <- tempfile()
    cwd <- getwd()
    dir.create(td)
    file.copy(system.file("unitTests", pkg, package = "Rcpp"), td, recursive = TRUE)
    setwd(td)
    on.exit( { setwd(cwd); unlink(td, recursive = TRUE) } )
    R <- shQuote(file.path( R.home(component = "bin"), "R"))
    cmd <- paste(R, "CMD build", pkg)
    system(cmd)
    dir.create("templib")
    install.packages(paste0(pkg, "_0.1.0.tar.gz"), "templib", repos = NULL, type = "source")
    require(pkg, lib.loc = "templib", character.only = TRUE)
    hello_world <- get("rcpp_hello_world", asNamespace(pkg))
    checkEquals(hello_world(), list(c("foo", "bar"), c(0.0, 1.0)),
                msg = "code from client package")

    checkException(.Call("hello_world_ex", PACKAGE = pkg), msg = "exception in client package")
}

if (.runThisTest && ! .onWindows) {
    test.client.testRcppPackage <- function() {
        .client.package("testRcppPackage")
    }
}
