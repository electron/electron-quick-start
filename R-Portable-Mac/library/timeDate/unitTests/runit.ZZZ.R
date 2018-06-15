# keep track if TZ of system has been changed !
# testTZ defined in runit.AAA.R
test.AAA <-  function() {
    print(testTZ)
    checkIdentical(testTZ, Sys.timezone())
}
