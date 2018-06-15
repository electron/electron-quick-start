## ---- include = FALSE----------------------------------------------------
library(glue)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ------------------------------------------------------------------------
collapse_transformer <- function(regex = "[*]$", ...) {
  function(code, envir) {
    if (grepl(regex, code)) {
        code <- sub(regex, "", code)
    }
    res <- evaluate(code, envir)
    collapse(res, ...)
  }
}

glue("{1:5*}\n{letters[1:5]*}", .transformer = collapse_transformer(sep = ", "))

glue("{1:5*}\n{letters[1:5]*}", .transformer = collapse_transformer(sep = ", ", last = " and "))

## ---- eval = require("emo")----------------------------------------------
emoji_transformer <- function(code, envir) {
  if (grepl("[*]$", code)) {
    code <- sub("[*]$", "", code)
    collapse(ji_find(code)$emoji)
  } else {
    ji(code)
  }
}

glue_ji <- function(..., .envir = parent.frame()) {
  glue(..., .open = ":", .close = ":", .envir = .envir, .transformer = emoji_transformer)
}
glue_ji("one :heart:")
glue_ji("many :heart*:")

## ------------------------------------------------------------------------
sprintf_transformer <- function(code, envir) {
  m <- regexpr(":.+$", code)
  if (m != -1) {
    format <- substring(regmatches(code, m), 2)
    regmatches(code, m) <- ""
    res <- evaluate(code, envir)
    do.call(sprintf, list(glue("%{format}f"), res))
  } else {
    evaluate(code, envir)
  }
}

glue_fmt <- function(..., .envir = parent.frame()) {
  glue(..., .transformer = sprintf_transformer, .envir = .envir)
}
glue_fmt("π = {pi:.2}")

## ------------------------------------------------------------------------
safely_transformer <- function(otherwise = NA) {
  function(code, envir) {
    tryCatch(evaluate(code, envir),
      error = function(e) if (is.language(otherwise)) eval(otherwise) else otherwise)
  }
}

glue_safely <- function(..., .otherwise = NA, .envir = parent.frame()) {
  glue(..., .transformer = safely_transformer(.otherwise), .envir = .envir)
}

# Default returns missing if there is an error
glue_safely("foo: {xyz}")

# Or an empty string
glue_safely("foo: {xyz}", .otherwise = "Error")

# Or output the error message in red
library(crayon)
glue_safely("foo: {xyz}", .otherwise = quote(glue("{red}Error: {conditionMessage(e)}{reset}")))

