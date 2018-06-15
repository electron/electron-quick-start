
library(compiler)

##
## Test code for constant folding
##

makeCenv <- compiler:::makeCenv
checkConst <- compiler:::checkConst
constantFoldSym <- compiler:::constantFoldSym
constantFold <- compiler:::constantFold

## using a global environment
ce <- makeCenv(.GlobalEnv)
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 3)),
                    checkConst(base::pi)))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 2)),
                    NULL))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 1)),
                    NULL))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 0)),
                    NULL))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 3, env = ce)),
                    checkConst(1 + 2)))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 2, env = ce)),
                    checkConst(1 + 2)))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 1, env = ce)),
                    NULL))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 0, env = ce)),
                    NULL))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 3, env = ce)),
                    checkConst(sqrt(2))))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 2, env = ce)),
                    NULL))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 1, env = ce)),
                    NULL))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 0, env = ce)),
                    NULL))

## using a namespace environment
ce <- makeCenv(getNamespace("stats"))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 3)),
                    list(value = base::pi)))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 2)),
                    list(value = base::pi)))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 1)),
                    checkConst(base::pi)))
stopifnot(identical(constantFoldSym(quote(pi), list(env = ce, optimize = 0)),
                    NULL))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 3, env = ce)),
                    checkConst(1 + 2)))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 2, env = ce)),
                    checkConst(1 + 2)))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 1, env = ce)),
                    checkConst(1 + 2)))
stopifnot(identical(constantFold(quote(1 + 2), list(optimize = 0, env = ce)),
                    NULL))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 3, env = ce)),
                    checkConst(sqrt(2))))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 2, env = ce)),
                    checkConst(sqrt(2))))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 1, env = ce)),
                    checkConst(sqrt(2))))
stopifnot(identical(constantFold(quote(sqrt(2)), list(optimize = 0, env = ce)),
                    NULL))
