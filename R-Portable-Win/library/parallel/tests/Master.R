
runone <- function(f)
{
    message("  Running ", sQuote(f))
    infile <- paste(f, "RR", sep = ".")
    outfile <- paste(f, "Rout", sep = ".")
    cmd <- paste(shQuote(file.path(R.home("bin"), "R")),
                 "CMD BATCH --vanilla",
                 shQuote(infile), shQuote(outfile))
    res <- system(cmd)
    if (res) {
        cat(readLines(outfile), sep="\n")
        file.rename(outfile, paste(outfile, "fail", sep="."))
        return(1L)
    }
    savefile <- paste(outfile, "save", sep = "." )
    if (file.exists(savefile)) {
        message("  Comparing ", sQuote(outfile), " to ",
                sQuote(savefile), " ...", appendLF = FALSE)
        res <- tools:::Rdiff(outfile, savefile, TRUE)
        if (!res) message(" OK")
    }
    0L
}

res <- 0L
if(.Platform$OS.type == "unix") {
    res <- res + runone("multicore1")
    res <- res + runone("multicore2")
    res <- res + runone("multicore3")
}
res <- res + runone("snow1")
res <- res + runone("snow2")

if(res) stop(gettextf("%d tests failed", res))

