#### These are *NOT* compared with output in the released version of
###  'cluster'  currently

library(cluster)

data(xclara)
## Try 100 times *different* random samples -- for reliability:
nSim <- 100
nCl <- 3 # = no.classes
## unknown problem: this is still platform dependent to some extent:

set.seed(107)# (reproducibility; somewhat favorable with "small iDoubt")
cl <- replicate(nSim, clara(xclara, nCl, rngR = TRUE)$cluster)
tcl <- apply(cl,1, tabulate, nbins = nCl)
## those that are not always in same cluster (5 out of 3000 for this seed):
(iDoubt <- which(apply(tcl,2, function(n) all(n < nSim))))

if(FALSE) {# doExtras --
rrr <- lapply(1:128, function(iseed) {
    set.seed(iseed)# (reproducibility; somewhat favorable with "small iDoubt")
    cat(iseed, if(iseed %% 10 == 0)"\n")
    cl <- replicate(nSim, clara(xclara, nCl, rngR = TRUE)$cluster)
    tcl <- apply(cl,1, tabulate, nbins = nCl)
    which(apply(tcl,2, function(n) all(n < nSim)))
})
## compare with "true" -- are the "changers" only those with small sil.width?

print(system.time(px <- pam(xclara,3)))# 1.84 on lynne(2013)
}## doExtras


if(length(iDoubt)) { # (not for all seeds)
  tabD <- tcl[,iDoubt, drop=FALSE]
  dimnames(tabD) <- list(cluster = paste(1:nCl), obs = format(iDoubt))
  t(tabD) # how many times in which clusters
}
