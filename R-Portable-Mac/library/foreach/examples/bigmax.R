library(foreach)
library(RSQLite)

# Define a simple iterator for a query result, which is
# just a wrapper around the fetch function.
iquery <- function(con, statement, ..., n=1) {
  rs <- dbSendQuery(con, statement, ...)
  nextEl <- function() {
    d <- fetch(rs, n)
    if (nrow(d) == 0) {
      dbClearResult(rs)
      stop('StopIteration')
    }
    d
  }
  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# Create an SQLite instance.
m <- dbDriver('SQLite')

# Initialize a new database to a tempfile and copy a data frame
# into it repeatedly to get more data to process.
tfile <- tempfile()
con <- dbConnect(m, dbname=tfile)
data(USArrests)
dbWriteTable(con, 'USArrests', USArrests)
for (i in 1:99)
  dbWriteTable(con, 'USArrests', USArrests, append=TRUE)

# Create an iterator to issue the query, selecting the fields of interest.
# We then compute the maximum of each of those fields, 100 records at a time.
qit <- iquery(con, 'select Murder, Assault, Rape from USArrests', n=100)
r <- foreach(d=qit, .combine='pmax', .packages='foreach') %dopar% {
  foreach(x=iter(d, by='col'), .combine='c') %do% max(x)
}
print(r)

# Clean up
dbDisconnect(con)
file.remove(tfile)
