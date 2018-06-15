\name{NEWS}
\title{NEWS file for the rpart package}

\section{Changes in version 4.1-0}{
  \itemize{
    \item The C and R code has been reformatted for legibility.
    
    \item The old compatibility function \code{rpconvert()} has been removed.
    
    \item The cross-validation functions allow for user interrupt at the
    end of evaluating each split.
    
    \item Variable \code{Reliability} in data set \code{car90} is
    corrected to be an ordered factor, as documented.

    \item Surrogate splits are now considered only if they send two or
    more cases \emph{with non-zero weight} each way.  For
    numeric/ordinal variables the restriction to non-zero weights is
    new: for categorical variables this is a new restriction.

    \item Surrogate splits which improve only by rounding error over the
    default split are no longer returned.  Where weights and missing
    values are present, the \code{splits} component for some of these
    was not returned correctly.
  }
}


\section{Changes in version 4.0-3}{
  \itemize{
    \item A fit of class \samp{"rpart"} now contains a component for
    variable \sQuote{importance}, which is reported by the
    \code{summary()} method.

    \item The \code{text()} method gains a \code{minlength} argument,
    like the \code{labels()} method.  This adds finer control: the
    default remains \code{pretty = NULL}, \code{minlength = 1L}.

    \item The handling of fits with zero and fractional weights has been
    corrected: the results may be slightly different (or even
    substantially different when the proportion of zero weights is
    large).

    \item Some memory leaks have been plugged.

    \item There is a second vignette, \file{longintro.Rnw}, a version of
    the original Mayo Tecnical Report on \pkg{rpart}.
  }
}

\section{Changes in version 4.0-2}{
  \itemize{
    \item Added dataset \code{car90}, a corrected version of the
    S-PLUS dataset \code{car.all} (used with permission).

    \item This version does not use \code{paste0{}} and so works
    with \R 2.14.x.
  }
}
    
\section{Changes in version 4.0-1}{
  \itemize{
    
    \item Merged in a set of Splus code changes that had accumulated at
    Mayo over the course of a decade. The primary one is a change in how
    indexing is done in the underlying C code, which leads to a major
    speed increase for large data sets.  Essentially, for the lower
    leaves all our time used to be eaten up by bookkeeping, and this was
    replaced by a different approach.  The primary routine also uses
    \code{.Call{}} so as to be more memory efficient.
    
    \item The other major change was an error for asymmetric loss
    matrices, prompted by a user query.  With L=loss asymmetric, the
    altered priors were computed incorrectly -- they were using L'
    instead of L.  Upshot -- the tree would not not necessarily choose
    optimal splits for the given loss matrix.  Once chosen, splits were
    evaluated correctly.  The printed \dQuote{improvement} values are of
    course the wrong ones as well.  It is interesting that for my little
    test case, with L quite asymmetric, the early splits in the tree are
    unchanged -- a good split still looks good.
	
    \item Add the \code{return.all} argument to \code{xpred.rpart()}.

    \item Added a set of formal tests, i.e., cases with known answers to
    which we can compare.
    
    \item Add a \file{usercode} vignette, explaining how to add user defined
    splitting functions.
    
    \item The class method now also returns the node probability.
    
    \item Add the \code{stagec} data set, used in some tests.
    
    \item The \code{plot.rpart} routine needs to store a value that will
    be visible to the \code{rpartco} routine at a later time.  This is
    now done in an environment in the namespace.
  }
}

\section{Changes in version 3.1-55}{
  \itemize{
    \item Force use of registered symbols in R >= 2.16.0
    \item Update Polish translations.
    \item Work on message formats.
  }
}

\section{Changes in version 3.1-54}{
  \itemize{
    \item Add Polish translations
  }
}

\section{Changes in version 3.1-53}{
  \itemize{
    \item \code{rpart}, \code{rpart.matrix}: allow backticks in formulae.
    \item \file{tests/backtick.R}: regession test
  }
}

\section{Changes in version 3.1-52}{
  \itemize{
    \item \file{src/xval.c}: ensure unused code is not compiled in.
  }
}

\section{Changes in version 3.1-51}{
  \itemize{
    \item  Change description of \samp{margin} in \code{?plot.rpart}
    as suggested by Bill Venables.
  }
}
