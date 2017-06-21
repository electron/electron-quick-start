## Example of scoping problem.
## Originally from a report by Markus Jantti:
## https://stat.ethz.ch/pipermail/r-help/2005-November/081382.html
library(nlme)
data(Ovary)
## stolen from example(anova.gls)
# AR(1) errors within each Mare
fm1 <- gls(follicles ~ sin(2*pi*Time) + cos(2*pi*Time), Ovary,
           correlation = corAR1(form = ~ 1 | Mare))
(int1 <- intervals(fm1))
stopifnot(
    all.equal(int1$corStruct["Phi",],
	      c(lower=0.66842829, est.=0.753207889, upper=0.81866619),
	      tol = 6e-6)# 3.44e-6 needed on solaris-x86
   ,
    all.equal(as.vector(int1$sigma),
	      c(3.9747061, 4.61617157, 5.361161), tol = 6e-6)
)

# variance changes with a power of the absolute fitted values?
fm2 <- update(fm1, weights = varPower())
(a12 <- anova(fm1, fm2))
stopifnot(identical(a12, anova(fm1, fm2, type = "seq")))# latter had failed

## now define a little function
dummy <- function(obj) anova(obj[[1]], obj[[2]])
(d12 <- dummy(list(fm1, fm2)))
## last failed < 3.1-66
rownames(d12) <- rownames(a12)
stopifnot(all.equal(a12, d12, tol = 1e-15),
          all.equal(a12[2,"p-value"], 0.111752516, tol = 1e-5)
)

## PR#13567
fm1Orth.gls <- gls(distance ~ Sex * I(age - 11), Orthodont,
                   correlation = corSymm(form = ~ 1 | Subject),
                   weights = varIdent(form = ~ 1 | age))
(aOr <- anova(fm1Orth.gls, Terms = "Sex"))
stopifnot(all.equal(aOr[,"F-value"], 9.4030752449,
		    aOr[,"p-value"], 0.0027608643857))

## anova.gls(.) -- REML & ML
(a1  <- anova(fm1))
(a1m <- anova(fm1, type="marginal"))
##
fm1M <- update(fm1, method = "ML")
(a1M <- anova(fm1M))
(a1Mm <- anova(fm1M, type = "marginal"))
stopifnot(
    all.equal(a1M[,"F-value"],
              c(378.774471, 19.1105834, 1.71334909),
              tolerance = 1e-7)
   ,
    all.equal(summary(fm1M)$tTable[,"t-value"] ^ 2,
	      as.matrix(a1Mm)[,"F-value"], tolerance = 1e-14)
   ,
    all.equal(summary(fm1 )$tTable[,"t-value"] ^ 2,
              as.matrix(a1m )[,"F-value"], tolerance = 1e-14)
)
