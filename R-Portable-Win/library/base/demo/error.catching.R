	##================================================================##
	###  In longer simulations, aka computer experiments,		 ###
	###  you may want to						 ###
	###  1) catch all errors and warnings (and continue)		 ###
	###  2) store the error or warning messages			 ###
	###								 ###
	###  Here's a solution	(see R-help mailing list, Dec 9, 2010):	 ###
	##================================================================##

##' Catch *and* save both errors and warnings, and in the case of
##' a warning, also keep the computed result.
##'
##' @title tryCatch both warnings (with value) and errors
##' @param expr an \R expression to evaluate
##' @return a list with 'value' and 'warning', where
##'   'value' may be an error caught.
##' @author Martin Maechler;
##' Copyright (C) 2010-2012  The R Core Team
tryCatch.W.E <- function(expr)
{
    W <- NULL
    w.handler <- function(w){ # warning handler
	W <<- w
	invokeRestart("muffleWarning")
    }
    list(value = withCallingHandlers(tryCatch(expr, error = function(e) e),
				     warning = w.handler),
	 warning = W)
}

str( tryCatch.W.E( log( 2 ) ) )
str( tryCatch.W.E( log( -1) ) )
str( tryCatch.W.E( log("a") ) )
