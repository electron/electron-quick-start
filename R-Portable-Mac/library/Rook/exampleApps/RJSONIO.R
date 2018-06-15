library(Rook)
library(RJSONIO)
app <- function(env){
    req <- Request$new(env)
    res <- Response$new()

    obj <- sub('^/','',req$path_info())

    
    # Get out of here fast if no object exists
    if (!exists(obj)) return(res$finish())

#    res$write(paste(capture.output(str(req$params()),file=NULL),collapse='\n'))
#    return(res$finish())

    # Gather args from one of three sources: GET, POST as a x-www-urlencoded,
    # or POST as JSON payload. params() squishes GET and POST together when
    # POST is x-www-urlencoded.
    if (!is.null(req$params())) {
	args <- req$params()
    } else {
	# TODO: Collect POST payload and pass to RJSONIO
	args <- list()
    }

    # Normalize arguments to R types if necessary. Integers to integer, Numerics to numeric, etc.
    # Maybe we can propose a vector syntax in CGI that's coherent, too.
    for (i in names(args)){

	# Keep as character anything that starts with a quote char
	if (grepl('^[\'"]',args[[i]]))
	    next

	# Integer
	if (grepl('^[+-]?\\d+$',args[[i]]))
	    args[[i]] <- as.integer(args[[i]])

	# Numeric. need to add scientific notation
	if (grepl('^[+-]?[0-9.]+$',args[[i]]))
	    args[[i]] <- as.numeric(args[[i]])
    }
    
    if (is.function(get(obj)))
	res$write(toJSON(do.call(obj,args)))
    else
	res$write(toJSON(get(obj)))
	
    res$finish()
}
