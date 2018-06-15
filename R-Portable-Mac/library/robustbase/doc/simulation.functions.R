## Called from ./lmrob_simulation.Rnw
##              ~~~~~~~~~~~~~~~~~~~~~

###########################################################################
## 1. simulation helper functions
###########################################################################

f.estname <- function(est = 'lmrob')
  ## Purpose: translate between 'estname' and actual function name,
  ##          defaults to 'lmrob'
  ##          f.lmRob is just a wrapper for lmRob, since there are some
  ##          problems with the weight and weights arguments
  ## ----------------------------------------------------------------------
  ## Arguments: est: name of estimator
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:36
  switch(est,
         lm.rbase = 'lmrob', lm.robust = 'f.lmRob', rlm = 'rlm', lm = 'lm',
         est)

f.errname <- function(err, prefix = 'r')
  ## Purpose: translate between natural name of distribution and
  ##          R (r,p,q,d)-name
  ## ----------------------------------------------------------------------
  ## Arguments: err: name of distribution
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:36
  paste(prefix,
        switch(err,normal="norm", t="t", cauchy="cauchy",cnormal="cnorm",
               err),sep = '')

f.requires.envir <- function(estname)
  ## Purpose: returns indicator on whether estname requires envir argument
  ## ----------------------------------------------------------------------
  ## Arguments: estname: name of estimating function
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  7 Oct 2009, 09:34
  switch(estname,
         f.lmrob.local = TRUE,
         FALSE)

f..paste..list <- function(lst)
  if (length(lst) == 0) return("") else
  paste(names(lst),lst,sep='=',collapse=', ')

f..split..str <- function(str) {
  litems <- strsplit(str,', ')
  lst <- lapply(litems, function(str) strsplit(str,'='))
  rlst <- list()
  for (llst in lst) {
    lv <- vector()
    for (litem in llst) lv[litem[1]] <- litem[2]
    rlst <- c(rlst, list(lv))
  }
  rlst
}

f.list2str <- function(lst, idx)
  ## Purpose: convert a list into a string that identifies the
  ##          function and parameter configuration
  ## ----------------------------------------------------------------------
  ## Arguments: lst: list or list of lists
  ##            idx: only take the elements in idx
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  7 Oct 2009, 10:03
  f..paste..list(if(missing(idx)) unlist(lst) else unlist(lst)[idx])

f.as.numeric <- function(val)
{
  ## Purpose: convert value to numeric if possible
  ## ----------------------------------------------------------------------
  ## Arguments: vec: value to convert
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 26 Oct 2009, 12:10

  r <- suppressWarnings(as.numeric(val))
  if (is.na(r)) {
    ## is character, try to convert to TRUE and FALSE
    return(switch(casefold(val),
           "true" = TRUE,
           "false" = FALSE,
           val))
  } else return(r)
}
f.as.numeric.vectorized <- function(val) sapply(val, f.as.numeric)

f.as.integer <- function(val)
{
  ## Purpose: convert value to numeric if possible
  ## ----------------------------------------------------------------------
  ## Arguments: vec: value to convert
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 26 Oct 2009, 12:10

  r <- suppressWarnings(as.integer(val))
  if (is.na(r)) {
    ## is character, try to convert to TRUE and FALSE
    return(switch(casefold(val),
           "true" = TRUE,
           "false" = FALSE,
           val))
  } else return(r)
}

f.str2list <- function(str, splitchar = '\\.')
{
  ## Purpose: inverse of f.list2str
  ## ----------------------------------------------------------------------
  ## Arguments: str: string or list of strings produced with f.list2str
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 14:20

  ## split input string or strings into a list of vectors
  lst <- f..split..str(as.character(str))
  rlst <- list()
  ## walk list
  for (lv in lst) {
    lrlst <- list()
    ## for each element of the vector
    for (ln in names(lv)) {
      ## split
      lnames <- strsplit(ln, splitchar)[[1]]
      ## set either directly
      if (length(lnames) == 1) lrlst[ln] <- f.as.numeric(lv[ln])
      ## or, if it contains a dot, as a sublist
      else {
        if (is.null(lrlst[[lnames[1]]])) lrlst[[lnames[1]]] <- list()
        lrlst[[lnames[1]]][paste(lnames[-1],collapse='.')] <- f.as.numeric(lv[ln])
      }
    }
    rlst <- c(rlst, list(lrlst))
  }
  rlst
}

f.round.numeric <- function(num, digits = 0) { ## round only numeric values in list
  idx <- sapply(num, is.numeric)
  ret <- num
  ret[idx] <- lapply(num[idx],round,digits=digits)
  ret
}

f.errs2str <- function(errs)
{
  ## Purpose: convert list of errors into pretty strings
  ## ----------------------------------------------------------------------
  ## Arguments: errs: estlist element errs
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 14:51

  rv <- vector()
  for (lerr in errs) {
    rv <- c(rv,
              switch(lerr$err,
                     normal = paste("N(",lerr$args$mean,",",
                       lerr$args$sd,")", sep=""),
                     set =,
                     t = paste("t",lerr$args$df,sep=""),
                     paste(lerr$err,"(",paste(f.round.numeric(lerr$args,2),
                                              collapse=","),")",sep="")))
  }
  rv
}

f.procedures2str <- function(procs)
{
  ## Purpose: convert procedures element in estlist to pretty data.frame
  ## ----------------------------------------------------------------------
  ## Arguments: proc: estlist element procedures
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 14:57

  rdf <- rep(" ",7)

  for (lproc in procs) {
    method <- if(is.null(lproc$args$method))
      switch(lproc$estname,
             lm = 'lsq',
             "SM") else lproc$args$method
    cov <- switch(lproc$estname, ## lm.robust, rlm, lmrob: set default arguments
                  lm.robust = list(cov = 'Default',
                    cov.corrfact = 'empirical',
                    cov.xwx = TRUE,
                    cov.resid = 'trick',
                    cov.hubercorr = TRUE,
                    cov.dfcorr = 1),
                  rlm = list(cov = 'Default',
                    cov.corrfact = 'empirical',
                    cov.xwx = FALSE,
                    cov.resid = 'final',
                    cov.hubercorr = TRUE,
                    cov.dfcorr = 1),
                  ## lmrob = list(cov = 'f.avar1', ## method .vcov.MM equals f.avar1
                  ##   cov.resid = 'final'),
                  lmrob = do.call('lmrob.control', ## get default arguments from lmrob.control
                    lproc$args)[c('cov', 'cov.corrfact', 'cov.xwx',
                                  'cov.resid', 'cov.hubercorr', 'cov.dfcorr')],
                  if (is.null(lproc$args)) list(cov = 'Default') else lproc$args)
    if (is.null(lproc$args$psi)) {
      psi <- switch(lproc$estname,
                    rlm =,
                    lmrob = 'bisquare',
                    lm.robust = {
                      if (is.null(lproc$args$weight)) {
                        if (is.null(lproc$args$weight2)) 'optimal'
                        else lproc$args$weight2
                      } else lproc$args$weight[2] },
                    "NA")
    } else {
      psi <- lproc$args$psi
      ## test if tuning.psi is the default one
      if (!is.null(lproc$args$tuning.psi) &&
	  isTRUE(all.equal(lproc$args$tuning.psi, .Mpsi.tuning.default(psi))))
	psi <- paste(psi, lproc$args$tuning.psi)
    }
    D.type <- switch(lproc$estname,
                     lmrob.u =,
                     lmrob = if (is.null(lproc$args$method) ||
                       lproc$args$method %in% c('SM', 'MM')) 'S' else 'D',
                     lmrob.mar = if (is.null(lproc$args$type)) 'qE' else lproc$args$type,
                     rlm = 'rlm',
                     lm.robust = 'rob',
                     lm = 'lm',
                     'NA')
    rdf <- rbind(rdf,c(lproc$estname, method, f.args2str(lproc$args),
                       cov$cov, f.cov2str(cov), psi, D.type))
  }
  colnames(rdf) <- c("Function", "Method", "Tuning", "Cov", "Cov.Tuning", "Psi", "D.type")
  if (NROW(rdf) == 2) t(rdf[-1,]) else rdf[-1,]
}

f.chop <- function(str,l=1)
  ## Purpose: chop string by l characters
  ## ----------------------------------------------------------------------
  ## Arguments: str: string to chop
  ##            l: number of characters to chop
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:19
  substr(str,1,nchar(str)-l)

fMpsi2str <- function(psi)
{
  ## Purpose: make pretty M.psi and D.chi, etc.
  ## ----------------------------------------------------------------------
  ## Arguments: M.psi: M.psi argument
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:28

  if (is.null(psi)) psi
  else if (psi == "tukeyPsi1" || psi == "tukeyChi") "bisquare"
  else if (grepl("Psi1$",psi)) f.chop(psi,4)
  else if (grepl("Chi$",psi)) f.chop(psi,3)
  else psi
}

f.c.psi2str <- function(c.psi)
{
  ## Purpose: make pretty tuning.psi and D.tuning.chi, etc.
  ## ----------------------------------------------------------------------
  ## Arguments: c.psi: tuning.psi argument
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:34

  if (is.null(c.psi)) return(NULL)

  round(as.numeric(c.psi),2)
}

f.args2str <- function(args)
{
  ## Purpose: convert args element in procedures element of estlist
  ##          to a pretty string
  ## ----------------------------------------------------------------------
  ## Arguments: args: args element in procedures element of estlist
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:11

  lst <- list()
  lst$psi <- if (!is.null(args$weight)) args$weight[2]
  else if (!is.null(args$weight2)) args$weight2
  else args$psi

  lst$c.psi <- if (!is.null(args$efficiency))
    round(f.eff2c.psi(args$efficiency, lst$psi),2)
  else f.c.psi2str(args$tuning.psi)

  if (!is.null(args$method) && grepl("D",args$method)) {
    lst$D <- if (!is.null(args$D.type)) args$D.type else NULL
    lst$tau <- args$tau
  }

  f..paste..list(lst)
}

f.cov2str <- function(args)
{
  ## Purpose: convert cov part in args element in procedures element of
  ##          estlist to a pretty string
  ## ----------------------------------------------------------------------
  ## Arguments: args: args element in procedures element of estlist
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:39

  lst <- list()

  if (!is.null(args$cov) && !args$cov %in% c('Default','f.avarwh'))
    lst$cov <- sub('^f\\.', '', args$cov)
  else {
    lst$hc <- args$cov.hubercorr
    lst$dfc <- args$cov.dfcorr
    lst$r <- args$cov.resid
    lst$rtau <- args$cov.corrfact
    lst$xwx <- args$cov.xwx
  }
  ## convert logical to numeric
  lst <- lapply(lst, function(x) if (is.logical(x)) as.numeric(x) else x)

  f..paste..list(lst)
}

f.procstr2id <- function(procstrs, fact = TRUE)
{
  ## Purpose: create short identifiers of procstrs
  ## ----------------------------------------------------------------------
  ## Arguments: procstrs: vector of procstrs
  ##            fact: convert to factor or not
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  3 Nov 2009, 08:58

  lst0 <- f.str2list(procstrs)
  r <- sapply(lst0, function(x) {
    paste(c(x$estname,
            if (is.null(x$args$method)) NULL else x$args$method,
            substr(c(x$args$psi,x$args$weight2, x$args$weight[2]), 1, 3)),
            collapse = '.')
  })
  if (fact) ru <- unique(r)
  if (fact) factor(r, levels = ru, labels = ru) else r
}

f.splitstrs <- function(strs, split = '_', ...)
{
  ## Purpose: split vector of strings by split and convert the list into
  ##          a data.frame with columns type and id
  ## ----------------------------------------------------------------------
  ## Arguments: strs: vector of strings
  ##            split: character vector to use for splitting
  ##            ...: arguments to strsplit, see ?strsplit
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 19 Oct 2009, 08:46

  lstr <- strsplit(strs, split, ...)
  ldf <- t(as.data.frame(lstr))
  rownames(ldf) <- NULL
  as.data.frame(ldf, stringsAsFactors = FALSE)
}

f.abind <- function(arr1,arr2, along = ndim)
{
  ## Purpose: like abind, but less powerful
  ## ----------------------------------------------------------------------
  ## Arguments: arr1, arr2: arrays to bind
  ##            along: dimension along to bind to,
  ##                   defaults to last dimension
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 20 Oct 2009, 11:33
  ## if along =! last dimension: permutate array
  ndim <- length(dim(arr1))
  if (along != ndim) {
    arr1 <- aperm(arr1, perm = c((1:ndim)[-along],along))
    arr2 <- aperm(arr2, perm = c((1:ndim)[-along],along))
  }
  ldmn1 <- dimnames(arr1)
  ldmn2 <- dimnames(arr2)
  ld1 <- dim(arr1)
  ld2 <- dim(arr2)
  if (length(ld1) != length(ld2))
    stop('f.abind: Dimensions must be identical')
  if (!identical(ldmn1[-ndim],ldmn2[-ndim]))
    stop('f.abind: Dimnames other than in the along dimension must match exactly')
  if (any(ldmn1[[ndim]] %in% ldmn2[[ndim]]))
    stop('f.abind: Dimnames in along dimension must be unique')
  ldmn3 <- ldmn1
  ldmn3[[ndim]] <- c(ldmn1[[ndim]], ldmn2[[ndim]])
  ld3 <- ld1
  ld3[ndim] <- ld1[ndim] + ld2[ndim]
  ## build array
  arr3 <- array(c(arr1, arr2), dim = ld3, dimnames = ldmn3)
  ## permutate dimensions back
  if (along != ndim) {
    lperm <- 1:ndim
    lperm[along] <- ndim
    lperm[(along+1):ndim] <- along:(ndim-1)
    arr3 <- aperm(arr3, perm = lperm)
  }
  arr3
}

f.abind.3 <- function(...) f.abind(..., along = 3)

f.rename.level <- function(factor, from, to) {
  ## Purpose: rename level in a factor
  ## ----------------------------------------------------------------------
  ## Arguments: factor: factor variable
  ##            from: level to be changed
  ##            to: value
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 18 Aug 2010, 14:45
  levels(factor)[levels(factor) == from] <- to
  factor
}



###########################################################################
## 2. main simulation functions
###########################################################################

f.sim <- function(estlist,
                  .combine = 'f.abind',
                  .combine.2 = 'f.abind.3', ## hack for foreach
                  silent = TRUE)
{
  ## Purpose: perform simulation according to estlist entry ec
  ## ----------------------------------------------------------------------
  ## Arguments: ec: estlist, list consisting of:
  ##                - design: data frame of design
  ##                - nrep: number of repetitions
  ##                - errs: list of error distributions including arguments
  ##                    - err: name of error distribution
  ##                    - args: list of arguments (to be passed to do.call()
  ##                - procedures: list of parameter configurations and
  ##                    procedures to call
  ##                    - estname: name of estimation procedure
  ##                    - args: arguments that define the call
  ##            silent: silent argument to try
  ## ----------------------------------------------------------------------
  ## Author: Werner Stahel / Manuel Koller, Date: 21 Aug 2008, 07:55

  ## get designs
  ldd <- estlist$design
  use.intercept <- if(is.null(estlist$use.intercept)) TRUE
  else estlist$use.intercept
  nobs <- NROW(ldd)
  npar <- NCOL(ldd) + use.intercept
  nrep <- estlist$nrep
  nlerrs <- nobs*nrep
  ## initialize:
  lestlist <- estlist
  ## 'evaluate' estlist$procedure list
  lprocs <- c()
  for (i in 1:length(estlist$procedures)) {
    ## generate lprocstr (identification string)
    lprocs[i] <- estlist[['procedures']][[i]][['lprocstr']] <-
      f.list2str(estlist[['procedures']][[i]])
  }
  ## find all error distributions
  lerrs <- unique(sapply(lestlist$errs, f.list2str))
  ## walk estlist$output to create output column names vector
  ## store result into lnames, it is used in f.sim.process
  lnames <- c()
  for (i in 1:length(estlist$output)) {
    llnames <- estlist[['output']][[i]][['lnames']] <-
      eval(estlist[['output']][[i]][['names']])
    lnames <- c(lnames, llnames)
  }

  ## get different psi functions
  lpsifuns <- unlist(unique(lt <- sapply(estlist$procedures, function(x) x$args$psi)))
  ## get entries without psi argument
  lrest <- sapply(lt, is.null)
  if (sum(lrest) > 0) lpsifuns <- c(lpsifuns, '__rest__')

  ## Walk error distributions
  res <- foreach(lerrlst = estlist$errs, .combine = .combine) %:%
    foreach(lpsifun = lpsifuns, .combine = .combine.2) %dopar% {
      ## filter for psi functions
      lidx <- if (lpsifun == '__rest__') lrest else
      unlist(sapply(estlist$procedures,
                    function(x) !is.null(x$args$psi) && x$args$psi == lpsifun))
      cat(f.errs2str(list(lerrlst)), lpsifun, " ")
      ## get function name and parameters
      lerrfun <- f.errname(lerrlst$err)
      lerrpar <- lerrlst$args
      lerrstr <- f.list2str(lerrlst)

      ## --- initialize array
      lres <- array(NA, dim=c(nrep, ## data dimension
                          length(lnames), ## output type dimension
                          sum(lidx), ## estimation functions and arguments dimension
                          1), ## error distributions dimension
                    dimnames = list(Data = NULL,
                      Type = lnames, Procstr = lprocs[lidx], Errstr = lerrstr))
      ## set seed
      set.seed(estlist$seed)
      ## generate errors: seperately for each repetition
      lerrs <- c(sapply(1:nrep, function(x) do.call(lerrfun, c(n = nobs, lerrpar))))

      ## if estlist$design has an attribute 'gen'
      ## then this function gen will generate designs
      ## and takes arguments: n, p, rep
      ## and returns the designs in a list
      if (is.function(attr(ldd, 'gen'))) {
        ldds <- attr(ldd, 'gen')(nobs, npar - use.intercept, nrep, lerrlst)
      }

      ## Walk repetitions
      for (lrep in 1:nrep) {
        if (lrep%%100 == 0) cat(" ", lrep)
        lerr <- lerrs[(1:nobs)+(lrep-1)*nobs]
        if (exists('ldds')) {
          ldd <- ldds[[lrep]]
          ## f.sim.reset.envirs()
        }
        ## Walk estimator configurations
        for (lproc in estlist$procedures[lidx]) {
          ## call estimating procedure
          lrr <- tryCatch(do.call(f.estname(lproc$estname),
                                  c(if(use.intercept)
                                    list(lerr ~ .    , data = ldd) else
                                    list(lerr ~ . - 1, data = ldd), lproc$args)),
                          error=function(e)e)
          ERR <- inherits(lrr, 'error')
          if (ERR && !silent) {
            print(lproc$lprocstr)
            print(lrr)
          }
          if (!silent && !converged(lrr)) {
            print(lproc$lprocstr)
            browser() ## <<<
          }
          ## check class: if procedure failed:
          if (ERR) next
          ## check convergence of estimator
          if (!converged(lrr)) next
          ## process output
          for (lov in estlist$output) {
            llnames <- lov$lnames
	    ret <- tryCatch(lres[lrep,llnames,lproc$lprocstr,lerrstr] <- eval(lov$fun),
			    error= function(e)e)
	    if (!silent && inherits(ret, 'error')) {
	      cat('Error', dQuote(ret$message), 'in repetition',lrep,
		  '\n for:',llnames,'procstr:',lproc$lprocstr,'\n')
              browser() ## <<<
              print(lov$fun)
              print(try(eval(lov$fun)))
            }
          }
        }
      }
      ## print debug information if requested
      if (!silent) str(lres)
      lres
  }
  ## restore original order of lprocs
  res <- res[,,match(lprocs, dimnames(res)[[3]]),,drop=FALSE]
  ## set attributes
  attr(res, 'estlist') <- lestlist
  cat("\n")
  res
}

###########################################################################
## build estlist
###########################################################################

f.combine <- function(..., keep.list = FALSE) {
  ## Purpose: creates a list of all combinations of elements given as
  ##          arguments, similar to expand.grid.
  ##          Arguments can be named.
  ##          If an argument is a list, then its elements are considered
  ##          as fixed objects that should not be recombined.
  ##          if keep.list = TRUE, these elements are combined
  ##          as a list with argument.
  ## ----------------------------------------------------------------------
  ## Arguments: collection of lists or vectors with argument names
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  7 Oct 2009, 11:13
  ## convert arguments into a big list
  args <- list(...)
  ## if more than two arguments, call recursively
  if (length(args) > 2)
    lst <- do.call("f.combine", c(args[-1], list(keep.list=keep.list)))
  else {
    ## if just two arguments, create list of second argument
    ## if this is a list, then there's nothing to do
    if (!keep.list && is.list(args[[2]])) lst <- args[[2]]
    ## else convert to a list of one-elements lists with proper name
    else {
      lst <- list()
      for (lelem in args[[2]]) {
        llst <- list(lelem)
        if (!is.null(names(args)[2])) names(llst)[1] <- names(args)[2]
        lst <- c(lst, list(llst))
      }
    }
  }
  ## ok, now we can add the first element to all elements of lst
  lst2 <- list()
  if (keep.list && is.list(args[[1]])) args[[1]] <- lapply(args[[1]], list)
  for (lelem in args[[1]]) {
    for (relem in lst) {
      llst <- c(lelem, relem)
      if (nchar(names(llst)[1]) == 0 && nchar(names(args)[1])>0)
        names(llst)[1] <- names(args)[1]
      lst2 <- c(lst2, list(llst))
    }
  }
  lst2
}

## some fragments to build estlist
## errors
.errs.normal.1 <- list(err = 'normal',
                       args = list(mean = 0, sd = 1))
.errs.normal.2 <- list(err = 'normal',
                       args = list(mean = 0, sd = 2))
.errs.t.13 <- list(err = 't',
                  args = list(df = 13))
.errs.t.11 <- list(err = 't',
                  args = list(df = 11))
.errs.t.10 <- list(err = 't',
                  args = list(df = 10))
.errs.t.9 <- list(err = 't',
                  args = list(df = 9))
.errs.t.8 <- list(err = 't',
                  args = list(df = 8))
.errs.t.7 <- list(err = 't',
                  args = list(df = 7))
.errs.t.5 <- list(err = 't',
                  args = list(df = 5))
.errs.t.3 <- list(err = 't',
                  args = list(df = 3))
.errs.t.1 <- list(err = 't',
                  args = list(df = 1))

## skewed t distribution
.errs.skt.Inf.2 <- list(err = 'cskt',
                         args = list(df = Inf, gamma = 2))
.errs.skt.5.2 <- list(err = 'cskt',
                       args = list(df = 5, gamma = 2))
## log normal distribution
.errs.lnrm <- list(err = 'lnorm',
                   args = list(meanlog = 0, sdlog = 0.6936944))
## laplace distribution
.errs.laplace <- list(err = 'laplace',
                      args = list(location = 0, scale = 1/sqrt(2)))

## contaminated normal
.errs.cnorm..1.0.10 <- list(err = 'cnorm',
                            args = list(epsilon = 0.1, meanc = 0, sdc = sqrt(10)))

.errs.cnorm..1.4.1 <- list(err = 'cnorm',
                           args = list(epsilon = 0.1, meanc = 4, sdc = 1))

.errs.test <- list(.errs.normal.1
                   ,.errs.t.5
                   ,.errs.t.3
                   ,.errs.t.1
                   )

## arguments
.args.final <- f.combine(psi = c('optimal', 'bisquare', 'lqq', 'hampel'),
                         seed = 0,
                         max.it = 500,
                         k.max = 2000,
                         c(list(list(method = 'MM', cov = '.vcov.avar1')),
                           list(list(method = 'MM', cov = '.vcov.w',
                                     start = 'lrr')),
                           f.combine(method = c('SMD', 'SMDM'),
                                     cov = '.vcov.w',
                                     start = 'lrr')))

## use fixInNamespace("lmrob.fit", "robustbase")
## insert:
## N = {
## tmp <- lmrob..M..fit(x = x/init$tau, y = y/init$tau, obj =
## init)
## tmp$qr <- NULL
## tmp
## },

## .args.final <- f.combine(psi = c('optimal', 'bisquare', 'ggw', 'lqq'),
##                          seed = 0,
##                          max.it = 500,
##                          k.max = 2000,
##                          c(list(list(method = "SMDM", cov = '.vcov.w')),
##                            list(list(method = "SMDN", cov = '.vcov.w',
##                                      start = 'lrr'))))


## standard for lmRob
.args.bisquare.lmRob.0 <- list(## initial.alg = 'random',
                               efficiency = 0.95
                               ,weight = c('bisquare', 'bisquare'),
                               trace = FALSE
                               )

.args.optimal.lmRob.0 <- list(## initial.alg = 'random',
                              efficiency = 0.95
                              ,weight = c('optimal', 'optimal'),
                              trace = FALSE)

.procedures.final <- c(list(list(estname = 'lm')),
                       f.combine(estname = 'lmrob.u', args = .args.final,
                                 keep.list = TRUE),
                       f.combine(estname = 'lmrob.mar',
                                 args = f.combine(psi = 'bisquare',
                                   seed = 0, max.it = 500, k.max = 2000,
                                   cov = '.vcov.w', type = c('qT', 'qE')),
                                 keep.list = TRUE),
                       f.combine(estname = 'lm.robust',
                                 args = list(.args.bisquare.lmRob.0,
                                   .args.optimal.lmRob.0), keep.list = TRUE))

## output
.output.sigma <- list(sigma = list(
                        names = quote("sigma"),
                        fun = quote(sigma(lrr))))
.output.beta <- list(beta = list(
                       names = quote(paste('beta',1:npar,sep='_')),
                       fun = quote(coef(lrr))))
.output.se <- list(se = list(
                     names = quote(paste('se',1:npar,sep='_')),
                     fun = quote(sqrt(diag(covariance.matrix(lrr))))))
.output.sumw <- list(sumw = list(
                       names = quote("sumw"),
                       fun = quote(sum(robustness.weights(lrr)))))
.output.nnz <- list(nnz = list(
                      names = quote("nnz"),
                      fun = quote(sum(robustness.weights(lrr) < 1e-3))))

###########################################################################
## simulation results processing functions
###########################################################################

## use apply to aggregate data
## use matplot(t(result)) to plot aggregated data

f.apply <- function(res, items = dimnames(res)[[2]],
                    FUN, ..., swap = FALSE)
{
  ## Purpose: similar to apply, return data not as matrix, but
  ##          as data.frame
  ## ----------------------------------------------------------------------
  ## Arguments: res: simulation results array
  ##            items: items to use in apply
  ##            FUN: function to apply
  ##            ...: additional arguments to FUN
  ##            swap: if TRUE: swap first two columns
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 13:39

  ## aggregate data
  lz <- apply(res[,items,,,drop=FALSE], 2:4, FUN, ...)
  ## if return object has four dimensions (multidim output of FUN)
  ## rotate first three dimensions
  if (length(dim(lz)) == 4 && swap) aperm(lz, perm=c(2,1,3,4)) else lz
}

f.dimnames2df <- function(arr, dm = dimnames(arr),
                          page = TRUE, err.on.same.page = TRUE,
                          value.col = ndim - 2,
                          procstr.col = ndim - 1,
                          errstr.col = ndim,
                          procstr.id = TRUE,
                          split = '_')
{
  ## Purpose: create data frame from dimnames:
  ##          len_1 .. len_100, cpr_1 .. cpr_100
  ##          will yield a data frame with column id from 1 .. 100
  ##          column type with cpr and len and columns procstr and errstr
  ##          It is assumed, that the max number (100) is the same for all
  ##          output value types
  ## ----------------------------------------------------------------------
  ## Arguments: arr: 3 or more dim array (optional)
  ##            dm: dimnames to be used
  ##            page: add a column page to simplify plots
  ##            err.on.same.page: whether all errs should be on the same
  ##                              page
  ##            value.col: index of value column (set to NULL for none)
  ##                       the values in this column are split name_id
  ##                       and put into two columns in the data frame
  ##            procstr.col: index of procedure column
  ##                         (both: or NULL for not to be converted)
  ##            errstr.col: index of error string column
  ##            procstr.id: create procstr id
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 19 Oct 2009, 08:41

  if (!is.list(dm)) stop('f.dimnames2df: dm must be a list')
  ## remove 'NULL' dimensions
  dm <- dm[!sapply(dm,is.null)]
  ndim <- length(dm)
  if (ndim == 0) stop('f.dimnames2df: dimnames all null')
  ldims <- sapply(dm, length)
  ## split and convert types into data.frame
  if (!is.null(value.col)) {
    ldf <- f.splitstrs(dm[[value.col]], split = split)
    lid <- NCOL(ldf) == 2
    if (lid) lids <- unique(as.numeric(ldf[,2])) ## convert ids into numeric
    ## we do not need to repeat over different types of values, only ids
    ldims[value.col] <- ldims[value.col] / length(unique(ldf[,1]))
  }
  ## merge into one large data.frame: for each distribution
  rdf <- list()
  for (ld in 1:ndim) {
    lname <- if (is.null(lname <- names(dm)[ld])) length(rdf)+1 else lname
    ltimes <- if (ld == ndim) 1 else prod(ldims[(ld+1):ndim])
    leach <- if (ld == 1) 1 else prod(ldims[1:(ld-1)])
    if (!is.null(value.col) && ld == value.col) {
      if (lid) rdf[[paste(lname,'Id')]] <-
        rep(lids,times=ltimes,each=leach) ## value ids
      ## no else: the values will be added in the a2df procedures
    } else if (!is.null(procstr.col) && ld == procstr.col) {
      ## convert procstrs to data.frame with pretty names
      lprdf <- data.frame(f.procedures2str(f.str2list(dm[[ld]])),
                          Procstr = factor(dm[[ld]], levels = dm[[ld]],
                            labels = dm[[ld]]))
      if (procstr.id) lprdf$PId <- f.procstr2id(dm[[ld]])
      ## repeat
      lprdf <- if (ltimes == 1 && leach == 1)
        lprdf else apply(lprdf,2,rep,times=ltimes,each=leach)
      lprdf <- as.data.frame(lprdf, stringsAsFactors=FALSE)
      ## convert all into nice factors (with the original ordering)
      for (lk in colnames(lprdf)) {
        luniq <- unique(lprdf[[lk]])
        lprdf[[lk]] <- factor(lprdf[[lk]], levels = luniq, labels = luniq)
      }
      rdf <- c(rdf, lprdf)
    } else if (!is.null(errstr.col) && ld == errstr.col) {
      ## convert errstrs to data.frame with pretty names
      ledf <- f.errs2str(f.str2list(dm[[ld]]))
      ## repeat and convert to factor with correct ordering
      rdf[[lname]] <- factor(rep(dm[[ld]],times=ltimes,each=leach),
                             levels = dm[[ld]], labels = dm[[ld]])
      rdf[['Error']] <- factor(rep(ledf,times=ltimes,each=leach),
                               levels = ledf, labels = ledf)
    } else {
      ## no conversion necessary
      rdf[[lname]] <- rep(dm[[ld]],times=ltimes,each=leach)
    }
  }
  ## add page argument
  if (page && !is.null(procstr.col)) {
    ltpf <- if (!is.null(errstr.col) && !err.on.same.page)
      interaction(rdf[['Procstr']],rdf[['Error']])
    else interaction(rdf[['Procstr']])
    rdf[['Page']] <- as.numeric(factor(ltpf, unique(ltpf)))
  }
  rdf <- as.data.frame(rdf)
  if (!is.null(value.col))
    attr(rdf, 'Types') <- unique(ldf[,1])
  rdf
}

f.a2df.2 <- function(arr, dm = dimnames(arr), err.on.same.page = FALSE, ...)
{
  ## Purpose: convert arr to data.frame
  ##          uses f.dimnames2df and adds a column to contain the values
  ##          if ndim == 4 and dimnames NULL: assumes first dimension is
  ##          data dimension which is ignored by f.dimnames2df
  ##          add counter
  ## ----------------------------------------------------------------------
  ## Arguments: arr: array to convert
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 23 Oct 2009, 12:29

  ## ndim == 2 ??
  ndim <- length(dim(arr))
  ## if ndim == 4: check if dimnames of dim 1 are NULL
  if (ndim == 4 && is.null(dm[[1]]))
      dm[[1]] <- 1:dim(arr)[1]
  rdf <- f.dimnames2df(dm=dm, ...)
  ## just add values for all 'Types', possibly including Type.ID
  if (ndim > 2)
    for (lvt in attr(rdf, 'Types')) {
      llvt <- if (is.null(rdf$Type.Id)) lvt else paste(lvt,unique(rdf$Type.Id),sep='_')
      rdf[[lvt]] <- as.vector(switch(ndim,
                                     stop('wrong number of dimensions'), ## 1
                                     arr, ## 2
                                     arr[llvt,,], ## 3
                                     arr[,llvt,,])) ## 4
    }
  else
    rdf$values <- as.vector(arr)
  rdf
}


f.dimnames2pc.df <- function(arr, dm = dimnames(arr),
                             npcs = NCOL(estlist$design.predict), ...)
{
  ## Purpose: create data frame to be used in plotting of pc components
  ##          calls f.dimnames2df and adds an additional column for
  ##          identifying the principal components
  ## ----------------------------------------------------------------------
  ## Arguments: arr, dm: see f.dimnames.df
  ##            npcs: number of principal components
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 23 Oct 2009, 11:51

  if (missing(npcs) && !is.null(attr(estlist$design.predict, 'npcs')))
    npcs <- attr(estlist$design.predict, 'npcs')

  ## convert into data.frame
  rdf <- f.dimnames2df(dm = dm, ...)
  ## calculate number of points per principal component
  npts <- (length(unique(rdf$Type.Id)) - 1) / npcs
  ## add new column pc
  rdf$PC <- 1
  if (npcs > 1)
    for (li in 2:npcs) {
      lids <- (1:npts + npts*(li-1) + 1)
      rdf$PC[rdf$Type.Id %in% lids] <- li ## fixme: center is not repeated
    }
  rdf$PC <- factor(rdf$PC, levels = 1:npcs, labels = paste('PC',1:npcs,sep=' '))
  rdf
}

f.a2pc.df <- function(arr, ...)
{
  ## Purpose: convert arr to data.frame
  ##          uses f.dimnames2pc.df and adds a column to contain the values
  ## ----------------------------------------------------------------------
  ## Arguments: arr: array to convert
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 23 Oct 2009, 12:29

  ## convert dimnames
  rdf <- f.dimnames2pc.df(arr, err.on.same.page = FALSE,...)
  ## add values
  for (lvt in attr(rdf, 'Types'))
    rdf[[lvt]] <- as.vector(arr[paste(lvt,unique(rdf$Type.Id),sep='_'),,])
  ## repeat values: only PC_1 has center value, add it for other PCs
  ## build index
  idx <- 1:NROW(rdf)
  rpc <- as.character(rdf$PC)
  for (lerr in levels(rdf$Error)) {
    for (lprc in levels(rdf$Procstr)) {
      for (lpc in levels(rdf$PC)) {
        if (lpc == 'PC 1') next
        ## get first entry of this PC
        lmin <- min(which(rdf$Error == lerr & rdf$Procstr == lprc & rdf$PC == lpc))
        ## where is this in idx?
        lwm <- min(which(lmin == idx))
        ## get first entry of PC_1
        lmin1 <- min(which(rdf$Error == lerr & rdf$Procstr == lprc & rdf$PC == 'PC 1'))
        ## update idx
        idx <- c(idx[1:(lwm-1)], lmin1, idx[lwm:length(idx)])
        ## update PC column of result
        rpc <- c(rpc[1:(lwm-1)], lpc, rpc[lwm:length(rpc)])
      }
    }
  }
  ## repeat centers
  rdf <- rdf[idx,]
  ## update PC column
  rdf$PC <- factor(rpc)
  ## return
  rdf
}

f.calculate <- function(expr,arr,dimname = as.character(expr))
{
  ## Purpose: calculate formula and return as conformable array
  ## ----------------------------------------------------------------------
  ## Arguments: expr: expression to calculate (string is also ok)
  ##            arr: array (from f.sim)
  ##            dimname: name of the calculated dimension
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  9 Oct 2009, 10:15

  if (!is.expression(expr)) expr <- as.expression(expr)

  lnams <- dimnames(arr)[[2]]
  lst <- list()
  for (lnam in lnams)
    expr <- gsub(paste(lnam,'\\b',sep=''),
                 paste("arr[,",lnam,",,,drop=FALSE]",sep='"'), expr)

  r <- eval(parse(text = expr))
  dimnames(r)[[2]] <- dimname
  r

  ## maybe use abind to merge the two arrays?
}

f.calculate.many <- function(expr, arr, dimname = dims, dims)
{
  ## Purpose: calculate formula and abind into array
  ##          supply expr as string with # symbols to be replaced
  ##          dimname can also contain # symbols
  ## ----------------------------------------------------------------------
  ## Arguments: same as f.calculate and
  ##            dims: vector of items to replace # with
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 14 Oct 2009, 10:11

  for (i in 1:length(dims)) {
    lexpr <- gsub("#",dims[i],expr)
    ldimname <-
      if (length(dimname) > 1) dimname[i] else gsub("#",dims[i],dimname)
    if (i == 1)
      rarr <- f.calculate(lexpr,arr,ldimname)
    else
      rarr <- abind(rarr, f.calculate(lexpr,arr,ldimname), along=2)
  }

  rarr
}

f.errs <- function(estlist, err, rep, gen = NULL, nobs, npar)
{
  ## Purpose: generate and return errors of specified repetition
  ##          or, if missing, all errors as a matrix
  ## ----------------------------------------------------------------------
  ## Arguments: estlist: estlist
  ##            err: error distribution (estlist$errs[1] for example)
  ##            rep: desired repetition (optional)
  ##            gen: function to generate designs (optional)
  ##            nobs: nr. rows, npap: nr. predictors (both optional)
  ## ---------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 13 Oct 2009, 11:21

  nobs <- NROW(estlist$design)
  nrep <- estlist$nrep
  nlerrs <- nobs*nrep
  npred <- NROW(estlist$design.predict)

  ## get function name and parameters
  lerrfun <- f.errname(err$err)
  lerrpar <- err$args
  lerrstr <- f.list2str(err)
  ## set seed
  set.seed(estlist$seed)
  ## generate errors: seperately for each repetition
  lerrs <- c(sapply(1:nrep, function(x) do.call(lerrfun, c(n = nobs, lerrpar))))
  ## lerrs <- do.call(lerrfun, c(n = nlerrs, lerrpar))
  ## to get to the same seed state as f.sim(.default)
  ## generate also the additional errors
  ## calculate additional number of errors
  for (i in 1:length(estlist$output)) {
    if (!is.null(estlist[['output']][[i]][['nlerrs']]))
      nlerrs <- nlerrs + eval(estlist[['output']][[i]][['nlerrs']])
  }
  if (length(lerrs) < nlerrs)
    nowhere <- do.call(lerrfun, c(n = nlerrs - length(lerrs), lerrpar))
  ## generate designs
  if (!is.null(gen) && is.function(gen)) {
    ldds <- gen(nobs, npar, nrep, err)
  }
  ## return errors
  ret <- if (!missing(rep)) lerrs[1:nobs+(rep-1)*nobs] else matrix(lerrs, nobs)
  if (exists('ldds')) attr(ret, 'designs') <- if (!missing(rep)) ldds[[i]] else ldds
  ret
}

f.selection <- function(procstrs = dimnames(r.test)[[3]],
                        what = c('estname', 'args.method', 'args.psi', 'args.tuning.psi',
                          'args.type', 'args.weight2', 'args.efficiency'),
                        restr = '')
{
  ## Purpose: get selection of results: first one of the specified estimates
  ## ----------------------------------------------------------------------
  ## Arguments: procstrs: what is the selection
  ##            what: named vector to use in grep
  ##            restr: do not select estimators with procstr
  ##                   that match this regexp parameters
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  2 Nov 2009, 09:06

  ## match restrictions
  lrestr <- -(lall <- 1:length(procstrs)) ## no restrictions
  if (!missing(restr)) {
    lrestr <- grep(restr, procstrs)
    if (length(lrestr) == 0) lrestr <- -lall
    procstrs <- procstrs[-lrestr]
  }
  ## procstr2list, but do not split into sublists
  lproclst <- f.str2list(procstrs, splitchar='_____')
  ## helper function: select only items that occur what
  tfun <- function(x) x[what]
  lproclst <- lapply(lproclst, tfun)
  ## convert back to string
  lprocstr <- sapply(lproclst, f.list2str)
  ## get all unique combinations and the first positions
  lidx <- match(unique(lprocstr), lprocstr)
  r <- procstrs[lidx]
  attr(r, 'idx') <- lall[-lrestr][lidx]
  r
}

f.get.current.dimnames <- function(i,dn,margin)
{
  ## Purpose: get current dimnames in the margins of array
  ##          we're applying on
  ## ----------------------------------------------------------------------
  ## Arguments: i:  counter
  ##            dn: dimnames
  ##            margin: margin argument to apply
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 16 Apr 2010, 10:44

  ## pos <- integer(0)
  lcdn <- character(0)

  for (lm in margin) {
    ## get length of current margin
    llen <- length(dn[[lm]])
    ## i modulo llen gives the current position in this dimension
    lpos <- (if (i > 0) i-1 else 0) %% llen + 1
    ## update pos
    ## pos <- c(pos, lpos)
    ## update lcdn
    lcdn <- c(lcdn, dn[[lm]][lpos])
    ## update i: subtract lpos and divide by llen
    i <- (i - lpos) / llen + 1
  }
  lcdn
}

f.n <- Vectorize(function(design)
{
  ## Purpose: get n obs of design
  ## ----------------------------------------------------------------------
  ## Arguments: design: design to get n of
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 19 Apr 2010, 11:19

  NROW(get(design))
})

f.p <- Vectorize(function(design)
{
  ## Purpose: get p par of design
  ## ----------------------------------------------------------------------
  ## Arguments: design: design to get p of
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 19 Apr 2010, 11:19

  NCOL(get(design)) + 1
})

f.which.min <- function(x, nr = 1) {
  ## Purpose: get the indices of the minimal nr of observations
  ## ----------------------------------------------------------------------
  ## Arguments: x: vector of values
  ##            nr: number of indices to return
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  4 May 2010, 12:18
  match(sort(x)[1:nr], x)
}

f.which.max <- function(x, nr = 1) f.which.min(-x, nr)

## f.get.scale <- function(procstr, proclst = f.str2list(procstr))
## {
##   ## Purpose: get scale estimate used for procstrs
##   ## ----------------------------------------------------------------------
##   ## Arguments: procstr: procstrs (dimnames(r.test)[[3]]) as output by
##   ##                     f.list2str()
##   ##            proclst: list of procedures, as in estlist$procedures
##   ## ----------------------------------------------------------------------
##   ## Author: Manuel Koller, Date:  9 Sep 2010, 13:52

##   ret <- list()

##   for (lproc in proclst) {
##     if (lproc$estname == 'lm') {
##       ## least squares
##       ret <- c(ret, list(list(fun='f.lsq')))
##     } else {
##       ## default (S-scale):
##       fun <- 'lmrob.mscale'
##       lidx <- names(lproc$args)[na.omit(match(c('psi', 'tuning.chi', 'seed'),
##                                               names(lproc$args)))]

##       if (!is.null(lproc$args$method) &&
##                substr(lproc$args$method,1,3) == 'SMD') {
##         ## D-scale
##         fun <- 'lmrob.dscale'
##         lidx <- names(lproc$args)[na.omit(match(c('psi', 'tuning.psi'),
##                                               names(lproc$args)))]
##       } else if (lproc$estname == 'lmrob.mar' ### continue here
##       ret <- c(ret, list(list(fun=fun, args=lproc$args[lidx])))
##     }

## })



###########################################################################
## functions related to prediction
###########################################################################

f.prediction.points <- function(design, type = c('pc', 'grid'),
                                length.out = 4*NCOL(design), f = 0.5,
                                direction = +1, max.pc = 5)
{
  ## Purpose: generate prediction points for design
  ##          generate four points along the second principal component
  ##          in the center, 2 intermediate distances and long distance
  ##          (from the center)
  ## ----------------------------------------------------------------------
  ## Arguments: design: design matrix
  ##            type: type of prediction points: grid / principal components
  ##            length.out: approximate number of prediction points
  ##            f: extend range by f (like extendrange())
  ##            direction: +1 or -1: which direction to go from the center
  ##            max.pc: maximum number of principal components to use
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  9 Oct 2009, 16:48

  ## match type argument
  type = match.arg(type)
  ## get ranges
  lrange <- apply(design, 2, range)
  ## extend range by f
  lrange <- data.frame(apply(lrange, 2, extendrange, f = f))

  switch(type,
         pc = {
           ## calculate robust covariance matrix
           rob <- covMcd(design)
           ## and use it to calculate the principal components
           rpc <- princomp(covmat = rob$cov)
           ## get corner with maximum distance from rob$center
           lidx <- apply(abs(lrange - rob$center),2,which.max)
           lcr <- diag(as.matrix(lrange[lidx,]))
           ## create grid points:
           rdf <- rob$center
           ## for each principal component
           for (id in 1:min(NCOL(rpc$loadings),max.pc)) {
             ## calculate factor to reach each boundary
             lfct <- (lcr - rob$center) / rpc$loadings[,id]
             ## calculate distances to boundaries and take the minimal one
             lmin <- which.min(sapply(lfct, function(x) sum((rpc$loadings[,id] * x)^2)))
             ## create sequence of multiplicands
             lmult <- seq(0,lfct[lmin],length.out=length.out/NCOL(rpc$loadings))
             rdf <- rbind(rdf, rep(rob$center,each=length(lmult)-1) +
                          direction*lmult[-1] %*% t(rpc$loadings[,id]))
           }
         },
         grid = {
           ## generate sequences for every dimension
           lval <- as.data.frame(apply(lrange,2,f.seq,
                                       length.out = round(length.out^(1/NCOL(design))) ))
           ## return if 1 dimension, otherwise create all combinations
           rdf <- if (NCOL(design) > 1)
             t(as.data.frame(do.call('f.combine', lval))) else lval

         })
  rdf <- as.data.frame(rdf)
  rownames(rdf) <- NULL
  colnames(rdf) <- colnames(design)
  if (type == 'pc') attr(rdf, 'npcs') <- id
  rdf
}

## ## plot with
## require(rgl)
## plot3d(design)
## points3d(f.prediction.points(design), col = 2)

## d.data <- data.frame(y = rnorm(10), x = 1:10)
## pred <- f.prediction.points(d.data[,-1,drop=FALSE])
## obj <- f.lmrob.local(y ~ x, d.data)
## f.predict(obj, pred, interval = 'prediction')
## as.vector(t(cbind(rnorm(4), f.predict(obj, pred, interval = 'prediction'))))

## estlist for prediction:
## start with .output.test
## we only need sigma
.output.prediction <- c(.output.sigma,.output.beta,.output.se,.output.sumw,.output.nnz)
.output.prediction$predict <-
  list(names = quote({
    npred <- NROW(estlist$design.predict)
    paste(c('fit', 'lwr', 'upr', 'se.fit', 'cpr'),
          rep(1:npred,each = 5), sep = '_')}),
       fun = quote({
         lpr <- f.predict(lrr, estlist$design.predict, interval = 'prediction',
                          se.fit = TRUE) ##, df = 16)
         lpr <- cbind(lpr$fit, lpr$se.fit)
         lqf <- f.errname(lerrlst$err, 'p')
         lcpr <- do.call(lqf, c(list(lpr[,'upr']), lerrpar)) -
           do.call(lqf, c(list(lpr[,'lwr']), lerrpar))
         as.vector(t(cbind(lpr,lcpr)))}))

.estlist.prediction <- list(design = dd,
                            nrep = 200,
                            errs = .errs.test,
                            seed = 0,
                            procedures = .procedures.final,
                            design.predict = f.prediction.points(dd),
                            output = .output.prediction,
                            use.intercept = TRUE)

## predict confidence intervals instead of prediction intervals
.estlist.confint <- .estlist.prediction
.estlist.confint$output$predict$fun <-
  parse(text=gsub('prediction', 'confidence', deparse(.output.prediction$predict$fun)))

###########################################################################
## Generate designs - function
###########################################################################

f.gen <- function(n, p, rep, err) {
  ## get function name and parameters
  lerrfun <- f.errname(err$err)
  lerrpar <- err$args
  ## generate random predictors
  ret <- lapply(1:rep, function(...)
                data.frame(matrix(do.call(lerrfun, c(n = n*p, lerrpar)), n, p)))
  attr(ret[[1]], 'gen') <- f.gen
  ret
}

.output.sigmaE <- list(sigmaE = list(
                     names = quote("sigmaE"),
                     fun = quote({
                       ## estimate scale using current scale estimate.
                       ## this amounts to recalculating the estimate
                       ## with just an intercept
                       llargs <- lproc$args
                       llestname <- lproc$estname
                       ## save time and just calculate S-estimate and no covariance matrix
                       if (grepl('^lmrob', llestname)) {
                         llestname <- 'lmrob'
                         llargs$cov <- 'none'
                         llargs$envir <- NULL ## drop envir argument
                         if (llargs$method %in% c('MM', 'SM')) llargs$method <- 'S'
                         if (grepl('M$', llargs$method))
                           llargs$method <- f.chop(llargs$method)
                       } else if (lproc$estname == 'lm.robust') {
                         llargs$estim <- 'Initial'
                       }
                       llrr <- tryCatch(do.call(f.estname(lproc$estname),
                                                c(list(lerr ~ 1), llargs)),
                                        error = function(e)e)
                       ## check class: if procedure failed: class == 'try-error'
                       if (inherits(llrr, 'error')) NA
                       ## check convergence of estimator
                       else if (lproc$estname != 'lm.robust' && !converged(llrr)) NA
                       else sigma(llrr)
                     })))

