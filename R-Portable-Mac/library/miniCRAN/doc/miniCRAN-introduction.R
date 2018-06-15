## ----make-repo-1---------------------------------------------------------
library("miniCRAN")

# use Revolution Analytics CRAN mirror
revolution <- c(CRAN = "http://cran.microsoft.com")

# Specify list of packages to download
pkgs <- c("foreach")
pkgList <- pkgDep(pkgs, repos = revolution, type = "source", suggests = FALSE, 
                  availPkgs = cranJuly2014)
pkgList

## ----make-repo-2, eval=FALSE---------------------------------------------
#  # Create temporary folder for miniCRAN
#  dir.create(pth <- file.path(tempdir(), "miniCRAN"))
#  
#  # Make repo for source and win.binary
#  makeRepo(pkgList, path = pth, repos = revolution, type = c("source", "win.binary"))

## ----make-repo-3, eval=FALSE---------------------------------------------
#  # List all files in miniCRAN
#  list.files(pth, recursive = TRUE, full.names = FALSE)

## ----make-repo-4, eval=FALSE---------------------------------------------
#  # Check for available packages
#  pkgAvail(repos = pth, type = "win.binary")[, c(1:3, 5)]

## ----make-repo-5, eval=FALSE---------------------------------------------
#  install.packages(pkgs,
#                   repos = paste0("file:///", pth),
#                   type = "source")

## ----addto-repo-new-1, eval=FALSE----------------------------------------
#  # Add new packages (from CRAN) to the miniCRAN repo
#  addPackage("Matrix", path = pth, repos = revolution, type = c("source", "win.binary"))
#  pkgAvail(repos = pth, type = "win.binary")[, c(1:3, 5)]

## ----addto-repo-old-1, eval=FALSE----------------------------------------
#  # create a data frame with the package and version info
#  oldVers <- data.frame(
#    package = c("foreach", "codetools", "iterators"),
#    version = c("1.4.0", "0.2-7", "1.0.5"),
#    stringsAsFactors = FALSE
#  )
#  
#  # download old source package version and create repo index
#  addOldPackage(pkgList, path = pth, vers = oldVers$version, repos = revolution, type = "source")

## ----addto-repo-old-2, eval=FALSE----------------------------------------
#  # List package versions in the miniCRAN repo (produces warning about duplicates)
#  pkgVersionsSrc <- checkVersions(pkgList, path = pth, type = "source")
#  pkgVersionsBin <- checkVersions(pkgList, path = pth, type = "win.binary")
#  
#  # After inspecting package versions, remove old versions
#  basename(pkgVersionsSrc) # duplicate versions
#  basename(pkgVersionsBin)
#  
#  file.remove(pkgVersionsSrc[c(2,4,6)])
#  
#  # rebuild the package index after removing duplicate package versions
#  updateRepoIndex(pth, type = c("source", "win.binary"))

## ----addto-repo-old-3, eval=FALSE----------------------------------------
#  pkgAvail(pth, type = "source")[, c(1:3, 5)] # contains the old versions
#  pkgAvail(pth, type = "win.binary")[, c(1:3, 5)] # contains the current versions

## ----update-repo-1, eval=FALSE-------------------------------------------
#  # Check if updated packages are available
#  oldPackages(path = pth, repos = revolution, type = "source")[, 1:3] # should need update
#  oldPackages(path = pth, repos = revolution, type = "win.binary")[, 1:3] # should be current

## ----update-repo-2, eval=FALSE-------------------------------------------
#  # Update available packages
#  updatePackages(path = pth, repos = revolution, type = "source", ask = FALSE) # should need update
#  updatePackages(path = pth, repos = revolution, type = "win.binary", ask = FALSE) # should be current

## ----cleanup, include=FALSE, eval=FALSE----------------------------------
#  # Delete temporary folder
#  unlink(pth, recursive = TRUE)

