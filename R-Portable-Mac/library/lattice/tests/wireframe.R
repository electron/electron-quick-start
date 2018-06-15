
library(lattice)
data(volcano)

foo <-
    data.frame(z = as.vector(volcano),
               x = rep(1:87, 61),
               y = rep(1:61, each = 87))

wireframe(z ~ x * y, foo)

## this used to give an error, but seems fine now (?)
wireframe(z ~ x * y, foo, subset = z > 150)


## Example 1 (a). valgrind shows warnings, starting with


## ==9058== Invalid read of size 8
## ==9058==    at 0xA450AFF: wireframePanelCalculations (threeDplot.c:291)

## and subsequently in various other places in that function leading to

## ==9058== Conditional jump or move depends on uninitialised value(s)
## ==9058==    at 0x3FFAA466CF: __printf_fp (in /lib64/libc-2.4.so)
## ==9058==    by 0x3FFAA423AE: vfprintf (in /lib64/libc-2.4.so)
## ==9058==    by 0x3FFAA4A477: fprintf (in /lib64/libc-2.4.so)
## ==9058==    by 0x94975BE: PostScriptRLineTo (devPS.c:2683)

## A bit more tracing shows it is accessing element 4016 in an array of
## length 2456, and the plot seems nonsense (and random) when viewed on
## screen. (BDR, 2006/09/17)

## DS's earlier comment: what's this supposed to do ?  weird thing is,
## result is random (probably indicator of memory access errors)

if (FALSE)
{

    wireframe(z + I(z + 100) ~ x * y, foo,
              subset = z > 150,
              scales = list(arrows = FALSE))
}

## this works as expected

wireframe(z + I(z + 100) ~ x * y, foo)

## Example 1 (b).  Another way of seeing the problem:

## this is OK:

bar <- foo
bar$z[bar$z < 150] <- NA
wireframe(z + I(z + 100) ~ x * y, bar,
          scales = list(arrows = FALSE))

## but this is not
if (FALSE)
{
    wireframe(z + I(z + 100) ~ x * y,
              subset(bar, !is.na(z)),
              scales = list(arrows = FALSE))
}


## Example 2.  Probably another example of the same "bug": see
## https://stat.ethz.ch/pipermail/r-devel/2005-September/034544.html


library(lattice)

n <- 20
psteps <- 50
binomtable <- function(n, psteps)
{
    x <- (0:(10*n))/10
    p <- (0:psteps)/psteps
    dd <- expand.grid(x=x,p=p)
    dd$F <- pbinom(dd$x,n,dd$p)
    dd$x0 <-trunc(dd$x)
    dd
}

bt <- binomtable(n = 5, psteps = 100)
bt[bt$x - bt$x0 >= 0.9, ]$F <- NA

if (FALSE)
{
    ## this is problematic
    wireframe(F ~ x * p, bt,
              groups = bt$x0, shade = TRUE,
              scales = list(arrows = FALSE)) 
}

## this one OK
wireframe(F ~ x * p, bt, shade = TRUE,
          scales = list(arrows = FALSE))

## this too
wireframe(F ~ x * p | factor(x0), bt,
          ## groups = bt$x0,
          shade = TRUE,
          scales = list(arrows = FALSE)) 


## Working hypothesis: the problem crops up when there are groups
## (specified either directly or through the formula interface) AND x
## and y values for each group don't represent the full evaluation
## grid.  The second condition is a bit unclear.  In example 2, each
## group's support is disjoint from that of the others.  In example 1,
## both groups have the same support, they are just not the full grid.

