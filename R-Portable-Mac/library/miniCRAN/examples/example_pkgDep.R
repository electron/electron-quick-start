
\dontrun{
pkgDep(pkg = c("ggplot2", "plyr", "reshape2"),
       repos = c(CRAN = getOption("minicran.mran"))
)
}

pdb <- cranJuly2014
\dontrun{
pdb <- pkgAvail(repos = c(CRAN = getOption("minicran.mran")))
}

pkgDep(pkg = c("ggplot2", "plyr", "reshape2"), pdb)

