#### Testing M-S estimator --- self-contained utility functions ---
####

## Exercised from ../../tests/m-s-estimator.R
##		  ~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Test subsampling algorithm
m_s_subsample <- function(x1, x2, y, control, orthogonalize=TRUE) {
    storage.mode(x1) <- "double"
    storage.mode(x2) <- "double"
    storage.mode(y) <- "double"

    z <- .C(robustbase:::R_lmrob_M_S,
            x1,
            x2,
            y,
            res=double(length(y)),
            n=length(y),
            p1=NCOL(x1),
            p2=NCOL(x2),
            nResample=as.integer(control$nResample),
            max_it_scale=as.integer(control$maxit.scale),
            scale=double(1),
            b1=double(NCOL(x1)),
            b2=double(NCOL(x2)),
            tuning_chi=as.double(control$tuning.chi),
            ipsi=.psi2ipsi(control$psi),
            bb=as.double(control$bb),
            K_m_s=as.integer(control$k.m_s),
            max_k=as.integer(control$k.max),
            rel_tol=as.double(control$rel.tol),
	    inv_tol=as.double(control$solve.tol),
	    scale_tol=as.double(control$scale.tol),
            converged=FALSE,
            trace_lev=as.integer(control$trace.lev),
            orthogonalize=as.logical(orthogonalize),
            subsample=TRUE,
            descent=FALSE, # and hence no 'convergence' here ..
            mts = 0L,
            ss = 1L)
    z[c("b1", "b2", "scale")]
}

## Test descent algorithm
m_s_descent <- function(x1, x2, y, control, b1, b2, scale) {
    storage.mode(x1) <- "double"
    storage.mode(x2) <- "double"
    storage.mode(y) <- "double"

    z <- .C(robustbase:::R_lmrob_M_S,
            X1=x1,
            X2=x2,
            y=y,
            res=double(length(y)),
            n=length(y),
            p1=NCOL(x1),
            p2=NCOL(x2),
            nResample=as.integer(control$nResample),
            max_it_scale=as.integer(control$maxit.scale),
            scale=as.double(scale),
            b1=as.double(b1),
            b2=as.double(b2),
            tuning_chi=as.double(control$tuning.chi),
            ipsi=.psi2ipsi(control$psi),
            bb=as.double(control$bb),
            K_m_s=as.integer(control$k.m_s),
            max_k=as.integer(control$k.max),
            rel_tol=as.double(control$rel.tol),
	    inv_tol=as.double(control$solve.tol),
	    scale_tol=as.double(control$scale.tol),
            converged=logical(1),
            trace_lev=as.integer(control$trace.lev),
            orthogonalize=FALSE,
            subsample=FALSE,
            descent=TRUE,
            ##     -----
            mts = 0L,
            ss = 1L)
    z[c("b1", "b2", "scale", "res", "converged")]
}

find_scale <- function(r, s0, n, p, control) {
    c.chi <- robustbase:::.psi.conv.cc(control$psi, control$tuning.chi)

    b <- .C(robustbase:::R_lmrob_S,
            x = double(1),
            y = as.double(r),
            n = as.integer(n),
            p = as.integer(p),
            nResample = 0L, # <- only.scale=TRUE , now in lmrob.S()
            scale = as.double(s0),
            coefficients = double(p),
            as.double(c.chi),
            .psi2ipsi(control$psi),
            as.double(control$bb),
            best_r = 0L,
            groups = 0L,
            n.group = 0L,
            k.fast.s = 0L,
            k.iter = 0L,
            maxit.scale = as.integer(control$maxit.scale),
            refine.tol = as.double(control$refine.tol),
            inv.tol = as.double(control$solve.tol),
	    scale_tol=as.double(control$scale.tol),
            converged = logical(1),
            trace.lev = 0L,
            mts = 0L,
            ss = 1L,
            fast.s.large.n = as.integer(n+1)
            )[c("coefficients", "scale", "k.iter", "converged")]
    b$scale
}

## m_s_descent()--R-only--version :
m_s_descent_Ronly <- function(x1, x2, y, control, b1, b2, scale) {
    stopifnot(is.list(control), is.numeric(control$k.max))
    n <- length(y)
    p1 <- ncol(x1)
    p2 <- ncol(x2)
    p <- p1+p2
    t2 <- b2
    t1 <- b1
    rs <- drop(y - x1 %*% b1 - x2 %*% b2)
    sc <- scale
    ## do refinement steps
    ## do maximally control$k.max iterations
    ## stop if converged
    ## stop after k.fast.m_s step of no improvement
    if (control$trace.lev > 4) cat("scale:", scale, "\n")
    if (control$trace.lev > 4) cat("res:", rs, "\n")
    n.imp <- nnoimprovement <- nref <- 0L; conv <- FALSE
    while((nref <- nref + 1) <= control$k.max && !conv &&
          nnoimprovement < control$k.m_s) {
        ## STEP 1: UPDATE B2
        y.tilde <- y - x1 %*% t1
        w <- Mwgt(rs / sc, control$tuning.chi, control$psi)
        if (control$trace.lev > 4) cat("w:", w, "\n")
        z2 <- lm.wfit(x2, y.tilde, w)
        t2 <- z2$coef
        if (control$trace.lev > 4) cat("t2:", t2, "\n")
        rs <- y - x2 %*% t2
        ## STEP 2: OBTAIN M-ESTIMATE OF B1
        z1 <- lmrob.lar(x1, rs, control)
        t1 <- z1$coef
        if (control$trace.lev > 4) cat("t1:", t1, "\n")
        rs <- z1$resid
        ## STEP 3: COMPUTE THE SCALE ESTIMATE
        sc <- find_scale(rs, sc, n, p, control)
        if (control$trace.lev > 4) cat("sc:", sc, "\n")
        ## STEP 4: CHECK FOR CONVERGENCE

        ##... FIXME

        ## STEP 5: UPDATE BEST FIT
        if (sc < scale) {
            scale <- sc
            b1 <- t1
            b2 <- t2
            nnoimprovement <- 0L
            n.imp <- n.imp + 1L
        } else nnoimprovement <- nnoimprovement + 1L
    }
    ## STEP 6: FINISH
    if (nref == control$k.max)
        warning("M-S estimate: maximum number of refinement steps reached.")
    ## if we'd really check for convergence above :
    ## if (nnoimprovement == control$k.m_s)
    ##     warning("M-S estimate: maximum number of no-improvements reached.")

    list(b1=b1, b2=b2, scale=scale, res=rs, nref=nref,
	 n.improve = n.imp)#, converged=conv, nnoimprovement=nnoimprovement)
}
