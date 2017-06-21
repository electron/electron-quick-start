stopifnot(require(Matrix), require(methods)) # Matrix classes; new, slot<-

KNex <-
    local({
	load(system.file(file.path("external", "KNex_slots.rda"), package = "Matrix"))
	## -> 'L'
	r <- list(mm = new("dgCMatrix"), y = L[["y"]])
	for (n in c("Dim", "i","p","x")) ## needs methods::slot<-
	    slot(r$mm, n) <- L[[n]]
	r
    })
