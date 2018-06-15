library(foreach)

# define a combine function that writes the results to a file.
# note that the first argument is not a result, but the file
# object, and must be specified via the .init argument and
# returned as the value of this function.
output <- function(fobj, ...) {
  lines <- list(...)
  cat(sprintf('writing %d line(s)\n', length(lines)))
  writeLines(unlist(lines), con=fobj)
  fobj
}

# create a temporary file to write the results to
fname <- tempfile('foreach')
fobj <- file(fname, 'w')

# use ireadLines to create an iterator over the lines of the input file,
# which are converted to upper case, and processed by the output function
foreach(input=ireadLines('output.R'), .combine=output, .init=fobj,
        .multicombine=TRUE, .maxcombine=5) %do%
  toupper(input)

# display the results and clean up
close(fobj)
file.show(fname)
file.remove(fname)
