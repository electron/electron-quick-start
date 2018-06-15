## MM: this leaves away sys.source() from 
#  File src/library/base/R/source.R
#  Part of the R package, https://www.R-project.org
#
#  Copyright (C) 1995-2016 The R Core Team
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/



source <-
function(file, local = FALSE, echo = verbose, print.eval = echo,
         exprs, spaced = use_file,
	 verbose = getOption("verbose"),
	 prompt.echo = getOption("prompt"),
	 max.deparse.length = 150, width.cutoff = 60L,
         deparseCtrl = "showAttributes", ## rather?  c("keepInteger", "showAttributes", "keepNA"),
         chdir = FALSE,
         encoding = getOption("encoding"),
         continue.echo = getOption("continue"),
         skip.echo = 0, keep.source = getOption("keep.source"))
{
    envir <- if (isTRUE(local)) parent.frame()
	     else if(identical(local, FALSE)) .GlobalEnv
	     else if (is.environment(local)) local
	     else stop("'local' must be TRUE, FALSE or an environment")
    if (!missing(echo)) {
	if (!is.logical(echo))
	    stop("'echo' must be logical")
	if (!echo && verbose) {
	    warning("'verbose' is TRUE, 'echo' not; ... coercing 'echo <- TRUE'")
	    echo <- TRUE
	}
    }
    if (verbose) {
	cat("'envir' chosen:")
	print(envir)
    }

    if(use_file <- missing(exprs)) {

    ofile <- file # for use with chdir = TRUE
    from_file <- FALSE # true, if not stdin() nor from srcref
    srcfile <- NULL
    if(is.character(file)) {
        have_encoding <- !missing(encoding) && encoding != "unknown"
        if(identical(encoding, "unknown")) {
            enc <- utils::localeToCharset()
            encoding <- enc[length(enc)]
        } else enc <- encoding
        if(length(enc) > 1L) {
            encoding <- NA
	    owarn <- options(warn = 2)
            for(e in enc) {
                if(is.na(e)) next
                zz <- file(file, encoding = e)
                res <- tryCatch(readLines(zz, warn = FALSE), error = identity)
                close(zz)
                if(!inherits(res, "error")) { encoding <- e; break }
            }
            options(owarn)
        }
        if(is.na(encoding))
            stop("unable to find a plausible encoding")
        if(verbose)
            cat(gettextf('encoding = "%s" chosen', encoding), "\n", sep = "")
        if(file == "") {
	    file <- stdin()
	    srcfile <- "<stdin>"
        } else {
            filename <- file
	    file <- file(filename, "r", encoding = encoding)
	    on.exit(close(file))
            if (isTRUE(keep.source)) {
	    	lines <- readLines(file, warn = FALSE)
	    	on.exit()
	    	close(file)
            	srcfile <- srcfilecopy(filename, lines, file.mtime(filename)[1],
            			       isFile = TRUE)
	    } else {
            	from_file <- TRUE
		srcfile <- filename
	    }

            ## We translated the file (possibly via a guess),
            ## so don't want to mark the strings.as from that encoding
            ## but we might know what we have encoded to, so
            loc <- utils::localeToCharset()[1L]
            encoding <- if(have_encoding)
                switch(loc,
                       "UTF-8" = "UTF-8",
                       "ISO8859-1" = "latin1",
                       "unknown")
            else "unknown"
	}
    } else {
    	lines <- readLines(file, warn = FALSE)
        srcfile <-
            if (isTRUE(keep.source))
                srcfilecopy(deparse(substitute(file)), lines)
            else
                deparse(substitute(file))
    }

    exprs <- if (!from_file) {
        if (length(lines))  # there is a C-level test for this
            .Internal(parse(stdin(), n = -1, lines, "?", srcfile, encoding))
        else expression()
    } else
    	.Internal(parse(file, n = -1, NULL, "?", srcfile, encoding))

    on.exit()
    if (from_file) close(file)

    if (verbose)
	cat("--> parsed", length(exprs), "expressions; now eval(.)ing them:\n")

    if (chdir){
        if(is.character(ofile)) {
	    if(grepl("^(ftp|http|file)://", ofile)) ## is URL
                warning("'chdir = TRUE' makes no sense for a URL")
	    else if((path <- dirname(ofile)) != ".") {
                owd <- getwd()
                if(is.null(owd))
                    stop("cannot 'chdir' as current directory is unknown")
                on.exit(setwd(owd), add=TRUE)
                setwd(path)
            }
        } else {
            warning("'chdir = TRUE' makes no sense for a connection")
        }
    }

    } else { # 'exprs' specified: !use_file
	if(!missing(file)) stop("specify either 'file' or 'exprs' but not both")
	if(!is.expression(exprs))
	    exprs <- as.expression(exprs)
    }

    Ne <- length(exprs)
    if (echo) {
	## Reg.exps for string delimiter/ NO-string-del /
	## odd-number-of-str.del needed, when truncating below
	sd <- "\""
	nos <- "[^\"]*"
	oddsd <- paste0("^", nos, sd, "(", nos, sd, nos, sd, ")*", nos, "$")
        ## A helper function for echoing source.  This is simpler than the
        ## same-named one in Sweave
	trySrcLines <- function(srcfile, showfrom, showto) {
	    tryCatch(suppressWarnings(getSrcLines(srcfile, showfrom, showto)),
		     error = function(e) character())
	}
    }
    yy <- NULL
    lastshown <- 0
    srcrefs <- attr(exprs, "srcref")
    if(verbose && !is.null(srcrefs)) {
        cat("has srcrefs:\n"); utils::str(srcrefs) }
    for (i in seq_len(Ne+echo)) {
    	tail <- i > Ne
        if (!tail) {
	    if (verbose)
		cat("\n>>>> eval(expression_nr.", i, ")\n\t	 =================\n")
	    ei <- exprs[i]
	}
	if (echo) {
	    nd <- 0
	    srcref <- if(tail) attr(exprs, "wholeSrcref") else
		if(i <= length(srcrefs)) srcrefs[[i]] # else NULL
 	    if (!is.null(srcref)) {
	    	if (i == 1) lastshown <- min(skip.echo, srcref[3L]-1)
	    	if (lastshown < srcref[3L]) {
	    	    srcfile <- attr(srcref, "srcfile")
	    	    dep <- trySrcLines(srcfile, lastshown+1, srcref[3L])
	    	    if (length(dep)) {
			leading <- if(tail) length(dep) else srcref[1L]-lastshown
			lastshown <- srcref[3L]
			while (length(dep) && grepl("^[[:blank:]]*$", dep[1L])) {
			    dep <- dep[-1L]
			    leading <- leading - 1L
			}
			dep <- paste0(rep.int(c(prompt.echo, continue.echo),
					      c(leading, length(dep)-leading)),
				      dep, collapse="\n")
			nd <- nchar(dep, "c")
		    } else
		    	srcref <- NULL  # Give up and deparse
	    	}
	    }
	    if (is.null(srcref)) {
	    	if (!tail) {
		    # Deparse.  Must drop "expression(...)"
		    dep <- substr(paste(deparse(ei, width.cutoff = width.cutoff,
						control = deparseCtrl),
					collapse = "\n"), 12L, 1e+06L)
		    dep <- paste0(prompt.echo,
				  gsub("\n", paste0("\n", continue.echo), dep))
		    ## We really do want chars here as \n\t may be embedded.
		    nd <- nchar(dep, "c") - 1L
		}
	    }
	    if (nd) {
		do.trunc <- nd > max.deparse.length
		dep <- substr(dep, 1L, if (do.trunc) max.deparse.length else nd)
		cat(if (spaced) "\n", dep, if (do.trunc)
		    paste(if (grepl(sd, dep) && grepl(oddsd, dep))
			  " ...\" ..." else " ....", "[TRUNCATED] "),
		    "\n", sep = "")
	    }
	}
	if (!tail) {
	    yy <- withVisible(eval(ei, envir))
	    i.symbol <- mode(ei[[1L]]) == "name"
	    if (!i.symbol) {
		## ei[[1L]] : the function "<-" or other
		curr.fun <- ei[[1L]][[1L]]
		if (verbose) {
		    cat("curr.fun:")
		    utils::str(curr.fun)
		}
	    }
	    if (verbose >= 2) {
		cat(".... mode(ei[[1L]])=", mode(ei[[1L]]), "; paste(curr.fun)=")
		utils::str(paste(curr.fun))
	    }
	    if (print.eval && yy$visible) {
		if(isS4(yy$value))
		    methods::show(yy$value)
		else
		    print(yy$value)
	    }
	    if (verbose)
		cat(" .. after ", sQuote(deparse(ei, control =
					  unique(c(deparseCtrl, "useSource")))),
		    "\n", sep = "")
 	}
    }
    invisible(yy)
}

withAutoprint <- function(exprs, local = TRUE, print. = TRUE, echo = TRUE,
                          max.deparse.length = Inf,
                          width.cutoff = max(20, getOption("width")),
                          deparseCtrl = c("keepInteger", "showAttributes", "keepNA"),
                          ...)
{
    if(is.expression(exprs)) {
	## just use it
    } else if(is.list(exprs) && all(vapply(exprs, is.language, NA))) {
	## go ahead
    } else {
	exprs <- substitute(exprs)
	if(is.call(exprs)) {
	    if(exprs[[1]] == as.symbol("{"))
		exprs <- as.list(exprs[-1])
	    ## else:  use that call
	} else
	    stop("'exprs' must be an unevaluated call, 'expression' or 'list'")
    }

    source(exprs = exprs, local = local, print.eval = print., echo = echo,
           max.deparse.length = max.deparse.length, width.cutoff = width.cutoff,
	   deparseCtrl = deparseCtrl, ...)
}
