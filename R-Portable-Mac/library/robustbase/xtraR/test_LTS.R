#### Utility functions for testing ltsReg()
#### -------------------------------------- ../tests/tlts.R

repLTS <- function(form, data, nrep = 1, method = c("FASTLTS","MASS"))
{
    if(method == "MASS")
        ## MASS::lqs(x,y,control=list(psamp = NA, nsamp= "best", adjust= FALSE))
        for(i in 1:nrep) MASS::lqs(form, data = data, method = "lts")
    else
        ## set mcd=FALSE - we want to time only the LTS algorithm
        for(i in 1:nrep) ltsReg(form, data = data, mcd = FALSE)
}

doLTSdata <- function(nrep = 1, time = nrep >= 3, short = time, full = !short,
		   method = c("FASTLTS", "MASS"))
{
    ##@bdescr
    ## Test the function ltsReg() on the literature datasets:
    ##
    ## Call ltsReg() for "all" regression datasets available in robustbase
    ## and print:
    ##  - execution time (if time)
    ##  - objective function
    ##  - best subsample found (if not short)
    ##  - outliers identified (with cutoff 0.975) (if not short)
    ##  - estimated coeficients and scale (if full)
    ##
    ##@edescr
    ##
    ##@in  nrep    : [integer] number of repetitions to use for estimating the
    ##                         (average) execution time
    ##@in  time    : [boolean] whether to evaluate the execution time
    ##@in  short   : [boolean] whether to do short output (i.e. only the
    ##                         objective function value). If short == FALSE,
    ##                         the best subsample and the identified outliers are
    ##                         printed. See also the parameter full below
    ##@in  full    : [boolean] whether to print the estimated coeficients and scale
    ##@in  method  : [character] select a method: one of (FASTLTS, MASS)


    dolts <- function(form, dname, dataset, nrep = 1) {

        if(missing(dataset)) {
            data(list = dname)
            dataset <- get(dname)
        } else if(missing(dname))
            dname <- deparse(substitute(dataset))
        environment(form) <- environment() ## !?!
        x <- model.matrix(form, model.frame(form, data = dataset))
        dx <- dim(x) - 0:1 # not counting intercept

        if(method == "MASS") {
            lts <- MASS::lqs(form, data = dataset, method = "lts")
            quan <- (dx[1] + (dx[2] + 1) + 1)/2 #default: (n+p+1)/2
        } else {
            lts <- ltsReg(form, data = dataset, mcd = FALSE)
            quan <- lts$quan
        }

        xres <- sprintf("%*s %3d %3d %3d %12.6f",
                        lname, dname, dx[1], dx[2], as.integer(quan), lts$crit)
        if(time) {
            xtime <- system.time(repLTS(form, data = dataset, nrep, method))[1]
            xres <- sprintf("%s %10.1f", xres, 1000 * xtime / nrep)
        }
        cat(xres, "\n")

        if(!short) {
            cat("Best subsample: \n")
            print(lts$best)

            ibad <- which(lts$lts.wt == 0)
            names(ibad) <- NULL
            nbad <- length(ibad)
            cat("Outliers: ",nbad,"\n")
            if(nbad > 0)
                print(ibad)
            if(full) {
                cat("-------------\n")
                print(lts)
                print(summary(lts))
            }
            cat("--------------------------------------------------------\n")
        }
    }

    method <- match.arg(method)

    data(heart)
    data(starsCYG)
    data(phosphor)
    data(stackloss)
    data(coleman)
    data(salinity)
    data(aircraft)
    data(delivery)
    data(wood)
    data(hbk)

    cll <- sys.call()
    cat("\nCall: ", deparse(substitute(cll)),"\n")

    cat("========================================================\n")
    cat("Data Set               n   p  Half      obj    Time [ms]\n")
    cat("========================================================\n")
    ##   1 3 5 7 9.1 3 5 7 9. 123 123
    lname <- 20 ##        --^

    dolts(clength ~ . , "heart", nrep = nrep)
    dolts(log.light ~ log.Te , "starsCYG", nrep = nrep)
    dolts(plant ~ . , "phosphor", nrep = nrep)
    dolts(stack.loss ~ . , "stackloss", nrep = nrep)
    dolts(Y ~ . , "coleman", nrep = nrep)
    dolts(Y ~ . , "salinity")
    dolts(Y ~ . , "aircraft")
    dolts(delTime ~ . , "delivery")
    dolts(y ~ . , "wood", nrep = nrep)
    dolts(Y ~ . , "hbk", nrep = nrep)

    cat("========================================================\n")
}
