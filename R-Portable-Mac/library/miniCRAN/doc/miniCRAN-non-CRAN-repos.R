## ----setup---------------------------------------------------------------
# Wrapper around available.packages ---------------------------------------
 
index <- function(url, type = "source", filters = NULL, head = 5, cols = c("Package", "Version")) {
  contribUrl <- contrib.url(url, type = type)
  p <- available.packages(contribUrl, type = type, filters = filters)
  p[1:head, cols]
}
 

## ----CRAN, eval=FALSE----------------------------------------------------
#  CRAN <- "http://cran.r-project.org"
#  index(CRAN)

## ----revo, eval=FALSE----------------------------------------------------
#  revoStable <- "http://packages.revolutionanalytics.com/cran/3.1/stable"
#  index(revoStable)
#  
#  revoMirror <- "http://cran.revolutionanalytics.com"
#  index(revoMirror)

## ----rforge, eval=FALSE--------------------------------------------------
#  rforge <- "http://r-forge.r-project.org"
#  index(rforge)

## ----bioc, eval=FALSE----------------------------------------------------
#  bioc <- local({
#    env <- new.env()
#    on.exit(rm(env))
#    evalq(source("http://bioconductor.org/biocLite.R", local = TRUE), env)
#    biocinstallRepos()
#  })
#  
#  bioc
#  bioc[grep("BioC", names(bioc))]
#  
#  
#  index(bioc["BioCsoft"])

