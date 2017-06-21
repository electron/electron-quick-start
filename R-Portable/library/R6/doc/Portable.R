## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ------------------------------------------------------------------------
library(R6)
# Simulate packages by creating environments
pkgA <- new.env()
pkgB <- new.env()

# Create a function in pkgA but not pkgB
pkgA$fun <- function() 10

ClassA <- R6Class("ClassA",
  portable = FALSE,
  public = list(
    foo = function() fun()
  ),
  parent_env = pkgA
)

# ClassB inherits from ClassA
ClassB <- R6Class("ClassB",
  portable = FALSE,
  inherit = ClassA,
  parent_env = pkgB
)

## ------------------------------------------------------------------------
a <- ClassA$new()
a$foo()

## ----eval=FALSE----------------------------------------------------------
#  b <- ClassB$new()
#  b$foo()
#  #> Error in b$foo() : could not find function "fun"

## ------------------------------------------------------------------------
pkgA <- new.env()
pkgB <- new.env()

pkgA$fun <- function() {
  "This function `fun` in pkgA"
}

ClassA <- R6Class("ClassA",
  portable = TRUE,  # The default
  public = list(
    foo = function() fun()
  ),
  parent_env = pkgA
)

ClassB <- R6Class("ClassB",
  portable = TRUE,
  inherit = ClassA,
  parent_env = pkgB
)


a <- ClassA$new()
a$foo()

b <- ClassB$new()
b$foo()

## ------------------------------------------------------------------------
pkgC <- new.env()
pkgC$fun <- function() {
  "This function `fun` in pkgC"
}

ClassC <- R6Class("ClassC",
  portable = TRUE,
  inherit = ClassA,
  public = list(
    foo = function() fun()
  ),
  parent_env = pkgC
)

cc <- ClassC$new()
# This method is defined in ClassC, so finds pkgC$fun
cc$foo()

## ------------------------------------------------------------------------
NP <- R6Class("NP",
  portable = FALSE,
  public = list(
    x = 1,
    getxy = function() c(x, y),
    sety = function(value) y <<- value
  ),
  private = list(
    y = NA
  )
)

np <- NP$new()

np$sety(20)
np$getxy()

## ----eval=FALSE----------------------------------------------------------
#  P <- R6Class("P",
#    portable = TRUE,
#    public = list(
#      x = 1,
#      getxy = function() c(x, y),
#      sety = function(value) y <<- value
#    ),
#    private = list(
#      y = NA
#    )
#  )
#  
#  p <- P$new()
#  
#  # No error, but instead of setting private$y, this sets y in the global
#  # environment! This is because of the sematics of <<-.
#  p$sety(20)
#  y
#  #> [1] 20
#  
#  p$getxy()
#  #> Error in p$getxy() : object 'y' not found

## ------------------------------------------------------------------------
P2 <- R6Class("P2",
  portable = TRUE,
  public = list(
    x = 1,
    getxy = function() c(self$x, private$y),
    sety = function(value) private$y <- value
  ),
  private = list(
    y = NA
  )
)

p2 <- P2$new()
p2$sety(20)
p2$getxy()

## ----eval=FALSE----------------------------------------------------------
#  ClassB <- R6Class("ClassB",
#    inherit = pkgA::ClassA,
#    public = list(x = 1)
#  )
#  
#  # We'll fill this at load time
#  objB <- NULL
#  
#  .onLoad <- function(libname, pkgname) {
#    # The namespace is locked after loading; we can still modify objB at this time.
#    objB <<- ClassB$new()
#  }

