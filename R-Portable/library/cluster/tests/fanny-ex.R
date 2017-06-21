.libPaths() # show full library tree {also as check of R CMD check!}
library(cluster)

####---------- Tests for FANNY  i.e., fanny() --------------------------
####
### -- thanks to ../.Rbuildignore , the output of this is
### -- only compared to saved values for the maintainer

###--- An extension of  example(fanny) : -------------------
set.seed(21)
## generate 10+15 objects in two clusters, plus 3 objects lying
## between those clusters.
x <- rbind(cbind(rnorm(10, 0, 0.5), rnorm(10, 0, 0.5)),
           cbind(rnorm(15, 5, 0.5), rnorm(15, 5, 0.5)),
           cbind(rnorm( 3,3.2,0.5), rnorm( 3,3.2,0.5)))

.proctime00 <- proc.time()

(fannyx <- fanny(x, 2))
summary(fannyx)
str(fannyx)
## Different platforms differ (even gcc 3.0.1 vs 3.2 on same platform)!
## {70 or 71 iterations}
## ==> No "fanny-ex.Rout.save" is distributed !
## --------------------------------------------
summary(fanny(x,3))# one extra cluster

(fanny(x,2, memb.exp = 1.5))
(fanny(x,2, memb.exp = 1.2))
(fanny(x,2, memb.exp = 1.1))
(fanny(x,2, memb.exp = 3))

data(ruspini) # < to run under R 1.9.1
summary(fanny(ruspini, 3), digits = 9)
summary(fanny(ruspini, 4), digits = 9)# 'correct' #{clusters}
summary(fanny(ruspini, 5), digits = 9)

cat('Time elapsed: ', proc.time() - .proctime00,'\n')
data(chorSub)
p4cl <- pam(chorSub, k = 4, cluster.only = TRUE)
## The first two are "completely fuzzy" -- and now give a warnings
f4.20 <- fanny(chorSub, k = 4, trace.lev = 1) ; f4.20$coef
f4.18  <- fanny(chorSub, k = 4,   memb.exp = 1.8) # same problem
f4.18. <- fanny(chorSub, k = 4,   memb.exp = 1.8,
                iniMem.p = f4.20$membership) # very quick convergence
stopifnot(all.equal(f4.18[-c(7,9)], f4.18.[-c(7,9)], tol = 5e-7))

f4.16  <- fanny(chorSub, k = 4, memb.exp = 1.6) # now gives 4 crisp clusters
f4.16. <- fanny(chorSub, k = 4, memb.exp = 1.6,
                iniMem.p = f4.18$membership, trace.lev = 2)# "converges" immediately - WRONGLY!
f4.16.2 <- fanny(chorSub, k = 4, memb.exp = 1.6,
                 iniMem.p = cluster:::as.membership(p4cl),
                 tol = 1e-10, trace.lev = 2)## looks much better:
stopifnot(f4.16$clustering == f4.16.2$clustering,
          all.equal(f4.16[-c(1,7,9)], f4.16.2[-c(1,7,9)], tol = 1e-7),
          all.equal(f4.16$membership, f4.16.2$membership, tol = 0.001))
## the memberships are quite close but have only converged to precision 0.000228

f4.14 <- fanny(chorSub, k = 4,                memb.exp = 1.4)
f4.12 <- fanny(chorSub, k = 4,                memb.exp = 1.2)

table(f4.12$clustering, f4.14$clustering)# close but different
table(f4.16$clustering, f4.14$clustering)# dito
table(f4.12$clustering, f4.16$clustering)# hence differ even more

symnum(cbind(f4.16$membership, 1, f4.12$membership),
       cutpoints= c(0., 0.2, 0.6, 0.8, 0.9, 0.95, 1 -1e-7, 1 +1e-7),
       symbols   = c(" ", ".", ",", "+",  "*", "B","1"))


## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')
