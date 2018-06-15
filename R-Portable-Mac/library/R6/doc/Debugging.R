## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----eval=FALSE----------------------------------------------------------
#  # An example class
#  Simple <- R6Class("Simple",
#    public = list(
#      x = 10,
#      getx = function() self$x
#    )
#  )
#  
#  # This will enable debugging the getx() method for objects of the 'Simple'
#  # class that are instantiated in the future.
#  Simple$debug("getx")
#  
#  s <- Simple$new()
#  s$getx()
#  # [Debugging prompt]

## ----eval=FALSE----------------------------------------------------------
#  # Disable debugging for future instances:
#  Simple$undebug("getx")
#  
#  s <- Simple$new()
#  s$getx()
#  #> [1] 10

## ----eval=FALSE----------------------------------------------------------
#  s <- Simple$new()
#  debug(s$getx)
#  s$getx()
#  # [Debugging prompt]

## ----eval=FALSE----------------------------------------------------------
#  undebug(s$getx)
#  s$getx()
#  #> [1] 10

