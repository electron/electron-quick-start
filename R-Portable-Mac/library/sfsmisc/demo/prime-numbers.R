####---- Prime numbers, factorization, etc. --- "illustration of programming"
####---- A Collection of pure S / R -- Experiments from the 1990's
####---- mostly carried by discussions on the good old S-news mailing list

### Mostly using the functions currently hidden in sfsmisc namespace
### FIXME: ---> Move these function definitons to ../inst/ ---> see  ../TODO (10)
factorizeBV    <- sfsmisc:::factorizeBV
primes.        <- sfsmisc:::primes.
test.factorize <- sfsmisc:::test.factorize
prime.sieve    <- sfsmisc:::prime.sieve
factors        <- sfsmisc:::factors

##
factorizeBV(6)
##[1] 2 3
str( factorizeBV(4:8) )


### 1) The super speedy primes() function from Bill Venables
###    {and improved by M.Maechler}:

## on a Pentium 4 2.80 GHz with 2 GB RAM ;

N <- 1e7

## keep this working for  S+ ! compatible
for(i in 1:3) print(system.time(p7 <- primes.(N))[1:3]) ## Bill Venables' original
##- [1] 3.86 1.93  8.75
##- [1] 4.02 1.60 11.34
##- [1] 4.14 1.60 11.51
## about 10-20% slower on 'lynne'

for(i in 1:3) print(system.time(p7. <- primes(N))[1:3]) ## Martin Maechler's improvement
##- [1] 2.29 0.76 6.47
##- [1] 2.58 0.73 6.67
##- [1] 2.71 0.59 6.64
stopifnot(p7 == p7.)

## On 'lynne' (AMD Athlon 64bit 2800+, 1G RAM), speedup somewhat similar;
## Also here
system.time(for(i in 1:50) p5  <- primes (1e5))[1:3]
system.time(for(i in 1:50) p5. <- primes.(1e5))[1:3]
stopifnot(p5 == p5.)


## 2)

factorize(n <- c(7,27,37,5*c(1:5, 8, 10)))
factorize(47)
factorize(7207619)## quick !
factorize(131301607)# prime -> still only 0.02 seconds (on lynne)!

## Factorizing larger than max.int -- not prime;
## should be much quicker with other algo (2nd largest prime == 71) !!
factorize(76299312910)

system.time(fac.1ex <- factorize(1000 + 1:99)) #-- 0.95 sec (sophie Sparc 5)
#-- 0.02 sec (P 4, 1.6GHz);  0.4 / .65 sec (florence Ultra 1/170)
system.time(fac.2ex <- factorize(10000 + 1:999))
## R 0.49 : 5.4 sec (florence Ultra 1/170)
## ------   6.1 sec (sophie   Ultra 1/140)
## R 0.50-: ~ 3.5 sec (sophie  ..........)  <<< FASTER !
## ------

## This really used to take time -- no longer w/ current factorize() in 2004 !
system.time(factorize.10000 <- factorize(1:10000))
## sophie: Sparc 5 (..) :lots of swapping after while, >= 20 minutes CPU;
##			then using less and less CPU, ..more swapping ==> KILL
## florence (hypersparc): [1] 1038.90   5.09 1349.   ( 17 min. CPU)
## lynne (Ultra-1):       [1]  658.77   0.90  677.
## lynne (Pentium 4):     [1]    2.43   0.16    2.68
## helen (Pentium 4), R1.9.1:    1.02   0.01    1.04
## lynne (64b,2800+), R2.0.1:    0.86   0.00    0.86

object.size(factorize.10000) #--> 3027743 now (R 1.5.1) 3188928;
                                        # '* 2' for 64-bit
###--- test
test.factorize(fac.1ex[1:10]) #-- T T T ..
which(!test.factorize(fac.1ex))
which(!test.factorize(factorize(8000 + 1:1000)))


prime.sieve(prime.sieve())
system.time(P1e4 <- prime.sieve(prime.sieve(prime.sieve()), max=10000))
##-> 1.45 (on sophie: fast Sparc 5 ..)
##-> ~0.8 (on jessica: Ultra-2)
##->  0.08 (on lynne, Pentium 4 (1600 MHz))
##----> see below for a sample of 20 !
stopifnot(length(P1e4) == 1229)

CPU.p1e4 <- numeric(20)
for(i in 1:20)  CPU.p1e4[i] <-
  system.time(P1e4 <- prime.sieve(prime.sieve(prime.sieve()), max=10000))[1]
CPU.p1e4
summary(CPU.p1e4)
##-Ultra-2    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
##-Ultra-2   0.690   0.690   0.790   0.755   0.800   0.810
## P4 R-?)   0.070   0.070   0.080   0.078   0.080   0.100
## P4 R-1.9  0.040   0.050   0.050   0.048   0.050   0.050
system.time(P1e4.2 <- prime.sieve( max=10000))
##-> 1.46 (sophie)   maybe a little longer
stopifnot(identical(P1e4 , P1e4.2))

system.time(P1e5 <- prime.sieve(P1e4, max=1e5)) ## note!  primes() is faster!
##-> 105.7  (on sophie: fast Sparc 5)
##->  58.83 (on jessica: Ultra2)
##->   5.67 (on lynne: Pentium 4)
##->   3.96 (on lynne: Pentium 4 -- R 1.9)
##->   1.37 (on lynne: AMD 64    -- R 2.0.1)

stopifnot(p5 == P1e5,
          length(P1e5) == 9592)

P1000 <- prime.sieve(max=1000)

plot(P1000,  seq(P1000), type='b', main="Prime number theorem")
lines(P1000, P1000/log(P1000), col=2, lty=2, lwd=1.5)

plot(P1e4,  seq(P1e4), type='l', main="Prime number theorem")
lines(P1e4, P1e4/log(P1e4), col=2, lty=2, lwd=1.5)

stopifnot(require("sfsmisc"))
## For a nice plot:
ps.do("prime-number.ps")
mult.fig(2, main="Prime number theorem")
plot(P1e5,seq(P1e5), type='l', main="pi(n) &  n/log(n) ",
     xlab='n',ylab='pi(n)', log='xy', sub = 'log - log - scale')
lines(P1e5, P1e5/log(P1e5), col=2, lty=2, lwd=1.5)
mtext("demo(\"prime-numbers\", package = \"sfsmisc\")",
      side = 3, cex=.75, adj=1, line=3, outer=TRUE)
plot(P1e5, seq(P1e5) / (P1e5/log(P1e5)), type='b', pch='.',
     main= "Prime number theorem : pi(n) / {n/log(n)}", ylim =c(1,1.3),
     xlab = 'n', ylab='pi(n) / (n/log(n)', log='x')
abline(h=1, col=3, lty=2)
ps.end()


##  3)  the factors() from Bill Dunlap etc
factors( round(gamma(13:14)))
##- $"479001600":
##-  [1]  2  2	2  2  2	 2  2  2  2  2	3  3  3	 3  3  5  5  7 11
##-
##- $"6227020800":
##-  [1]  2  2	2  2  2	 2  2  2  2  2	3  3  3	 3  3  5  5  7 11 13


## --- You can use table() to collect repeated factors : ----

lapply( factors( round(gamma(13:14))), table)
##- $"479001600":
##-   2 3 5 7 11
##-  10 5 2 1  1
##-
##- $"6227020800":
##-   2 3 5 7 11 13
##-  10 5 2 1  1  1

