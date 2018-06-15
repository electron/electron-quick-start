## ---- echo = FALSE-------------------------------------------------------
library(httr)
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)

## ------------------------------------------------------------------------
library(httr)
r <- GET("http://httpbin.org/get")

## ------------------------------------------------------------------------
r

## ------------------------------------------------------------------------
status_code(r)
headers(r)
str(content(r))

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/get")
# Get an informative description:
http_status(r)

# Or just access the raw code:
r$status_code

## ------------------------------------------------------------------------
warn_for_status(r)
stop_for_status(r)

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/get")
content(r, "text")

## ---- eval = FALSE-------------------------------------------------------
#  content(r, "text", encoding = "ISO-8859-1")

## ------------------------------------------------------------------------
content(r, "raw")

## ---- eval = FALSE-------------------------------------------------------
#  bin <- content(r, "raw")
#  writeBin(bin, "myfile.txt")

## ------------------------------------------------------------------------
# JSON automatically parsed into named list
str(content(r, "parsed"))

## ------------------------------------------------------------------------
headers(r)

## ------------------------------------------------------------------------
headers(r)$date
headers(r)$DATE

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/cookies/set", query = list(a = 1))
cookies(r)

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/cookies/set", query = list(b = 1))
cookies(r)

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/get", 
  query = list(key1 = "value1", key2 = "value2")
)
content(r)$args

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/get", 
  query = list(key1 = "value 1", "key 2" = "value2", key2 = NULL))
content(r)$args

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/get", add_headers(Name = "Hadley"))
str(content(r)$headers)

## ------------------------------------------------------------------------
r <- GET("http://httpbin.org/cookies", set_cookies("MeWant" = "cookies"))
content(r)$cookies

## ------------------------------------------------------------------------
r <- POST("http://httpbin.org/post", body = list(a = 1, b = 2, c = 3))

## ------------------------------------------------------------------------
url <- "http://httpbin.org/post"
body <- list(a = 1, b = 2, c = 3)

# Form encoded
r <- POST(url, body = body, encode = "form")
# Multipart encoded
r <- POST(url, body = body, encode = "multipart")
# JSON encoded
r <- POST(url, body = body, encode = "json")

## ---- eval = FALSE-------------------------------------------------------
#  POST(url, body = body, encode = "multipart", verbose()) # the default
#  POST(url, body = body, encode = "form", verbose())
#  POST(url, body = body, encode = "json", verbose())

## ---- eval = FALSE-------------------------------------------------------
#  POST(url, body = upload_file("mypath.txt"))
#  POST(url, body = list(x = upload_file("mypath.txt")))

## ------------------------------------------------------------------------
sessionInfo()

