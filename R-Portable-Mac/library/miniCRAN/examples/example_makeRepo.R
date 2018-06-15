
# Specify list of packages to download
revolution <- c(CRAN = getOption("minicran.mran"))
pkgs <- c("foreach")

pdb <- cranJuly2014

\dontrun{
  pdb <- pkgAvail(
    repos = c(CRAN = getOption("minicran.mran")),
    type = "source"
  )
}

pkgList <- pkgDep(pkgs, availPkgs = pdb, repos = revolution, type = "source", suggests = FALSE)
pkgList


\dontrun{
# Create temporary folder for miniCRAN
dir.create(pth <- file.path(tempdir(), "miniCRAN"))

# Make repo for source and win.binary
makeRepo(pkgList, path = pth, repos = revolution, type = "source")

# List all files in miniCRAN
list.files(pth, recursive = TRUE)

# Check for available packages
pkgAvail(repos = pth, type = "source")

# Repeat process for windows binaries
makeRepo(pkgList, path = pth, repos = revolution, type = "win.binary")
pkgAvail(repos = pth, type = "win.binary")

# Delete temporary folder
unlink(pth, recursive = TRUE)
}
