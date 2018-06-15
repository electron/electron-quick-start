Sys.unsetenv("R_PARALLEL_PORT")

check.RS <- function(verbose = TRUE) {
    s1 <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if(verbose) { cat("current .Random.seed :\n"); utils::str(s1) }
    if(any("parallel" == loadedNamespaces())) unloadNamespace("parallel")
    loadNamespace("parallel")
    s2 <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    stopifnot(all.equal(s1, s2)) ## both NULL (if there was none); equal also otherwise
    unloadNamespace("parallel")
    invisible(s1)
}

s1 <- check.RS()
for(n in 1:3) check.RS(verbose=FALSE)

if(is.null(s1)) { ## create one
    runif(1)
} else { # remove it
    rm(.Random.seed)
}
s2 <- check.RS()

stopifnot(xor(is.null(s1),
	      is.null(s2)))
