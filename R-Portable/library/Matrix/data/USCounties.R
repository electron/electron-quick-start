stopifnot(require(Matrix), require(methods)) # Matrix classes; new, slot<-

USCounties <-
    local({
	load(system.file(file.path("external", "USCounties_slots.rda"),
                         package = "Matrix"))
	## -> 'L'
	r <- new("dsCMatrix")
	for (n in c("Dim", "i","p","x"))
	    slot(r, n) <- L[[n]]
	r
    })

## The reverse:
##  L <- list()
##  for (n in c("Dim", "i","p","x"))    L[[n]] <- slot(USCounties, n)

