% Check from R:
%  news(db = tools:::.build_news_db_from_package_NEWS_Rd("~/R/Pkgs/sfsmisc/inst/NEWS.Rd"))
\name{NEWS}
\title{News for \R Package \pkg{sfsmisc}}
\encoding{UTF-8}

%%% TODO:
      %% \item New \code{rDatetime()} for random date/time sequences
      %% within a specified time range.

\section{CHANGES in sfsmisc VERSION 1.1-2 [2018-03-01]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new \code{funEnv()} utility: \code{list()}-like construction
      of a set of functions (and more) which all share the same
      environment.

      \item Using \code{Authors@R} in \file{DESCRIPTION} and so finally
      honor the many contributors by listing them.

      \item Requiring R >= 3.2.0, so we can use \code{\\CRANpkg{.}} in
      help files.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{histBxp()} no longer evokes a warning from \code{hist.default()}.

      \item \code{digitsBase(0)} now works.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.1-1 [2017-06-08]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{sessionInfoX()} now also reports \code{capabilities()}
      (and more, depending on \R's version).

      \item \code{mult.fig()}'s default for \code{mgp} now adapts to a
      non-default value of \code{par("las")}.

      \item \code{eaxis()} gets new options \code{axp} and \code{n.axp}
      for more flexible automatic tick marks.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{integrate.xy()} is more careful in matching "data"
      with grid points, thanks to a bug report by Loraine Liping Seng.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.1-0 [2016-02-22]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{primes()} has optional \code{pSeq} argument,
      surprisingly with no known benefit.
      \item tweaks for \code{xy.unique.x()} speedup.
      \item \code{QUnif(..., p, ...)} now works for large \eqn{p} (and
      gets a \code{silent} option to suppress the message).
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item Fix the \code{tkdensity()} bug introduced on 2015-07-22,
      hence, for \pkg{sfsmisc} versions \code{1.0-28} and \code{1.0-29},
      with the \dQuote{codetools cleanup}.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-29 [2016-01-22]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new function \code{read.org.table()} to read emacs
      \file{org} files via \code{\link{read.table}()}.

      \item new \code{loessDemo()}, providing a version of an old
      \code{loess.demo()}.

      \item new \code{sessionInfoX()} utility (with \code{print()} method).
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item (workaround R (<= 3.2.2) bug:) the (invisible) return value
      \code{str_data()} no longer contains extraneous \code{NULL}
      entries in the filtering case.
    }
  }
}


\section{CHANGES in sfsmisc VERSION 1.0-28 [2015-08-06]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item \code{tkdensity()} is tweaked such as to look more standard
      to \pkg{codetools};
      \item similarly (much less) for \code{factorize()} and \code{roundfixS()}
      \item new \code{demo("pretty-lab")}
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item also import from "base" packages
      \item \code{pretty10exp(*, lab.type = "latex")} typo fixed;
      \code{eaxis()} works better with \code{lab.type = "latex"}, both
      thanks to David Seifert.
    }
  }
}


\section{CHANGES in sfsmisc VERSION 1.0-27 [2015-01-05]}{
  \subsection{Repository}{
    \itemize{
      \item Moved sources to Github (\url{https://github.com/mmaechler/sfsmisc}),
      on Aug. 9, 2014, from years of emacs backups and a few RCS \dQuote{archives}.
      Blogged about it on \url{http://mmaechler.blogspot.ch/}.
    }
  }
  \subsection{NEW FEATURES}{
    \itemize{
      \item New \code{missingCh()} utility, also for didactical purposes;
      \item new \code{rotn()} "utility".
      \item \code{eaxis()} gets an optional \code{sub10} argument.
      \item \code{mat2tex()} gets new option \code{envir = "tabular"}.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{cairoSwd()} adapted to new Sweave conventions.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-26 [2014-06-16]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new \code{is.whole()} to test if numbers are integer valued.
      \item new \code{cairoSwd()} from Alain Hauser (not yet exported).
      \item new \code{bi2int()} utility (called from \code{as.intBase()})
      with a nice IP numbers transformation example.
      \item \code{toLatex.numeric()} gets \code{times} arg (from Alain).
      \item \code{pretty10exp()} gets new args \code{lab.type} and
      \code{lab.sep} from Ben Bolker.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item not using \code{prt.DEBUG()} anymore ourselves, as it has been
      deprecated.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-25 [2014-01-24]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item better docu on \code{Sys.cpuinfo()}
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item finally deprecate \code{prt.DEBUG()}
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-24 [2013-08-03]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item Deprecate  u.assign0() as globalenv assignment is mostly
      deprecated, and the S <-> R compatibility is unneeded now.
      \item ps.do() and pdf.do() are now closures with their own file name.
      ==> no globalenv assignment needed anymore.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-13 [2010-10-20]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new \code{demo(hatMat)}  being more explicit than \code{?hatMat}
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-12 [2010-09-04]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item \code{plotDS()} bug fix
    }
  }
}


\section{CHANGES in sfsmisc VERSION 1.0-11 [2010-02-22]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item fix nearCor() example
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-10 [2009-12-16]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item pdf.do() with better defaults [ ==> compatible to ps.do() ]
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-9  [2009-11-18]}{

}

\section{CHANGES in sfsmisc VERSION 1.0-8  [2009-08-10]}{

}

\section{CHANGES in sfsmisc VERSION 1.0-7  [2009-01-10]}{

}

\section{CHANGES in sfsmisc VERSION 1.0-6  [2008-11-25]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new Sys.meminfo()
      \item p.profileTraces() improved; eaxis()
    }
  }
}


\section{CHANGES in sfsmisc VERSION 1.0-5  [2008-11-01]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new Duplicated()
      \item ellipsePoints() improvements
      \item eaxis() improvements
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item str_data() buglet
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-4  [2008-07-31]}{

}

\section{CHANGES in sfsmisc VERSION 1.0-3  [2008-06-26]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item pdf.do() has better default behavior.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 1.0-2  [2008-05-03]}{

}

\section{CHANGES in sfsmisc VERSION 1.0-1  [2008-01-30]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item Encoding (latin1), and other platform issues
      \item inv.seq() and eaxis() improvements
    }
  }
}


\section{CHANGES in sfsmisc VERSION 1.0-0  [2007-12-10]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item plotDS() is new name for pl.ds() now allows 'ys' to be a smooth
      "fit structure".  That is now easily constructed via
      \item new seqXtend() function for constructing a sequence which includes
      a give set of numbers x.
      \item y <- roundfixS(x) yields integers y[i] with the same sum as x[i].
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.96-01  [2007-11-21]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new function eaxis() for "engineering" / "extended" axis
      drawing, notably for log-axis labeling
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.95-13  [2007-09-13]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new function nearcor() {find nearest correlation matrix};
      almost as donated by Jens Oehlschlaegel.
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item pdf.latex(), pdf.do() : defaults; viewer specifications...
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.95-12  [2007-06-30]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item New internal Sys.procinfo() function for cleaner implementation of
      Sys.cpuinfo() and Sys.meminfo().
    }
  }
}

\section{CHANGES in sfsmisc VERSION 0.95-10  [2007-06-25]}{
  \subsection{NEW FEATURES}{
    \itemize{
    \item new pdf.do(), pdf.end(), pdf.latex()), as analogues to ps.do() etc,
    \item implemented as wrapper to new  dev.latex() utility function
	(dev.latex): instead of ps.latex();
	(pdf.latex, ps.latex): now wrappers to dev.latex
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.95-9  [2007-03-15]}{

}

\section{CHANGES in sfsmisc VERSION 0.95-8  [2007-01-18]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-7  [2006-10-19]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-6  [2006-06-26]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-5  [2006-06-22]}{

}



\section{CHANGES in sfsmisc VERSION 0.95-4  [2006-02-26]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-3  [2006-01-25]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-2  [2005-11-03]}{

}


\section{CHANGES in sfsmisc VERSION 0.95-1  [2005-04-25]}{
  \subsection{NEW FEATURES}{
    \itemize{
    \item rnls() for robust nonlinear regression;
   	lseq() {seq() on log scale} utility
    \item now has a NAMESPACE
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-8  [2004-12-14]}{
  \subsection{BUG FIXES}{
    \itemize{
      \item TA.plot() now also works for lme() results.
    }
  }
}

\section{CHANGES in sfsmisc VERSION 0.9-7  [2004-11-04]}{
  \itemize{
    \item Depends on R 1.9.0 (was effectively the case earlier):
    Removing old package names "modreg", "stepfun", etc
  }
}



\section{CHANGES in sfsmisc VERSION 0.9-6  [2004-09-27]}{
  \itemize{
    \item bug fix in p.ts(): case of start(.) of length 2
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-5  [2004-08-12]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item new posdefify(m) returns a positive definite matrix close to 'm'
      \item New  QUnif() and sHalton() for quasi-random number generation
    }
  }
  \subsection{BUG FIXES}{
    \itemize{
      \item fixed labeling bug in compresid2way().
    }
  }
  \subsection{DEPRECATED & DEFUNCT}{
    \itemize{
      \item mult.fig()'s global assignment to 'old.par' is now deprecated.
      do work with op <- mult.fig(...)$old.par instead !!
      \item plotCI() is now deprecated -- use the one from package "gregmisc"!
    }
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-4  [2004-05-26]}{
  \itemize{
    \item p.ts() allows date-time objects for x-axis labeling, with new
    arguments 'date.x', 'do.x.axis', 'do.x.rug', 'ax.format' and 'xlab'
    \item strcodes() had a bug (offset by 1) which also lead to one in AsciiToInt()
    \item p.res.2x() has new arguments 'xlim', 'ylim', 'main' and a new default
    for 'scol' (= 2:3).
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-3  [2004-02-23]}{
  \itemize{
    \item p.res.2x() allows 'scol' of length 2.
    \item n.plot()  fixed the "log = .." (non-default) option.
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-2  [2004-02-07]}{
  \itemize{
    \item put Sys.*() functions into unix-only directory
    \item ps.end() tries behaves better for non-unix finding the file
    \item u.date() becomes OS-independent.
  }
}


\section{CHANGES in sfsmisc VERSION 0.9-1  [2004-02-04 -- 1st CRAN ver.!]}{
  \itemize{
    \item new function compresid2way() from Werner Stahel.
    \item f.robftest() now returns an object of class "htest"

    \cr \cr
%% FIXME: It seems wrong that this cannot be put into a final \note{.}
%%   tools:::.build_news_db_from_package_NEWS_Rd("~/R/Pkgs/sfsmisc/inst/NEWS.Rd")

    \item For more details, see the \file{ChangeLog} file!
  }
}

