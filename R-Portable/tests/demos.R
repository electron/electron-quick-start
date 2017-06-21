#### Run all demos that do not depend on tcl and other specials.
.ptime <- proc.time()
set.seed(123)
options(keep.source=TRUE, useFancyQuotes=FALSE, warn = 1)

## Drop these for strict testing {and add them to demos2.R)
## lm.glm is in ../src/library/utils/man/demo.Rd }:
dont <- list(graphics = c("Hershey", "Japanese", "plotmath"),
             stats = c("lm.glm", "nlm")
             )
## don't take tcltk here
for(pkg in c("base", "graphics", "stats")) {

    demos <- list.files(file.path(system.file(package = pkg), "demo"),
                        pattern = "\\.R$")
    demos <- demos[is.na(match(demos, paste(dont[[pkg]], "R",sep=".")))]

    if(length(demos)) {
        if(need <- pkg != "base" &&
           !any((fpkg <- paste("package", pkg, sep=":")) == search()))
            library(pkg, character.only = TRUE)

        for(nam in sub("\\.R$", "", demos))
            demo(nam, character.only = TRUE)

        if(need) detach(pos = which(fpkg == search()))
    }
}

cat("Time elapsed: ", proc.time() - .ptime, "\n")
