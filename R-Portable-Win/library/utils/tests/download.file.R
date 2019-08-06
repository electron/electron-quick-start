
## Tests for HTTP headers -----------------------------------------------

is_online <- function() {
  tryCatch({
    con <- suppressWarnings(socketConnection("8.8.8.8", port = 53))
    close(con)
    con <- url("http://eu.httpbin.org/headers")
    lines <- readLines(con)
    close(con)
    stopifnot(any(grepl("Host.*eu.httpbin.org", lines)))
    TRUE
  }, error = function(e) FALSE)
}

get_headers <- function(path = "anything", quiet = TRUE, ...,
                        protocol = "http") {
  url <- get_path(path, protocol)
  tmp <-  tempfile()
  on.exit(try(unlink(tmp)), add = TRUE)
  download.file(url, tmp, quiet = quiet, ...)
  readLines(tmp)
}

get_headers_url <- function(path = "anything", ..., protocol = "http") {
  con <- url(get_path(path, protocol), ...)
  on.exit(try(close(con)), add = TRUE)
  readLines(con)
}

get_path <- function(path = "anything", protocol = "http") {
  paste0(protocol, "://", "eu.httpbin.org/", path)
}

with_options <- function(opts, expr) {
  old <- do.call(options, as.list(opts))
  on.exit(options(old), add = TRUE)
  expr
}

tests <- function() {
  cat("- User agent is still set\n")
  with_options(list(HTTPUserAgent = "foobar"), {
    h <- get_headers()
    stopifnot(any(grepl("User-Agent.*foobar", h)))
  })

  with_options(list(HTTPUserAgent = "foobar"), {
    h <- get_headers(headers = c(foo = "bar", zzzz = "bee"))
    stopifnot(any(grepl("User-Agent.*foobar", h)))
    stopifnot(any(grepl("Foo.*bar", h)))
    stopifnot(any(grepl("Zzzz.*bee", h)))
  })

  cat("- Can supply headers\n")
  h <- get_headers(headers = c(foo = "bar", zzzz = "bee"))
  stopifnot(any(grepl("Foo.*bar", h)))
  stopifnot(any(grepl("Zzzz.*bee", h)))

  cat("- Basic auth\n")
  ret <- tryCatch({
    h <- suppressWarnings(get_headers(
      "basic-auth/Aladdin/OpenSesame",
      headers = c(Authorization = "Basic QWxhZGRpbjpPcGVuU2VzYW1l")))
    TRUE
  }, error = function(e) FALSE)
  stopifnot(any(grepl("authenticated.*true", h)))

  if (getOption("download.file.method") == "libcurl") {
    cat("- Multiple urls (libcurl only)\n")
    urls <- get_path(c("anything", "headers"))
    tmp1 <- tempfile()
    tmp2 <- tempfile()
    on.exit(unlink(c(tmp1, tmp2)), add = TRUE)
    download.file(urls, c(tmp1, tmp2), quiet = TRUE,
                  headers = c(foo = "bar", zzzz = "bee"))
    h1 <- readLines(tmp1)
    h2 <- readLines(tmp2)
    stopifnot(any(grepl("Foo.*bar", h1)))
    stopifnot(any(grepl("Zzzz.*bee", h1)))
    stopifnot(any(grepl("Foo.*bar", h2)))
    stopifnot(any(grepl("Zzzz.*bee", h2)))
  }

  if (getOption("download.file.method", "") != "internal") {
    cat("- HTTPS\n")
    h <- get_headers(headers = c(foo = "bar", zzzz = "bee"),
                     protocol = "https")
    stopifnot(any(grepl("Foo.*bar", h)))
    stopifnot(any(grepl("Zzzz.*bee", h)))
  }

  cat("- If headers not named, then error\n")
  ret <- tryCatch(
    download.file(get_path(), headers = c("foo", "xxx" = "bar")),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))
  ret <- tryCatch(
    download.file(get_path(), headers = "foobar"),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))

  cat("- If headers are NA, then error\n")
  ret <- tryCatch(
    download.file(get_path(), headers = c("foo" = NA, "xxx" = "bar")),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))
  ret <- tryCatch(
    download.file(
      get_path(), quiet = TRUE,
      headers = structure(c("foo", "bar", names = c("foo", NA)))),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))

  cat("- user agent is set in url()\n")
  with_options(list(HTTPUserAgent = "foobar"), {
    h <- get_headers_url()
    stopifnot(any(grepl("User-Agent.*foobar", h)))
  })

  cat("- file() still works with URLs\n")
  con <- file(get_path("anything", "http"))
  on.exit(close(con), add = TRUE)
  h <- readLines(con)
  stopifnot(any(grepl("Host.*eu.httpbin.org", h)))

  cat("- If headers not named, then url() errors\n")
  ret <- tryCatch(
    url(get_path(), headers = c("foo", "xxx" = "bar")),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))

  cat("- If headers are NA, then url() errors\n")
  ret <- tryCatch(
    url(get_path(), headers = c("foo" = "bar", "xxx" = NA)),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))
  ret <- tryCatch(
    url(get_path(),
        headers = structure(c("1", "2"), names = c("foo", NA))),
    error = function(err) TRUE)
  stopifnot(isTRUE(ret))

  cat("- Can supply headers in url()\n")
  h <- get_headers_url(headers = c(foo = "bar", zzzz = "bee"))
  stopifnot(any(grepl("Foo.*bar", h)))
  stopifnot(any(grepl("Zzzz.*bee", h)))

  if (getOption("download.file.method", "") != "internal") {
    cat("- HTTPS with url()\n")
    h <- get_headers_url(headers = c(foo = "bar", zzzz = "bee"),
                         protocol = "https")
    stopifnot(any(grepl("Foo.*bar", h)))
    stopifnot(any(grepl("Zzzz.*bee", h)))
  }
}

main <- function() {
  cat("internal method\n")
  with_options(c(download.file.method = "internal"), tests())

  if (.Platform$OS.type == "windows")  {
    cat("\nwininet method\n")
    with_options(c(download.file.method = "wininet"), tests())
  }

  if (isTRUE(capabilities()[["libcurl"]])) {
    cat("\nlibcurl method\n")
    with_options(c(download.file.method = "libcurl"), tests())
  }
}

if (is_online()) main()
