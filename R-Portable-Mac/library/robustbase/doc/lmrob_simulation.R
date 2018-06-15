### R code from vignette source 'lmrob_simulation.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: initial-setup
###################################################
## set options
options(width=60,
        warn=1) # see warnings where they happen (should eliminate)

## number of workers to start
if(FALSE) {## good for pkg developers
    options(cores=  max(1, parallel::detectCores() - 2))
} else { ## CRAN allows maximum of 2:
    options(cores= min(2, parallel::detectCores()))
}

## Number of Repetitions:
N <- 1000

## get path (= ../inst/doc/ in source pkg)
robustDoc <- system.file('doc', package='robustbase')
robustDta <- robustDoc

## initialize (packages, data, ...):
source(file.path(robustDoc, 'simulation.init.R')) # 'xtable'

## set the amount of trimming used in calculation of average results
trim <- 0.1



###################################################
### code chunk number 2: graphics-setup
###################################################
## load required packages for graphics
stopifnot(require(ggplot2),
          require(GGally),# for ggpairs() which replaces ggplot2::plotmatrix()
          require(grid),
          require(reshape2))
source(file.path(robustDoc, 'graphics.functions.R'))

## set ggplot theme
theme <- theme_bw(base_size = 10)
theme$legend.key.size <- unit(1, "lines")# was 0.9 in pre-v.3 ggplot2
theme$plot.margin <- unit(c(1/2, 1/8, 1/8, 1/8), "lines")# was (1/2, 0,0,0)
theme_set(theme)
## set default sizes for lines and points
update_geom_defaults("point",  list(size = 4/3))
update_geom_defaults("line",   list(size = 1/4))
update_geom_defaults("hline",  list(size = 1/4))
update_geom_defaults("smooth", list(size = 1/4))
## alpha value for plots with many points
alpha.error <- 0.3
alpha.n <- 0.4

## set truncation limits used by f.truncate() & g.truncate.*:
trunc <- c(0.02, 0.14)
trunc.plot <- c(0.0185, 0.155)

f.truncate <- function(x, up = trunc.plot[2], low = trunc.plot[1]) {
  x[x > up] <- up
  x[x < low] <- low
  x
}

g.truncate.lines <- geom_hline(yintercept = trunc,
                               color = theme$panel.border$colour)
g.truncate.line <- geom_hline(yintercept = trunc[2],
                              color = theme$panel.border$colour)
g.truncate.areas <- annotate("rect", xmin=rep(-Inf,2), xmax=rep(Inf,2),
                             ymin=c(0,Inf), ymax=trunc,
                             fill = theme$panel.grid.major$colour)
g.truncate.area <- annotate("rect", xmin=-Inf, xmax=Inf,
                            ymin=trunc[2], ymax=Inf,
                            fill = theme$panel.grid.major$colour)

legend.mod <- list(`SMD.Wtau` = quote('SMD.W'~tau),
                   `SMDM.Wtau` = quote('SMDM.W'~tau),
                   `MM.Avar1` = quote('MM.'~Avar[1]),
                   `MMqT` = quote('MM'~~q[T]),
                   `MMqT.Wssc` = quote('MM'~~q[T]*'.Wssc'),
                   `MMqE` = quote('MM'~~q[E]),
                   `MMqE.Wssc` = quote('MM'~~q[E]*'.Wssc'),
                   `sigma_S` = quote(hat(sigma)[S]),
                   `sigma_D` = quote(hat(sigma)[D]),
                   `sigma_S*qE` = quote(q[E]*hat(sigma)[S]),
                   `sigma_S*qT` = quote(q[T]*hat(sigma)[S]),
                   `sigma_robust` = quote(hat(sigma)[robust]),
                   `sigma_OLS` = quote(hat(sigma)[OLS]),
                   `t1` = quote(t[1]),
                   `t3` = quote(t[3]),
                   `t5` = quote(t[5]),
                   `cskt(Inf,2)` = quote(cskt(infinity,2))
                   )


###################################################
### code chunk number 3: tab-psi-functions
###################################################
## get list of psi functions
lst <- lapply(estlist$procedures, function(x) {
  if (is.null(x$args)) return(list(NULL, NULL, NULL))
  if (!is.null(x$args$weight))
    return(list(x$args$weight[2],
                round(f.psi2c.chi(x$args$weight[1]),3),
                round(f.eff2c.psi(x$args$efficiency, x$args$weight[2]),3)))
  return(list(x$args$psi,
              round(if (is.null(x$args$tuning.chi))
                    lmrob.control(psi=x$args$psi)$tuning.chi else
                    x$args$tuning.chi,3),
              round(if (is.null(x$args$tuning.psi))
                    lmrob.control(psi=x$args$psi)$tuning.psi else
                    x$args$tuning.psi,3)))
})
lst <- unique(lst) ## because of rounding, down from 21 to 5 !
lst <- lst[sapply(lst, function(x) !is.null(x[[1]]))] # 5 --> 4
## convert to table
tbl <- do.call(rbind, lst)
tbl[,2:3] <- apply(tbl[,2:3], 1:2, function(x) {
  gsub('\\$NA\\$', '\\\\texttt{NA}',
       paste('$', unlist(x), collapse=', ', '$', sep='')) })
tbl[,1] <- paste('\\texttt{', tbl[,1], '}', sep='')
colnames(tbl) <- paste('\\texttt{', c('psi', 'tuning.chi', 'tuning.psi'),
                       '}', sep='')
print(xtable(tbl), sanitize.text.function=identity,
      include.rownames = FALSE, floating=FALSE)


###################################################
### code chunk number 4: fig-psi-functions
###################################################
getOption("SweaveHooks")[["fig"]]()
d.x_psi <- function(x, psi) {
  cc <- lmrob.control(psi = psi)$tuning.psi
  data.frame(x=x, value=Mpsi(x, cc, psi), psi = psi)
}
x <- seq(0, 10, length.out = 1000)
tmp <- rbind(d.x_psi(x, 'optimal'),
             d.x_psi(x, 'bisquare'),
             d.x_psi(x, 'lqq'),
             d.x_psi(x, 'hampel'))
print( ggplot(tmp, aes(x, value, color = psi)) +
       geom_line(lwd=1.25) + ylab(quote(psi(x))) +
       scale_color_discrete(name = quote(psi ~ '-function')))


###################################################
### code chunk number 5: fgen
###################################################

f.gen <- function(n, p, rep, err) {
  ## get function name and parameters
  lerrfun <- f.errname(err$err)
  lerrpar <- err$args
  ## generate random predictors
  ret <- replicate(rep, matrix(do.call(lerrfun, c(n = n*p, lerrpar)),
                               n, p), simplify=FALSE)
  attr(ret[[1]], 'gen') <- f.gen
  ret
}

ratios <- c(1/20, 1/10, 1/5, 1/3, 1/2)## p/n
lsit <- expand.grid(n = c(25, 50, 100, 400), p = ratios)
lsit <- within(lsit, p <- as.integer(n*p))
.errs.normal.1 <- list(err = 'normal',
                       args = list(mean = 0, sd = 1))
for (i in 1:NROW(lsit))
  assign(paste('rand',lsit[i,1],lsit[i,2],sep='_'),
         f.gen(lsit[i,1], lsit[i,2], rep = 1, err = .errs.normal.1)[[1]])


###################################################
### code chunk number 6: fig-example-design
###################################################
getOption("SweaveHooks")[["fig"]]()
require(GGally)
colnames(rand_25_5) <- paste0("X", 1:5) # workaround new (2014-12) change in GGally
## and the 2016-11-* change needs data frames:
df.r_25_5 <- as.data.frame(rand_25_5)
print(ggpairs(df.r_25_5, axisLabels="show", title = "rand_25_5: n=25, p=5"))


###################################################
### code chunk number 7: lmrob_simulation.Rnw:363-364
###################################################
aggrResultsFile <- file.path(robustDta, "aggr_results.Rdata")


###################################################
### code chunk number 8: simulation-run
###################################################
if (!file.exists(aggrResultsFile)) {
  ## load packages required only for simulation
  stopifnot(require(robust),
            require(skewt),
            require(foreach))
  if (!is.null(getOption("cores"))) {
      if (getOption("cores") == 1)
          registerDoSEQ() ## no not use parallel processing
      else {
          stopifnot(require(doParallel))
          if (.Platform$OS.type == "windows") {
              cl <- makeCluster(getOption("cores"))
              clusterExport(cl, c("N", "robustDoc"))
              clusterEvalQ(cl, slave <- TRUE)
              clusterEvalQ(cl, source(file.path(robustDoc, 'simulation.init.R')))
              registerDoParallel(cl)
          } else registerDoParallel()
      }
  } else registerDoSEQ() ## no not use parallel processing
  for (design in c("dd", ls(pattern = 'rand_\\d+_\\d+'))) {
    print(design)
    ## set design
    estlist$design <- get(design)
    estlist$use.intercept <- !grepl('^rand', design)
    ## add design.predict: pc
    estlist$design.predict <-
      if (is.null(attr(estlist$design, 'gen')))
        f.prediction.points(estlist$design) else
      f.prediction.points(estlist$design, max.pc = 2)

    filename <- file.path(robustDta,
                          sprintf('r.test.final.%s.Rdata',design))
    if (!file.exists(filename)) {
      ## run
      print(system.time(r.test <- f.sim(estlist, silent = TRUE)))
      ## save
      save(r.test, file=filename)
      ## delete output
      rm(r.test)
      ## run garbage collection
      gc()
    }
  }
}


###################################################
### code chunk number 9: str-estlist
###################################################
str(estlist, 1)


###################################################
### code chunk number 10: estl-errs
###################################################
estlist$errs[[1]]


###################################################
### code chunk number 11: show-errs (eval = FALSE)
###################################################
## set.seed(estlist$seed)
## errs <- c(sapply(1:nrep, function(x) do.call(fun, c(n = nobs, args))))


###################################################
### code chunk number 12: lmrob_simulation.Rnw:441-442
###################################################
str(estlist$output[1:3], 2)


###################################################
### code chunk number 13: simulation-aggr
###################################################
if (!file.exists(aggrResultsFile)) {
  files <- list.files(robustDta, pattern = 'r.test.final\\.')
  res <- foreach(file = files) %dopar% {
    ## get design, load r.test, initialize other stuff
    design <- substr(basename(file), 14, nchar(basename(file)) - 6)
    cat(design, ' ')
    load(file.path(robustDta, file))
    estlist <- attr(r.test, 'estlist')
    use.intercept <-
      if (!is.null(estlist$use.intercept)) estlist$use.intercept else TRUE
    sel <- dimnames(r.test)[[3]] ## [dimnames(r.test)[[3]] != "estname=lm"]
    n.betas <- paste('beta',1:(NCOL(estlist$design)+use.intercept),sep='_')
    ## get design
    lX <- if (use.intercept)
      as.matrix(cbind(1, get(design))) else as.matrix(get(design))
    n <- NROW(lX)
    p <- NCOL(lX)
    ## prepare arrays for variable designs and leverages
    if (is.function(attr(estlist$design, 'gen'))) {
      lXs <- array(NA, c(n, NCOL(lX), dim(r.test)[c(1, 4)]),
                   list(Obs = NULL, Pred = colnames(lX), Data = NULL,
                        Errstr = dimnames(r.test)[[4]]))
    }
    ## generate errors
    lerrs <- array(NA, c(n, dim(r.test)[c(1,4)]) ,
                   list(Obs = NULL, Data = NULL, Errstr = dimnames(r.test)[[4]]))
    for (i in 1:dim(lerrs)[3]) {
      lerrstr <- f.list2str(estlist$errs[[i]])
      lerr <- f.errs(estlist, estlist$errs[[i]],
                     gen = attr(estlist$design, 'gen'),
                     nobs = n, npar = NCOL(lX))
      lerrs[,,lerrstr] <- lerr
      if (!is.null(attr(lerr, 'designs'))) {
        ## retrieve generated designs: this returns a list of designs
        lXs[,,,i] <- unlist(attr(lerr, 'designs'))
        if (use.intercept)
          stop('intercept not implemented for random desings')
      }
      rm(lerr)
    }
    if (is.function(attr(estlist$design, 'gen'))) {
      ## calculate leverages
      lXlevs <- apply(lXs, 3:4, .lmrob.hat)
    }
    ## calculate fitted values from betas
    if (!is.function(attr(estlist$design, 'gen'))) { ## fixed design case
      lfitted <- apply(r.test[,n.betas,sel,,drop=FALSE],c(3:4),
                       function(bhat) { lX %*% t(bhat) } )
    } else { ## variable design case
      lfitted <- array(NA, n*prod(dim(r.test)[c(1,4)])*length(sel))
      lfitted <- .C('R_calc_fitted',
                    as.double(lXs), ## designs
                    as.double(r.test[,n.betas,sel,,drop=FALSE]), ## betas
                    as.double(lfitted), ## result
                    as.integer(n), ## n
                    as.integer(p), ## p
                    as.integer(dim(r.test)[1]), ## nrep
                    as.integer(length(sel)), ## n procstr
                    as.integer(dim(r.test)[4]), ## n errstr
                    DUP=FALSE, NAOK=TRUE, PACKAGE="robustbase")[[3]]
    }
    tdim <- dim(lfitted) <-
      c(n, dim(r.test)[1], length(sel),dim(r.test)[4])
    lfitted <- aperm(lfitted, c(1,2,4,3))
    ## calculate residuals = y - fitted.values
    lfitted <- as.vector(lerrs) - as.vector(lfitted)
    dim(lfitted) <- tdim[c(1,2,4,3)]
    lfitted <- aperm(lfitted, c(1,2,4,3))
    dimnames(lfitted) <-
      c(list(Obs = NULL), dimnames(r.test[,,sel,,drop=FALSE])[c(1,3,4)])
    lresids <- lfitted
    rm(lfitted)
    ## calculate lm MSE and trim trimmed MSE of betas
    tf.MSE <- function(lbetas) {
      lnrm <- rowSums(lbetas^2)
      c(MSE=mean(lnrm,na.rm=TRUE),MSE.1=mean(lnrm,trim=trim,na.rm=TRUE))
    }
    MSEs <- apply(r.test[,n.betas,,,drop=FALSE],3:4,tf.MSE)
    li <- 1 ## so we can reconstruct where we are
    lres <- apply(lresids,3:4,f.aggregate.results <- {
      function(lresid) {
        ## the counter li tells us, where we are
        ## we walk dimensions from left to right
        lcdn <- f.get.current.dimnames(li, dimnames(lresids), 3:4)
        lr <- r.test[,,lcdn[1],lcdn[2]]
        ## update counter
        li <<- li + 1
        ## transpose and normalize residuals with sigma
        lresid <- t(lresid) / lr[,'sigma']
        if (lcdn[1] != 'estname=lm') {
          ## convert procstr to proclst and get control list
          largs <- f.str2list(lcdn[1])[[1]]$args
          if (grepl('lm.robust', lcdn[1])) {
            lctrl <- list()
            lctrl$psi <- toupper(largs$weight2)
            lctrl$tuning.psi <-
              f.eff2c.psi(largs$efficiency, lctrl$psi)
            lctrl$method <- 'MM'
          } else {
            lctrl <- do.call('lmrob.control',largs)
          }
          ## calculate correction factors
          ## A
          lsp2 <- rowSums(Mpsi(lresid,lctrl$tuning.psi, lctrl$psi)^2)
          ## B
          lspp <- rowSums(lpp <- Mpsi(lresid,lctrl$tuning.psi, lctrl$psi,1))
          ## calculate Huber\'s small sample correction factor
          lK <- 1 + rowSums((lpp - lspp/n)^2)*NCOL(lX)/lspp^2 ## 1/n cancels
        } else {
          lK <- lspp <- lsp2 <- NA
        }
        ## only calculate tau variants if possible
        if (grepl('args.method=\\w*(D|T)\\w*\\b', lcdn[1])) { ## SMD or SMDM
          ## calculate robustness weights
          lwgts <- Mwgt(lresid, lctrl$tuning.psi, lctrl$psi)
          ## function to calculate robustified leverages
          tfun <-
            if (is.function(attr(estlist$design, 'gen')))
              function(i) {
                if (all(is.na(wi <- lwgts[i,]))) wi
                else .lmrob.hat(lXs[,,i,lcdn[2]],wi)
              }
            else
              function(i) {
                if (all(is.na(wi <- lwgts[i,]))) wi else .lmrob.hat(lX, wi)
              }
          llev <- sapply(1:dim(r.test)[1], tfun)
          ## calculate unique leverages
          lt <- robustbase:::lmrob.tau(list(),h=llev,control=lctrl)
          ## normalize residuals with tau (transpose lresid)
          lresid <- t(lresid) / lt
          ## A
          lsp2t <- colSums(Mpsi(lresid,lctrl$tuning.psi,
                                lctrl$psi)^2)
          ## B
          lsppt <- colSums(Mpsi(lresid,lctrl$tuning.psi,
                                                     lctrl$psi,1))
        } else {
          lsp2t <- lsppt <- NA
        }

        ## calculate raw scales based on the errors
        lproc <- f.str2list(lcdn[1])[[1]]
        q <- NA
        M <- NA
        if (lproc$estname == 'lmrob.mar' && lproc$args$type == 'qE') {
          ## for lmrob_mar, qE variant
          lctrl <- lmrob.control(psi = 'bisquare',
                                 tuning.chi=uniroot(function(c)
                                   robustbase:::lmrob.bp('bisquare', c) - (1-p/n)/2,
                                   c(1, 3))$root)
          se <- apply(lerrs[,,lcdn[2]],2,lmrob.mscale,control=lctrl,p=p)
          ltmp <- se/lr[,'sigma']
          q <- median(ltmp, na.rm = TRUE)
          M <- mad(ltmp, na.rm = TRUE)
        } else if (!is.null(lproc$args$method) && lproc$args$method == 'SMD') {
          ## for D-scales
          se <- apply(lerrs[,,lcdn[2]],2,lmrob.dscale,control=lctrl,
                      kappa=robustbase:::lmrob.kappa(control=lctrl))
          ltmp <- se/lr[,'sigma']
          q <- median(ltmp, na.rm = TRUE)
          M <- mad(ltmp, na.rm = TRUE)
        }

        ## calculate empirical correct test value (to yield 5% level)
        t.val_2 <- t.val_1 <- quantile(abs(lr[,'beta_1']/lr[,'se_1']), 0.95,
                                       na.rm = TRUE)
        if (p > 1) t.val_2 <- quantile(abs(lr[,'beta_2']/lr[,'se_2']), 0.95,
                                       na.rm = TRUE)

        ## return output: summary statistics:
        c(## gamma
          AdB2.1 = mean(lsp2/lspp^2,trim=trim,na.rm=TRUE)*n,
          K2AdB2.1 = mean(lK^2*lsp2/lspp^2,trim=trim,na.rm=TRUE)*n,
          AdB2t.1 = mean(lsp2t/lsppt^2,trim=trim,na.rm=TRUE)*n,
          sdAdB2.1 = sd.trim(lsp2/lspp^2*n,trim=trim,na.rm=TRUE),
          sdK2AdB2.1 = sd.trim(lK^2*lsp2/lspp^2*n,trim=trim,na.rm=TRUE),
          sdAdB2t.1 = sd.trim(lsp2t/lsppt^2*n,trim=trim,na.rm=TRUE),
          ## sigma
          medsigma = median(lr[,'sigma'],na.rm=TRUE),
          madsigma = mad(lr[,'sigma'],na.rm=TRUE),
          meansigma.1 = mean(lr[,'sigma'],trim=trim,na.rm=TRUE),
          sdsigma.1 = sd.trim(lr[,'sigma'],trim=trim,na.rm=TRUE),
          meanlogsigma = mean(log(lr[,'sigma']),na.rm=TRUE),
          meanlogsigma.1 = mean(log(lr[,'sigma']),trim=trim,na.rm=TRUE),
          sdlogsigma = sd(log(lr[,'sigma']),na.rm=TRUE),
          sdlogsigma.1 = sd.trim(log(lr[,'sigma']),trim=trim,na.rm=TRUE),
          q = q,
          M = M,
          ## beta
          efficiency.1 = MSEs['MSE.1','estname=lm',lcdn[2]] /
          MSEs['MSE.1',lcdn[1],lcdn[2]],
          ## t-value: level
          emplev_1 = mean(abs(lr[,'beta_1']/lr[,'se_1']) > qt(0.975, n - p),
            na.rm = TRUE),
          emplev_2 = if (p>1) {
            mean(abs(lr[,'beta_2']/lr[,'se_2']) > qt(0.975, n - p), na.rm = TRUE)
          } else NA,
          ## t-value: power
          power_1_0.2 = mean(abs(lr[,'beta_1']-0.2)/lr[,'se_1'] > t.val_1,
            na.rm = TRUE),
          power_2_0.2 = if (p>1) {
            mean(abs(lr[,'beta_2']-0.2)/lr[,'se_2'] > t.val_2, na.rm = TRUE)
          } else NA,
          power_1_0.4 = mean(abs(lr[,'beta_1']-0.4)/lr[,'se_1'] > t.val_1,
            na.rm = TRUE),
          power_2_0.4 = if (p>1) {
            mean(abs(lr[,'beta_2']-0.4)/lr[,'se_2'] > t.val_2, na.rm = TRUE)
          } else NA,
          power_1_0.6 = mean(abs(lr[,'beta_1']-0.6)/lr[,'se_1'] > t.val_1,
            na.rm = TRUE),
          power_2_0.6 = if (p>1) {
            mean(abs(lr[,'beta_2']-0.6)/lr[,'se_2'] > t.val_2, na.rm = TRUE)
          } else NA,
          power_1_0.8 = mean(abs(lr[,'beta_1']-0.8)/lr[,'se_1'] > t.val_1,
            na.rm = TRUE),
          power_2_0.8 = if (p>1) {
            mean(abs(lr[,'beta_2']-0.8)/lr[,'se_2'] > t.val_2, na.rm = TRUE)
          } else NA,
          power_1_1 = mean(abs(lr[,'beta_1']-1)/lr[,'se_1'] > t.val_1,
            na.rm = TRUE),
          power_2_1 = if (p>1) {
            mean(abs(lr[,'beta_2']-1)/lr[,'se_2'] > t.val_2, na.rm = TRUE)
          } else NA,
          ## coverage probability: calculate empirically
          ## the evaluation points are constant, but the designs change
          ## therefore this makes only sense for fixed designs
          cpr_1 = mean(lr[,'upr_1'] < 0 | lr[,'lwr_1'] > 0, na.rm = TRUE),
          cpr_2 = mean(lr[,'upr_2'] < 0 | lr[,'lwr_2'] > 0, na.rm = TRUE),
          cpr_3 = mean(lr[,'upr_3'] < 0 | lr[,'lwr_3'] > 0, na.rm = TRUE),
          cpr_4 = mean(lr[,'upr_4'] < 0 | lr[,'lwr_4'] > 0, na.rm = TRUE),
          cpr_5 = if (any(colnames(lr) == 'upr_5')) {
            mean(lr[,'upr_5'] < 0 | lr[,'lwr_5'] > 0, na.rm = TRUE) } else NA,
          cpr_6 = if (any(colnames(lr) == 'upr_6')) {
            mean(lr[,'upr_6'] < 0 | lr[,'lwr_6'] > 0, na.rm = TRUE) } else NA,
          cpr_7 = if (any(colnames(lr) == 'upr_7')) {
            mean(lr[,'upr_7'] < 0 | lr[,'lwr_7'] > 0, na.rm = TRUE) } else NA
          )
      }})

    ## convert to data.frame
    lres <- f.a2df.2(lres, split = '___NO___')
    ## add additional info
    lres$n <- NROW(lX)
    lres$p <- NCOL(lX)
    lres$nmpdn <- with(lres, (n-p)/n)
    lres$Design <- design

    ## clean up
    rm(r.test, lXs, lXlevs, lresids, lerrs)
    gc()
    ## return lres
    lres
  }
  save(res, trim, file = aggrResultsFile)
  ## stop cluster
  if (exists("cl")) stopCluster(cl)
}


###################################################
### code chunk number 14: simulation-aggr2
###################################################
load(aggrResultsFile)
## this will fail if the file is not found (for a reason)
## set eval to TRUE for chunks simulation-run and simulation-aggr
## if you really want to run the simulations again.
## (better fail with an error than run for weeks)

## combine list elements to data.frame
test.1 <- do.call('rbind', res)
test.1 <- within(test.1, {
  Method[Method == "SM"] <- "MM"
  Method <- Method[, drop = TRUE]
  Estimator <- interaction(Method, D.type, drop = TRUE)
  Estimator <- f.rename.level(Estimator, 'MM.S', 'MM')
  Estimator <- f.rename.level(Estimator, 'SMD.D', 'SMD')
  Estimator <- f.rename.level(Estimator, 'SMDM.D', 'SMDM')
  Estimator <- f.rename.level(Estimator, 'MM.qT', 'MMqT')
  Estimator <- f.rename.level(Estimator, 'MM.qE', 'MMqE')
  Estimator <- f.rename.level(Estimator, 'MM.rob', 'MMrobust')
  Estimator <- f.rename.level(Estimator, 'lsq.lm', 'OLS')
  Est.Scale <- f.rename.level(Estimator, 'MM', 'sigma_S')
  Est.Scale <- f.rename.level(Est.Scale, 'MMrobust', 'sigma_robust')
  Est.Scale <- f.rename.level(Est.Scale, 'MMqE', 'sigma_S*qE')
  Est.Scale <- f.rename.level(Est.Scale, 'MMqT', 'sigma_S*qT')
  Est.Scale <- f.rename.level(Est.Scale, 'SMDM', 'sigma_D')
  Est.Scale <- f.rename.level(Est.Scale, 'SMD', 'sigma_D')
  Est.Scale <- f.rename.level(Est.Scale, 'OLS', 'sigma_OLS')
  Psi <- f.rename.level(Psi, 'hampel', 'Hampel')
})
## add interaction of Method and Cov
test.1 <- within(test.1, {
  method.cov <- interaction(Estimator, Cov, drop=TRUE)
  levels(method.cov) <-
    sub('\\.+vcov\\.(a?)[wacrv1]*', '\\1', levels(method.cov))
  method.cov <- f.rename.level(method.cov, "MMa", "MM.Avar1")
  method.cov <- f.rename.level(method.cov, "MMrobust.Default", "MMrobust.Wssc")
  method.cov <- f.rename.level(method.cov, "MM", "MM.Wssc")
  method.cov <- f.rename.level(method.cov, "SMD", "SMD.Wtau")
  method.cov <- f.rename.level(method.cov, "SMDM", "SMDM.Wtau")
  method.cov <- f.rename.level(method.cov, "MMqT", "MMqT.Wssc")
  method.cov <- f.rename.level(method.cov, "MMqE", "MMqE.Wssc")
  method.cov <- f.rename.level(method.cov, "OLS.Default", "OLS")
  ## ratio: the closest 'desired ratios' instead of exact p/n;
  ##        needed in plots only for stat_*(): median over "close" p/n's:
  ratio <- ratios[apply(abs(as.matrix(1/ratios) %*% t(as.matrix(p / n)) - 1),
                        2, which.min)]
})

## calculate expected values of psi^2 and psi'
test.1$Ep2 <- test.1$Epp <- NA
for(Procstr in levels(test.1$Procstr)) {
  args <- f.str2list(Procstr)[[1]]$args
  if (is.null(args)) next
  lctrl <- do.call('lmrob.control',args)
  test.1$Ep2[test.1$Procstr == Procstr] <-
    robustbase:::lmrob.E(psi(r)^2, lctrl, use.integrate = TRUE)
  test.1$Epp[test.1$Procstr == Procstr] <-
    robustbase:::lmrob.E(psi(r,1), lctrl, use.integrate = TRUE)
}
## drop some observations, separate fixed and random designs
test.fixed <- droplevels(subset(test.1, n == 20)) ## n = 20 -- fixed  design
test.1     <- droplevels(subset(test.1, n != 20)) ## n !=20 -- random designs
test.lm <- droplevels(subset(test.1, Function == 'lm')) # lm = OLS
test.1  <- droplevels(subset(test.1, Function != 'lm')) # Rob := all "robust"
test.lm$Psi <- NULL
test.lm.2 <- droplevels(subset(test.lm, Error == 'N(0,1)'))                   # OLS for N(*)
test.2    <- droplevels(subset(test.1,  Error == 'N(0,1)' & Function != 'lm'))# Rob for N(*)
## subsets
test.3 <- droplevels(subset(test.2, Method != 'SMDM'))# Rob, not SMDM  for N(*)
test.4 <- droplevels(subset(test.1, Method != 'SMDM'))# Rob, not SMDM  for all


###################################################
### code chunk number 15: fig-meanscale
###################################################
getOption("SweaveHooks")[["fig"]]()
## ## exp(mean(log(sigma))): this looks almost identical to mean(sigma)
print(ggplot(test.3, aes(p/n, exp(meanlogsigma.1), color = Est.Scale)) +
      stat_summary(aes(x=ratio), # <- "rounded p/n": --> median over "neighborhood"
                   fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      geom_hline(yintercept = 1) +
      g.scale_y_log10_1() +
      facet_wrap(~ Psi) +
      ylab(quote('geometric ' ~ mean(hat(sigma)))) +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.", labels=lab(test.3$Est.Scale)))


###################################################
### code chunk number 16: fig-sdscale-1
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(test.3, aes(p/n, sdlogsigma.1*sqrt(n), color = Est.Scale)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      ylab(quote(sd(log(hat(sigma)))*sqrt(n))) +
      facet_wrap(~ Psi) +
      geom_point  (data=test.lm.2, alpha=alpha.n, aes(color = Est.Scale)) +
      stat_summary(data=test.lm.2, aes(x=ratio, color = Est.Scale),
                   fun.y=median, geom='line') +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.",
                            labels= lab(test.3   $Est.Scale,
                                        test.lm.2$Est.Scale)))


###################################################
### code chunk number 17: fig-sdscale-all
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(test.4,
             aes(p/n, sdlogsigma.1*sqrt(n), color = Est.Scale)) +
      ylim(with(test.4, range(sdlogsigma.1*sqrt(n)))) +
      ylab(quote(sd(log(hat(sigma)))*sqrt(n))) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = Error), alpha = alpha.error) +
      facet_wrap(~ Psi) +
      ## "FIXME" (?): the next 'test.lm' one  give warnings
      geom_point  (data=test.lm, aes(color = Est.Scale), alpha=alpha.n) +
      ##-> Warning: Removed 108 rows containing missing values    (geom_point).
      stat_summary(data=test.lm, aes(x = ratio, color = Est.Scale),
                   fun.y=median, geom='line') +
      ##-> Warning: Removed 108 rows containing non-finite values (stat_summary).
      g.scale_shape(labels=lab(test.4$Error)) +
      scale_colour_discrete("Scale Est.",
                            labels=lab(test.4 $Est.Scale,
                                       test.lm$Est.Scale)))


###################################################
### code chunk number 18: fig-qscale
###################################################
getOption("SweaveHooks")[["fig"]]()
t3est2 <- droplevels(subset(test.3, Estimator %in% c("SMD", "MMqE")))
print(ggplot(t3est2,
             aes(p/n, q, color = Est.Scale)) + ylab(quote(q)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      geom_hline(yintercept = 1) +
      g.scale_y_log10_1() +
      facet_wrap(~ Psi) +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.", labels=lab(t3est2$Est.Scale)))


###################################################
### code chunk number 19: fig-Mscale
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t3est2,
             aes(p/n, M/q, color = Est.Scale)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      g.scale_y_log10_0.05() +
      facet_wrap(~ Psi) +
      ylab(quote(M/q)) +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.", labels=lab(t3est2$Est.Scale)))


###################################################
### code chunk number 20: fig-qscale-all
###################################################
getOption("SweaveHooks")[["fig"]]()
t1.bi <- droplevels(subset(test.1, Estimator %in% c("SMD", "MMqE") &
                                   Psi == 'bisquare'))
print(ggplot(t1.bi,
             aes(p/n, q, color = Est.Scale)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      geom_hline(yintercept = 1) +
      g.scale_y_log10_1() +
      facet_wrap(~ Error) + ## labeller missing!
      ylab(quote(q)) +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.", labels=lab(tmp$Est.Scale)),
      legend.mod = legend.mod)


###################################################
### code chunk number 21: fig-Mscale-all
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t1.bi,
             aes(p/n, M/q, color = Est.Scale)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      g.scale_y_log10_0.05() +
      facet_wrap(~ Error) +
      ylab(quote(M/q)) +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete("Scale Est.", labels=lab(tmp$Est.Scale)),
      legend.mod = legend.mod)


###################################################
### code chunk number 22: fig-efficiency
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(test.2, aes(p/n, efficiency.1, color = Estimator)) +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      geom_hline(yintercept = 0.95) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      facet_wrap(~ Psi) +
      ylab(quote('efficiency of' ~~ hat(beta))) +
      g.scale_shape(quote(n)) +
      scale_colour_discrete(name = "Estimator",
                            labels = lab(test.2$Estimator)))


###################################################
### code chunk number 23: fig-efficiency-all
###################################################
getOption("SweaveHooks")[["fig"]]()
t.1xt1 <- droplevels(subset(test.1, Error != 't1'))
print(ggplot(t.1xt1,
             aes(p/n, efficiency.1, color = Estimator)) +
      ylab(quote('efficiency of '~hat(beta))) +
      geom_point(aes(shape = Error), alpha = alpha.error) +
      geom_hline(yintercept = 0.95) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      g.scale_shape(values=c(16,17,15,3,7,8,9,1,2,4)[-4],
                    labels=lab(t.1xt1$Error)) +
      facet_wrap(~ Psi) +
      scale_colour_discrete(name = "Estimator",
                            labels = lab(t.1xt1$Estimator)))


###################################################
### code chunk number 24: fig-AdB2-1
###################################################
getOption("SweaveHooks")[["fig"]]()
t.2o. <- droplevels(subset(test.2, !is.na(AdB2t.1)))
print(ggplot(t.2o., aes(p/n, AdB2.1/(1-p/n), color = Estimator)) +
      geom_point(aes(shape=factor(n)),    alpha = alpha.n) +
      geom_point(aes(y=K2AdB2.1/(1-p/n)), alpha = alpha.n) +
      geom_point(aes(y=AdB2t.1),          alpha = alpha.n) +
      stat_summary(aes(x=ratio),                     fun.y=median, geom='line') +
      stat_summary(aes(x=ratio, y=K2AdB2.1/(1-p/n)), fun.y=median, geom='line', linetype=2) +
      stat_summary(aes(x=ratio, y=AdB2t.1),          fun.y=median, geom='line', linetype=3) +
      geom_hline(yintercept = 1/0.95) +
      g.scale_y_log10_1() +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete(name = "Estimator", labels = lab(t.2o.$Estimator)) +
      ylab(quote(mean(hat(gamma)))) +
      facet_wrap(~ Psi))


###################################################
### code chunk number 25: fig-sdAdB2-1
###################################################
getOption("SweaveHooks")[["fig"]]()
t.2ok <- droplevels(subset(test.2, !is.na(sdAdB2t.1)))
print(ggplot(t.2ok,
             aes(p/n, sdAdB2.1/(1-p/n), color = Estimator)) +
      geom_point(aes(shape=factor(n)),      alpha = alpha.n) +
      geom_point(aes(y=sdK2AdB2.1/(1-p/n)), alpha = alpha.n) +
      geom_point(aes(y=sdAdB2t.1),          alpha = alpha.n) +
      stat_summary(aes(x=ratio),                       fun.y=median, geom='line') +
      stat_summary(aes(x=ratio, y=sdK2AdB2.1/(1-p/n)), fun.y=median, geom='line', linetype= 2) +
      stat_summary(aes(x=ratio, y=sdAdB2t.1),          fun.y=median, geom='line', linetype= 3) +
      g.scale_y_log10_0.05() +
      scale_shape_discrete(quote(n)) +
      scale_colour_discrete(name = "Estimator", labels=lab(t.2ok$Estimator))  +
      ylab(quote(sd(hat(gamma)))) +
      facet_wrap(~ Psi))


###################################################
### code chunk number 26: fig-emp-level
###################################################
getOption("SweaveHooks")[["fig"]]()
t.2en0 <- droplevels(subset(test.2, emplev_1 != 0))
print(ggplot(t.2en0,
             aes(p/n, f.truncate(emplev_1), color = method.cov)) +
      g.truncate.lines + g.truncate.areas +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      scale_shape_discrete(quote(n)) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_hline(yintercept = 0.05) +
      g.scale_y_log10_0.05() +
      scale_colour_discrete(name = "Estimator", labels=lab(t.2en0$method.cov))  +
      ylab(quote("empirical level "~ list (H[0] : beta[1] == 0) )) +
      facet_wrap(~ Psi))


###################################################
### code chunk number 27: fig-lqq-level
###################################################
getOption("SweaveHooks")[["fig"]]()
tmp <- droplevels(subset(test.1, Psi == 'lqq' & emplev_1 != 0))
print(ggplot(tmp, aes(p/n, f.truncate(emplev_1), color = method.cov)) +
      ylab(quote("empirical level "~ list (H[0] : beta[1] == 0) )) +
      g.truncate.line + g.truncate.area +
      geom_point(aes(shape = factor(n)), alpha = alpha.n) +
      stat_summary(aes(x=ratio), fun.y=median, geom='line') +
      geom_hline(yintercept = 0.05) +
      g.scale_y_log10_0.05() +
      g.scale_shape(quote(n)) +
      scale_colour_discrete(name = "Estimator", labels=lab(tmp$method.cov)) +
      facet_wrap(~ Error)
     ,
      legend.mod = legend.mod
      )


###################################################
### code chunk number 28: fig-power-1-0_2
###################################################
getOption("SweaveHooks")[["fig"]]()
t2.25  <- droplevels(subset(test.2,    n == 25))# <-- fixed n ==> no need for 'ratio'
tL2.25 <- droplevels(subset(test.lm.2, n == 25))
scale_col_D2.25 <- scale_colour_discrete(name = "Estimator (Cov. Est.)",
                                         labels=lab(t2.25 $method.cov,
                                                    tL2.25$method.cov))
print(ggplot(t2.25,
             aes(p/n, power_1_0.2, color = method.cov)) +
      ylab(quote("empirical power "~ list (H[0] : beta[1] == 0.2) )) +
      geom_point(# aes(shape = Error),
          alpha = alpha.error) +
      stat_summary(fun.y=median, geom='line') +
      geom_point  (data=tL2.25, alpha = alpha.n) +
      stat_summary(data=tL2.25, fun.y=median, geom='line') +
      ## g.scale_shape("Error", labels=lab(t2.25$Error)) +
      scale_col_D2.25 +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 29: fig-power-1-0_4
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t2.25,
             aes(p/n, power_1_0.4, color = method.cov)) +
      ylab(quote("empirical power "~ list (H[0] : beta[1] == 0.4) )) +
      geom_point(alpha = alpha.error) +
      stat_summary(fun.y=median, geom='line') +
      geom_point  (data=tL2.25, alpha = alpha.n) +
      stat_summary(data=tL2.25,
                   fun.y=median, geom='line') +
      ## g.scale_shape("Error", labels=lab(t2.25$Error)) +
      scale_col_D2.25 +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 30: fig-power-1-0_6
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t2.25,
             aes(p/n, power_1_0.6, color = method.cov)) +
      ylab(quote("empirical power "~ list (H[0] : beta[1] == 0.6) )) +
      geom_point(# aes(shape = Error),
          alpha = alpha.error) +
      stat_summary(fun.y=median, geom='line') +
      geom_point  (data=tL2.25, alpha = alpha.n) +
      stat_summary(data=tL2.25, fun.y=median, geom='line') +
      scale_col_D2.25 +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 31: fig-power-1-0_8
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t2.25,
             aes(p/n, power_1_0.8, color = method.cov)) +
      ylab(quote("empirical power "~ list (H[0] : beta[1] == 0.8) )) +
      geom_point(alpha = alpha.error) +
      stat_summary(fun.y=median, geom='line') +
      geom_point  (data=tL2.25, alpha = alpha.n) +
      stat_summary(data=tL2.25, fun.y=median, geom='line') +
      g.scale_shape("Error", labels=lab(t2.25$Error)) +
      scale_col_D2.25 +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 32: fig-power-1-1
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(t2.25,
             aes(p/n, power_1_1, color = method.cov)) +
      ylab(quote("empirical power "~ list (H[0] : beta[1] == 1) )) +
      geom_point(alpha = alpha.error) +
      stat_summary(fun.y=median, geom='line') +
      geom_point  (data=tL2.25, alpha = alpha.n) +
      stat_summary(data=tL2.25, fun.y=median, geom='line') +
      ## g.scale_shape("Error", labels=lab(t2.25$Error)) +
      scale_col_D2.25 +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 33: fig-pred-points
###################################################
getOption("SweaveHooks")[["fig"]]()
pp <- f.prediction.points(dd)[1:7,]
## Worked in older ggplot2 -- now  plotmatrix() is gone, to be replaced by GGally::ggpairs):
## tmp <- plotmatrix(pp)$data
## tmp$label <- as.character(1:7)
## print(plotmatrix(dd) + geom_text(data=tmp, color = 2, aes(label=label), size = 2.5))
tmp <- ggpairs(pp)$data
tmp$label <- as.character(1:7) # and now?
## ggpairs() + geom_text()  does *NOT* work {ggpairs has own class}
## print(ggpairs(dd) + geom_text(data=tmp, color = 2, aes(label=label), size = 2.5))
print( ggpairs(dd) )## now (2016-11) fine


###################################################
### code chunk number 34: fig-cpr
###################################################
getOption("SweaveHooks")[["fig"]]()
n.cprs <- names(test.fixed)[grep('cpr', names(test.fixed))] # test.fixed: n=20 => no 'x=ratio'
test.5 <- melt(test.fixed[,c('method.cov', 'Error', 'Psi', n.cprs)])
test.5 <- within(test.5, {
  Point <- as.numeric(do.call('rbind', strsplit(levels(variable), '_'))[,2])[variable]
})
print(ggplot(test.5,
             aes(Point, f.truncate(value), color = method.cov)) +
      geom_point(aes(shape = Error), alpha = alpha.error) +
      g.truncate.line + g.truncate.area +
      stat_summary(fun.y=median, geom='line') +
      geom_hline(yintercept = 0.05) +
      g.scale_y_log10_0.05() +
      g.scale_shape(labels=lab(test.5$Error)) +
      scale_colour_discrete(name = "Estimator (Cov. Est.)",
                            labels=lab(test.5$method.cov)) +
      ylab("empirical level of confidence intervals") +
      facet_wrap(~ Psi)
      )


###################################################
### code chunk number 35: maxbias-fn
###################################################
## Henning (1994) eq 33:
g <- Vectorize(function(s, theta, mu, ...) {
  lctrl <- lmrob.control(...)
  rho <- function(x)
    Mchi(x, lctrl$tuning.chi, lctrl$psi, deriv = 0)
  integrate(function(x) rho(((1 + theta^2)/s^2*x)^2)*dchisq(x, 1, mu^2/(1 + theta^2)),
            -Inf, Inf)$value
})
## Martin et al 1989 Section 3.2: for mu = 0
g.2 <- Vectorize(function(s, theta, mu, ...) {
  lctrl <- lmrob.control(...)
  lctrl$tuning.psi <- lctrl$tuning.chi
  robustbase:::lmrob.E(chi(sqrt(1 + theta^2)/s*r), lctrl, use.integrate = TRUE)})
g.2.MM <- Vectorize(function(s, theta, mu, ...) {
  lctrl <- lmrob.control(...)
  robustbase:::lmrob.E(chi(sqrt(1 + theta^2)/s*r), lctrl, use.integrate = TRUE)})
## Henning (1994) eq 30, one parameter case
g.3 <- Vectorize(function(s, theta, mu, ...) {
  lctrl <- lmrob.control(...)
  rho <- function(x)
    Mchi(x, lctrl$tuning.chi, lctrl$psi, deriv = 0)
  int.x <- Vectorize(function(y) {
    integrate(function(x) rho((y - x*theta - mu)/s)*dnorm(x)*dnorm(y),-Inf, Inf)$value })
  integrate(int.x,-Inf, Inf)$value
})
inv.g1 <- function(value, theta, mu, ...) {
  g <- if (mu == 0) g.2 else g.3
  uniroot(function(s) g(s, theta, mu, ...) - value, c(0.1, 100))$root
}
inv.g1.MM <- function(value, theta, mu, ...) {
  g <- if (mu == 0) g.2.MM else g.3.MM
  ret <- tryCatch(uniroot(function(s) g(s, theta, mu, ...) - value, c(0.01, 100)),
                  error = function(e)e)
  if (inherits(ret, 'error')) {
    warning('inv.g1.MM: ', value, ' ', theta, ' ', mu,' -> Error: ', ret$message)
    NA
  } else {
    ret$root
  }
}
s.min <- function(epsilon, ...) inv.g1(0.5/(1 - epsilon), 0, 0, ...)
s.max <- function(epsilon, ...) inv.g1((0.5-epsilon)/(1-epsilon), 0, 0, ...)

BS <- Vectorize(function(epsilon, ...) {
  sqrt(s.max(epsilon, ...)/s.min(epsilon, ...)^2 - 1) })

l <- Vectorize(function(epsilon, ...) {
  sigma_be <- s.max(epsilon, ...)
  sqrt((sigma_be/inv.g1.MM(g.2.MM(sigma_be,0,0,...) +
                           epsilon/(1-epsilon),0,0,...))^2 - 1) })
u <- Vectorize(function(epsilon, ...) {
  gamma_be <- s.min(epsilon, ...)
  max(l(epsilon, ...),
      sqrt((gamma_be/inv.g1.MM(g.2.MM(gamma_be,0,0,...) +
                               epsilon/(1-epsilon),0,0,...))^2 - 1)) })


###################################################
### code chunk number 36: max-asymptotic-bias
###################################################
asymptMBFile <- file.path(robustDta, 'asymptotic.max.bias.Rdata')
if (!file.exists(asymptMBFile)) {
  x <- seq(0, 0.35, length.out = 100)
  rmb <- rbind(data.frame(l=l(x, psi = 'hampel'),
                          u=u(x, psi = 'hampel'), psi = 'Hampel'),
               data.frame(l=l(x, psi = 'lqq'),
                          u=u(x, psi = 'lqq'), psi = 'lqq'),
               data.frame(l=l(x, psi = 'bisquare'),
                          u=u(x, psi = 'bisquare'), psi = 'bisquare'),
               data.frame(l=l(x, psi = 'optimal'),
                          u=u(x, psi = 'optimal'), psi = 'optimal'))
  rmb$x <- x
  save(rmb, file=asymptMBFile)
} else load(asymptMBFile)


###################################################
### code chunk number 37: fig-max-asymptotic-bias
###################################################
getOption("SweaveHooks")[["fig"]]()
print(ggplot(rmb, aes(x, l, color=psi)) + geom_line() +
        geom_line(aes(x, u, color=psi), linetype = 2) +
      xlab(quote("amount of contamination" ~~ epsilon)) +
      ylab("maximum asymptotic bias bounds") +
      coord_cartesian(ylim = c(0,10)) +
      scale_y_continuous(breaks = 1:10) +
      scale_colour_hue(quote(psi ~ '-function')))


