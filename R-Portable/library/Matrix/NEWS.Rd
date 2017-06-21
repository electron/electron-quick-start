% Check from R:
%  news(db = tools:::.build_news_db_from_package_NEWS_Rd("~/R/Pkgs/Matrix/inst/NEWS.Rd"))
\name{NEWS}
\title{News for \R Package \pkg{Matrix}}% MM: look into ../svn-log-from.all
\encoding{UTF-8}
%% as long as not R >= 3.2.0, ~/R/D/r-devel/R/share/Rd/macros/system.Rd :
\newcommand{\CRANpkg}{\href{https://CRAN.R-project.org/package=#1}{\pkg{#1}}}
\newcommand{\sspace}{\ifelse{latex}{\out{~}}{ }}
%% NB: The date (yyyy-mm-dd) is the "Packaged:" date in ../DESCRIPTION

%%_NOT YET__FIXME_   needs cholmod_l_dense_to_sparse() in our dense_to_Csparse()
%% \item \code{as(<large-matrix>, "sparseMatrix")} no longer fails
%%  when \code{prod(dim(.))} is larger than \eqn{2^{31} - 1}.

\section{Changes in version 1.2-9 (2017-03-08, svn r3211)}{
  \subsection{New Features}{
    \itemize{
      \item \code{"Ops"} between "table", "xtabs", and our matrices now work.
      \item \code{as(matrix(diag(3), 3, dimnames=rep(list(c("A","b","c")),2)),
 	"diagonalMatrix")@x} is no longer named.
      \item \code{norm(x, "2")} now works as well (and equivalently to \code{base::norm}).
      \item \code{sparseVector()} now also works without \code{x} argument.
      \item \code{c.sparseVector()} method for \code{c()} of
      sparseVectors (and available as regular function on purpose).
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{as(Diagonal(3), "denseMatrix")} no longer returns a
      non-dense \code{"ddiMatrix"}.

      \item \code{S[sel,] <- value} and similar no longer segfault, but
      give a \code{"not (yet?) supported"} error
      for sparse matrices \code{S} and logical \code{sel} when
      \code{sel} contains \code{NA}s.

      The same error (instead of a low-level one) is signalled for
      \emph{indexing} (with NA-containing logical \code{sel}), i.e.,
      \code{S[sel,]}.
      %% from in ../TODO :
      %% \item \code{S[sel,]}, \code{S[,sel] <- value} and similar now also work for
      %% sparse matrices \code{S} and logical \code{sel} when \code{sel} contains \code{NA}s.

      \item \code{which(x, arr.ind=TRUE, *)} (when \code{x} is a
      \code{"lMatrix"} or \code{"nMatrix"}) now works the same as
      \code{base::which}, obeying an optional \code{useNames} argument
      which defaults to \code{TRUE}.  Previously, the resulting
      two-column matrix typically had empty \code{dimnames}.
    }
  }
}

\section{Changes in version 1.2-8 (2017-01-16, svn r3201)}{
  \subsection{New Features}{
    \itemize{
      \item 0-length matrix \code{"Ops"} (binary operations) are now
      compatible to R-devel (to be \R 3.4.0).
      \item C-API: \code{SuiteSparse_long} is now defined as
      \code{int64_t} on all platforms, and we now include (C99) \file{inttypes.h}
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{x[.] <- value} now also works for
      \code{"sparseVector"}'s, both as \code{x} and as \code{value}.
      \item \code{x[FALSE] <- value} now also works for \code{"sparseVector"}'s.

      \item \code{rep(x, *)} now works for \code{"sparseVector"}s and
      sparse and dense \code{"Matrix"}-classed matrices \code{x}.

      \item \code{solve(<sparse_LU>)} no gives an error in some cases of
      singular matrices, where before the C code accessed illegal memory locations.
    }
  }
}


\section{Changes in version 1.2-7.1 (2016-08-29, svn r3187)}{
  \itemize{ \item in C code, protect _POSIX_C_SOURCE by #ifdef __GLIBC__ }
}
\section{Changes in version 1.2-7 (2016-08-27, svn r3185)}{
  \subsection{New Features}{
    \itemize{
      \item \code{cBind()} and \code{rBind()} have been almost silently
      deprecated in \R \code{>= 3.2.0} and now give a warning,
      \dQuote{once per session} only.

      \item \code{bandSparse(*, k=k, *)} now returns matrices inheriting from
      \code{"triangularMatrix"} when obvious from the diagonal indices \code{k}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{KhatriRao(X,Y)} now also works when \code{X} or
      \code{Y} is completely zero.
    }
  }
}

\section{Changes in version 1.2-6 (2016-04-27, svn r3175)}{
  \subsection{Bug Fixes}{
    \itemize{
      \item The 0-dim. Matrix multiplication fix in 1.2-5 did trigger
      wrong warnings in other diagonal matrix multiplications.
    }
  }
}

\section{Changes in version 1.2-5 (2016-04-14, svn r3170)}{
  \subsection{New Features}{
    \itemize{
      \item \code{isSymmetric(m)} now also works for \code{"indMatrix"} \code{m}.
      \item \code{isSymmetric(m)} is faster for large dense asymmetric matrices.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item Matrix multiplications (\code{A \%*\% B}) now work correctly
      when one of the matrices is diagonal and the other has a zero dimension.
    }
  }
}

\section{Changes in version 1.2-4 (2016-02-29, svn r3162)}{
  \subsection{New Features}{
    \itemize{
      \item \code{sparseMatrix()} gets new argument \code{triangular}
      and a smarter default for \code{dims} when \code{symmetric} or
      \code{triangular} is true.
      \item \code{as(<sparse>, "denseMatrix")} now works in more cases
      when \code{prod(dim(.))} is larger than \eqn{2^{31} - 1}.
      Hence, e.g., \code{!S} now works for much larger sparse matrices
      \code{S}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item creating very large dense matrices, e.g., by
      \code{as(<sparseM.>, "matrix")} would segfault (in case it could
      allocate enough storage).
    }
  }
}

\section{Changes in version 1.2-3 (2015-11-19, svn r3155)}{
  \subsection{New Features}{
    \itemize{
      \item \code{MatrixClass()} is exported now.
      \item More exports of semi-internal functions (for speed, named
      \code{".<foo>"}, i.e., inofficial API), such as \code{.solve.dgC.lu()}.
      \item more Korean translations
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item Packages \emph{linking} to \pkg{Matrix} (\code{LinkingTo:}
      in \file{DESCRIPTION}) now find
      \samp{alloca} properly defined in \file{Matrix.h} even for non-GNU
      compilation environments such as on Solaris or AIX.

      \item extended "n?CMatrix" classes (e.g., from \code{setClass(.,
	contains="ngCMatrix")}) now can be coerced via \code{as(.)} to
      \code{"d.CMatrix"}.

      \item The printing of largish sparse matrices is improved, notably
      in the case where columns are suppressed, via new \code{fitWidth =
	TRUE} option in \code{printSpMatrix2()}. %%% FIXME __ EXAMPLES __

      \item \code{cbind2()} and \code{rbind2()} no longer fail to
      determine \code{sparse} when it is unspecified and hence
      \code{NA}, fixing R-forge bug #6259.
    }
  }
}

\section{Changes in version 1.2-2 (2015-07-03, svn r3131)}{
  \subsection{New Features}{
    \itemize{
      \item Explicitly import from \dQuote{base} packages such as \code{"stats"}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item Our \code{colSums(x)}, \code{rowMeans(y)}, \dots, methods
      now \dQuote{keep names}, i.e., if the result is a numeric vector,
      and the matrix \code{x} has column or row names, these become the
      \code{names(.)} of the result, fixing R-forge bug #6018.
    }
  }
}

\section{Changes in version 1.2-1 (2015-05-30, svn r3127)}{
  \subsection{New Features}{
    \itemize{
      \item \code{"Matrix"} now has an \code{initialization()} method
      coercing 0-length dimnames components to \code{NULL} and other
      non-\code{NULL} dimnames to \code{character}.  Before, e.g.,
      numeric dimnames components partially worked, even though it has
      always been documented that non-\code{NULL} dimnames should be
      \code{character}.
      \item For \code{symmetricMatrix} objects which have symmetrical
      dimnames by definition, it is allowed to only set one half of the
      \code{dimnames} to save storage, e.g., \code{list(NULL, nms)} is
      \emph{semantically} equivalent to \code{list(nms, nms)}.

      \item \code{as.vector(<sparseVector>)} etc, now work, too.
      \item \code{lu(\emph{<sparseMatrix>})} now keeps \code{dimnames}.
      \item better \file{NEWS.Rd} (which pleases Kurt and \command{tidy} ;-)
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{S[] <- T} and \code{S[] <- spV} now work (in more cases)
      for sparse matrices S, T and sparseVector \code{spV}.
      \item Huge dense matrix multiplication did lead to segfaults, see
      R-help, \dQuote{does segfault mean (always) a bug?}, May 5, 2015.
      Fixed by using C's Alloca() only in smallish cases.
      \item Optional arguments in \code{image()}, e.g., \code{main=
	<..>)} now also work for \code{lgCMatrix}, \code{nMatrix} etc;
      thanks to a 4.5 years old report by Mstislav Elagin.
      \item \code{dimnames(A) <- val} now resets the \code{factors} slot
      to empty, as the factorizations now keep dimnames more often.
      \item \code{crossprod(<matrix>, Diagonal(<n>))} works again (and
      these are tested more systematically).
      \item Matrix products (\code{\%*\%}, \code{crossprod}, and
      \code{tcrossprod}) for \code{"dtrMatrix"} are correct in all
      cases, including keeping dimnames.
      \item \code{Matrix(d)} (and other coercions to \code{"Matrix"})
      now correctly keeps \code{dimnames} also when \code{d} is a
      traditional \emph{diagonal} \code{"matrix"}.
    }
  }
}

\section{Changes in version 1.2-0 (2015-04-03, svn r3096)}{
  \subsection{New Features}{
    \itemize{
      \item New \code{\%&\%} for \dQuote{boolean arithmetic} matrix product.
      \item New argument \code{boolArith = NA} in \code{crossprod()} and
      \code{tcrossprod()}.  \code{boolArith = TRUE} now forces boolean
      arithmetic, where \code{boolArith = FALSE} forces numeric one.

      Several of these products are more efficient thanks to new C
      functionality based on our new \code{chm_transpose_dense()}, and
      others based on \code{geMatrix_crossprod},
      \code{geMatrix_matrix_mm}, etc.

      \item Most dense matrix products, also for non-\code{dgeMatrix},
      including \code{"l..Matrix"} and \code{"n..Matrix"} ones are now
      directly handled by new \code{.Call()}s.

      \item \code{"dMatrix"} (numeric) and \code{"lMatrix"} (logical)
      matrices can now be coerced to \code{"nMatrix"} (non-zero pattern
      or \dQuote{boolean}) even when they contain \code{NA}s, which then
      become \code{TRUE}s.

      \item More thorough checking of \code{cbind2()} and
      \code{rbind2()} methods, notably as they are called from \code{cbind()}
      and \code{rbind()} from \R version 3.2.0 on.

      \code{rbind2(<dense>, <dense>)} is faster, being based on new C code.

      \item symmetric Matrices (i.e., inheriting from
      \code{"symmetricMatrix"}) are allowed to have \code{dimnames} of
      the form \code{list(NULL, <names>)} \emph{and} now print correctly
      and get correctly coerced to general matrices.

      \item \code{indMatrix} object (\dQuote{index matrices}) no longer
      need to be \dQuote{skinny}.

      \item \code{rsparseMatrix()} now accepts \code{rand.x = NULL} and
      then creates a random \emph{patter\bold{n}} matrix
      (\code{"nsparseMatrix"}).

      \item \code{anyDuplicatedT()} and \code{uniqTsparse()} low level
      utilities are exported now.

      \item Partial Korean translations of messages.
    }
  }
  \subsection{Deprecation}{
    \itemize{
      \item For \eqn{R \ge 3.2.0}, \code{cBind()} and \code{rBind()}
      are deprecated, as they are no longer needed since \code{cbind()}
      and \code{rbind()} do work automatically.
    }
  }

  \subsection{Bug Fixes}{
    \itemize{
      \item Fix some \code{rbind2()} methods.
      \item \code{t()} now transposes the dimnames even for symmetric
      matrices.
      \item \code{diag(M) <- val} did not always recycle \code{val} to
      full length, e.g., when \code{M} was a \code{"dtrMatrix"}.
      \item \code{crossprod(<indMatrix>)} was wrong in cases where the
      matrix had all-zero columns.
      \item Matrix products (\code{\%*\%}, \code{crossprod}, and
      \code{tcrossprod}) with one sparse and one dense argument now
      return \emph{numeric} (a \code{"dMatrix"}) when they should, i.e.,
      unless the new setting \code{boolArith = TRUE} is applied.
    }
  }
}

\section{Changes in version 1.1-5 (2015-01-18, svn r3037)}{
  \subsection{New Features}{
    \itemize{
      \item More use of \code{anyNA()} (for speedup).
      \item Matrix products (\code{\%*\%}, \code{crossprod},
      \code{tcrossprod}) now behave compatibly to \R 3.2.0, i.e., more
      lenient in matching dimensions for matrix - vector products.
      \item \code{isTriangular()} gets new optional argument \code{upper = NA}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{crossprod()} and \code{tcrossprod()} fixes for
      several <diagonal> o <sparse> combinations.
      \item \code{rowMeans(<dgeMatrix>, na.rm=TRUE)} was wrong sometimes.
      \item fix and speedup of coercions (\code{as(., .)}) from and to
      symmetric or triangular matrices.
      \item \code{invPerm()} coercion to integer
      \item \code{dimnames( solve(.,.) )} fix [r3036]
      \item \code{tril()} and \code{triu()} now return correct \code{uplo}.
      \item \code{names(dimnames(.))} now preserved, e.g. in
      \code{symmpart()} or subsetting (\code{A[i,j]}).
    }
  }
}

\section{Changes in version 1.1-4 (2014-06-14, svn r2994)}{
  \subsection{New Features}{
    \itemize{
      \item new \code{rsparsematrix()} for random sparse Matrices.
      \item improved warnings, notably for unused arguments previously
      swallowed into \code{...}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{crossprod(<vec>, <dsyMatrix>)} fixed.
      \item \code{crossprod()} and \code{kronecker()} fixes for some
      <indMatrix> cases.
    }
  }
}

\section{Changes in version 1.1-3 (2014-03-30, svn r2982)}{
  \subsection{New Features}{
    \itemize{
      \item \code{\%*\%} and \code{crossprod()} now also work with
      \code{sparseVector}s.
      \item speedup of \code{crossprod(v, <sparseM>)}, thanks to nudge
      by Niels Richard Hansen.
      \item new help page for all such matrix products
      (\file{../man/matrix-products.Rd}).
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{image()} now gets correct \code{ylim} again.
      \item More consistent matrix products.
    }
  }
}

\section{Changes in version 1.1-2-2 (2014-03-04, svn r2966)}{
  \subsection{Bug Fixes}{
    \itemize{
      \item correct adaption to \R 3.1.0
      \item using \code{tolerance} (and not \sQuote{tol}) in \code{all.equal()}
    }
  }
}

\section{Changes in version 1.1-2 (2014-01-28, svn r2962)}{
  \subsection{New Features}{
    \itemize{
      \item export fast power-user coercion utilities
      \code{.dsy2mat()}, \code{.dxC2mat()}, \code{.T2Cmat()}, \code{..2dge()}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item matrix products now (mostly) work with \code{sparseVector}s;
      and correctly in some more cases.
    }
  }
}

\section{Changes in version 1.1-1.1 (2013-12-30, svn r2957)}{
    \itemize{
      \item Testing code's \code{assertWarning()} adapted for \eqn{R \le 3.0.1}.
      \item \code{Depends: R >= 2.15.2} eases checking.
    }
}

\section{Changes in version 1.1-1 (2013-12-28)}{
  \subsection{New Features}{
    \itemize{
      \item \code{image(.., xlim, ylim)}: nicer defaults %% ../R/dgTMatrix.R
      for the axis limits, and \code{ylim} is sorted decreasingly; not
      strictly back-compatible but should never harm.
      \item \code{rankMatrix(*, method="qr")} now using \code{tol}
      \item \code{T2graph()} and \code{graph2T()} export old functionality explicitly.
      Tweaks in conversions between \code{"graph"} and
      \code{"sparseMatrix"} objects.  Notably, \code{as(<graph>,
	<Matrix>)} now more often returns a (0/1 pattern) "n..Matrix".
      \item \code{sparseMatrix()}: new \code{use.last.ij} argument.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{KhatriRao()}: fix rownames (X <-> Y)
      \item \code{qr.coef()}, \code{qr.fitted}, and \code{qr.resid} now
      also work with \emph{sparse} RHS \code{y}.
      \item sparse matrix \dQuote{sub assignments}, e.g., \code{M[ii] <- v},
      speedup and fixes.
      \item bug fixes also in \code{M[negative indices] <- value} and
      \code{<sparseMatrix>[cbind(i,j)]}.
    }
  }
}

\section{Changes in version 1.1-0 (2013-10-21, svn r2930)}{
  \subsection{New Features}{
    \itemize{
      \item \code{fac2sparse} and \code{fac2Sparse} now exported, with a
      new \code{giveCsparse} option.
      \item Update to latest \command{SuiteSparse} C library by Tim Davis,
      U. Florida.
      \item ensuing \dQuote{C API changes}
      \item new \code{.SuiteSparse_version()} function
      \item Many \sQuote{Imports:} instead of \sQuote{Depends:}.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item fixed long lasting undetected \code{solve(<dsCMatrix>, *)}
      bug.
      \item Our \code{all.equal()} methods no longer sometimes return
      \code{c("TRUE", "....difference..")}.
      \item \code{rankMatrix(<matrix>)}: fix the internal \code{x.dense}
      definition.
    }
  }
}

\section{Changes in version 1.0-14 (2013-09-12, svn r2907)}{
  \subsection{Bug Fixes}{
    \itemize{
      \item Revert some wrong changes to \code{solve(<sparse>, *)} from
      1.0-13 (\dQuote{stop gap fix} for \R 3.0.2).
    }
  }
}

\section{Changes in version 1.0-13 (2013-09-10, svn r2904)}{
  \subsection{New Features}{
    \itemize{
      \item New (efficient) \code{KhatriRao()} function by Michael Cysouw
      \item New \code{"indMatrix"} class of \dQuote{index matrices}, a
      generalization of \code{"pMatrix"}, the permutation matrices, many
      methods generalized from pMatrix to indMatrix.  All (initial)
      functionality contributed by Fabian Scheibl, Univ.\sspace{} Munich.
      \item Export and document \code{isDiagonal()} and
      \code{isTriangular()} as they are useful outside of \pkg{Matrix}.
      \item \code{rankMatrix(M, method="qr")} no longer needs
      \code{sval} which makes it considerably more useful for large
      sparse \code{M}.
      \item Start providing \code{anyNA} methods for \eqn{R >= 3.1.0}.
      \item \code{solve(<sparse> a, <sparse> b)}: if \code{a} is
      symmetric, now compute \emph{sparse} result.
      \item \code{nearPD()} gets new option \code{conv.norm.type = "I"}.
      \item \code{determinant(<dpoMatrix>)} now uses \code{chol()}, and
      hence also an existing (\sQuote{cached}) Cholesky factor.
      \item 3 new \code{C -> R} utilities (including hidden \R function
      \code{.set.factors()} for caching also from \R, not just in C).
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{M[] <- v} for unitriangular \code{M} now correct.
      \item \code{lu(.)} no longer sometimes returns unsorted columns.
    }
  }
}

\section{Changes in version 1.0-12 (2013-03-26, svn r2872)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}


\section{Changes in version 1.0-11 (2013-02-02)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item \code{as(<csr>, "dgCMatrix")} (from package \CRANpkg{SparseM})
      now works again.
      \item .
    }
  }
}

\section{Changes in version 1.0-10 (2012-10-22)}{
  \subsection{New Features}{
    \itemize{
      \item \code{.sparseDiagonal()}: new \code{unitri} argument, and
      more flexibility;
      \item new \code{solve(<dsCMatrix>, <missing>)} via efficient C code.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-9 (2012-09-05)}{
  \subsection{New Features}{
    \itemize{
      \item new \code{sparseVector()} constructor function.
      \item \code{is.finite()} \code{is.infinite()} now work for our
      matrices and "*sparseVector" objects.
      \item \code{diag(.) <- V} now preserves symmetricity,
      triangularity and even uni-triangularity sometimes.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item Quite a few fixes for \code{Ops} (arithmetic, logic, etc)
      group methods.
      \item Ditto for \code{diagonalMatrix} methods.
    }
  }
}

\section{Changes in version 1.0-6 (2012-03-16, publ. 2012-06-18)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-5 (2012-03-15)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-4 (2012-02-21)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-3 (2012-01-13)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-2 (2011-11-19)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-1 (2011-10-18)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 1.0-0 (2011-10-04)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 0.9996875-3 (2011-08-13)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 0.9996875-2 (2011-08-09)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 0.9996875-1 (2011-08-08)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }

  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}

\section{Changes in version 0.999375-50 (2011-04-08)}{
  \subsection{New Features}{
    \itemize{
      \item .
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}


% How can I add vertical space ?

% \preformatted{} is not allowed, nor is \cr





%--------------- start of DB+MM history: ------------------------

\section{Changes in version 0.95-1 (2005-02-18, svn r561)}{
  \subsection{Authorship}{
    \itemize{
      \item During Doug Bates' sabbatical in Zurich,
      Martin Maechler becomes co-author of the \pkg{Matrix} package.
    }
  }
  \subsection{New Features}{
    \itemize{
      \item Beginning of class reorganization with a more systematic
      naming scheme.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item More (correct) coercions \code{as(<from>, <to>)}.
    }
  }
}

\section{Changes in version 0.9-1 (2005-01-24, svn r451)}{
  \subsection{New Features}{
    \itemize{
      \item lme4 / lmer specific R code moved out to \CRANpkg{lme4} package.
    }
  }
  \subsection{Bug Fixes}{
    \itemize{
      \item .
    }
  }
}




% How can I add vertical space ?  ( \preformatted{} is not allowed, nor is \cr )


%--------------- pre-pre-history: ------------------------

\section{Changes in version 0.8-2 (2004-04-06, svn r51)}{
  \subsection{Authorship}{
    \itemize{
      \item Doug Bates (only)
    }
  }
  \subsection{New Features}{
    \itemize{
      \item Sparse matrices, classes and methods, partly via
      \item Interface to LDL, TAUCS, Metis and UMFPACK C libraries
    }
  }
}

% How can I add vertical space ? .................................


\section{Version 0.2-4}{
\subsection{..., 0.3-1, 0.3-n (n=3,5,...,26): 22 more CRAN releases}{
  \itemize{ \item ............................................. } }}

% How can I add vertical space ?
% \preformatted{} is not allowed, nor is \cr



\section{Version 0.2-1 (2000-07-15)}{
  The first CRAN release of the \pkg{Matrix} package,
  titled \dQuote{A Matrix library for R} authored by
  Douglas Bates (maintainer, principal author) and Saikat DebRoy.
  \subsection{Features}{
    \itemize{
      \item \code{Matrix()} constructor for \R objects of class \code{Matrix}.
      \item \code{Matrix.class()} returning informal subclasses such as
      \code{"Hermitian"}, \code{"LowerTriangular"}
      \item \code{is.Orthonormal()}, \code{is.Hermitian()} ,
      \code{is.UpperTriangular()} functions.
      \item \code{SVD()}, \code{lu()}, and \code{schur()} decomposition
      generics with \code{"Matrix"} methods.
      \item \code{rcond()}, \code{norm()}, \code{det()};
      \code{expand()} and \code{facmul()}.

      \item C++ interface to LAPACK
    }
  }
}
