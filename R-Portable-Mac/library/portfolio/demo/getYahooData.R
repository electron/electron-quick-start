########################################
##
##  yahoo.R
##
##  Demonstration for downloading data from yahoo
##  using get.yahoo.data.R
##
####################################################

library(portfolio)
data(dow.jan.2005)

p <- new("portfolio", symbol.var = "symbol", data = dow.jan.2005)

## Gets additional data for the portfolio

p <- getYahooData(p, symbol.var = "symbol")

p@data
