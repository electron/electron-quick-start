#### Testing print(), format()	and the like --- mainly with numeric()
####
#### to be run as
####
####	R < print-tests.R  >&  print-tests.out-__version__
####			   == (csh)
opt.conformance <- 0

DIG <- function(d)
    if(missing(d)) getOption("digits") else options(digits=as.integer(d))

DIG(7)#-- the default; just to make sure ...
options(width = 200)

n1 <- 2^(4*1:7)
i1 <- as.integer(n1)

v1 <- 2^c(-12, 2*(-4:-2),3,6,9)
v2 <- v1^(63/64)
## avoid ending in `5' as printing then depends on rounding of
## the run-time (and not all round to even).
v1[1:4] <-c(2.44140624e-04, 3.90624e-03, 1.5624e-02, 6.24e-02)


v3 <- pi*100^(-1:3)
v4 <- (0:2)/1000 + 1e-10 #-- tougher one

digs1 <- c(1,2*(1:5),11:15)		# 16: platform dependent
					# 30 gives ERROR : options(digits=30)
digs2 <- c(1:20)#,30) gives 'error' in R: ``print.default(): invalid digits..''

all(i1 == n1)# TRUE
i1# prints nicely
n1# did not; does now (same as 'i1')

round (v3, 3)#S+ & R 0.49:
##[1]	0.031	    3.142     314.159	 31415.927 3141592.654
signif(v3, 3)
##R.49: [1] 0.0314	3.1400	   314.0000   31400.0000 3140000.0000
##S+	[1] 3.14e-02 3.14e+00 3.14e+02 3.14e+04 3.14e+06

###----------------------------------------------------------------
##- Date: Tue, 20 May 97 17:11:18 +0200

##- From: Martin Maechler <maechler@stat.math.ethz.ch>
##- To: R-devel@stat.math.ethz.ch
##- Subject: R-alpha: print 'problems': print(2^30, digits=12); comments at start of function()
##-
##- Both of these bugs are not a real harm,
##- however, they have been annoying me for too long ... ;-)
##-
##- 1)
print  (2^30, digits = 12) #-  WAS exponential form, unnecessarily -- now ok
formatC(2^30, digits = 12) #- shows you what you'd want above

## S and R are now the same here;  note that the problem also affects
##	paste(.)  & format(.) :

DIG(10); paste(n1); DIG(7)


## Assignment to .Options$digits: Does NOT work for  print() nor cat()
for(i in digs1) { .Options$digits <- i; cat(i,":"); print (v1[-1]) }

## using options()  *does* things
for(i in digs1) { DIG(i); cat(i,":"); print (v3) }
for(i in digs1) { DIG(i); cat(i,":", formatC(v3, digits=i, width=8),"\n") }


## R-0.50: switches to NON-exp at 14, but should only at 15...
## R-0.61++: doesn' switch at all (or at 20 only)
## S-plus: does not switch at all..
for(i in digs1) { cat(i,":");  print(v1, digits=i) }

## R 0.50-a1: switches at 10 inst. 11
for(i in digs1) { cat(i,":");  print(v1[-1], digits=i) }

for(i in digs1) { DIG(i); cat(i,":", formatC(v2, digits=i, width=8),"\n") }

for(i in digs1) { cat(i,":");  print(v2, digits=i) } #-- exponential all thru
##	 ^^^^^ digs2 (>= 18: PLATFORM dependent !!
for(i in digs1) { cat(i,":", formatC(v2, digits=i, width=8),"\n") }

DIG(7)#-- the default; just to make sure ...

N1 <- 10; N2 <- 7; n <- 8
x <- 0:N1
Mhyp <- rbind(phyper(x, N1, N2, n), dhyper(x, N1, N2, n))
Mhyp
##-	 [,1]	      [,2]	 [,3]	  [,4]	    [,5]      [,6]	[,7]
##- [1,]    0 0.0004113534 0.01336898 0.117030 0.4193747 0.7821884 0.9635952
##- [2,]    0 0.0004113534 0.01295763 0.103661 0.3023447 0.3628137 0.1814068
##-	       [,8]	  [,9] [,10] [,11]
##- [1,] 0.99814891 1.00000000	   1	 1
##- [2,] 0.03455368 0.00185109	   0	 0

m11 <- c(-1,1)
Mm <- pi*outer(m11, 10^(-5:5))
Mm <- cbind(Mm, outer(m11, 10^-(5:1)))
Mm
do.p <- TRUE
do.p <- FALSE
for(di in 1:10) {
    options(digits=di)
    cat(if(do.p)"\n",formatC(di,w=2),":", format.info(Mm),"\n")
    if(do.p)print(Mm)
}
##-- R-0.49 (4/1997)	 R-0.50-a1 (7.7.97)
##-  1 : 13 5 0		 1 :  6 0 1
##-  2 :  8 1 1	=	 2 :  8 1 1
##-  3 :  9 2 1	=	 3 :  9 2 1
##-  4 : 10 3 1	=	 4 : 10 3 1
##-  5 : 11 4 1	=	 5 : 11 4 1
##-  6 : 12 5 1	=	 6 : 12 5 1
##-  7 : 13 6 1	=	 7 : 13 6 1
##-  8 : 14 7 1	=	 8 : 14 7 1
##-  9 : 15 8 1	=	 9 : 15 8 1
##- 10 : 16 9 1	=	10 : 16 9 1
nonFin <- list(c(Inf,-Inf), c(NaN,NA), NA_real_, Inf)
mm <- sapply(nonFin, format.info)
fm <- lapply(nonFin, format)
w <- c(4,3,2,3)
stopifnot(sapply(lapply(fm, nchar), max) == w,
	  mm == rbind(w, 0, 0))# m[2,] was 2147483647; m[3,] was 1
cnF <- c(lapply(nonFin, function(x) complex(re=x, im=x))[-3],
         complex(re=NaN, im=-Inf))
cmm <- sapply(cnF, format.info)
cfm <- lapply(cnF, format)
cw <- sapply(lapply(cfm, nchar), max)
stopifnot(cw == cmm[1,]+1 +cmm[4,]+1,
	  nchar(format(c(NA, 1 + 2i))) == 4)# wrongly was (5,4)


##-- Ok now, everywhere
for(d in 1:9) {cat(d,":"); print(v4, digits=d) }
DIG(7)


###------------ Very big and very small
umach <- unlist(.Machine)[paste("double.x", c("min","max"), sep='')]
xmin <- umach[1]
xmax <- umach[2]
tx <- unique(c(outer(-1:1,c(.1,1e-3,1e-7))))# 7 values  (out of 9)
tx <- unique(sort(c(outer(umach,1+tx))))# 11 values (+ 1 Inf)
length(tx <- tx[is.finite(tx)]) # 11
(txp <- tx[tx >= 1])#-- Positive exponent -- 4 values
(txn <- tx[tx <	 1])#-- Negative exponent -- 7 values

x2 <- c(0.099999994, 0.2)
x2 # digits=7: show all seven "9"s
print(x2, digits=6) # 0.1 0.2 , not 0.10 0.20
v <- 6:8; names(v) <- v; sapply(v, format.info, x=x2)

(z <- sort(c(outer(range(txn), 8^c(0,2:3)))))
outer(z, 0:6, signif) # had NaN's till 1.1.1

olddig <- options(digits=14) # RH6.0 fails at 15
z <- 1.234567891234567e27
for(dig in 1:14) cat(formatC(dig,w=2),
                     format(z, digits=dig), signif(z, digits=dig), "\n")
options(olddig)
# The following are tests of printf inside formatC
##------ Use  Emacs screen width 134 ;	Courier 12 ----
# cat("dig|  formatC(txp, d=dig)\n")
# for(dig in 1:17)# about >= 18 is platform dependent [libc's printf()..].
#     cat(formatC(dig,w=2), formatC(txp,		      dig=dig, wid=-29),"\n")
# cat("signif() behavior\n~~~~~~~~\n",
#     "dig|  formatC(signif(txp, dig=dig), dig = dig\n")
# for(dig in 1:15)#
#     cat(formatC(dig,w=2), formatC(signif(txp, d=dig), dig=dig, wid=-26),"\n")

# if(opt.conformance >= 1) {
#     noquote(cbind(formatC(txp, dig = 22)))
# }

# cat("dig|  formatC(signif(txn, d = dig), dig=dig\n")
# for(dig in 1:15)#
#     cat(formatC(dig,w=2), formatC(signif(txn, d=dig), dig=dig, wid=-20),"\n")

# ##-- Testing  'print' / digits :
# for(dig in 1:13) { ## 12:13: libc-2.0.7 diff; 14:18 --- PLATFORM-dependent !!!
#     cat("dig=",formatC(dig,w=2),": "); print(signif(txp, d=dig),dig=dig+1)
# }

##-- Wrong alignment when printing character matrices with  quote = FALSE
m1 <- matrix(letters[1:24],6,4)
m1
noquote(m1)

##--- Complex matrices and named vectors :

x0 <- x <- c(1+1i, 1.2 + 10i)
names(x) <- c("a","b")
x
(xx <-	rbind(x,  2*x))
	rbind(x0, 2*x0)
x[4:6] <- c(Inf,Inf*c(-1,1i))
x  + pi
matrix(x + pi, 2)
matrix(x + 1i*pi, 3)
xx + pi
t(cbind(xx, xx+ 1i*c(1,pi)))

#--- format checks after incorrect changes in Nov 2000
zz <- data.frame("(row names)" = c("aaaaa", "b"), check.names = FALSE)
format(zz)
format(zz, justify = "left")
zz <- data.frame(a = I("abc"), b = I("def\"gh"))
format(zz)
# " (font-locking: closing the string above)

# test format.data.frame on former AsIs's.
set.seed(321)
dd <- data.frame(x = 1:5, y = rnorm(5), z = c(1, 2, NA, 4, 5))
model <- glm(y ~ x, data = dd, subset = 1:4, na.action = na.omit)
expand.model.frame(model, "z", na.expand = FALSE)
expand.model.frame(model, "z", na.expand = TRUE)

## print.table() changes affecting summary.data.frame
options(width=82)
summary(attenu) # ``one line''
lst <- levels(attenu$station)
levels(attenu$station)[lst == "117"] <- paste(rep(letters,3),collapse="")
summary(attenu) # {2 + one long + 2 } variables
## in 1.7.0, things were split to more lines

## format.default(*, nsmall > 0)  -- for real and complex

sf <- function(x, N=14) sapply(0:N, function(i) format(x,nsmall=i))
sf(2)
sf(3.141)
sf(-1.25, 20)

oDig <- options(digits= 3)
sf(pi)
sf(1.2e7)
sf(1.23e7)
s <- -0.01234
sf(s)

sf(pi + 2.2i)
sf(s + pi*1i)

options(oDig)

e1 <- tryCatch(options(max.print=Inf), error=function(e)e)
e2 <- tryCatch(options(max.print= 0),  error=function(e)e)
stopifnot(inherits(e1, "error"))


## Printing of "Date"s
options(width = 80)
op <- options(max.print = 500)
dd <- as.Date("2012-03-12") + -10000:100
writeLines(t1 <- tail(capture.output(dd)))
l6 <- length(capture.output(print(dd, max = 600)))
options(op)
t2 <- tail(capture.output(print(dd, max = 500)))
stopifnot(identical(t1, t2), l6 == 121)
## not quite consistent in R <= 2.14.x

