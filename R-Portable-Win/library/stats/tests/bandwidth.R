### Sanity checks for some of the Jan 2017 breakage.

options(digits = 5)

## UCV, BCV and SJ all gave wrong answers in example(bw.ucv)
c(nrd0 = bw.nrd0(precip), nrd = bw.nrd(precip),
  ucv = bw.ucv(precip), bcv = bw.bcv(precip),
  "SJ-dpi" = bw.SJ(precip, method = "dpi"),
  "SJ-ste" = bw.SJ(precip, method = "ste"))

## wrong answers/errors in R < 3.3.3 for largish datasets
set.seed(1); bw.bcv(rnorm(6000))
set.seed(1); x <- rnorm(47000)
bw.ucv(x); bw.SJ(x,  method = "dpi"); bw.SJ(x,  method = "ste")

## An extremely unbalanced example where counts exceed INT_MAX
## Prior to R 3.4.0 was slow as O(n^2)
set.seed(1); bw.SJ(c(runif(65537), 1e7))

