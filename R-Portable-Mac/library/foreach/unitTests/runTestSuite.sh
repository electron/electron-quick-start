#!/bin/sh

LOGFILE=test.log

R --vanilla --slave > ${LOGFILE} 2>&1 <<'EOF'
library(foreach)
library(RUnit)

verbose <- as.logical(Sys.getenv('FOREACH_VERBOSE', 'FALSE'))
method <- Sys.getenv('FOREACH_BACKEND', 'SEQ')

if (method == 'SNOW') {
  cat('** Using SNOW backend\n')
  library(doSNOW)
  cl <- makeSOCKcluster(3)
  .Last <- function() {
    cat('shutting down SOCK cluster...\n')
    stopCluster(cl)
    cat('shutdown complete\n')
  }
  registerDoSNOW(cl)
} else if (method == 'NWS') {
  cat('** Using NWS backend\n')
  library(doNWS)
  registerDoNWS()
} else if (method == 'MC') {
  cat('** Using multicore backend\n')
  library(doMC)
  registerDoMC()
} else if (method == 'SEQ') {
  cat('** Using sequential backend\n')
  registerDoSEQ()
} else {
  stop('illegal backend specified: ', method)
}

options(warn=1)
options(showWarnCalls=TRUE)

cat('Starting test at', date(), '\n')
cat(sprintf('doPar backend name: %s, version: %s\n', getDoParName(), getDoParVersion()))
cat(sprintf('Running with %d worker(s)\n', getDoParWorkers()))

tests <- c('foreachTest.R', 'errorTest.R', 'combineTest.R', 'iteratorTest.R',
           'loadFactorTest.R', 'nestedTest.R', 'packagesTest.R', 'mergeTest.R',
           'whenTest.R', 'stressTest.R')

errcase <- list()
for (f in tests) {
  cat('\nRunning test file:', f, '\n')
  t <- runTestFile(f)
  e <- getErrors(t)
  if (e$nErr + e$nFail > 0) {
    errcase <- c(errcase, t)
    print(t)
  }
}

if (length(errcase) == 0) {
  cat('*** Ran all tests successfully ***\n')
} else {
  cat('!!! Encountered', length(errcase), 'problems !!!\n')
  for (t in errcase) {
    print(t)
  }
}

cat('Finished test at', date(), '\n')
EOF
