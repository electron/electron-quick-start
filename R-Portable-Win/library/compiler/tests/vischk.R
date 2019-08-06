## Check that R_Visible is being set properly.

library(compiler)
vcheck <- function(expr)
    stopifnot(withVisible(eval(compile(substitute(expr))))$visible)

asfoo <- function(x) structure(x, class = "foo")
xfoo <- asfoo(1)

## FastMath1
vcheck(sqrt(invisible(2)))
vcheck(exp(invisible(2)))
vcheck(sqrt(invisible(2L)))
vcheck(exp(invisible(2L)))
vcheck(sqrt(invisible(xfoo)))
vcheck(exp(invisible(xfoo)))

## FastUnary
vcheck(+ invisible(2))
vcheck(- invisible(2))
vcheck(+ invisible(2L))
vcheck(- invisible(2L))
vcheck(+ invisible(xfoo))
vcheck(- invisible(xfoo))

## FastBinary
vcheck(1 + invisible(2))
vcheck(1 - invisible(2))
vcheck(3 * invisible(2))
vcheck(1 / invisible(2))
vcheck(3 ^ invisible(2))
vcheck(1 + invisible(2L))
vcheck(1L + invisible(2))
vcheck(1 + invisible(xfoo))

## FastRelop2
vcheck(1 == invisible(2))
vcheck(1 != invisible(2))
vcheck(1 < invisible(2))
vcheck(1 <= invisible(2))
vcheck(1 >= invisible(2))
vcheck(1 > invisible(2))
vcheck(1 > invisible(2L))
vcheck(1L > invisible(2L))
vcheck(1 > invisible(xfoo))

## Builtin2
vcheck(1 & invisible(2))
vcheck(0 | invisible(2))
vcheck(0 | invisible(2L))
vcheck(0L | invisible(2L))
vcheck(0 | invisible(xfoo))

## Builtin1
vcheck(! invisible(2))
vcheck(! invisible(2L))
vcheck(! invisible(xfoo))

## DO_VECSUBSET
vcheck(1[invisible(1)])
vcheck(xfoo[invisible(1)])

## MATSUBSET_PTR
vcheck(matrix(1)[1, invisible(1)])
vcheck(asfoo(matrix(1))[1, invisible(1)])

## SUBSET_N_PTR
vcheck(array(1, c(1, 1, 1))[1, 1, invisible(1)])
vcheck(asfoo(array(1, c(1, 1, 1)))[1, 1, invisible(1)])

## DO_DFLTDISPATCH
vcheck(invisible(1)[])
vcheck(matrix(1)[,invisible(1)])
## not sure how to trigger [[ issue
vcheck(c(invisible(2)))
vcheck(xfoo[])

## DOLLAR
vcheck(invisible(list(x = 1))$x)
`$.foo` <- function(x, y) invisible(x)
vcheck(xfoo$bar)

## ISINTEGER
vcheck(is.integer(invisible(1)))
vcheck(is.integer(invisible(xfoo)))

## DO_ISTYPE
vcheck(is.logical(invisible(1)))
vcheck(is.double(invisible(1)))
vcheck(is.complex(invisible(1)))
vcheck(is.character(invisible(1)))
vcheck(is.symbol(invisible(1)))

## DO_ISTEST
vcheck(is.null(invisible(1)))
vcheck(is.object(invisible(1)))
vcheck(is.numeric(invisible(1)))

## &&, ||
vcheck(invisible(TRUE) || FALSE)
vcheck(FALSE || invisible(FALSE))
vcheck(invisible(FALSE) && FALSE)
vcheck(TRUE && invisible(TRUE))

## LOG, LOGBASE, MATH1
vcheck(log(invisible(2)))
vcheck(log(2, invisible(2)))
vcheck(log(invisible(xfoo)))
vcheck(log(xfoo, invisible(2)))
vcheck(sin(invisible(2)))
vcheck(cos(invisible(2)))

## DOTCALL

## COLON, SEQLEN, SEQALONG
vcheck(1 : invisible(2))
vcheck(1 : invisible(xfoo))
vcheck(seq_len(invisible(2)))
vcheck(seq_len(invisible(xfoo)))
vcheck(seq_along(invisible(1)))
vcheck(seq_along(invisible(xfoo)))
