library(compiler)

oldJIT <- enableJIT(3)

## need a test of level 1 to make sure functions are compiled

## need more tests here

repeat { break }

while(TRUE) break

for (i in 1:10) i

enableJIT(oldJIT)

