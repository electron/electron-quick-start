#t.test(x, y = NULL, alternative = c("two.sided", "less", "greater"),
#    mu = 0, paired = FALSE, var.equal = FALSE, conf.level = 0.95)

## just retrieve values from the dialog box and assemble call in
## interpreted code
menu.ttest <- function()
{
    z <- .C("menu_ttest", vars=character(2), ints=integer(4), level=double(1))
    ## check for cancel button
    if (z$ints[4] > 1) return(invisible())
    ## do it this way to get named variables in the answer
    oc <- call("t.test", x = as.name(z$vars[1]), y = as.name(z$vars[2]),
               alternative = c("two.sided", "less", "greater")[1+z$ints[1]],
               paired = z$ints[2] != 0,
               var.equal = z$ints[3] != 0,
               conf.level = z$level)
    eval(oc)
}

## assemble call as string in C code
menu.ttest2 <- function()
{
    .C("menu_ttest2")
    return(invisible())
}

## assemble and evaluate call in C code
menu.ttest3 <- function() .Call("menu_ttest3")


del.ttest <- function() winMenuDel("Statistics")

.onAttach <- function(libname, pkgname)
{
    if(interactive()) {
        winMenuAdd("Statistics")
        winMenuAdd("Statistics/Classical tests")
        winMenuAddItem("Statistics/Classical tests", "t-test:1", "menu.ttest()")
        winMenuAddItem("Statistics/Classical tests", "t-test:2", "menu.ttest2()")
        winMenuAddItem("Statistics/Classical tests", "t-test:3", "menu.ttest3()")
        packageStartupMessage("To remove the Statistics menu use del.ttest()")
    }
}

.onDetach <- function(libpath) del.ttest()

