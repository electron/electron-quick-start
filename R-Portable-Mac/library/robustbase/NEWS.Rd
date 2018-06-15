% Check from R:
%  news(db = tools:::.build_news_db_from_package_NEWS_Rd("~/R/Pkgs/robustbase/inst/NEWS.Rd"))
\name{NEWS}
\title{News for \R Package \pkg{robustbase}}
\encoding{UTF-8}

\section{CHANGES in robustbase VERSION 0.93-0 (2018-04-21, svn r805)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{.psi.const(*, "lqq")} now also gives a
      \code{"constants"} attribute.

      \item more examples and help on Mpsi() etc functions and tuning constants.

      \item The S estimator \code{lmrob.S()} and M-S estimator now both
      make use of the new \code{lmrob.control()} argument
      \code{scale.tol} which defaults to \code{1e-10}, its formerly
      hardwired value.

      \item \code{lmrob.S()} further gets a new option \code{only.scale = FALSE},
      which when true allows to only compute the S scale estimate.  In
      that case, but also generally, \code{trace.lev = 3} or larger also
      produces output showing the C level \code{find_scale()} iterations.

      \item (By Manuel Koller) There's now a small C API to call our
      \code{Mpsi()} etc from C code in other packages, as
      \code{C_psi()}, etc; using new \file{../inst/include/robustbase.h}.

      \item \code{nlrob()$call$algorithm} now always contains the
      algorithm used as a \code{\link{character}} string, compatibly
      with \code{\link{nls}()}.

      \item new data set \code{steamUse}.
      %% which also depicts the \dQuote{non-robust} behavior of \code{lmrob(setting="KS2014")}

      \item Vignette \file{lmrob_simulation.Rnw}: fixed the wrong
      \dQuote{emprical power} plots; with faster \pkg{ggplot2}, remove
      all \code{eval=FALSE} for plots and longer store the
      \file{*.pdf}s.

      \code{nlrob()} gets \code{model} option to ask for the
      \code{model.frame} to be returned.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{lmrob(..., method = "S")} no longer necessarily
      produces a warning in \code{.vcov.w()}.

      \item \code{nlrob()} returns a correct \code{dataClasses} component.
    }
  }
  \subsection{Tests Tweaks}{
    \itemize{
      \item For use in non-R-internal BLAS/Lapack libraries, several
      \file{tests/*.R} examples have been tweaked.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-8 (2017-10-30, svn r778)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{fullRank()} utility for \code{adjOutlyingness}:

      \item \code{adjOutlyingness()}, gets new options \code{p.samp} and
      \code{trace.lev}, and when it fails to find enough good
      directions, now checks the rank and mentions \code{fullRank()} in
      case the matrix is (QR-)rank deficient.

      \item The \code{"lmrob"} method for \code{vcov()} gets optional
      argument \code{complete = TRUE}, where only \emph{complete =
	FALSE} is back compatible.

      \item improved (error) messages in singular case in
      \code{.vcov.avar1()}.

      \item \code{.psi.const()} is exported as well, and help is
      improved about using and setting non-default psi tuning constants.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item loosened some regression test tolerances (for alternatives
      to BLAS) in \file{tests/(mc-strict|poisson-ex)}.

      \item \code{scaleTau2(x, *)} gains an optional \code{sigma0}
      argument and now returns zero instead of \code{NaN} when
      \code{sigma0 == 0}.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-7 (2016-11-23, svn r742)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{vignette(psi_functions)}

      \item \code{adjOutlyingness(..., maxit.mult = max(100, p))} new option,
      allowing more iterations for finding \dQuote{good} projection directions.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{summary(nlrob(*, method = "CM"))} now works.
      \item \code{lmrob..MM..fit()} now works again when \code{x} and
      \code{y} are specified, but neither \code{method} nor \code{obj} is.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-6 (2016-05-28, svn r717)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item Now provide an \code{"lmrob"} method for the standard \R
      generic function \code{hatvalues()}, and also export its lower
      level workhorse \code{.lmrob.hat()} (formerly hidden
      \code{lmrob.leverages()}), which now by default has
      \code{names(.)}.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{.lmrob.hat()} (formerly \code{lmrob.leverages()}) has
      been corrected for the rank-deficient case.
      \item \code{classPC(m)} now also works for a 1-column matrix.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-5 (2015-07-21, svn r698)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \emph{Hidden} \code{print()} methods \code{print.summary.lmrob()}
      and \code{print.lmrob.S()} get a \code{showAlgo = TRUE} argument
      which the user can set to FALSE in order to suppress printing of
      the \dQuote{Algorithmic parameters}.
      \item import (remaining parts) from "base" packages.
      \item \code{summary(<nlrob>)} now also prints a summary on the residuals.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{summary(lmrob(.))}'s variance-covariance matrix is now
      called \code{cov} instead of \code{cov.unscaled} (because it
      \emph{is} scaled).  Code which has been using \code{vcov(<lmrob>)}
      or \code{<lmrob> $ cov}, or even \code{<summary.lmrob> $ cov} is not affected.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-4 (2015-06-04, svn r696)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item Started this \file{NEWS.Rd} file, to eventually replace the \file{ChangeLog}
      \item \code{plot.lmrob()} also identifies largest residuals as
      \code{plot.lm()}.  Also gets new argument \code{panel}, and
      \code{add.smooth=TRUE} behavior.
      \item adapt to the fact that R 3.3.0 will have its own
      \code{sigma()} S3 generic.
      \item setup for having message translations (volunteers sought!).
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item more careful in \file{../src/mc.c} (valgrind, thanks to Brian)
      \item add missing documentation, better examples for \code{predict.lmrob}
      \item \code{warn.limit.*} checks in \code{lmrob*()}
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-3 (2015-01-14, svn r679)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item The \sQuote{Co-Median} \code{covComed()} from Maria Anna,
      tweaked by Valentin and modified considerably by Martin.
      \item Also document (and export) \code{r6pack()} utility.
      \item New \code{smoothWgt()} function --- \dQuote{Biweight on a
	Stick} --- to be used as \code{wgtFUN} option for \code{covMcd()}
      or \code{covComed()}.
      \item New utility \code{colMedians()} and \code{rowMedians}, as we
      use columnwise medians in so many places.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item Tweaks to \code{medcouple()}, after detecting flaws -- which
      may be inherent and have \emph{not} been removed.
      \item Improved its documentation and the \code{adjOutlyingness()}
      one, notably its \dQuote{central} case.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-2 (2014-11-22, svn r660)}{
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{covMcd()} with new options (\code{kmini},
      \code{nmini}) now ok (sometimes wrong in 0.92-1).
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-1 (2014-11-18)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item The deterministic MCD, via \code{covMcd(..., nsamp="deterministic")}.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{adjOutlyingness()}: reverse the defaults of
      \code{clower} and \code{cupper} and fix an \dQuote{eternal}
      erronous \eqn{\pm}{+/-} swap; see new note in \file{man/adjOutlyingness.Rd}.
    }
  }
}

\section{CHANGES in robustbase VERSION 0.92-0 (2014-11-18)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{nlrob()} now works with indexed vector parameters.
      \item new \code{outlierStats()} (Manuel).
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item got rid of Fortran compiler warnings about \bold{ancient} style.
      \item \code{nlrob(*, weigths)}, fixing R-forge bug #5988.
      \item \code{covMcd()} fix for \dQuote{MAD = 0} case (new
      \code{exactfit} code 3).
    }
  }
}

\section{CHANGES in robustbase VERSION 0.91-1 (2014-05-01)}{
  \subsection{BUG FIXES}{
    \itemize{
      \item .
    }
  }
}

\section{CHANGES in robustbase VERSION 0.91-0 (2014-04-24)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item .
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item .
    }
  }
}

\section{CHANGES in robustbase VERSION 0.90-1 (2014-01-30)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item .
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item .
    }
  }
}

\section{CHANGES in robustbase VERSION 0.9-8 (2013-06-14)}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item .
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item .
    }
  }
}
