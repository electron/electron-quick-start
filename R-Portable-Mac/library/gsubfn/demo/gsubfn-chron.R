
# Use read.zoo to read data with a chron time index
# Ignore fractional seconds.

library(zoo)
library(chron)
library(gsubfn)

# test data
Lines <- "2006-01-24 02:41:24.00011,1.22930000,5,1.22950000,7
2006-01-25 04:41:24.00011,1.22930000,5,1.22950000,7
2006-01-26 07:41:24.00011,1.22930000,5,1.22950000,7"

# convert to chron
to.chron <- function(x) 
   strapply(format(x), "([0-9-]+) ([0-9:]+)",
	~ chron(as.numeric(as.Date(dd)), tt), simplify = c)

read.zoo(text = Lines, sep = ",", FUN = to.chron)

