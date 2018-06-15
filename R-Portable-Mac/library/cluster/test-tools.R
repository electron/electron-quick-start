#### Will be sourced by several R scripts in ../tests/

### ------- General test "tools" (from the Matrix package):
### ==> 'Suggests: Matrix' in ../DESCRIPTION
source(system.file("test-tools-1.R", package = "Matrix", lib.loc = .Library),
       keep.source = FALSE)

if(doExtras <- cluster:::doExtras())## from ../R/0aaa.R
    cat("doExtras <- cluster:::doExtras() :  TRUE\n")

