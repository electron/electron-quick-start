## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>",
  eval = as.logical(Sys.getenv("VIGNETTE_EVAL", "FALSE")),
  cache = TRUE)
library(glue)

## ----setup2, include = FALSE---------------------------------------------
#  plot_comparison <- function(x, ...) {
#    library(ggplot2)
#    x$expr <- forcats::fct_reorder(x$expr, x$time)
#    colors <- ifelse(levels(x$expr) == "glue", "orange", "grey")
#    autoplot(x, ...) +
#      theme(axis.text.y = element_text(color = colors)) +
#        aes(fill = expr) + scale_fill_manual(values = colors, guide = FALSE)
#  }

## ------------------------------------------------------------------------
#  bar <- "baz"
#  
#  simple <-
#    microbenchmark::microbenchmark(
#    glue = glue::glue("foo{bar}"),
#    gstring = R.utils::gstring("foo${bar}"),
#    paste0 = paste0("foo", bar),
#    sprintf = sprintf("foo%s", bar),
#    str_interp = stringr::str_interp("foo${bar}"),
#    rprintf = rprintf::rprintf("foo$bar", bar = bar)
#  )
#  
#  print(unit = "eps", order = "median", signif = 4, simple)
#  
#  plot_comparison(simple)

## ------------------------------------------------------------------------
#  bar <- rep("bar", 1e5)
#  
#  vectorized <-
#    microbenchmark::microbenchmark(
#    glue = glue::glue("foo{bar}"),
#    gstring = R.utils::gstring("foo${bar}"),
#    paste0 = paste0("foo", bar),
#    sprintf = sprintf("foo%s", bar),
#    rprintf = rprintf::rprintf("foo$bar", bar = bar)
#  )
#  
#  print(unit = "ms", order = "median", signif = 4, vectorized)
#  
#  plot_comparison(vectorized, log = FALSE)

