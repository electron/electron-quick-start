library(cluster)

if(getRversion() < "3.4.0") source("withAutoprint.R")

data(animals)
(mani <- mona(animals, trace=TRUE))
str(mani)
## version of the data withOUT missing:
animal.F <- mani$data
(maniF <- mona(animal.F, trace=TRUE))

data(plantTraits)
## Now construct  'plantT2' which has *all* binary variables
not2 <- vapply(plantTraits, function(var) !(is.factor(var) && nlevels(var) == 2), NA)
names(plantTraits)[not2]

plantT2 <- plantTraits
for(n in names(plantTraits)[not2]) {
    v <- plantTraits[,n]
    if(is.factor(v)) {
        lv <- as.integer(levels(v))# ok for this data
        v <- as.integer(v)
        M <- median(lv)
    } else M <- median(v, na.rm = TRUE)
    stopifnot(is.finite(M))
    plantT2[,n] <- (v <= M)
}
summary(plantT2)

(mon.pl2 <- mona(plantT2, trace = TRUE))


set.seed(1)
ani.N1 <- animals; ani.N1[cbind(sample.int(20, 10), sample.int(6, 10, replace=TRUE))] <- NA
(maniN <- mona(ani.N1, trace=TRUE))

for(seed in c(2:20)) {
    set.seed(seed); cat("seed = ", seed,"\n")
    ani.N2 <- animals
    ani.N2[cbind(sample.int(20, 9),
                 sample.int( 6, 9, replace=TRUE))] <- NA
    try(print(maniN2 <- mona(ani.N2, trace=TRUE)))
}

## Check all "too many NA" and other illegal cases
ani.NA   <- animals; ani.NA[4,] <- NA
aniNA    <- within(animals, { end[2:9] <- NA })
aniN2    <- animals; aniN2[cbind(1:6, c(3, 1, 4:6, 2))] <- NA
ani.non2 <- within(animals, end[7] <- 3 )
ani.idNA <- within(animals, end[!is.na(end)] <- 1 )
## use tools::assertError() {once you don't use *.Rout.save anymore}
try( mona(ani.NA)   )
try( mona(aniNA)    )
try( mona(aniN2)    )
try( mona(ani.non2) )
try( mona(ani.idNA) )

if(require(MASS)) withAutoprint({
    if(R.version$major != "1" || as.numeric(R.version$minor) >= 7)
        RNGversion("1.6")
    set.seed(253)
    n <- 512; p <- 3
    Sig <- diag(p); Sig[] <- 0.8 ^ abs(col(Sig) - row(Sig))
    x3 <- mvrnorm(n, rep(0,p), Sig) >= 0
    x <- cbind(x3, rbinom(n, size=1, prob = 1/2))

    sapply(as.data.frame(x), table)

    mx <- mona(x)
    str(mx)
    lapply(mx[c(1,3,4)], table)
    mx # (too much, but still)
})


try(
mona(cbind(1:0), trace=2)
) ## error: need p >= 2
## in the past, gave
## Loop npass = 1: (ka,kb) = (1,2)
##   for(j ..) -> jma=1, jtel(.,z) = (17952088, 8) --> splitting: (nel; jres, ka, km) = (1; -17952086, 1, 17952089)
##  inner loop: for(k in ka:km) use ner[k]:  1 2 2 2 2 2 2 2 2 2 ..... [infinite loop]
