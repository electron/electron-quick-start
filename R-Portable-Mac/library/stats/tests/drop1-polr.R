### Test calling drop1.default() "deep down" -- via
### correct formula environment

library(stats)
if(!require(MASS)) q()

regr <- function(formula, data, ...)
{
    lform <- formula(formula)
    d1 <- data
    i.polr(lform, d1, ...)
}

i.polr <- function(form, data, ...)
{
    lfo <- form
    d2 <- data
    environment(lfo) <- environment()
    lreg <- polr(lfo, data = d2, ...)
    do.drop(lreg, lreg1$coef, ltesttype = "Chisq")
}

do.drop <- function(lreg, lcoeftab, ltesttype)
    drop1(lreg, test = ltesttype, scope = terms(lreg), trace = FALSE)

m  <- polr(Sat ~ Infl + Type + Cont, data = housing)
rr <- regr(formula(m), data = housing)
dr1 <- drop1(m)
stopifnot(is.data.frame(rr),
	  all.equal(rr[-(3:4)], dr1, check.attributes = FALSE))
