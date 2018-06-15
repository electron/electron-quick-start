library(foreach)
library(RSQLite)

# Define a simple iterator for a query result, which is
# just a wrapper around the fetch function
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

# Create an SQLite instance
m <- dbDriver('SQLite')

# Initialize a new database to a tempfile and copy a data frame
# into it repeatedly to get more data to process
tfile <- tempfile()
con <- dbConnect(m, dbname=tfile)
data(USArrests)
dbWriteTable(con, 'USArrests', USArrests)
for (i in 1:99)
  dbWriteTable(con, 'USArrests', USArrests, append=TRUE)

# Create an iterator to issue the query, selecting the fields of interest
qit <- iquery(con, 'select Murder, Assault, Rape from USArrests', n=50)

# Define a combine function for the partial results
comb <- function(...) {
  n <- foreach(a=list(...), .combine='+') %do% a$n
  means <- foreach(a=list(...), .combine='+') %do% ((a$n / n) * a$means)
  list(n=n, means=means)
}

# Compute the mean of each of those fields, 50 records at a time
r <- foreach(d=qit, .combine=comb, .multicombine=TRUE) %dopar%
  list(n=nrow(d), means=mean(d))

print(r)

# Clean up
dbDisconnect(con)
file.remove(tfile)
