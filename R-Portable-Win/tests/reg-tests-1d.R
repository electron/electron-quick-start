## Regression tests for R >= 3.4.0

pdf("reg-tests-1d.pdf", encoding = "ISOLatin1.enc")
.pt <- proc.time()

## body() / formals() notably the replacement versions
x <- NULL; tools::assertWarning(   body(x) <-    body(mean))	# to be error
x <- NULL; tools::assertWarning(formals(x) <- formals(mean))	# to be error
x <- NULL; tools::assertWarning(f <-    body(x)); stopifnot(is.null(f))
x <- NULL; tools::assertWarning(f <- formals(x)); stopifnot(is.null(f))
## these all silently coerced NULL to a function in R <= 3.2.x


## match(x, t): fast algorithm for length-1 'x' -- PR#16885
## a) string 'x'  when only encoding differs
tmp <- "年付"
tmp2 <- "\u5e74\u4ed8" ; Encoding(tmp2) <- "UTF-8"
for(ex in list(c(tmp, tmp2), c("foo","foo"))) {
    cat(sprintf("\n|%s|%s| :\n----------\n", ex[1], ex[2]))
    for(enc in c("latin1", "UTF-8", "unknown")) { # , "MAC", "WINDOWS-1251"
	cat(sprintf("%9s: ", enc))
	tt <- ex[1]; Encoding(tt) <- enc; t2 <- ex[2]
	if(identical(i1 <- (  tt       %in% t2),
		     i2 <- (c(tt, "a") %in% t2)[1]))
	    cat(i1,"\n")
	else
	    stop("differing: ", i1, ", ", i2)
    }
}
##
outerID <- function(x,y, ...) outer(x,y, Vectorize(identical,c("x","y")), ...)
## b) complex 'x' with different kinds of NaN
x0 <- c(0,1, NA_real_, NaN)
z <- outer(x0,x0, complex, length.out=1L)
z <- c(z[is.na(z)], # <- of length 4 * 4 - 2*2 = 12
       as.complex(NaN), as.complex(0/0), # <- typically these two differ in bits
       complex(real = NaN), complex(imaginary = NaN),
       NA_complex_, complex(real = NA), complex(imaginary = NA))
## 1..12 all differ, then
symnum(outerID(z,z, FALSE,FALSE,FALSE,FALSE))# [14] differing from all on low level
symnum(outerID(z,z))                         # [14] matches 2, 13,15
(mz <- match(z, z)) # (checked with m1z below)
zRI <- rbind(Re=Re(z), Im=Im(z)) # and see the pattern :
print(cbind(format = format(z), t(zRI), mz), quote=FALSE)
stopifnot(apply(zRI, 2, anyNA)) # NA *or* NaN: all TRUE
is.NA <- function(.) is.na(.) & !is.nan(.)
(iNaN <- apply(zRI, 2, function(.) any(is.nan(.))))
(iNA <-  apply(zRI, 2, function(.) any(is.NA (.)))) # has non-NaN NA's
## use iNA for consistency check once FIXME happened
m1z <- sapply(z, match, table = z)
stopifnot(identical(m1z, mz),
	  identical(m1z == 1L,             iNA),
          identical(match(z, NA, 0) == 1L, iNA),
	  identical(mz[mz != 1L], c(2L, 4L, 9L, 10L, 12L, 2L, 2L, 2L, 9L)))
## m1z uses match(x, *) with length(x) == 1 and failed in R 3.3.0
set.seed(17)
for(. in 1:20) {
    zz <- sample(z)
    stopifnot(identical(match(zz,zz), vapply(zz, match, -1L, table = zz)))
}
##
## PR#16909 - a consequence of the match() bug; check here too:
dvn <- paste0("var\xe9", 1:2); Encoding(dvn) <- "latin1"
dv <- data.frame(1:3, 3); names(dv) <- dvn; dv[,"var\u00e92"] <- 2
stopifnot(ncol(dv) == 2, dv[,2] == 2, identical(names(dv), dvn))
## in R 3.3.0, got a 3rd column


## deparse(<complex>,  "digits17")
fz <- format(z <- c(outer(-1:2, 1i*(-1:1), `+`)))
(fz0 <- sub("^ +","",z))
r <- c(-1:1,100, 1e20); z2 <- c(outer(pi*r, 1i*r, `+`)); z2
dz2 <- deparse(z2, control="digits17")
stopifnot(identical(deparse(z, 200, control = "digits17"),
                    paste0("c(", paste(fz0, collapse=", "), ")")),
          print((sum(nchar(dz2)) - 2) / length(z2)) < 22, # much larger in <= 3.3.0
          ## deparse <-> parse equivalence, 17 digits should be perfect:
	  all.equal(z2, eval(parse(text = dz2)), tolerance = 3e-16)) # seen 2.2e-35 on 32b
## deparse() for these was "ugly" in R <= 3.3.x


## length(environment(.)) == #{objects}
stopifnot(identical(length(      baseenv()),
                    length(names(baseenv()))))
## was 0 in R <= 3.3.0


## "srcref"s of closures
op <- options(keep.source = TRUE)# as in interactive use
getOption("keep.source")
stopifnot(identical(function(){}, function(){}),
          identical(function(x){x+1},
                    function(x){x+1})); options(op)
## where all FALSE in 2.14.0 <= R <= 3.3.x because of "srcref"s etc


## PR#16925, radix sorting INT_MAX w/ decreasing=TRUE and na.last=TRUE
## failed ASAN check and segfaulted on some systems.
data <- c(2147483645L, 2147483646L, 2147483647L, 2147483644L)
stopifnot(identical(sort(data, decreasing = TRUE, method = "radix"),
                    c(2147483647L, 2147483646L, 2147483645L, 2147483644L)))


## as.factor(<named integer>)
ni <- 1:2; Nni <- names(ni) <- c("A","B")
stopifnot(identical(Nni, names(as.factor(ni))),
	  identical(Nni, names(   factor(ni))),
	  identical(Nni, names(   factor(ni+0))), # +0 : "double"
	  identical(Nni, names(as.factor(ni+0))))
## The first one lost names in  3.1.0 <= R <= 3.3.0


## strtrim(<empty>, *) should work as substr(<empty>, *) does
c0 <- character(0)
stopifnot(identical(c0, strtrim(c0, integer(0))))
## failed in R <= 3.3.0


## Factors with duplicated levels {created via low-level code}:
set.seed(11)
f0 <- factor(sample.int(9, 20, replace=TRUE))
(f <- structure(f0, "levels" = as.character(c(2:7, 2:4))))
tools::assertWarning(print(f))
tools::assertError(validObject(f))
## no warning in print() for R <= 3.3.x


## R <= 3.3.0 returned integer(0L) from unlist() in this case:
stopifnot(identical(levels(unlist(list(factor(levels="a")))), "a"))


## diff(<difftime>)
d <- as.POSIXct("2016-06-08 14:21", tz="UTC") + as.difftime(2^(-2:8), units="mins")
dd  <- diff(d)
ddd <- diff(dd)
d3d <- diff(ddd)
d7d <- diff(d, differences = 7)
(ldd <- list(dd=dd, ddd=ddd, d3d=d3d, d7d=d7d))
stopifnot(identical(ddd, diff(d, differences = 2)),
	  identical(d3d, diff(d, differences = 3)))
stopifnot(vapply(ldd, units, "") == "secs",
	  vapply(ldd, class, "") == "difftime",
	  lengths(c(list(d), ldd)) == c(11:8, 11-7))
## was losing time units in R <= 3.3.0


## sample(NA_real_) etc
for(xx in list(NA, NA_integer_, NA_real_, NA_character_, NA_complex_, "NA", 1i))
    stopifnot(identical(xx, sample(xx)))
## error in R <= 3.3.1


## merge.data.frame with names matching order()'s arguments (PR#17119)
nf <- names(formals(order))
nf <- nf[nf != "..."]
v1 <- c(1,3,2)
v2 <- c(4,2,3)
for(nm in nf)  {
    cat(nm,":\n")
    mdf <- merge(
        as.data.frame(setNames(list(v1), nm=nm)),
        as.data.frame(setNames(list(v2), nm=nm)), all = TRUE)
    stopifnot(identical(mdf,
                        as.data.frame(setNames(list(0+ 1:4), nm=nm))))
}
## some were wrong, others gave an error in R <= 3.3.1


## PR#16936: table() dropping "NaN" level & 'exclude' sometimes failing
op <- options(warn = 2)# no warnings allowed
(fN1 <- factor(c("NA", NA, "NbN", "NaN")))
(tN1 <- table(fN1)) ##--> was missing 'NaN'
(fN <- factor(c(rep(c("A","B"), 2), NA), exclude = NULL))
(tN  <- table(fN, exclude = "B"))       ## had extraneous "B"
(tN. <- table(fN, exclude = c("B",NA))) ## had extraneous "B" and NA
stopifnot(identical(c(tN1), c(`NA`=1L, `NaN`=1L, NbN=1L))
        , identical(c(tN),  structure(2:1, .Names = c("A", NA)))
        , identical(c(tN.), structure(2L,  .Names = "A"))
)
## both failed in R <= 3.3.1
stopifnot(identical(names(dimnames(table(data.frame(Titanic[2,2,,])))),
		    c("Age", "Survived", "Freq"))) # was wrong for ~ 32 hours
##
## Part II:
x <- factor(c(1, 2, NA, NA), exclude = NULL) ; is.na(x)[2] <- TRUE
x # << two "different" NA's (in codes | w/ level) looking the same in print()
stopifnot(identical(x, structure(as.integer(c(1, NA, 3, 3)),
				 .Label = c("1", "2", NA), class = "factor")))
(txx <- table(x, exclude = NULL))
stopifnot(identical(txx, table(x, useNA = "ifany")),
	  identical(as.vector(txx), c(1:0, 3L)))
## wrongly gave  1 0 2  for R versions  2.8.0 <= Rver <= 3.3.1
u.opt <- list(no="no", ifa = "ifany", alw = "always")
l0 <- c(list(`_` = table(x)),
           lapply(u.opt, function(use) table(x, useNA=use)))
xcl <- list(NULL=NULL, none=""[0], "NA"=NA, NANaN = c(NA,NaN))
options(op) # warnings ok:
lt <- lapply(xcl, function(X)
    c(list(`_` = table(x, exclude=X)), #--> 4 warnings from (exclude, useNA):
      lapply(u.opt, function(use) table(x, exclude=X, useNA=use))))
(y <- factor(c(4,5,6:5)))
ly <-  lapply(xcl, function(X)
    c(list(`_` = table(y, exclude=X)), #--> 4 warnings ...
      lapply(u.opt, function(use) table(y, exclude=X, useNA=use))))
lxy <-  lapply(xcl, function(X)
    c(list(`_` = table(x, y, exclude=X)), #--> 4 warnings ...
      lapply(u.opt, function(use) table(x, y, exclude=X, useNA=use))))
op <- options(warn = 2)# no warnings allowed

stopifnot(
    vapply(lt, function(i) all(vapply(i, class, "") == "table"), NA),
    vapply(ly, function(i) all(vapply(i, class, "") == "table"), NA),
    vapply(lxy,function(i) all(vapply(i, class, "") == "table"), NA)
    , identical((ltNA  <- lt [["NA"  ]]), lt [["NANaN"]])
    , identical((ltNl  <- lt [["NULL"]]), lt [["none" ]])
    , identical((lyNA  <- ly [["NA"  ]]), ly [["NANaN"]])
    , identical((lyNl  <- ly [["NULL"]]), ly [["none" ]])
    , identical((lxyNA <- lxy[["NA"  ]]), lxy[["NANaN"]])
    , identical((lxyNl <- lxy[["NULL"]]), lxy[["none" ]])
)
## 'NULL' behaved special (2.8.0 <= R <= 3.3.1)  and
##  *all* tables in l0 and lt were == (1 0 2) !
ltN1 <- ltNA[[1]]; lyN1 <- lyNA[[1]]; lxyN1 <- lxyNA[[1]]
lNl1 <- ltNl[[1]]; lyl1 <- lyNl[[1]]; lxyl1 <- lxyNl[[1]]

stopifnot(
    vapply(names(ltNA) [-1], function(n) identical(ltNA [[n]], ltN1 ), NA),
    vapply(names(lyNA) [-1], function(n) identical(lyNA [[n]], lyN1 ), NA),
    vapply(names(lxyNA)[-1], function(n) identical(lxyNA[[n]], lxyN1), NA),
    identical(lyN1, lyl1),
    identical(2L, dim(ltN1)), identical(3L, dim(lyN1)),
    identical(3L, dim(lNl1)),
    identical(dimnames(ltN1), list(x = c("1","2"))),
    identical(dimnames(lNl1), list(x = c("1","2", NA))),
    identical(dimnames(lyN1), list(y = paste(4:6))),
    identical(  1:0    , as.vector(ltN1)),
    identical(c(1:0,3L), as.vector(lNl1)),
    identical(c(1:2,1L), as.vector(lyN1))
    , identical(c(1L, rep(0L, 5)), as.vector(lxyN1))
    , identical(dimnames(lxyN1), c(dimnames(ltN1), dimnames(lyN1)))
    , identical(c(1L,1:0), as.vector(table(3:1, exclude=1, useNA = "always")))
    , identical(c(1L,1L ), as.vector(table(3:1, exclude=1)))
)

x3N <- c(1:3,NA)
(tt <- table(x3N, exclude=NaN))
stopifnot(tt == 1, length(nt <- names(tt)) == 4, is.na(nt[4])
	, identical(tt, table(x3N, useNA = "ifany"))
	, identical(tt, table(x3N, exclude = integer(0)))
	, identical(t3N <- table(x3N), table(x3N, useNA="no"))
	, identical(c(t3N), setNames(rep(1L, 3), as.character(1:3)))
	##
	, identical(c("2" = 1L), c(table(1:2, exclude=1) -> t12.1))
	, identical(t12.1, table(1:2, exclude=1, useNA= "no"))
	, identical(t12.1, table(1:2, exclude=1, useNA= "ifany"))
	, identical(structure(1:0, .Names = c("2", NA)),
		    c(     table(1:2, exclude=1, useNA= "always")))
)
options(op) # (revert to default)


## contour() did not check args sufficiently
tryCatch(contour(matrix(rnorm(100), 10, 10), levels = 0, labels = numeric()),
         error = function(e) e$message)
## caused segfault in R 3.3.1 and earlier


## unique.warnings() needs better duplicated():
.tmp <- lapply(list(0, 1, 0:1, 1:2, c(1,1), -1:1), function(x) wilcox.test(x))
stopifnot(length(uw <- unique(warnings())) == 2)
## unique() gave only one warning in  R <= 3.3.1


op <- options(warn = 2)# no warnings allowed

## findInterval(x, vec)  when 'vec' is of length zero
n0 <- numeric(); TF <- c(TRUE, FALSE)
stopifnot(0 == unlist(lapply(TF, function(L1)
    lapply(TF, function(L2) lapply(TF, function(L3)
        findInterval(x=8:9, vec=n0, L1, L2, L3))))))
## did return -1's for all.inside=TRUE  in R <= 3.3.1


## droplevels(<factor with NA-level>)
L3 <- c("A","B","C")
f <- d <- factor(rep(L3, 2), levels = c(L3, "XX")); is.na(d) <- 3:4
(dn <- addNA(d)) ## levels: A B C XX <NA>
stopifnot(identical(levels(print(droplevels(dn))), c(L3, NA))
	  ## only XX must be dropped; R <= 3.3.1 also dropped <NA>
	  , identical(levels(droplevels(f)), L3)
	  , identical(levels(droplevels(d)), L3) # do *not* add <NA> here
	  , identical(droplevels(d ), d [, drop=TRUE])
	  , identical(droplevels(f ), f [, drop=TRUE])
	  , identical(droplevels(dn), dn[, drop=TRUE])
	  )


## summary.default() no longer rounds (just its print() method does):
set.seed(0)
replicate(256, { x <- rnorm(1); stopifnot(summary(x) == x)}) -> .t
replicate(256, { x <- rnorm(2+rpois(1,pi))
    stopifnot(min(x) <= (sx <- summary(x)), sx <= max(x))}) -> .t
## was almost always wrong in R <= 3.3.x


## NULL in integer arithmetic
i0 <- integer(0)
stopifnot(identical(1L + NULL, 1L + integer()),
	  identical(2L * NULL, i0),
	  identical(3L - NULL, i0))
## gave double() in R <= 3.3.x


## factor(x, exclude)  when  'x' or 'exclude' are  character -------
stopifnot(identical(factor(c(1:2, NA), exclude = ""),
		    factor(c(1:2, NA), exclude = NULL) -> f12N))
fab <- factor(factor(c("a","b","c")), exclude = "c")
stopifnot(identical(levels(fab), c("a","b")))
faN <- factor(c("a", NA), exclude=NULL)
stopifnot(identical(faN, factor(faN, exclude="c")))
## differently with NA coercion warnings in R <= 3.3.x

## factor(x, exclude = X) - coercing 'exclude' or not
## From r-help/2005-April/069053.html :
fNA <- factor(as.integer(c(1,2,3,3,NA)), exclude = NaN)
stopifnot(identical(levels(fNA), c("1", "2", "3", NA)))
## did exclude NA wrongly in R <= 3.3.x
## Now when 'exclude' is a factor,
cc <- c("x", "y", "NA")
ff <- factor(cc)
f2 <- factor(ff, exclude = ff[3]) # it *is* used
stopifnot(identical(levels(f2), cc[1:2]))
## levels(f2) still contained NA in R <= 3.3.x


## arithmetic, logic, and comparison (relop) for 0-extent arrays
(m <- cbind(a=1[0], b=2[0]))
Lm <- m; storage.mode(Lm) <- "logical"
Im <- m; storage.mode(Im) <- "integer"
stopifnot(
    identical( m, m + 1 ), identical( m,  m + 1 [0]), identical( m,  m + NULL),
    identical(Im, Im+ 1L), identical(Im, Im + 1L[0]), identical(Im, Im + NULL),
    identical(m, m + 2:3), identical(Im, Im + 2:3),
    identical(Lm, m & 1),  identical(Lm,  m | 2:3),
    identical(Lm, m & TRUE[0]), identical(Lm, Lm | FALSE[0]),
    identical(Lm, m & NULL), # gave Error (*only* place where NULL was not allowed)
    identical(Lm, m > 1), identical(Lm, m > .1[0]), identical(Lm, m > NULL),
    identical(Lm, m <= 2:3)
)
mm <- m[,c(1:2,2:1,2)]
tools::assertError(m + mm) # ... non-conformable arrays
tools::assertError(m | mm) # ... non-conformable arrays
tools::assertError(m == mm)# ... non-conformable arrays
## in R <= 3.3.x, relop returned logical(0) and  m + 2:3  returned numeric(0)

## arithmetic, logic, and comparison (relop) -- inconsistency for 1x1 array o <vector >= 2>:
(m1 <- matrix(1,1,1, dimnames=list("Ro","col")))
(m2 <- matrix(1,2,1, dimnames=list(c("A","B"),"col")))
if(FALSE) { # in the future (~ 2018):
tools::assertError(m1  + 1:2) ## was [1] 2 3  even w/o warning in R <= 3.3.x
} else tools::assertWarning(m1v <- m1 + 1:2); stopifnot(identical(m1v, 1+1:2))
tools::assertError(m1  & 1:2) # ERR: dims [product 1] do not match the length of object [2]
tools::assertError(m1 <= 1:2) # ERR:                  (ditto)
##
## non-0-length arrays combined with {NULL or double() or ...} *fail*
n0 <- numeric(0)
l0 <- logical(0)
stopifnot(identical(m1 + NULL, n0), # as "always"
	  identical(m1 +  n0 , n0), # as "always"
	  identical(m1 & NULL, l0), # ERROR in R <= 3.3.x
	  identical(m1 &  l0,  l0), # ERROR in R <= 3.3.x
	  identical(m1 > NULL, l0), # as "always"
	  identical(m1 >  n0 , l0)) # as "always"
## m2 was slightly different:
stopifnot(identical(m2 + NULL, n0), # ERROR in R <= 3.3.x
	  identical(m2 +  n0 , n0), # ERROR in R <= 3.3.x
	  identical(m2 & NULL, l0), # ERROR in R <= 3.3.x
	  identical(m2 &  l0 , l0), # ERROR in R <= 3.3.x
	  identical(m2 == NULL, l0), # as "always"
	  identical(m2 ==  n0 , l0)) # as "always"


## strcapture()
stopifnot(identical(strcapture("(.+) (.+)",
                               c("One 1", "noSpaceInLine", "Three 3"),
                               proto=data.frame(Name="", Number=0)),
                    data.frame(Name=c("One", NA, "Three"),
                               Number=c(1, NA, 3))))


## PR#17160: min() / max()  arg.list starting with empty character
TFT <- 1:3 %% 2 == 1
stopifnot(
    identical(min(character(), TFT), "0"),
    identical(max(character(), TFT), "1"),
    identical(max(character(), 3:2, 5:7, 3:0), "7"),
    identical(min(character(), 3:2, 5:7), "2"),
    identical(min(character(), 3.3, -1:2), "-1"),
    identical(max(character(), 3.3, 4:0), "4"))
## all gave NA in R <= 3.3.0


## PR#17147: xtabs(~ exclude) fails in R <= 3.3.1
exc <- exclude <- c(TRUE, FALSE)
xt1 <- xtabs(~ exclude) # failed : The name 'exclude' was special
xt2 <- xtabs(~ exc)
xt3 <- xtabs(rep(1, length(exclude)) ~ exclude)
noCall  <- function(x) structure(x, call = NULL)
stripXT <- function(x) structure(x, call = NULL, dimnames = unname(dimnames(x)))
stopifnot(
    identical(dimnames(xt1), list(exclude = c("FALSE", "TRUE"))),
    identical(names(dimnames(xt2)), "exc"),
    all.equal(stripXT(xt1), stripXT(xt2)),
    all.equal(noCall (xt1), noCall (xt3)))
## [fix was to call table() directly instead of via do.call(.)]


## str(xtabs( ~ <var>)):
stopifnot(grepl("'xtabs' int", capture.output(str(xt2))[1]))
## did not mention "xtabs" in R <= 3.3.1


## findInterval(x_with_ties, vec, left.open=TRUE)
stopifnot(identical(
    findInterval(c(6,1,1), c(0,1,3,5,7), left.open=TRUE), c(4L, 1L, 1L)))
set.seed(4)
invisible(replicate(100, {
 vec <- cumsum(1 + rpois(6, 2))
 x <- rpois(50, 3) + 0.5 * rbinom(50, 1, 1/4)
 i <- findInterval(x, vec, left.open = TRUE)
 .v. <- c(-Inf, vec, Inf)
 isIn <-  .v.[i+1] < x  &  x <= .v.[i+2]
 if(! all(isIn)) {
     dump(c("x", "vec"), file=stdout())
     stop("not ok at ", paste(which(!isIn), collapse=", "))
 }
}))
## failed in R <= 3.3.1


## PR#17132 -- grepRaw(*, fixed = TRUE)
stopifnot(
    identical(1L,        grepRaw("abcd",     "abcd",           fixed = TRUE)),
    identical(integer(), grepRaw("abcdefghi", "a", all = TRUE, fixed = TRUE)))
## length 0 and seg.faulted in R <= 3.3.2


## PR#17186 - Sys.timezone() on some Debian-derived platforms
(S.t <- Sys.timezone())
if(is.na(S.t) || !nzchar(S.t)) stop("could not get timezone")
## has been NA_character_  in Ubuntu 14.04.5 LTS


## format()ing invalid hand-constructed  POSIXlt  objects
d <- as.POSIXlt("2016-12-06"); d$zone <- 1
tools::assertError(format(d))
d$zone <- NULL
stopifnot(identical(format(d),"2016-12-06"))
d$zone <- "CET" # = previous, but 'zone' now is last
tools::assertError(format(d))
dlt <- structure(
    list(sec = 52, min = 59L, hour = 18L, mday = 6L, mon = 11L, year = 116L,
         wday = 2L, yday = 340L, isdst = 0L, zone = "CET", gmtoff = 3600L),
    class = c("POSIXlt", "POSIXt"), tzone = c("", "CET", "CEST"))
dlt$sec <- 10000 + 1:10 # almost three hours & uses re-cycling ..
fd <- format(dlt)
stopifnot(length(fd) == 10, identical(fd, format(dct <- as.POSIXct(dlt))))
dlt2 <- as.POSIXlt(dct)
stopifnot(identical(format(dlt2), fd))
## The two assertError()s gave a seg.fault in  R <= 3.3.2


stopifnot(inherits(methods("("), "MethodsFunction"),
          inherits(methods("{"), "MethodsFunction"))
## methods("(") and ..("{")  failed in R <= 3.3.2


## moved after commit in r71778
f <- eval(parse(text = "function() { x <- 1 ; for(i in 1:10) { i <- i }}",
                keep.source = TRUE))
g <- removeSource(f)
stopifnot(is.null(attributes(body(g)[[3L]][[4L]])))

## pmin/pmax of ordered factors -- broken in R 3.3.2  [PR #17195]
of <- ordered(c(1,5,6))
set.seed(7); rof <- sample(of, 12, replace=TRUE)
stopifnot(identical(pmax(rof, of), ordered(pmax(c(rof), c(of)), labels=levels(rof)) -> pmar),
	  identical(pmax(of, rof), pmar),
	  identical(pmin(rof, of), ordered(pmin(c(rof), c(of)), labels=levels(rof)) -> pmir),
	  identical(pmin(of, rof), pmir),
	  identical(pmin(rof, 5), ordered(pmin(c(rof), 2), levels=1:3, labels=levels(rof))),
	  identical(pmax(rof, 6), ordered(pmax(c(rof), 3), levels=1:3, labels=levels(rof))),
	  identical(pmax(rof, 1), rof),
	  identical(pmin(rof, 6), rof),
	  identical(pmax(of, 5, rof), ordered(pmax(c(of),2L,c(rof)), levels=1:3,
                                              labels=levels(of)))
	  )
## these were "always" true .. but may change (FIXME ?)
stopifnot(
    identical(of,   pmin(of, 3)) # what? error? at least warning?
    ,
    identical(pmar, pmax(of, 3, rof))
)
## pmin/pmax() of 0-length S3 classed  [PR #17200]
for(ob0 in list(I(character()), I(0[0]), I(0L[0]),
                structure(logical(), class="L"),
                structure(character(), class="CH"))) {
    stopifnot(identical(ob0, pmax(ob0, ob0)),
              identical(ob0, pmin(ob0, ob0)),
              identical(ob0, pmin(ob0, "")),
              identical(ob0, pmax(ob0, "")))
}
## pmin()/pmax() of matching numeric data frames
mUSJ <- data.matrix(dUSJ <- USJudgeRatings)
stopifnot(
    identical(              pmin(dUSJ, 10 - dUSJ),
              as.data.frame(pmin(mUSJ, 10 - mUSJ))),
    identical(              pmax(dUSJ, 10 - dUSJ),
              as.data.frame(pmax(mUSJ, 10 - mUSJ))))
## had failed for a while.   Note however :
d1 <- data.frame(y0 = 0:3 +1/2) ; (d1.2 <- d1[1:2, , drop=FALSE])
stopifnot(## FIXME: The 'NA's really are wrong
    identical(pmax(d1,2),     data.frame(y0 = c(2, NA, 2.5, 3.5)))
   ,
    identical(pmax(d1, 3-d1), data.frame(y0 = .5+c(2, 1:3)))
   ,
    identical(pmax(d1.2, 2),  data.frame(y0 = c(2, NA)))
   ,
    identical(pmax(d1.2, 2-d1.2),data.frame(y0=c(1.5,1.5)))
   ,
    identical(pmin(d1, 2),    data.frame(y0 = c(.5+0:1, NA,NA)))
   ,
    identical(pmin(d1, 3-d1), data.frame(y0 = .5+c(0, 1:-1)))
   ,
    identical(pmin(d1.2, 2),  data.frame(y0 = c(.5, 1.5)))
   ,
    identical(pmin(d1.2, 2-d1.2),data.frame(y0 = c(.5,.5)))
)
## some CRAN pkgs have been relying that these at least "worked somehow"


## quantile(x, prob) monotonicity in prob[] - PR#16672
sortedQ <- function(x, prob, ...)
    vapply(1:9, function(type)
        !is.unsorted(quantile(x, prob, type=type, names=FALSE, ...)), NA)
xN <- c(NA, 10.5999999999999996, NA, NA, NA, 10.5999999999999996,
        NA, NA, NA, NA, NA, 11.3000000000000007, NA, NA,
        NA, NA, NA, NA, NA, 5.2000000000000002)
sQ.xN <- sortedQ(xN, probs = seq(0,1,1/10), na.rm = TRUE)
x2 <- rep(-0.00090419678460984, 602)
stopifnot(sQ.xN, sortedQ(x2, (0:5)/5))
## both not fulfilled in R < 3.4.0


## seq.int() anomalies in border cases, partly from Mick Jordan (on R-devel):
stopifnot(
    identical(1,         seq.int(to=1,  by=1 )),
    identical(1:2,       seq.int(to=2L, by=1L)),
    identical(c(1L, 3L), seq.int(1L, 3L, length.out=2))
)
## the first was missing(.), the others "double" in R < 3.4.0
tools::assertError(seq(1,7, by = 1:2))# gave warnings in R < 3.4.0
## seq() for <complex> / <integer>
stopifnot(all.equal(seq(1+1i, 9+2i, length.out = 9) -> sCplx,
                    1:9 + 1i*seq(1,2, by=1/8)),
          identical(seq(1+1i, 9+2i, along.with = 1:9), sCplx),
          identical(seq(1L, 3L, by=1L), 1:3)
)
## had failed in R-devel for a few days
D1 <- as.Date("2017-01-06")
D2 <- as.Date("2017-01-12")
seqD1 <- seq.Date(D1, D2, by = "1 day")
stopifnot(identical(seqD1, seq(D1, D2, by = "1 days")),
## These two work "accidentally" via seq -> seq.default + "Date"-arithmetic
          identical(seqD1, seq(by = 1, from = D1, length.out = 7)),
          identical(seqD1, seq(by = 1,   to = D2, length.out = 7))
## swap order of (by, to) ==> *FAILS* because directly calls seq.Date() - FIXME?
        , TRUE ||
          identical(seqD1, seq(to = D2,  by = 1, length.out = 7))
          )
## had failed in R-devel for a couple of days
stopifnot(identical(seq(9L, by = -1L, length.out = 4L), 9:6),
	  identical(seq(9L, by = -1L, length.out = 4 ), 9:6))
## for consistency, new in R >= 3.4.0


## Underflow happened when parsing small hex constants PR#17199
stopifnot(
    as.double("0x1.00000000d0000p-987") > 0,   # should be 7.645296e-298
    as.double("0x1.0000000000000p-1022") > 0,  # should be 2.225074e-308
    as.double("0x1.f89fc1a6f6613p-974") > 0    # should be 1.23456e-293
)
##


## format.POSIX[cl]t() after print.POSIXct()
dt <- "2012-12-12 12:12:12"
x <- as.POSIXct(dt, tz = "GMT")
stopifnot(identical(format(x), dt))
(Sys.t <- Sys.timezone())
someCET <- paste("Europe", c("Berlin", "Brussels", "Copenhagen", "Madrid",
                             "Paris", "Rome", "Vienna", "Zurich"), sep="/")
if(Sys.t %in% someCET)
    stopifnot(print(TRUE), identical(format(x, tz = ""), "2012-12-12 13:12:12"))
## had failed for almost a month in R-devel & R-patched


## xtabs() , notably with NA's :
asArr <- function(x) {
    attributes(x) <- list(dim=dim(x), dimnames=dimnames(x)); x }
as_A <- function(x, A) array(x, dim=dim(A), dimnames=dimnames(A))
eq_A <- function(a,b) ## equality of arrays, notably sparseMatrix vs dense
    identical(dim(a),dim(b)) && identical(dimnames(a),dimnames(b)) &&
        identical(as.vector(a), as.vector(b))
esoph2 <- droplevels(subset(esoph, subset = tobgp > "10-19" & alcgp >= "40-79"))
(xt <- xtabs(~ agegp + alcgp + tobgp, esoph2))
stopifnot(identical(dim(xt), c(6L, 3L, 2L)), # of the 6 x 3 x 2 = 36 entries,
          identical(which(xt == 0), c(7L, 12L, 18L, 23L, 30L, 32L, 36L)),
          ## the above 8 are zeros and the rest is 1 :
          all(xt[xt != 0] == 1))
xtC <- xtabs(ncontrols ~ agegp + alcgp + tobgp, data = esoph2)
stopifnot(# no NA's in data, hence result should have none, just 0's:
    identical(asArr(unname(xtC)),
	      array(c(4, 14, 15, 17, 9, 3,   0, 2, 5, 6, 3, 0,	 1, 4, 3, 3, 1, 0,
		      7,  8,  7,  6, 0, 1,   2, 1, 4, 4, 1, 0,	 2, 0, 4, 6, 1, 0),
		    dim = dim(xt))))

DF <- as.data.frame(UCBAdmissions)
xt <- xtabs(Freq ~ Gender + Admit, DF)
stopifnot(identical(asArr(xt),
		    array(c(1198, 557, 1493, 1278), dim = c(2L, 2L),
			  dimnames = list(Gender = c("Male", "Female"),
					  Admit = c("Admitted", "Rejected")))))
options(na.action = "na.omit")
DN <- DF; DN[cbind(6:9, c(1:2,4,1))] <- NA; DN

tools::assertError(# 'na.fail' should fail :
	   xtabs(Freq ~ Gender + Admit, DN, na.action = na.fail))
xt. <- xtabs(Freq ~ Gender + Admit, DN)
xtp <- xtabs(Freq ~ Gender + Admit, DN, na.action = na.pass)
xtN <- xtabs(Freq ~ Gender + Admit, DN, addNA = TRUE)
stopifnot(
    identical(asArr(xt - xt.), as_A(c(120,17, 207, 8 ), xt)),
    identical(asArr(xt - xtp), as_A(c(120,17, 207, NA), xt)), # not ok in R <= 3.3.2
    identical(asArr(-xtN + rbind(cbind(xt, 0), 0)),
              as_A(c(120, 17, -17, 207, NA, 0, -327, 0, 0), xtN))
)
## 'sparse = TRUE requires recommended package Matrix
if(requireNamespace('Matrix')) {
    xtS <- xtabs(Freq ~ Gender + Admit, DN, na.action = na.pass, sparse = TRUE)# error in R <= 3.3.2
    xtNS <- xtabs(Freq ~ Gender + Admit, DN, addNA = TRUE, sparse = TRUE)
    stopifnot(
        eq_A(xt., xtabs(Freq ~ Gender + Admit, DN, sparse = TRUE)),
        eq_A(xtp, xtS),
        eq_A(xtN, xtNS)
   )
}
## NA treatment partly wrong in R < 3.4.0; new option 'addNA'
ee <- esoph[esoph[,"ncases"] > 0, c(1:2,4)]
ee[,"ncases"] <- as.integer(ee[,"ncases"])
(tt <- xtabs(ncases ~ ., ee))
stopifnot(identical(as.vector(tt[1:2,]), # *integer* + first value
		    c(0L, 1L, 0L, 4L, 0L, 0L, 1L, 4L)))
## keeping integer in sum()mation of integers


## tapply() with FUN returning raw  |  with factor -> returning integer
stopifnot(identical(tapply(1:3, 1:3, as.raw),
                    array(as.raw(1:3), 3L, dimnames=list(1:3))), ## failed in R < 3.4.0
          identical(3:1, as.vector(tapply(1:3, 1:3, factor, levels=3:1))))


## str(<list of list>, max.level = 1)
LoL <- function(lenC, FUN = identity)
    lapply(seq_along(lenC), function(i) lapply(seq_len(lenC[i]), FUN))
xx <- LoL(c(7,3,17,798,3))
str(xx, list.len = 7, max.level = 1)
str2 <- capture.output(
 str(xx, list.len = 7, max.level = 2))
stopifnot(
    grepl("List of ", capture.output(str(xx, list.len = 7, max.level = 1))),
    length(str2) == 35, sum(grepl("list output truncated", str2)) == 2,
    vapply(paste("List of", lengths(xx)), function(pat) any(grepl(pat, str2)), NA)
)
## wrongly showed '[list output truncated]'  in R < 3.4.0


## stopifnot(all.equal(.)) message abbreviation
msg <- tryCatch(stopifnot(all.equal(rep(list(pi),4), list(3.1, 3.14, 3.141, 3.1415))),
		error = conditionMessage)
writeLines(msg)
stopifnot(length(strsplit(msg,"\n")[[1]]) == 1+3+1)
## was wrong for months in R-devel only


## available.packages() (not) caching in case of errors
tools::assertWarning(ap1 <- available.packages(repos = "http://foo.bar"))
tools::assertWarning(ap2 <- available.packages(repos = "http://foo.bar"))
stopifnot(nrow(ap1) == 0, identical(ap1, ap2))
## had failed for a while in R-devel (left empty *.rds file)


## rep()/rep.int() : when 'times' is a list
stopifnot(identical(rep    (4,   list(3)), c(4,4,4)),
          identical(rep.int(4,   list(3)), c(4,4,4)),
          identical(rep.int(4:5, list(2,1)), c(4L,4:5)),
          identical(rep    (4:5, list(2,1)), c(4L,4:5)))
## partly failed in R 3.3.{2,3}


## quantile(ordered(.)) - error message more directly useful
OL <- ordered(sample(LETTERS, 20, replace=TRUE))
(e <- tryCatch(quantile(OL), error = conditionMessage))
stopifnot(grepl("type.*1.*3", e),# typically works in several locales
	  is.ordered(quantile(OL, type = 1)),
	  is.ordered(quantile(OL, type = 3)))
## gave  "factors are not allowed" in R <= 3.3.x

## terms() ignored arg names (PR#17235)
a1 <- attr(terms(y ~ f(x, a = z) + f(x, a = z)),
           "term.labels")
a2 <- attr(terms(y ~ f(x, a = z) + f(x, b = z)),
           "term.labels")
stopifnot(length(a1) == 1, length(a2) == 2)
## both gave length 1


## keep at end
rbind(last =  proc.time() - .pt,
      total = proc.time())
