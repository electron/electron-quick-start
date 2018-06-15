### Moved from reg-tests-1c.R

## envRefClass prototypes are a bit special -- broke all.equal() for baseenv()
rc <- getClass("refClass")
rp <- rc@prototype
str(rp) ## failed
rp ## show() failed ..
(ner <- new("envRefClass")) # show() failed
stopifnot(all.equal(rp,rp), all.equal(ner,ner))
be <- baseenv()
system.time(stopifnot(all.equal(be,be)))## <- takes a few sec's
stopifnot(
    grepl("not identical.*character", print(all.equal(rp, ner))),
    grepl("not identical.*character", print(all.equal(ner, rp))))
system.time(stopifnot(all.equal(globalenv(), globalenv())))
## Much of the above failed in  R <= 3.2.0

proc.time()
