## ---- include = FALSE----------------------------------------------------
library(glue)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ------------------------------------------------------------------------
collapse_transformer <- function(regex = "[*]$", ...) {
  function(text, envir) {
    if (grepl(regex, text)) {
        text <- sub(regex, "", text)
    }
    res <- eval(parse(text = text, keep.source = FALSE), envir)
    glue_collapse(res, ...)
  }
}

glue("{1:5*}\n{letters[1:5]*}", .transformer = collapse_transformer(sep = ", "))

glue("{1:5*}\n{letters[1:5]*}", .transformer = collapse_transformer(sep = ", ", last = " and "))

## ------------------------------------------------------------------------
shell_transformer <- function(type = c("sh", "csh", "cmd", "cmd2")) {
  type <- match.arg(type)
  function(text, envir) {
    res <- eval(parse(text = text, keep.source = FALSE), envir)
    shQuote(res)
  }
}

glue_sh <- function(..., .envir = parent.frame(), .type = c("sh", "csh", "cmd", "cmd2")) {
  .type <- match.arg(.type)
  glue(..., .envir = .envir, .transformer = shell_transformer(.type))

}

filename <- "test"
writeLines(con = filename, "hello!")

command <- glue_sh("cat {filename}")
command
system(command)

## ---- eval = require("emo")----------------------------------------------
emoji_transformer <- function(text, envir) {
  if (grepl("[*]$", text)) {
    text <- sub("[*]$", "", text)
    glue_collapse(ji_find(text)$emoji)
  } else {
    ji(text)
  }
}

glue_ji <- function(..., .envir = parent.frame()) {
  glue(..., .open = ":", .close = ":", .envir = .envir, .transformer = emoji_transformer)
}
glue_ji("one :heart:")
glue_ji("many :heart*:")

## ------------------------------------------------------------------------
sprintf_transformer <- function(text, envir) {
  m <- regexpr(":.+$", text)
  if (m != -1) {
    format <- substring(regmatches(text, m), 2)
    regmatches(text, m) <- ""
    res <- eval(parse(text = text, keep.source = FALSE), envir)
    do.call(sprintf, list(glue("%{format}f"), res))
  } else {
    eval(parse(text = text, keep.source = FALSE), envir)
  }
}

glue_fmt <- function(..., .envir = parent.frame()) {
  glue(..., .transformer = sprintf_transformer, .envir = .envir)
}
glue_fmt("π = {pi:.2}")

## ------------------------------------------------------------------------
safely_transformer <- function(otherwise = NA) {
  function(text, envir) {
    tryCatch(
      eval(parse(text = text, keep.source = FALSE), envir),
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

