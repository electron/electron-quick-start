#### Test R's (64-bit) date-time functions .. output tested *sloppily*

## R's internal fixes are used on 32-bit platforms.
## macOS gets these wrong: see HAVE_WORKING_64BIT_MKTIME

Sys.setenv(TZ = "UTC")
(z <- as.POSIXct("1848-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-07-01 12:00"))
c(unclass(z))

Sys.setenv(TZ = "Europe/London")  # pretty much portable.
(z <- as.POSIXct("1848-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-07-01 12:00"))
c(unclass(z))

Sys.setenv(TZ = "EST5EDT")
(z <- as.POSIXct("1848-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-01-01 12:00"))
c(unclass(z))
(z <- as.POSIXct("2040-07-01 12:00"))
c(unclass(z))

## PR15613: had day as > 24hrs.
as.POSIXlt(ISOdate(2071,1,13,0,0,tz="Etc/GMT-1"))$wday
as.POSIXlt(ISOdate(2071,1,13,0,1,tz="Etc/GMT-1"))$wday


## Incorrect use of %d should work even though abbreviation does match
old <- Sys.setlocale("LC_TIME", "C") # to be sure
stopifnot(!is.na(strptime("11-August-1903", "%d-%b-%Y")))
