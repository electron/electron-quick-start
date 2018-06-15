dt <- setRefClass("dt", fields = list(data = "environment", row.names = "character"))

ev <- new.env()

d1 <- dt$new(data = ev, row.names = letters)

stopifnot(identical(d1$data, ev),
          identical(d1$row.names, letters))

# an invalid class should generate an error
d2 <- tryCatch(dt$new(data = ev, row.names = 1:12), error = function(e)e)

stopifnot(is(d2, "error"),
          grepl("row.names", d2$message, fixed = TRUE),
          grepl("character", d2$message, fixed = TRUE),
          grepl("integer", d2$message, fixed = TRUE))

# a simple subclass should be used, unchanged

setClass("tagStrings", contains = "character",
         representation(tag = "Date"))

date1 <- as.Date("2010-01-15")

t1 <- new("tagStrings", letters, tag = date1)

d3 <- dt$new(data = ev, row.names = t1)

stopifnot(identical(d3$row.names, t1))

