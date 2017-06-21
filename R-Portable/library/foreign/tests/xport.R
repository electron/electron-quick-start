library(foreign)
lookup.xport("Alfalfa.xpt")
Alfalfa <- read.xport("Alfalfa.xpt")
summary(Alfalfa)
## test data provided by FRohde@birchdavis.com
lookup.xport("test.xpt")
testdata <- read.xport("test.xpt")
summary(testdata)
q()
