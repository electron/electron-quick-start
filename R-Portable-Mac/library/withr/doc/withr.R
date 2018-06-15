## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(withr)

## ------------------------------------------------------------------------
par("col" = "black")
my_plot <- function(new) {
  old <- par(col = "red", pch = 19)
  plot(mtcars$hp, mtcars$wt)
  par(old)
}
my_plot()
par("col")

## ---- error = TRUE-------------------------------------------------------
par("col" = "black")
my_plot <- function(new) {
  old <- par(col = "red", pch = 19)
  plot(mtcars$hpp, mtcars$wt)
  par(old)
}
my_plot()
par("col")

## ---- error = TRUE-------------------------------------------------------
par("col" = "black")
my_plot <- function(new) {
  old <- par(col = "red", pch = 19)
  on.exit(par(old))
  plot(mtcars$hpp, mtcars$wt)
}
my_plot()
par("col")

options(test = 1)
{
  print(getOption("test"))
  on.exit(options(test = 2))
}
getOption("test")

## ------------------------------------------------------------------------
par("col" = "black")
my_plot <- function(new) {
  with_par(list(col = "red", pch = 19),
    plot(mtcars$hp, mtcars$wt)
  )
  par("col")
}
my_plot()
par("col")

## ------------------------------------------------------------------------
par("col" = "black")
my_plot <- function(new) {
  local_par(list(col = "red", pch = 19))
  plot(mtcars$hp, mtcars$wt)
}
my_plot()
par("col")

