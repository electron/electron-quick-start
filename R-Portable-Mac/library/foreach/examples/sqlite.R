library(foreach)
library(RSQLite)

# Define a simple iterator for a query result, which is
# just a wrapper around the fetch function
iquery <- function(con, statement, ..., n=1) {
  rs <- dbSendQuery(con, statement, ...)
  nextEl <- function() {
    r <- fetch(rs, n)
    if (nrow(r) == 0) {
      dbClearResult(rs)
      stop('StopIteration')
    }
    r
  }
  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# create a SQLite instance and create one connection.
m <- dbDriver('SQLite')

# initialize a new database to a tempfile and copy some data.frame
# from the base package into it
tfile <- tempfile()
con <- dbConnect(m, dbname=tfile)
data(USArrests)
dbWriteTable(con, 'USArrests', USArrests)

# issue the query, and then iterate over the results
it <- iquery(con, 'select * from USArrests', n=10)
r <- foreach(r=it, .combine='rbind') %do% {
  state <- r$row_names
  crime <- r$Murder + r$Assault + r$Rape
  data.frame(state=state, crime=crime)
}
print(r)

# clean up
dbDisconnect(con)
file.remove(tfile)
