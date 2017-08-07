## ----setup, include = FALSE----------------------------------------------
library(dplyr)
knitr::opts_chunk$set(collapse = T, comment = "#>")

## ---- results = "hide"---------------------------------------------------
if (utils::packageVersion("dplyr") > "0.5.0") {
  # code for new version
} else {
  # code for old version
}

## ---- eval = FALSE-------------------------------------------------------
#  if (utils::packageVersion("dplyr") > "0.5.0") {
#    dbplyr::build_sql(...)
#  } else {
#    dplyr::build_sql(...)
#  }

## ------------------------------------------------------------------------
#' @rawNamespace
#' if (utils::packageVersion("dplyr") > "0.5.0") {
#'   importFrom("dbplyr", "build_sql")
#' } else {
#'   importFrom("dplyr", "build_sql")
#' }

## ---- eval = FALSE-------------------------------------------------------
#  wrap_dbplyr_obj("build_sql")
#  
#  wrap_dbplyr_obj("base_agg")

## ---- eval = FALSE-------------------------------------------------------
#  quo <- quo(cyl)
#  select(mtcars, !! quo)

## ---- results = "hide"---------------------------------------------------
sym <- quote(cyl)
select(mtcars, !! sym)

call <- quote(mean(cyl))
summarise(mtcars, !! call)

## ------------------------------------------------------------------------
quo(!! sym)
quo(!! call)

rlang::as_quosure(sym)
rlang::as_quosure(call)

## ------------------------------------------------------------------------
f <- ~cyl
f
rlang::as_quosure(f)

## ------------------------------------------------------------------------
rlang::sym("cyl")
rlang::syms(letters[1:3])

## ------------------------------------------------------------------------
syms <- rlang::syms(c("foo", "bar", "baz"))
quo(my_call(!!! syms))

fun <- rlang::sym("my_call")
quo(UQ(fun)(!!! syms))

## ------------------------------------------------------------------------
call <- rlang::lang("my_call", !!! syms)
call

rlang::as_quosure(call)

# Or equivalently:
quo(!! rlang::lang("my_call", !!! syms))

## ---- eval=FALSE---------------------------------------------------------
#  lazyeval::interp(~ mean(var), var = rlang::sym("mpg"))

## ---- eval=FALSE---------------------------------------------------------
#  var <- "mpg"
#  quo(mean(!! rlang::sym(var)))

## ---- eval = FALSE-------------------------------------------------------
#  filter_.tbl_df <- function(.data, ..., .dots = list()) {
#    dots <- compat_lazy_dots(.dots, caller_env(), ...)
#    filter(.data, !!! dots)
#  }

## ---- eval = FALSE-------------------------------------------------------
#  filter.default <- function(.data, ...) {
#    filter_(.data, .dots = compat_as_lazy_dots(...))
#  }

## ---- eval = FALSE-------------------------------------------------------
#  filter.sf <- function(.data, ...) {
#    st_as_sf(NextMethod())
#  }

## ---- eval = FALSE-------------------------------------------------------
#  mutate_each(starwars, funs(as.character))
#  mutate_all(starwars, funs(as.character))

## ---- eval = FALSE-------------------------------------------------------
#  mutate_all(starwars, as.character)

## ---- eval = FALSE-------------------------------------------------------
#  mutate_each(starwars, funs(as.character), height, mass)
#  mutate_at(starwars, vars(height, mass), as.character)

## ---- eval = FALSE-------------------------------------------------------
#  summarise_at(mtcars, vars(starts_with("d")), mean)

## ---- eval = FALSE-------------------------------------------------------
#  mutate_at(starwars, c("height", "mass"), as.character)

