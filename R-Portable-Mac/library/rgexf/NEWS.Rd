\name{NEWS}
\title{rgexf NEWS}
\encoding{UTF-8}

\section{CHANGES IN rgexf version 0.15.2.3 [2015-02-03]}{
\itemize{
  \item Updating emails.
}
}
\section{CHANGES IN rgexf version 0.14.3 [2014-03-09]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item New option -digits- in several functions allow to control for printing precision (reported in issue 16, thanks Nico!).
      \item Function -igraph.to.gexf- now imports attributes.
    }
  }
  \subsection{BUG FIX}{
    \itemize{
      \item Option -defaultedgetype- in the -write.gexf- function now works for static graphs (reported in issue 17, thanks Avitus!).
      \item -datetime- time format in -write.gexf- now works for other formats different from numeric datetime types (reported as issue 15, thanks Thomas Ullmann!).
      \item Correcting errors in -plot.gexf- method, now visual attributes are imported correctly.
    }
  }
  \subsection{DEVELOPMENT}{
    \itemize{
     \item Option -keepFactors- default is now in -FALSE- (used to be in -TRUE-). When setted in -TRUE- and there are factors, a warning message will appear (reported in issue 18, thanks Tim Smith!).
    }
  }
}

\section{CHANGES IN rgexf version 0.13.11 [2013-11-27]}{
  \subsection{BUG FIX}{
    \itemize{
      \item Included class checks in -gexf- class functions (thanks to Samuel Finegold).
      \item \code{write.gexf} does not fails when dynamics different from \code{double} are passed (thank you Samuel Finegold!).
      \item Passing weights from igraph to gexf as now been fix (thank you Roberto Brunelli!).
      \item Fixing encoding issues thanks to Yong Cha's suggestion (thank you!).
    }
  }
}

\section{CHANGES IN rgexf version 0.13.8 [2013-08-06]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item New S3 method \code{plot.gexf}, implemented by Joshua B Kunst, shows the graph in the web browser by means of Sigma.js (!). 
      \item New functions \code{igraph.to.gexf} and \code{gexf.to.igraph} converts objects between \code{igraph} and \code{gexf} clases. Colors and attributes are preserved.
    }
  }
  \subsection{DEVELOPMENT}{
    \itemize{
      \item Improving general documentation.
      \item Just starting to add new options to \code{add.gexf.node/edge}, more precisely, passing attributes.
    }
  }
}

\section{CHANGES IN rgexf version 0.13.05 [2013-05-09]}{
  \subsection{BUG FIX}{
    \itemize{
      \item \code{sprintf} error when using other formats rather than double (issue 10).
      \item in \code{.addNodesEdges}, add support to case ``!attributes && vizattributes'' (issue 9).
    }
  }
}

\section{CHANGES IN rgexf version 0.13.03 [2013-03-14]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item New functions \code{add.node.spell} and \code{add.edge.spell} now allow to work with nodes and edges time spells.
      \item New function \code{check.dpl.edges}, written in C, analyzes links and reports duplicates (marking them) and number of times the same link is repeated considering if the graph is directed or not.
      \item New function \code{switch.edges}, also written in C, allows to order links representations (source and target) in order to set the smallest id as source and the highest as target.
      \item Function \code{write.gexf} now has an improved error handler. Now parses objects before even opening the XML graph.
      \item Edges support id assignment and labeling.
    }
  }
  \subsection{FIXES}{
    \itemize{
      \item Small bug detected in viz attributes fixed.
      \item Edges thickness viz att XML representation (\code{viz:thickness}) was replaced by \code{viz:size} (as it should be).
      \item \dQuote{Library} replaced by \dQuote{Package} everywhere (\code{ups!})
    }
  }
  \subsection{DEVELOPMENT}{
    \itemize{
      \item \code{.addNodesEdges} rewritten now works faster in most of CPUs (some of them with very high speedups) (Thanks to Duncan Temple Lang, RXML author)
      \item Several code routines have been extracted from \dQuote{bigger functions} and written as functions themselves.
    }
  }
}

\section{CHANGES IN rgexf version 0.13.01 [2013-01-04]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item New functions \code{new.gexf.graph}, \code{add.gexf.node}, \code{add.gexf.edge}, \code{rm.gexf.node} and \code{rm.gexf.edge} allow to build and manipulate \code{gexf} objects from scratch.
      \item New function \code{read.gexf} allows to import gexf files as \code{gexf} class objects.
      \item \code{gexf} function now it is called \code{write.gexf}.
      \item Edges now allow weighting.
      \item Viz Attributes (color, shape, size, etc.) can be included in both, nodes and edges.
      \item Real-life datasets have been includded.
      \item New function \code{edge.list} builds a dataframe of nodes from an edge list.
      \item New methods for \code{gexf} objects: \code{print.gexf} and \code{summary.gexf}.
    }
  }
  \subsection{DEVELOPMENT}{
    \itemize{
      \item \code{gexf} class objects are now a standard.
      \item Function \code{gexf} is now named \code{write.gexf}.
      \item Faster net build.
      \item More demos + improve ones.
      \item Cleaner code.
    }
  }
}

\section{CHANGES IN rgexf version 0.12.03.29 [2012-03-29]}{
  \subsection{FIXES}{
    \itemize{
      \item Fixing big misscoding at attvalues XML tag: it was replaced from "att" to "attvalue".
      \item Fixing problem with XML value printing: Leading speces where removed from XML values at ids, source, target, etc.
    }
  }
}

\section{CHANGES IN rgexf version 0.12.03 [2012-03-05]}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item Including a manual of the functions
    }
  }
  \subsection{DEVELOPMENT}{
    \itemize{
      \item Development repository more ordered acording to R package building.
    }
  }
}
