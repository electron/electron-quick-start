\name{menu.ttest}
\alias{menu.ttest}
\alias{menu.ttest2}
\alias{menu.ttest3}

\alias{del.ttest}

\title{An Example Dialog for t Tests}
\description{
  An example of writing a dialog box for an \R function.
}
\usage{
menu.ttest()
menu.ttest2()
menu.ttest3()

del.ttest()
}
\value{
  This just calls \code{\link{t.test}} and returns its value for
  printing by \code{print.htest}.
}
\details{
  The purpose of these functions is to exemplify GUI programming. See
  the source C code for the details.  The three functions differ in
  the way they return the information. \code{menu.ttest} returns the
  values of the fields etc for assembly in \R code. \code{menu.ttest2}
  submits a string directly to the console.  \code{menu.ttest3}
  returns the parsed and evaluated expression as an \R object.

  \code{del.test()} will remove the menu.
}

\examples{
## The functions are currently defined as
menu.ttest <- function () 
{
    z <- .C("menu_ttest", vars = character(2), ints = integer(4), 
            level = double(1))
    ## check for cancel button
    if (z$ints[4] > 1) return(invisible())
    ## do it this way to get named variables in the answer
    oc <- call("t.test", x = as.name(z$vars[1]), y = as.name(z$vars[2]), 
               alternative = c("two.sided", "less", "greater")[z$ints[1]], 
               paired = z$ints[2] != 0, var.equal = z$ints[3] != 0, 
               conf.level = z$level)
    eval(oc)
}

menu.ttest2 <- function()
{
    .C("menu_ttest2")
    return(invisible())
}

menu.ttest3 <- function() .Call("menu_ttest3")
}
\keyword{misc}
