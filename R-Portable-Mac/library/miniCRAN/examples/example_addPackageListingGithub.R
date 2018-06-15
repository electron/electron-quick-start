# Create package database
pdb <- cranJuly2014

\dontrun{
  pdb <- pkgAvail(repos = c(CRAN = getOption("minicran.mran")))

  # Overwrite pdb with development version of miniCRAN at github
  newpdb <- addPackageListingGithub(pdb = pdb, "andrie/miniCRAN")
  newpdb["miniCRAN", ]

  # Add package from github that's not currently on CRAN
  newpdb <- addPackageListingGithub(pdb = pdb, repo = "RevolutionAnalytics/checkpoint")
  newpdb["checkpoint", ]

  set.seed(1)
  plot(makeDepGraph("checkpoint", availPkgs = newpdb, suggests = TRUE))
}
