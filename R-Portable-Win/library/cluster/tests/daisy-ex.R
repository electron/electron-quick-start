## For different cluster versions

require(cluster)

if(interactive()) {
    (pkgPath <- .find.package("cluster", verbose = TRUE))
    (verC <- readLines(Dfile <- file.path(pkgPath, "DESCRIPTION"), n = 2)[2])
}

## trivial cases should 'work':
daisy(cbind(1))
(d10 <- daisy(matrix(0., 1,0))); str(d10)
d01 <- daisy(matrix(0., 0,1))
if(paste(R.version$major, R.version$minor, sep=".") >= "2.1.0")
    print(d01)
str(d01)
d32 <- data.frame(eins=c("A"=1,"B"=1,"C"=1), zwei=c(2,2,2))
daisy(d32)
daisy(d32, stand = TRUE)
daisy(d32, type = list(ordratio="zwei"))


str(d5 <- data.frame(a= c(0, 0, 0,1,0,0, 0,0,1, 0,NA),
                     b= c(NA,0, 1,1,0,1, 0,1,0, 1,0),
                     c= c(0, 1, 1,0,1,NA,1,0,1, 0,NA),
                     d= c(1, 1, 0,1,0,0, 0,0,0, 1,0),
                     e= c(1, NA,0,1,0,0, 0,0,NA,1,1)))
(d0 <- daisy(d5))
(d1 <- daisy(d5, type = list(asymm = 1:5)))
(d2 <- daisy(d5, type = list(symm = 1:2, asymm= 3:5)))
(d2.<- daisy(d5, type = list(     asymm= 3:5)))
stopifnot(identical(c(d2), c(d2.)))
(dS <- daisy(d5, stand = TRUE))# gave error in some versions
stopifnot(all.equal(as.vector(summary(c(dS), digits=9)),
                    c(0, 2.6142638, 3.4938562, 3.2933687, 4.0591077, 5.5580177),
                    tol = 1e-7))# 7.88e-9

d5[,4] <- 1 # binary with only one instead of two values
(d0 <- daisy(d5))
(d1 <- daisy(d5, type = list(asymm = 1:5)))# 2 NAs
(d2 <- daisy(d5, type = list(symm = 1:2, asymm= 3:5)))
(d2.<- daisy(d5, type = list(     asymm= 3:5)))
## better leave away the constant variable: it has no effect:
stopifnot(identical(c(d1), c(daisy(d5[,-4], type = list(asymm = 1:4)))))

###---- Trivial "binary only" matrices (not data frames) did fail:

x <- matrix(0, 2, 2)
dimnames(x)[[2]] <- c("A", "B")## colnames<- is missing in S+
daisy(x, type = list(symm= "B", asymm="A"))
daisy(x, type = list(symm= "B"))# 0 too

x2 <- x; x2[2,2] <- 1
daisy(x2, type= list(symm = "B"))# |-> 0.5  (gives 1 in S+)
daisy(x2, type= list(symm = "B", asymm="A"))# 1

x3 <- x; x3[] <- diag(2)
daisy(x3) # warning: both as interval scaled -> sqrt(2)
daisy(x3, type= list(symm="B", asymm="A"))#  1
daisy(x3, type= list(symm =c("B","A")))   #  1, S+: sqrt(2)
daisy(x3, type= list(asymm=c("B","A")))   #  1, S+ : sqrt(2)

x4 <- rbind(x3, 1)
daisy(x4, type= list(symm="B", asymm="A"))# 1   0.5 0.5
daisy(x4, type= list(symm=c("B","A")))    # dito;  S+ : 1.41  1   1
daisy(x4, type= list(asymm=c("A","B")))   # dito,     dito



## ----------- example(daisy) -----------------------

data(flower)
data(agriculture)

## Example 1 in ref:
##  Dissimilarities using Euclidean metric and without standardization
(d.agr  <- daisy(agriculture, metric = "euclidean", stand = FALSE))
(d.agr2 <- daisy(agriculture, metric = "manhattan"))


## Example 2 in ref
(dfl0 <- daisy(flower))
stopifnot(identical(c(dfl0),
                    c(daisy(flower, type = list(symm = 1)))) &&
          identical(c(dfl0),
                    c(daisy(flower, type = list(symm = 2)))) &&
          identical(c(dfl0),
                    c(daisy(flower, type = list(symm = 3)))) &&
          identical(c(dfl0),
                    c(daisy(flower, type = list(symm = c(1,3)))))
         )

(dfl1 <- daisy(flower, type = list(asymm = 3)))
(dfl2 <- daisy(flower, type = list(asymm = c(1, 3), ordratio = 7)))
(dfl3 <- daisy(flower, type = list(asymm = 1:3)))

## --- animals
data(animals)
d0 <- daisy(animals)

d1 <- daisy(animals - 1, type=list(asymm=c(2,4)))
(d2 <- daisy(animals - 1, type=list(symm = c(1,3,5,6), asymm=c(2,4))))
stopifnot(c(d1) == c(d2))

d3 <- daisy(2 - animals, type=list(asymm=c(2,4)))
(d4 <- daisy(2 - animals, type=list(symm = c(1,3,5,6), asymm=c(2,4))))
stopifnot(c(d3) == c(d4))

pairs(cbind(d0,d2,d4),
      main = "Animals -- symmetric and asymm. dissimilarities")
