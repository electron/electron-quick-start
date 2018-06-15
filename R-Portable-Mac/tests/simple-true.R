###---- ALL tests here should return  TRUE !
###
###---- "Real" Arithmetic; Numerics etc  -->  ./arith-true.R

### mode checking, etc.
is.recursive(expression(1+3, 2/sqrt(pi)))# fix PR#9

## sum():
all(1:12 == cumsum(rep(1,12)))
x <- rnorm(127); sx <- sum(x);	abs((sum(rev(x)) -sx)) < 1e-12 * abs(sx)

## seq():
typeof(1:4) == "integer" #-- fails for 0.2, 0.3,.., 0.9

## Check parsing with L suffix for integer literals.
typeof(1L) == "integer"
typeof(1000L) == "integer"
typeof(1e3L) == "integer"
typeof(1e-3L) == "double" # gives warning
1.L # gives warning
try(parse(text = "12iL")) # gives syntax error


all((0:6) == pi + ((-pi):pi))
all((0:7) == (pi+seq(-pi,pi, length=8))*7/(2*pi))

1 == as.integer(is.na(c(pi,NA)[2]))
1 == as.integer(is.nan(0/0))

## rev():
cc <- c(1:10,10:1) ;		all(cc == rev(cc))

## dim[names]():
all(names(c(a=pi, b=1, d=1:4)) == c("a","b", paste("d", 1:4, sep="")))
##P names(c(a=pi, b=1, d=1:4))
ncb <- dimnames(cbind(a=1, yy=1:3))[[2]]
(!is.null(ncb)) && all(ncb == c("a","yy"))

all(cbind(a=1:2, b=1:3, c=1:6) == t(rbind(a=1:2, b=1:3, c=1:6)))
##P rbind(a=1:2, b=1:3, c=1:6)
all(dim(cbind(cbind(I=1,x=1:4), c(a=pi))) == 4:3)# fails in S+

a <- b <- 1:3
all(dimnames(cbind(a, b))[[2]] == c("a","b"))

## rbind PR#338
all(dim(m <- rbind(1:2, diag(2))) == 3:2)
all(m == c(1,1,0, 2,0,1))

## factor():
is.factor(factor(integer()))
all(levels(ordered(rev(gl(3,4)))) == 1:3)# coercion to char
all(levels(factor(factor(9:1)[3:5])) == 5:7)
## crossing bug PR#40
is.factor(ff <- gl(2,3) : gl(3,2)) && length(ff) == 6
all(levels(ff) == t(outer(1:2, 1:3, paste, sep=":")))
## from PR#5
ll <- c("A","B"); ff <- factor(ll); f0 <- ff[, drop=TRUE]
all(f0 == ff) && all(levels(ff) == ll) && is.factor(ff) && is.factor(f0)

### data.frame s :

## from lists [bug PR#100]
x <- NULL
x$x1 <- 1:10
x$x2 <- 0:9
all(dim(dx <- as.data.frame(x)) == c(10,2))

## Logicals: (S is wrong)
l1 <- c(TRUE,FALSE,TRUE)
(! as.logical(as.data.frame(FALSE)[,1]))
all(l1 == as.logical(as.data.frame(l1)[,1]))

## empty data.frames :
x <- data.frame(a=1:3)
x30 <- {
    if(is.R()) x[, -1]# not even possible in S+
    else structure(list(), row.names = paste(1:3), class = "data.frame")
}
all(dim(x30) == c(3,0))
x01 <- x[-(1:3), , drop = FALSE]
x00 <- x01[,-1]
all(dim(x01) == 0:1)
all(dim(x00) == 0)
all(dim(x) == dim(rbind(x, x01)))
## bugs up to 1.2.3 :
all(dim(x30) == dim(m30 <- as.matrix(x30)))
all(dim(x01) == dim(m01 <- as.matrix(x01)))
all(dim(x30) == dim(as.data.frame(m30)))
all(dim(x01) == dim(as.data.frame(m01)))
all(dim(x01) == dim(   data.frame(m01)))
all(dim(x30) == dim(   data.frame(m30)))
all(dim(x)   == dim(cbind(x, x30)))
## up to 1.4.0 :
all(dim(x30) == dim( data.matrix(x30)))
all(dim(x00) == dim( data.matrix(x00)))

m0 <- matrix(pi, 0,3)
a302 <- array("", dim=c(3,0,2))
identical(apply(m0, 1, dim), NULL)
identical(apply(m0, 2, dim), NULL)
identical(apply(m0, 1,length),  integer(0))
identical(apply(m0, 2,length),  integer(3))
identical(apply(a302, 1, mode), rep("character",3))
## NO (maybe later?):
## identical(apply(a302, 2, mode), rep("character",0))
is.character(aa <- apply(a302, 2, mode)) && length(aa) == 0
identical(apply(a302, 3, mode), rep("character",2))
identical(apply(a302, 3, length),integer(2))
identical(apply(a302, 3, dim), matrix(as.integer(c(3,0)), 2 ,2))
identical(apply(a302, 1, dim), matrix(as.integer(c(0,2)), 2 ,3))
identical(apply(array(dim=3), 1,length), rep(1:1, 3))
identical(apply(array(dim=0), 1,length), rep(1:1, 0))# = integer(0)


### Subsetting

## bug PR#425
x <- matrix(1:4, 2, 2, dimnames=list(c("abc","ab"), c("cde","cd")))
y <- as.data.frame(x)
all(x["ab",] == c(2,4))
all(y["ab",] == c(2,4))

## from bug PR#447
x <- 1:2 ; x[c("2","2")] <- 4
all.equal(x, c(1:2, "2" = 4))

## stretching
l2 <- list(a=1, b=2)
l2["cc"] <- pi
l2[["d"]] <- 4
l2 $ e <- 55
all.equal(l2, list(a = 1, b = 2, cc = pi, d = 4, e = 55), tolerance = 0)
all.equal(l2["d"], list(d = 4))
l2$d == 4 && l2$d == l2[["d"]]

## bug in R <= 1.1
f1 <- y1 ~ x1
f2 <- y2 ~ x2
f2[2] <- f1[2]
deparse(f2) == "y1 ~ x2"

m <- cbind(a=1:2,b=c(R=10,S=11))
all(sapply(dimnames(m), length) == c(2,2))
## [[ for matrix:
m[[1,2]] == m[[3]] && m[[3]] == m[3] && m[3] == m[1,2]

## bug in R <= 1.1.1 : unclass(*) didn't drop the class!
## to be robust to S4 methods DON'T test for null class
## The test for attr(,"class") is valid, if essentially useless
d1 <- rbind(data.frame(a=1, b = I(TRUE)), new = c(7, "N"))
is.null(attr(unclass(d1$b), "class"))

## bugs in R 1.2.0
format(as.POSIXct(relR120 <- "2000-12-15 11:24:40")) == relR120
format(as.POSIXct(substr(relR120,1,10))) == substr(relR120,1,10)

## rank() with NAs (and ties)
x <- c(3:1,6,4,3,NA,5,0,NA)
rx <-  rank(x)
all(rx == c(4.5, 3:2, 8, 6, 4.5, 9, 7, 1, 10))
rxK <- rank(x, na.last = "keep")
all(rx [rx <= 8]    == na.omit(rxK))
all(rank(x, na.last = NA) == na.omit(rxK))

## as.list.function() instead of *.default():
identical(as.list(as.list),
	  alist(x = , ... = , UseMethod("as.list")))

## startsWith() / endsWith()  assertions
t1 <- c("Foobar", "bla bla", "something", "another", "blu", "brown",
        "blau blüht der Enzian")# non-ASCII
t2 <- c("some text", "any text")
t3 <- c("Martin", "Zürich", "Mächler")

all(endsWith(t1, "")); all(startsWith(t1, ""))
all(endsWith(t2, "")); all(startsWith(t2, ""))
all(endsWith(t3, "")); all(startsWith(t3, ""))
all(endsWith(t2, "text"))
all(endsWith(t2, " text"))
identical(startsWith(t1, "b" ), c(FALSE, TRUE, FALSE, FALSE, TRUE,  TRUE, TRUE))
identical(startsWith(t1, "bl"), c(FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE))
identical(startsWith(t1, "bla"),c(FALSE, TRUE, FALSE, FALSE,FALSE, FALSE, TRUE))
identical(  endsWith(t1, "n"),  c(FALSE,FALSE, FALSE, FALSE,FALSE,  TRUE, TRUE))
identical(  endsWith(t1, "an"), c(FALSE,FALSE, FALSE, FALSE,FALSE, FALSE, TRUE))
##
identical(startsWith(t3, "M" ), c( TRUE, FALSE, TRUE))
identical(startsWith(t3, "Ma"), c( TRUE, FALSE, FALSE))
identical(startsWith(t3, "Mä"), c(FALSE, FALSE, TRUE))

