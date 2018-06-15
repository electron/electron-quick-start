# keep track if TZ of system has been changed !
# test done in runit.ZZZ.R
Sys.setenv(TZ = "Pacific/Auckland")
testTZ <<- Sys.timezone()

