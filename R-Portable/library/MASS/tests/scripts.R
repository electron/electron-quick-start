if(!nzchar(Sys.getenv("MASS_TESTING"))) q("no")
unlink("scripts", recursive = TRUE)
dir.create("scripts")
Sys.unsetenv("R_TESTS") # avoid startup using startup.Rs (which is in the dir above)
setwd("scripts")
writeLines(c(".Random.seed <- c(0L,1:3)",
              "options(width = 65, show.signif.stars=FALSE)"),
           ".Rprofile")

runone <- function(f)
{
    message("  Running ", sQuote(basename(f)))
    outfile <- paste(basename(f), "out", sep = "")
    failfile <- paste(outfile, "fail", sep=".")
    unlink(c(outfile, failfile))
    res <- system2(file.path(R.home("bin"), "R"),
                   c("CMD BATCH --vanilla", shQuote(f), shQuote(outfile)),
                   env = paste("R_LIBS", Sys.getenv("R_LIBS"), sep = "="))
    if (res) {
        cat(tail(readLines(outfile), 20), sep="\n")
        file.rename(outfile, failfile)
        return(1L)
    }
    0L
}


library(MASS)
dd <- system.file("scripts", package="MASS")
files <- list.files(dd, pattern="\\.R$", full.names=TRUE)
res <- 0L
for(f in files) res <- res + runone(f)

proc.time()

if(res) stop(gettextf("%d scripts failed", res))
