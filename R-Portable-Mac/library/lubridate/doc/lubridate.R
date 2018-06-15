## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)

## ------------------------------------------------------------------------
library(lubridate)
ymd("20110604")
mdy("06-04-2011")
dmy("04/06/2011")

## ------------------------------------------------------------------------
arrive <- ymd_hms("2011-06-04 12:00:00", tz = "Pacific/Auckland")
arrive
leave <- ymd_hms("2011-08-10 14:00:00", tz = "Pacific/Auckland")
leave

## ------------------------------------------------------------------------
second(arrive)
second(arrive) <- 25
arrive
second(arrive) <- 0

wday(arrive)
wday(arrive, label = TRUE)

## ------------------------------------------------------------------------
meeting <- ymd_hms("2011-07-01 09:00:00", tz = "Pacific/Auckland")
with_tz(meeting, "America/Chicago")

## ------------------------------------------------------------------------
mistake <- force_tz(meeting, "America/Chicago")
with_tz(mistake, "Pacific/Auckland")

## ------------------------------------------------------------------------
auckland <- interval(arrive, leave) 
auckland
auckland <- arrive %--% leave
auckland

## ------------------------------------------------------------------------
jsm <- interval(ymd(20110720, tz = "Pacific/Auckland"), ymd(20110831, tz = "Pacific/Auckland"))
jsm

## ------------------------------------------------------------------------
int_overlaps(jsm, auckland)

## ------------------------------------------------------------------------
setdiff(auckland, jsm)

## ------------------------------------------------------------------------
minutes(2) ## period
dminutes(2) ## duration

## ------------------------------------------------------------------------
leap_year(2011) ## regular year
ymd(20110101) + dyears(1)
ymd(20110101) + years(1)

leap_year(2012) ## leap year
ymd(20120101) + dyears(1)
ymd(20120101) + years(1)

## ------------------------------------------------------------------------
meetings <- meeting + weeks(0:5)

## ------------------------------------------------------------------------
meetings %within% jsm

## ------------------------------------------------------------------------
auckland / ddays(1)
auckland / ddays(2)
auckland / dminutes(1)

## ------------------------------------------------------------------------
auckland %/% months(1)
auckland %% months(1)

## ------------------------------------------------------------------------
as.period(auckland %% months(1))
as.period(auckland)

## ------------------------------------------------------------------------
jan31 <- ymd("2013-01-31")
jan31 + months(0:11)
floor_date(jan31, "month") + months(0:11) + days(31)
jan31 %m+% months(0:11)

## ------------------------------------------------------------------------
last_day <- function(date) {
  ceiling_date(date, "month") - days(1)
}

