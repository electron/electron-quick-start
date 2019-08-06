x <- tools::Rd_db("base")
system.time(y <- lapply(x, function(e)
    tryCatch(tools::Rd2HTML(e, out = nullfile()),
	     error = identity))) # 3-5 sec
stopifnot(!vapply(y, inherits, NA, "error"))
## Gave error when "running" \Sexpr{.} DateTimeClasses.Rd
