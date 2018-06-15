### `checkVersions` and `add.packages.miniCRAN` require an existing miniCRAN repo

# Specify list of packages to download
revolution <- c(CRAN = getOption("miniCRAN.mran"))
pkgs <- c("foreach")
pkgTypes <- c("source", "win.binary")

pdb <- cranJuly2014

\dontrun{
  pdb <- pkgAvail(repos = revolution, type = "source")
}

pkgList <- pkgDep(pkgs, availPkgs = pdb, repos = revolution, type = "source", suggests = FALSE)
pkgList

\dontrun{
  # Create temporary folder for miniCRAN
  dir.create(pth <- file.path(tempdir(), "miniCRAN"))

  # Make repo for source and win.binary
  makeRepo(pkgList, path = pth, repos = revolution, type = pkgTypes)

  # Add other versions of a package (and assume these were added previously)
  oldVers <- data.frame(package = c("foreach", "codetools", "iterators"),
                        version = c("1.4.0", "0.2-7", "1.0.5"),
                        stringsAsFactors = FALSE)
  pkgs <- oldVers$package
  addOldPackage(pkgs, path = pth, vers = oldVers$version, repos = revolution, type = "source")
  # NOTE: older binary versions would need to be build from source

  # List package versions in the miniCRAN repo (produces warning about duplicates)
  pkgVersionsSrc <- checkVersions(pkgs, path = pth, type = "source")
  pkgVersionsBin <- checkVersions(pkgs, path = pth, type = "win.binary")

  # After inspecting package versions, remove old versions
  basename(pkgVersionsSrc) # "foreach_1.4.0.tar.gz"  "foreach_1.4.2.tar.gz"
  basename(pkgVersionsBin) # "foreach_1.4.0.zip"     "foreach_1.4.2.zip"
  file.remove(c(pkgVersionsSrc[1], pkgVersionsBin[1]))

  # Rebuild package index after adding/removing files
  updateRepoIndex(pth, type = pkgTypes, Rversion = R.version)

  pkgAvail(pth, type = "source")

  # Add new packages (from CRAN) to the miniCRAN repo
  addPackage("Matrix", path = pth, repos = revolution, type = pkgTypes)

  # Delete temporary folder
  unlink(pth, recursive = TRUE)
}
