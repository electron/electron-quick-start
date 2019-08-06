## ---- eval = FALSE-------------------------------------------------------
#  usethis::use_package("pillar")

## ------------------------------------------------------------------------
#' @export
latlon <- function(lat, lon) {
  as_latlon(complex(real = lon, imaginary = lat))
}

#' @export
as_latlon <- function(x) {
  structure(x, class = "latlon")
}

#' @export
c.latlon <- function(x, ...) {
  as_latlon(NextMethod())
}

#' @export
`[.latlon` <- function(x, i) {
  as_latlon(NextMethod())
}

#' @export
format.latlon <- function(x, ..., formatter = deg_min) {
  x_valid <- which(!is.na(x))

  lat <- unclass(Im(x[x_valid]))
  lon <- unclass(Re(x[x_valid]))

  ret <- rep("<NA>", length(x))
  ret[x_valid] <- paste(
    formatter(lat, c("N", "S")),
    formatter(lon, c("E", "W"))
  )
  format(ret, justify = "right")
}

deg_min <- function(x, pm) {
  sign <- sign(x)
  x <- abs(x)
  deg <- trunc(x)
  x <- x - deg
  min <- round(x * 60)

  ret <- sprintf("%d°%.2d'%s", deg, min, pm[ifelse(sign >= 0, 1, 2)])
  format(ret, justify = "right")
}

#' @export
print.latlon <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

latlon(32.7102978, -117.1704058)

## ------------------------------------------------------------------------
library(tibble)
data <- tibble(
  venue = "rstudio::conf",
  year  = 2017:2019,
  loc   = latlon(
    c(28.3411783, 32.7102978, NA),
    c(-81.5480348, -117.1704058, NA)
  ),
  paths = list(
    loc[1],
    c(loc[1], loc[2]),
    loc[2]
  )
)

data

## ----include=FALSE-------------------------------------------------------
import::from(pillar, type_sum)

## ------------------------------------------------------------------------
#' @importFrom pillar type_sum
#' @export
type_sum.latlon <- function(x) {
  "geo"
}

## ------------------------------------------------------------------------
data

## ----include=FALSE-------------------------------------------------------
import::from(pillar, pillar_shaft)

## ------------------------------------------------------------------------
#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.latlon <- function(x, ...) {
  out <- format(x)
  out[is.na(x)] <- NA
  pillar::new_pillar_shaft_simple(out, align = "right")
}

## ------------------------------------------------------------------------
data

## ------------------------------------------------------------------------
#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.latlon <- function(x, ...) {
  out <- format(x)
  out[is.na(x)] <- NA
  pillar::new_pillar_shaft_simple(out, align = "left", na_indent = 5)
}

data

## ------------------------------------------------------------------------
print(data, width = 35)

## ------------------------------------------------------------------------
#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.latlon <- function(x, ...) {
  out <- format(x)
  out[is.na(x)] <- NA
  pillar::new_pillar_shaft_simple(out, align = "right", min_width = 10)
}

print(data, width = 35)

## ------------------------------------------------------------------------
#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.latlon <- function(x, ...) {
  deg <- format(x, formatter = deg)
  deg[is.na(x)] <- pillar::style_na("NA")
  deg_min <- format(x)
  deg_min[is.na(x)] <- pillar::style_na("NA")
  pillar::new_pillar_shaft(
    list(deg = deg, deg_min = deg_min),
    width = pillar::get_max_extent(deg_min),
    min_width = pillar::get_max_extent(deg),
    subclass = "pillar_shaft_latlon"
  )
}

## ------------------------------------------------------------------------
deg <- function(x, pm) {
  sign <- sign(x)
  x <- abs(x)
  deg <- round(x)

  ret <- sprintf("%d°%s", deg, pm[ifelse(sign >= 0, 1, 2)])
  format(ret, justify = "right")
}

## ------------------------------------------------------------------------
#' @export
format.pillar_shaft_latlon <- function(x, width, ...) {
  if (all(crayon::col_nchar(x$deg_min) <= width)) {
    ornament <- x$deg_min
  } else {
    ornament <- x$deg
  }

  pillar::new_ornament(ornament)
}

data
print(data, width = 35)

## ------------------------------------------------------------------------
#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.latlon <- function(x, ...) {
  out <- format(x, formatter = deg_min_color)
  out[is.na(x)] <- NA
  pillar::new_pillar_shaft_simple(out, align = "left", na_indent = 5)
}

deg_min_color <- function(x, pm) {
  sign <- sign(x)
  x <- abs(x)
  deg <- trunc(x)
  x <- x - deg
  rad <- round(x * 60)
  ret <- sprintf(
    "%d%s%.2d%s%s",
    deg,
    pillar::style_subtle("°"),
    rad,
    pillar::style_subtle("'"),
    pm[ifelse(sign >= 0, 1, 2)]
  )
  ret[is.na(x)] <- ""
  format(ret, justify = "right")
}

data

## ----include=FALSE-------------------------------------------------------
import::from(pillar, is_vector_s3)

## ------------------------------------------------------------------------
#' @importFrom pillar is_vector_s3
#' @export
is_vector_s3.latlon <- function(x) TRUE

data

## ------------------------------------------------------------------------
time <- as.POSIXlt("2018-12-20 23:29:51", tz = "CET")
x <- as.POSIXlt(time + c(0, 60, 3600))
str(unclass(x))

## ------------------------------------------------------------------------
x
length(x)
str(x)

## ----include=FALSE-------------------------------------------------------
import::from(pillar, obj_sum)

## ------------------------------------------------------------------------
#' @importFrom pillar obj_sum
#' @export
obj_sum.POSIXlt <- function(x) {
  rep("POSIXlt", length(x))
}

## ------------------------------------------------------------------------
library(testthat)

## ----include = FALSE-----------------------------------------------------
unlink("latlon.txt")
unlink("latlon-bw.txt")

## ----error = TRUE, warning = TRUE----------------------------------------
test_that("latlon pillar matches known output", {
  pillar::expect_known_display(
    pillar_shaft(data$loc),
    file = "latlon.txt"
  )
})

## ------------------------------------------------------------------------
test_that("latlon pillar matches known output", {
  pillar::expect_known_display(
    pillar_shaft(data$loc),
    file = "latlon.txt"
  )
})

## ------------------------------------------------------------------------
readLines("latlon.txt")

## ----error = TRUE, warning = TRUE----------------------------------------
library(testthat)
test_that("latlon pillar matches known output", {
  pillar::expect_known_display(
    pillar_shaft(data$loc),
    file = "latlon.txt",
    crayon = FALSE
  )
})

## ------------------------------------------------------------------------
test_that("latlon pillar matches known output", {
  pillar::expect_known_display(
    pillar_shaft(data$loc),
    file = "latlon.txt",
    crayon = FALSE
  )
})

readLines("latlon.txt")

## ------------------------------------------------------------------------
expect_known_latlon_display <- function(x, file_base) {
  quo <- rlang::quo(pillar::pillar_shaft(x))
  pillar::expect_known_display(
    !! quo,
    file = paste0(file_base, ".txt")
  )
  pillar::expect_known_display(
    !! quo,
    file = paste0(file_base, "-bw.txt"),
    crayon = FALSE
  )
}

## ----error = TRUE, warning = TRUE----------------------------------------
test_that("latlon pillar matches known output", {
  expect_known_latlon_display(data$loc, file_base = "latlon")
})

## ------------------------------------------------------------------------
readLines("latlon.txt")
readLines("latlon-bw.txt")

## ----include = FALSE-----------------------------------------------------
unlink("latlon.txt")
unlink("latlon-bw.txt")

