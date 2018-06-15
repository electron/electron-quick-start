basic_tests <- list(
     list(input=c(TRUE, FALSE), any=TRUE, all=FALSE),
     list(input=c(FALSE, TRUE), any=TRUE, all=FALSE),

     list(input=c(TRUE, TRUE), any=TRUE, all=TRUE),
     list(input=c(FALSE, FALSE), any=FALSE, all=FALSE),

     list(input=c(NA, FALSE), any=NA, all=FALSE, any.na.rm=FALSE),
     list(input=c(FALSE, NA), any=NA, all=FALSE, any.na.rm=FALSE),

     list(input=c(NA, TRUE), any=TRUE, all=NA, all.na.rm=TRUE),
     list(input=c(TRUE, NA), any=TRUE, all=NA, all.na.rm=TRUE),

     list(input=logical(0), any=FALSE, all=TRUE),

     list(input=NA, any=NA, all=NA, any.na.rm=FALSE, any.na.rm=TRUE),

     list(input=c(TRUE, NA, FALSE), any=TRUE, any.na.rm=TRUE,
          all=FALSE, all.na.rm=FALSE)
     )

## any, all accept '...' for input.
list_input_tests <-
    list(
         list(input=list(TRUE, TRUE), all=TRUE, any=TRUE),
         list(input=list(FALSE, FALSE), all=FALSE, any=FALSE),
         list(input=list(TRUE, FALSE), all=FALSE, any=TRUE),
         list(input=list(FALSE, TRUE), all=FALSE, any=TRUE),

         list(input=list(FALSE, NA),
              all=FALSE, all.na.rm=FALSE, any=NA, any.na.rm=FALSE),
         list(input=list(NA, FALSE),
              all=FALSE, all.na.rm=FALSE, any=NA, any.na.rm=FALSE),

         list(input=list(TRUE, NA),
              all=NA, all.na.rm=TRUE, any=TRUE, any.na.rm=TRUE),
         list(input=list(NA, TRUE),
              all=NA, all.na.rm=TRUE, any=TRUE, any.na.rm=TRUE),

         list(input=list(NA, NA),
              any=NA, any.na.rm=FALSE, all=NA, all.na.rm=TRUE),

         list(input=list(rep(TRUE, 2), rep(TRUE, 10)),
              all=TRUE, any=TRUE),

         list(input=list(rep(TRUE, 2), c(TRUE, NA)),
              all=NA, all.na.rm=TRUE, any=TRUE),

         list(input=list(rep(TRUE, 2), c(TRUE, FALSE)),
              all=FALSE, any=TRUE),

         list(input=list(c(TRUE, FALSE), c(TRUE, NA)),
              all=FALSE, all.na.rm=FALSE, any=TRUE, any.na.rm=TRUE)
         )



do_tests <- function(L)
{
    run <- function(f, input, na.rm = FALSE)
    {
        if (is.list(input))
            do.call(f, c(input, list(na.rm = na.rm)))
        else f(input, na.rm = na.rm)
    }

    do_check <- function(case, f)
    {
        fun <- deparse(substitute(f))
        if (!identical(case[[fun]], run(f, case$input))) {
            cat("input: "); dput(case$input)
            stop(fun, " returned ", run(f, case$input),
                 " wanted ", case[[fun]], call. = FALSE)
        }
        narm <- paste(fun, ".na.rm", sep = "")
        if (!is.null(case[[narm]])) {
            if (!identical(case[[narm]],
                           run(f, case$input, na.rm = TRUE))) {
                cat("input: "); dput(case$input)
                stop(narm, " returned ", run(f, case$input, na.rm = TRUE),
                     " wanted ", case[[narm]], call. = FALSE)
            }
        }
    }
    lab <- deparse(substitute(L))
    for (case in L) {
        do_check(case, any)
        do_check(case, all)
    }
}

do_tests(basic_tests)
do_tests(list_input_tests)
