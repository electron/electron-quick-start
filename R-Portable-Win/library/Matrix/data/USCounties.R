stopifnot(requireNamespace("methods", quietly = TRUE),
	  requireNamespace("Matrix" , quietly = TRUE))

USCounties <-
    local({
	load(system.file(file.path("external", "USCounties_slots.rda"),
                         package = "Matrix"))
	## -> 'L'
	r <- methods::new("dsCMatrix")
        `slot<-` <- methods::`slot<-`
	for (n in c("Dim", "i","p","x"))
	    slot(r, n) <- L[[n]]
	r
    })

## The reverse:
if(FALSE) {
 L <- list()
 for (n in c("Dim", "i","p","x"))    L[[n]] <- slot(USCounties, n)
}

