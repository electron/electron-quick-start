
# Rmetrics is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# Rmetrics is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General
# Public License along with this library; if not, write to the
# Free Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA  02111-1307  USA

# Copyrights (C)
# for this R-port:
#   1999 - 2007, Diethelm Wuertz, GPL
#   Diethelm Wuertz <wuertz@itp.phys.ethz.ch>
#   info@rmetrics.org
#   www.rmetrics.org
# for the code accessed (or partly included) from other R-ports:
#   see R's copyright and license files
# for the code accessed (or partly included) from contributed R-ports
# and other sources
#   see Rmetrics's copyright file


################################################################################


checkEQ <- function(x,y) checkEquals(x, y, tol = 0)

test.timeLastDayInMonth <- function()
{
    ## What date has the last day in a month for a given date ?
    charvec <- "2006-04-16"
    lstDay <- as("2006-04-30", "timeDate")

    myFinCenter <- getRmetricsOptions("myFinCenter")

    timeLastDayInMonth(charvec, format = "%Y-%m-%d",
                       zone = myFinCenter, FinCenter = myFinCenter)

    timeLastDayInMonth(charvec, FinCenter = "Zurich")

    checkEQ(lstDay, timeLastDayInMonth(charvec))
}


## ------------------------------------------------------------------------------


test.timeFirstDayInMonth <- function()
{
    ## What date has the first day in a month for a given date ?
    checkEQ(timeFirstDayInMonth(c("2006-04-16","2000-02-29")),
            as(c("2006-04-01", "2000-02-01"), "timeDate"))
}


## ------------------------------------------------------------------------------


test.timeLastDayInQuarter <- function()
{
    ## What date has the last day in a quarter for a given date ?
    checkEQ(timeLastDayInQuarter("2006-04-16"),
            as("2006-06-30", "timeDate"))
}


## ------------------------------------------------------------------------------


test.timeFirstDayInQuarter <- function()
{
    ## What date has the first day in a quarter for a given date ?
    checkEQ(timeFirstDayInQuarter("2006-04-16"),
            as("2006-04-01", "timeDate"))
}


## ------------------------------------------------------------------------------


test.timeNdayOnOrAfter <- function()
{
    ## What date has the first Monday on or after March 15, 1986 ?
    checkEQ(timeNdayOnOrAfter("1986-03-15", 1),
            as("1986-03-17", "timeDate"))
}


## ------------------------------------------------------------------------------


test.timeNdayOnOrBefore <- function()
{
    ## What date has Friday on or before March 15, 1986?
    checkEQ(timeNdayOnOrBefore("1986-03-15", 5),
            as("1986-03-14", "timeDate"))
}


## ------------------------------------------------------------------------------

isOpExFriday <- function(ch.dts) {
    dts <- as.Date(ch.dts)
    from <- as.numeric(format(min(dts), "%Y"))
    to   <- as.numeric(format(max(dts), "%Y"))

    OEFri <- timeNthNdayInMonth(timeFirstDayInMonth(ch.dts), nday=5, nth=3)
    isBizday(timeDate(dts), holidayNYSE(from:to)) & dts == as(OEFri, "Date")
}


test.timeNthNdayInMonth <- function()
{
    ## What date is the second Monday in April 2004 ?
    checkEQ(timeNthNdayInMonth("2004-04-01", 1, 2),
            as("2004-04-12", "timeDate"))

    ## From the (timezone dependent) bug, reported by David Winsemius, Sep.23, 2011:
    dates <- structure(c(15228:15233, 15236:15240), class="Date")
    true.OE <- as.Date("2011-09-16")
    checkEQ(dates[isOpExFriday(dates)], true.OE)

    o.TZ <- Sys.getenv("TZ") ## reset at end:
    on.exit( Sys.setenv("TZ" = o.TZ) )
    Sys.setenv("TZ" = "America/New_York")
    setRmetricsOptions("myFinCenter" = "New_York")
    checkEQ(dates[isOpExFriday(dates)], true.OE)

    Sys.setenv("TZ" = "London/Europe")
    setRmetricsOptions("myFinCenter" = "Zurich")
    checkEQ(dates[isOpExFriday(dates)], true.OE)
}


## ------------------------------------------------------------------------------


test.timeLastNdayInMonth <- function()
{

    ## What date has the last Tuesday in May, 1996 ?
    checkEQ(timeLastNdayInMonth("1996-05-01", 2),
            as("1996-06-04", "timeDate"))

}


################################################################################
