library(cluster)

x <- cbind(c(0, -4, -22, -14, 0, NA, -28, 1, 10, -1,
             100 + c(13, 0, 2, 4, 7, 8, 1)),
           c(-5, -14, NA, -35, -30, NA, 7, 2, -18, 13,
             47, 64, 48, NA, NA, 44, 65))
x
(d <- dist(x,'manhattan'))
summary(d, na.rm = TRUE) # max = 270
## First call with "trace" (seg.fault typically later ...):
try( clara(x, k=2, metric="manhattan", sampsize=10, trace = 3) )
## Originally:already shows the problem:  nbest[] = c(0,0,...,0) must be WRONG!!
## Now: gives the proper error message.

## S-plus 6.1.2 (rel.2 for Linux, 2002) gives
##> cc <- clara(x, k=2, metric="manhattan", samples=2, sampsize=10)
## Problem in .Fortran("clara",: Internal error: data for decrementing
## ref.count didn't point to a valid arena (0x0), while calling subroutine clara

## The large example from  clara.R -- made small enough to still provoke
## the    "** dysta2() ...  OUT"  problem  {no longer!}
x <- matrix(c(0, 3, -4, 62, 1, 3, -7, 45, 36, 46, 45, 54, -10,
              51, 49, -5, 13, -6, 49, 52, 57, 39, -1, 55, 68, -3, 51, 11, NA,
              9, -3, 50, NA, 58, 9, 52, 12, NA, 47, -12, -6, -9, 5, 30, 38,
              54, -5, 39, 50, 50, 54, 43, 7, 64, 55, 4, 0, 72, 54, 37, 59,
              -1, 8, 43, 50, -2, 56, -8, 43, 6, 4, 48, -2, 14, 45, 49, 56,
              51, 45, 11, 10, 42, 50, 2, -12, 3, 1, 2, 2, -14, -4, 8, 0, 3,
              -11, 8, 5, 14, -1, 9, 0, 19, 10, -2, -9, 9, 2, 16, 10, 4, 1,
              12, 7, -4, 27, -8, -9, -9, 2, 8, NA, 13, -23, -3, -5, 1, 15,
              -3, 5, -9, -5, 14, 8, 7, -4, 26, 20, 10, 8, 17, 4, 14, 23, -2,
              23, 2, 16, 5, 5, -3, 12, 5, 14, -2, 4, 2, -2, 7, 9, 1, -15, -1,
              9, 23, 1, 7, 13, 2, -11, 16, 12, -11, -14, 2, 6, -8),
            ncol = 2)
str(x) # 88 x 2
try(clara(x, 2, samples = 20, trace = 3))# 2nd sample did show dysta2() problem
## To see error message for > 1 missing:
try(clara(rbind(NA,x), 2))

x <- x[-33,]
## still had the ** dysta2() .. OUT" problem {no longer!}
clara(x, 2, samples = 12, trace = 3)

data(xclara)
set.seed(123)
xclara[sample(nrow(xclara), 50),] <- NA
try( clara(xclara, k = 3) ) #-> "nice" error message depicting first 12 missing obs
