## These are tests that require libcurl functionality and a working
## Internet connection.

## As from R 3.4.0 method = "libcurl" is the default on a Unix-alike
## so this is in small part duplication -- but not on Windows.

if(!capabilities()["libcurl"]) {
    warning("no libcurl support")
    q()
}

if(.Platform$OS.type == "unix" &&
   is.null(nsl("cran.r-project.org"))) q()

example(curlGetHeaders, run.donttest = TRUE)

tf <- tempfile()
download.file("http://cran.r-project.org/", tf,  method = "libcurl")
file.size(tf)
unlink(tf)

tf <- tempfile()
download.file("ftp://ftp.stats.ox.ac.uk/pub/datasets/csb/ch11b.dat",
              tf,  method = "libcurl")
file.size(tf) # 2102
unlink(tf)


## test url connections on http
str(readLines(zz <- url("http://cran.r-project.org/", method = "libcurl")))
zz
stopifnot(identical(summary(zz)$class, "url-libcurl"))
close(zz)

## https URL
head(readLines(zz <- url("https://httpbin.org", method = "libcurl"),
               warn = FALSE))
close(zz)

## redirection (to a https:// URL)
head(readLines(zz <- url("http://bugs.r-project.org", method = "libcurl"),
               warn = FALSE))
close(zz)


## check graceful failure: warnings leading to error
## testUnknownUrlError <- tryCatch(suppressWarnings({
##     zz <- url("http://foo.bar", "r", method = "libcurl")
## }), error=function(e) {
##     conditionMessage(e) == "cannot open connection"
## })
## close(zz)
## stopifnot(testUnknownUrlError)

## tf <- tempfile()
## testDownloadFileError <- tryCatch(suppressWarnings({
##     download.file("http://foo.bar", tf, method="libcurl")
## }), error=function(e) {
##     conditionMessage(e) == "cannot download all files"
## })
## stopifnot(testDownloadFileError, !file.exists(tf))

tf <- tempfile()
testDownloadFile404 <- tryCatch(suppressWarnings({
    download.file("http://httpbin.org/status/404", tf, method="libcurl")
}), error=function(e) {
    conditionMessage(e) == "cannot open URL 'http://httpbin.org/status/404'"
})
stopifnot(testDownloadFile404, !file.exists(tf))

## check specific warnings
## testUnknownUrl <- tryCatch({
##     zz <- url("http://foo.bar", "r", method = "libcurl")
## }, warning=function(e) {
##     grepl("Couldn't resolve host name", conditionMessage(e))
## })
## close(zz)
## stopifnot(testUnknownUrl)

test404.1 <- tryCatch({
    open(zz <- url("http://httpbin.org/status/404", method="libcurl"))
}, warning=function(w) {
    grepl("404 Not Found", conditionMessage(w))
})
close(zz)
stopifnot(test404.1)

##  via read.table (which closes the connection)
tail(read.table(url("http://www.stats.ox.ac.uk/pub/datasets/csb/ch11b.dat",
                    method = "libcurl")))
tail(read.table(url("ftp://ftp.stats.ox.ac.uk/pub/datasets/csb/ch11b.dat",
                    method = "libcurl")))

## check option works
options(url.method = "libcurl")
zz <- url("http://www.stats.ox.ac.uk/pub/datasets/csb/ch11b.dat")
stopifnot(identical(summary(zz)$class, "url-libcurl"))
close(zz)
head(readLines("https://httpbin.org", warn = FALSE))

test404.2 <- tryCatch({
    open(zz <- url("http://httpbin.org/status/404"))
}, warning = function(w) {
    grepl("404 Not Found", conditionMessage(w))
})
close(zz)
stopifnot(test404.2)

showConnections(all = TRUE)
