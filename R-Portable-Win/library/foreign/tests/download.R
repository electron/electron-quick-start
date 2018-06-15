library(foreign)
if(!nzchar(Sys.getenv("R_FOREIGN_FULL_TEST"))) q("no")

read.dta("http://www.principlesofeconometrics.com/stata/airline.dta")

## no longer exists, Jan 2014
##str(read.spss("http://psyweb.psy.ox.ac.uk/dapweb/teaching/graduate/data/crime.sav",
##              to.data.frame=TRUE))

q()
