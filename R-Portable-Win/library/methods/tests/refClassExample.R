mEditor <- setRefClass("matrixEditor",
      fields = list( data = "matrix",
        edits = "list"),
      methods = list(
     edit = function(i, j, value) {
       ## the following string documents the edit method
       'Replaces the range [i, j] of the
        object by value.
        '
         backup <-
             list(i, j, data[i,j])
         data[i,j] <<- value
         edits <<- c(edits, list(backup))
         invisible(value)
     },
     undo = function() {
       'Undoes the last edit() operation
        and update the edits field accordingly.
        '
         prev <- edits
         if(length(prev)) prev <- prev[[length(prev)]]
         else stop("No more edits to undo")
         edit(prev[[1]], prev[[2]], prev[[3]])
         ## trim the edits list
         length(edits) <<- length(edits) - 2
         invisible(prev)
     }
     ))

xMat <- xEdited <- matrix(as.double(1:12),4,3)
xEdited[[2,2]] <- 0
xx <- mEditor$new(data = xMat)
xx$edit(2, 2, 0)
stopifnot(identical(xx$data, xEdited))
xEdited[[1,3]] <- -1
xx$edit(1,3, -1)
stopifnot(identical(xx$data, xEdited))
xx$undo()
xEdited[[1,3]] <- xMat[[1,3]]
stopifnot(identical(xx$data, xEdited))
xx$undo()
stopifnot(identical(xx$data, xMat))

## the tracing method
xx$trace(edit, quote(value <- 0))
xx$edit(2,2, -1) # traced should assign 0
stopifnot(identical(xx$data, xEdited))
xx$untrace(edit)
xx$edit(1, 3, -1) # now it should use -1
xEdited[[1,3]] <- -1
stopifnot(identical(xx$data, xEdited))
