## For examples skipped in testing because they are 'random'

## some should still be skipped when  --with-recommended-packages=no :
## (This is not really right as could be installed elsewhere.)
base.and.rec <- .packages(all.available = TRUE, lib = .Library)

set.seed(1)
if(.Platform$OS.type == "windows") options(pager = "console")

pdf("reg-examples-2.pdf", encoding = "ISOLatin1.enc")


## stats
example(SSasympOrig, run.donttest = TRUE)
example(SSlogis, run.donttest = TRUE)
example(constrOptim, run.donttest = TRUE)
example(cancor, run.donttest = TRUE)
example(aov, run.donttest = TRUE)
# signs for promax rotation are arbitrary
example(factanal, run.donttest = TRUE)
example(family, run.donttest = TRUE)
example(fft, run.donttest = TRUE)
example(glm, run.donttest = ("MASS" %in% base.and.rec))
example(glm.control, run.donttest = TRUE)
# from extractAIC
extractAIC(glm.D93)
example(influence.measures, run.donttest = TRUE)
example(lm, run.donttest = TRUE)
example(ls.diag, run.donttest = TRUE)
example(model.tables, run.donttest = TRUE)
example(nlminb, run.donttest = TRUE)
example(optim, run.donttest = TRUE)
example(prcomp, run.donttest = TRUE)
example(step, run.donttest = TRUE)
example(summary.manova, run.donttest = TRUE)
example(uniroot, run.donttest = TRUE)

proc.time()
