### Tests of often platform-dependent features of the POSIX[cl]t implementation.

### Expect differences, especially with 32-bit time_t

z <- ISOdate(1890:1912, 1, 10, tz="UTC")
## Rome changed to CET for 1894
as.POSIXlt(z, tz="Europe/Rome")
## Paris changed to PMT for 1892, WET for 1912
(zz <- as.POSIXlt(z, tz="Europe/Paris"))
strftime(zz, "%Y-%m-%d %H:%M:%S %Z")
## The offset was really 00:09:21 until 1911, then 00:00
## Many platforms will give the current offset, +0100
strftime(zz, "%Y-%m-%d %H:%M:%S %z")

## Some platforms give details of the latest conversion.
z <- ISOdate(c(seq(1890, 1940, 5), 1941:1946, 1950), 1, 10, tz="UTC")
as.POSIXlt(z, tz="Europe/Paris")
for(i in seq_along(z)) print(as.POSIXlt(z[i], tz="Europe/Paris"))
for(i in seq_along(z))
    print(strftime(as.POSIXlt(z[i], tz="Europe/Paris"), "%Y-%m-%d %H:%M:%S %z"))

strptime("1920-12-27 08:18:23", "%Y-%m-%d %H:%M:%S", tz="Europe/Paris")

## check %V etc

d <- expand.grid(day = 1:7, year = 2000:2010)
z1 <- with(d, ISOdate(year, 1, day))
d <- expand.grid(day = 25:31, year = 2000:2010)
z2 <- with(d, ISOdate(year, 12, day))
z <- sort(c(z1, z2))
strftime(z, "%G %g %W %U %u %V %W %w")

## tests of earlier years.  Default format is OS-dependent, so don't test it.
## ISOdate only accepts positive years.
z <- as.Date(ISOdate(c(0, 8, 9, 10, 11, 20, 110, 1010), 1, 10)) - 3630
strftime(z, "%04Y-%m-%d") # with leading zero(s)
strftime(z, "%_4Y-%m-%d") # with leading space(s)
strftime(z, "%0Y-%m-%d") # without


## more test of strftime
x <- ISOdate(2014, 3, 10, c(7, 13))
fmts <- c("%Y-%m-%d %H:%M:%S", "%F", "%A %a %b %h %e %I %j",
          ## locale-dependent ones
          "%X", # but the same in all English locales
          "%c", "%x", "%p", "%r")
for (f in fmts) print(format(x, f))
