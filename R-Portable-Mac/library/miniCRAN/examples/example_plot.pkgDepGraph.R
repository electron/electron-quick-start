tags <- "chron"

# Plot using defaults
pdb <- cranJuly2014

\dontrun{
  pdb <- pkgAvail(
    repos = c(CRAN = getOption("minicran.mran")),
    type = "source"
  )
}

dg <- makeDepGraph(tags, availPkgs = pdb  , includeBasePkgs = FALSE,
                   suggests = TRUE, enhances = TRUE)

set.seed(42);
plot(dg)

# Move edge legend to top left
set.seed(42);
plot(dg, legendPosition = c(-1, 1))

# Change font size and shape size
set.seed(42);
plot(dg, legendPosition = c(-1, 1), vertex.size = 20,  cex = 0.5)


# Move vertex legend to top right
set.seed(42);
plot(dg, legendPosition = c(1, 1), vertex.size = 20,  cex = 0.5)

