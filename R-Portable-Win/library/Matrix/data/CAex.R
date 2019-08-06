stopifnot(requireNamespace("methods", quietly = TRUE),
	  requireNamespace("Matrix" , quietly = TRUE))

CAex <-
    local({
	load(system.file(file.path("external", "CAex_slots.rda"), package = "Matrix"))
	## -> 'L'
	r <- methods::new("dgCMatrix")
	for (n in c("Dim", "i","p","x"))
	    methods::slot(r, n) <- L[[n]]
	r
    })

## The reverse { CAex |--> L } is
if(FALSE) {
    sNms <- c("Dim", "i", "p", "x")
    L <- lapply(sNms, function(N) slot(CAex, N)); names(L) <- sNms
    save(L, file = "/u/maechler/R/Pkgs/Matrix/inst/external/CAex_slots.rda")
}
