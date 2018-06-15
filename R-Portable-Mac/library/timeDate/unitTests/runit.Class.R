
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
# FUNCTION:              GENERATION OF TIMEDATE OBJECTS:
#  'timeDate'             S4 Class representation for timeDate objects
#  timeDate               Creates a 'timeDate' object from given dates
#   whichFormat            Returns format string called by timeDate
#   midnightStandard       Corrects for midnight standard called by timeDate
#  .formatFinCenter        Internal called by timeDate
#  timeCalendar           Creates a 'timeDate' object from calendar atoms
#  timeSequence           Creates a regularly spaced 'timeDate' object
#   seq.timeDate           A synonyme function for timeSequence
#  Sys.timeDate           Returns system time as an object of class 'timeDate'
#  is.timeDate            Tests if the object is of class 'timeDate'
# METHODS:               REPRESENTATION OF TIMEDATE OBJECTS:
#  print.timeDate         Prints 'timeDate' object
#  plot.timeDate          Plots 'timeDate' object
#  points.timeDate        Adds points to a 'timeDate' plot
#  lines.timeDate         Adds lines to a 'timeDate' plot
#  summary.timeDate       Summarizes details of a 'timeDate' object
#  format.timeDate        Formats 'timeDate' as ISO conform character string
################################################################################


test.timeDate =
function()
{
    # DW: We should pack this in several test.timeDate.* functions ...

    # Set Financial Center to GMT:
    setRmetricsOptions(myFinCenter = "GMT")
    print(getRmetricsOptions("myFinCenter"))

    # timeDate() Function:
    charvec = paste("2006-01-", c(10, 20, 30), sep = "")
    print(charvec)
    TD = timeDate(charvec)
    print(TD)
    CHARVEC = as.character(TD)
    attr(CHARVEC, "control")<-NULL
    checkIdentical(charvec, CHARVEC)

    # timeDate() Function, continued:
    charvec = paste("2006-01-", c("10 10", "20 10", "30 10"), sep = "")
    target = paste(charvec, ":00:00", sep = "")
    TD = timeDate(charvec)
    print(TD)
    CHARVEC = as.character(TD)
    attr(CHARVEC, "control")<-NULL
    checkIdentical(target, CHARVEC)

    # timeDate() Function, continued:
    charvec = paste("2006-01-", c("10 10:00", "20 10:00", "30 10:00"), sep = "")
    target = paste(charvec, ":00", sep = "")
    print(charvec)
    TD = timeDate(charvec)
    print(TD)
    CHARVEC = as.character(TD)
    attr(CHARVEC, "control")<-NULL
    checkIdentical(target, CHARVEC)

    # YYYYMMDDhhmmss:
    TD = timeDate("20010101")
    print(TD)
    checkIdentical(format(TD), "2001-01-01")
    TD = timeDate("200101010000")
    print(TD)
    checkIdentical(format(TD), "2001-01-01")
    TD = timeDate("20010101000000")
    print(TD)
    checkIdentical(format(TD), "2001-01-01")
    TD = timeDate("200101011600")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 16:00:00")
    TD = timeDate("20010101160000")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 16:00:00")

    # Format Slot Check:
    TD = timeDate("2001-01-01")
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d")
    TD = timeDate("2001-01-01 00:00")
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d")
    TD = timeDate("2001-01-01 00:00:00")
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d")
    TD = timeDate("2001-01-01 16:00")
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d %H:%M:%S")
    TD = timeDate("2001-01-01 16:00:00")
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d %H:%M:%S")
    TD = timeDate(c("2001-01-01 00:00", "2001-01-01 16:00"))
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d %H:%M:%S")
    TD = timeDate(c("2001-01-01 00:00:00", "2001-01-01 16:00:00"))
    print(TD)
    checkIdentical(TD@format, "%Y-%m-%d %H:%M:%S")

    # More timeDate Checks:
    TD = timeDate("20010101",
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 01:00:00")
    TD = timeDate("200101010000",
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 01:00:00")
    TD = timeDate("20010101000000",
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 01:00:00")
    TD = timeDate("200101011600",
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 17:00:00")
    TD = timeDate("20010101160000",
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), "2001-01-01 17:00:00")
    TD = timeDate(c("2001-01-01 00:00", "2001-01-01 16:00"),
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), c("2001-01-01 01:00:00", "2001-01-01 17:00:00"))
    TD = timeDate(c("2001-01-01 00:00:00", "2001-01-01 16:00:00"),
        zone = "GMT", FinCenter = "Zurich")
    print(TD)
    checkIdentical(format(TD), c("2001-01-01 01:00:00", "2001-01-01 17:00:00"))

    # Format: "%d-%b-%Y"
    Months = c("Mar", "Jun", "Sep", "Dec")
    charvec <- paste("01", Months, "2006", sep = "-")
    print(TD <- timeDate(charvec, format = "%d-%b-%Y"))
    ## checkIdentical(format(TD),
    ##   paste("2006", c("03-01", "06-01", "09-01", "12-01"), sep = "-"))

    # Format: "%m/%d/%Y"
    print(TD <- timeDate("12/15/2006", format = "%m/%d/%Y"))
    checkIdentical(format(TD), "2006-12-15")

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.whichFormat <-
    function()
{
    # Which Format:
    WF = whichFormat("20010101")
    print(WF)
    checkIdentical(WF, "%Y%m%d")
    WF = whichFormat("200101010000")
    print(WF)
    checkIdentical(WF, "%Y%m%d%H%M")
    WF = whichFormat("20010101000000")
    print(WF)
    checkIdentical(WF, "%Y%m%d%H%M%S")
    WF = whichFormat("200101011600")
    print(WF)
    checkIdentical(WF, "%Y%m%d%H%M")
    WF =  whichFormat("20010101160000")
    print(WF)
    checkIdentical(WF, "%Y%m%d%H%M%S")
    WF =  whichFormat("2001-01-01")
    print(WF)
    checkIdentical(WF, "%Y-%m-%d")
    WF =  whichFormat("2001-01-01 00:00")
    print(WF)
    checkIdentical(WF, "%Y-%m-%d %H:%M")
    WF =  whichFormat("2001-01-01 00:00:00")
    print(WF)
    checkIdentical(WF, "%Y-%m-%d %H:%M:%S")
    WF =  whichFormat("2001-01-01 16:00")
    print(WF)
    checkIdentical(WF, "%Y-%m-%d %H:%M")
    WF =  whichFormat("2001-01-01 16:00:00")
    print(WF)
    checkIdentical(WF, "%Y-%m-%d %H:%M:%S")
    WF =  whichFormat("01/01/2001")
    print(WF)
    checkIdentical(WF, "%m/%d/%Y")
    WF =  whichFormat("01-Jan-2001")
    print(WF)
    checkIdentical(WF, "%d-%b-%Y")

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.midnightStandard <-
    function()
{
    ISOform <- "%Y-%m-%d %H:%M:%S"

    .midAuto <- function(cc)  midnightStandard(cc,  whichFormat(cc))

    # Midnight Standard - Short Form:
    dd <- c("20010101", "20070131")
    dd.iso <- format(as.POSIXlt(strptime(dd, "%Y%m%d")), ISOform)
    print(MS <- .midAuto(dd))
    checkIdentical(MS, dd.iso)

    checkIdentical(dd.iso, .midAuto(c("200101010000", "200701310000")))

    checkIdentical(dd.iso, .midAuto(c("20010101000000", "20070131000000")))

    checkIdentical(dd.iso, .midAuto(c("2001-01-01 00:00:00",
                      "2007-01-31 00:00:00")))

    print(MS <- .midAuto("200101011600"))
    checkIdentical(MS, "2001-01-01 16:00:00")
    checkIdentical(MS, .midAuto("20010101160000"))


    ## midnight case :
    MN <- .midAuto("20010131240000")
    checkIdentical(MN, "2001-02-01 00:00:00")
    checkIdentical(MN, .midAuto(MN))
    checkIdentical(.midAuto("200101312400"), MN)# no seconds
    checkIdentical(.midAuto("2001013124"), MN)# no min., no sec.

    ## NEW: "arbitrary format":
    cv <- c("240000 20010131", "231020 20010131")
    print(MS <-  midnightStandard(cv, (fcv <- "%H%M%S %Y%m%d")))
    checkIdentical(MS, c("2001-02-01 00:00:00", "2001-01-31 23:10:20"))
    print(MS2 <-  midnightStandard2(cv, fcv))
    checkTrue(inherits(MS2, "POSIXct"))
    checkIdentical(MS, format(MS2))

    cv <- c('1/1/2010', '10/10/2010')
    print(MS <-  midnightStandard2(cv)) ## only the *2() version works here!
    checkTrue(inherits(MS, "POSIXct"))
    checkIdentical(format(MS), c("2010-01-01", "2010-10-10"))

    ## even more extreme
    cv <- c("24:00, 31.01.2001", "23:10, 31.01.2001",
            "24:00, 31.12.2005")
    print(MS <-  midnightStandard(cv, "%H:%M, %d.%m.%Y"))
    checkIdentical(MS, c("2001-02-01 00:00:00", "2001-01-31 23:10:00",
             "2006-01-01 00:00:00"))

    # Midnight Standard - Human Readable Form:
    print(MS <- .midAuto("2001-01-31"))

    checkIdentical(MS, "2001-01-31 00:00:00")

    checkIdentical(MS, .midAuto(MS))
    checkIdentical(MS, .midAuto("2001-01-31 00:00"))
    checkIdentical(MS, .midAuto("2001-01-31 00"))

    checkIdentical(MN, .midAuto("2001-01-31 24:00:00"))
    checkIdentical(MN, .midAuto("2001-01-31 24:00"))
    checkIdentical(MN, .midAuto("2001-01-31 24"))

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.POSIX =
function()
{
    # POSIX:
    setRmetricsOptions(myFinCenter = "GMT")
    X = ISOdate(year = 2006, month = 1:12, day = 1, hour = 0)
    print(X)
    print(class(X))
    TD = timeDate(X)
    print(TD)
    current = c(
        "2006-01-01", "2006-02-01", "2006-03-01", "2006-04-01",
        "2006-05-01", "2006-06-01", "2006-07-01", "2006-08-01",
        "2006-09-01", "2006-10-01", "2006-11-01", "2006-12-01")
    print(current)
    checkIdentical(format(TD), current)

    # POSIX, continued:
    X = ISOdate(year = 2006, month = 1:12, day = 1, hour = 0)
    GMT = timeDate(X, zone = "GMT", FinCenter = "GMT")
    print(GMT)
    current = c(
        "2006-01-01", "2006-02-01", "2006-03-01", "2006-04-01",
        "2006-05-01", "2006-06-01", "2006-07-01", "2006-08-01",
        "2006-09-01", "2006-10-01", "2006-11-01", "2006-12-01")
    print(current)
    checkIdentical(format(GMT), current)

    # POSIX, continued:
    NYC = timeDate(X, zone = "NewYork", FinCenter = "NewYork")
    print(NYC)
    current = c(
        "2006-01-01", "2006-02-01", "2006-03-01", "2006-04-01",
        "2006-05-01", "2006-06-01", "2006-07-01", "2006-08-01",
        "2006-09-01", "2006-10-01", "2006-11-01", "2006-12-01")
    print(current)
    checkIdentical(format(NYC), current)

    # POSIX, continued:
    GMT.NYC = timeDate(X, zone = "GMT", FinCenter = "NewYork")
    print(GMT.NYC)
    current = c(
        "2005-12-31 19:00:00", "2006-01-31 19:00:00", "2006-02-28 19:00:00",
        "2006-03-31 19:00:00", "2006-04-30 20:00:00", "2006-05-31 20:00:00",
        "2006-06-30 20:00:00", "2006-07-31 20:00:00", "2006-08-31 20:00:00",
        "2006-09-30 20:00:00", "2006-10-31 19:00:00", "2006-11-30 19:00:00")
    print(current)
    checkIdentical(format(GMT.NYC), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.asTimeDate =
function()
{
    # as.timeDate() Function:
    X = ISOdate(year = 2006, month = 1:12, day = 1, hour = 10)
    GMT = as.timeDate(X, zone = "GMT", FinCenter = "GMT")[c(6, 12)]
    print(GMT)
    current = c("2006-06-01 10:00:00", "2006-12-01 10:00:00")
    print(current)
    checkIdentical(format(GMT), current)

    # as.timeDate() Function, continued:
    X = ISOdate(year = 2006, month = 1:12, day = 1, hour = 10)
    NYC = as.timeDate(X, zone = "NewYork", FinCenter = "NewYork")[c(6, 12)]
    print(NYC)
    current = c("2006-06-01 10:00:00", "2006-12-01 10:00:00")
    print(current)
    checkIdentical(format(NYC), current)

    # as.timeDate() Function, continued:
    X = ISOdate(year = 2006, month = 1:12, day = 1, hour = 10)
    GMT.NYC = as.timeDate(X, zone = "GMT", FinCenter = "NewYork")[c(6, 12)]
    print(GMT.NYC)
    current = c("2006-06-01 06:00:00", "2006-12-01 05:00:00")
    print(current)
    checkIdentical(format(GMT.NYC), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.asDate =
function()
{
    # as.Date() Function:
    X = as.Date(ISOdate(year = 2006, month = 1:12, day = 1, hour = 10))
    GMT = as.timeDate(X, zone = "GMT", FinCenter = "GMT")[c(6, 12)]
    print(GMT)
    current = c("2006-06-01", "2006-12-01")
    print(current)
    checkIdentical(format(GMT), current)

    # as.Date() Function, continued:
    X = as.Date(ISOdate(year = 2006, month = 1:12, day = 1, hour = 10))
    NYC = as.timeDate(X, zone = "NewYork", FinCenter = "NewYork")[c(6, 12)]
    print(NYC)
    current = c("2006-06-01", "2006-12-01")
    print(current)
    checkIdentical(format(NYC), current)

###     # FIXME: YC, IMO the test case is wrong,
###     # i.e. current =  c("2006-05-31 20:00:00", "2006-11-30 19:00:00")
###     # as.Date() Function, continued:
###     X = as.Date(ISOdate(year = 2006, month = 1:12, day = 1, hour = 10))
###     GMT.NYC = as.timeDate(X, zone = "GMT", FinCenter = "NewYork")[c(6, 12)]
###     print(GMT.NYC)
###     current = c("2006-06-01", "2006-12-01")
###     print(current)
###     checkIdentical(format(GMT.NYC), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.timeCalendar =
function()
{
    # timeCalendar() Function, Check FinCenter:
    setRmetricsOptions(myFinCenter = "Zurich")
    target = as.character(getRmetricsOptions("myFinCenter"))
    target
    current = "Zurich"
    current
    checkIdentical(target, current)

    # timeCalendar() Function, Check CurrentYear:
    target = as.character(getRmetricsOptions("currentYear"))
    target
    current = substr(as.character(Sys.Date()), 1, 4)
    current
    checkIdentical(target, current)

    # timeCalendar() | timeSequence() Functions:
    # Generate timDate from timeCalendar, compare with timeSequence
    setRmetricsOptions(myFinCenter = "GMT")
    target = timeCalendar(y = 2006, m = 1:12, d = 1)
    target
    current = timeSequence(from = "2006-01-01", by = "month", length.out = 12)
    current
    checkIdentical(target, current)

    # timeCalendar() | timeSequence() Functions:
    # Generate timDate from timeCalendar, compare with timeSequence:
    setRmetricsOptions(myFinCenter = "Zurich")
    target = timeCalendar(y = 2006, m = 1:12, d = 1)
    target
    current = timeSequence(from = "2006-01-01", by = "month", length.out = 12)
    current
    checkIdentical(target, current)

    # timeCalendar() Function:
    # Date/Time:
    setRmetricsOptions(myFinCenter = "Zurich")
    ZRH.ZRH = timeCalendar(h = 16)
    GMT.ZRH = timeCalendar(h = 16, zone = "GMT")
    GMT.NYC = timeCalendar(h = 16, zone = "GMT", FinCenter = "NewYork")
    checkEqualsNumeric(target = sum(as.integer(ZRH.ZRH-GMT.ZRH)), -19)
    checkEqualsNumeric(target = sum(as.integer(GMT.ZRH-GMT.NYC)),   0)
    checkEqualsNumeric(target = sum(as.integer(GMT.NYC-ZRH.ZRH)), +19)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.timeSequence =
function()
{
    # timeCalendar -
    # Generate timDate Objects from Sequences:
    getRmetricsOptions("myFinCenter")
    target = timeSequence(from = "2006-01-01", to = "2006-01-31", by = "day")
    target
    current = timeCalendar(y = 2006, m = 1, d = 1:31)
    current
    checkIdentical(target, current)

    # By Hour:
    from = "2006-01-01 00:00:00"
    to   = "2006-01-01 23:59:59"
    timeSequence(from, to, by = "hour")

    # By Minute:
    from = "2006-01-01 16:00:00"
    to   = "2006-01-01 16:14:59"
    timeSequence(from, to, by = "min")

    # By Second:
    from = "2006-01-01 16:00:00"
    to   = "2006-01-01 16:00:14"
    timeSequence(from, to, by = "s")

    # Check length.out - hourly timeDates:
    from = "2006-01-01 16:00:00"
    timeSequence(from, length.out = 15, by = "year")
    timeSequence(from, length.out = 15, by = "quarter")
    timeSequence(from, length.out = 15, by = "week")
    timeSequence(from, length.out = 15, by = "month")
    timeSequence(from, length.out = 15, by = "day")
    timeSequence(from, length.out = 15, by = "hour")
    timeSequence(from, length.out = 15, by = "min")
    timeSequence(from, length.out = 15, by = "sec")

    # Check length.out - Dates:
    from = "2006-01-01"
    timeSequence(from, length.out = 15, by = "year")
    timeSequence(from, length.out = 15, by = "quarter")
    timeSequence(from, length.out = 15, by = "week")
    timeSequence(from, length.out = 15, by = "month")
    timeSequence(from, length.out = 15, by = "day")
    timeSequence(from, length.out = 15, by = "hour")
    timeSequence(from, length.out = 15, by = "min")
    timeSequence(from, length.out = 15, by = "sec")

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.sysTimeDate =
function()
{
    # Check Financieal Center:
    setRmetricsOptions(myFinCenter = "Zurich")
    checkIdentical(as.character(getRmetricsOptions("myFinCenter")), "Zurich")

    # Zurich:
    ZRH = Sys.timeDate()
    print(ZRH)

    # GMT:
    GMT = Sys.timeDate("GMT")
    print(GMT)

    # New York:
    NYC = Sys.timeDate("NewYork")
    print(NYC)

    # Check Class of Sys.timeDate()
    CLASS = class(Sys.timeDate())
    print(CLASS)
    checkIdentical(CLASS[[1]], "timeDate")

    # Check Class of Sys.Date()
    CLASS = class(Sys.Date())
    print(CLASS)
    checkIdentical(CLASS[[1]], "Date")

    # Compare timeDate() and as.timeDate() from Date object:
    DATE = Sys.Date()
    TD1 = timeDate(DATE, zone = "NewYork", FinCenter = "Zurich")
    TD2 = as.timeDate(DATE, zone = "NewYork", FinCenter = "Zurich")
    checkIdentical(target = TD1, current = TD2)


    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.displayMethods =
function()
{
    #  print.timeDate         Prints 'timeDate' object
    #  plot.timeDate          Plots 'timeDate' object
    #  points.timeDate        Adds points to a 'timeDate' plot
    #  lines.timeDate         Adds lines to a 'timeDate' plot
    #  summary.timeDate       Summarizes details of a 'timeDate' object
    #  format.timeDate        Formats 'timeDate' as ISO conform character string

    # Check Financieal Center:
    setRmetricsOptions(myFinCenter = "NewYork")
    print(getRmetricsOptions("myFinCenter"))
    checkIdentical(as.character(getRmetricsOptions("myFinCenter")), "NewYork")

    # print() Function
    DT = timeCalendar()
    PRINT = print(DT)
    checkIdentical(PRINT, DT)

    # plot() Function:
    DT = timeSequence("2006-01-01", length.out = 10)
    y = rnorm(10)
    plot(DT, y)
    points(DT, y, col = "red")
    lines(DT, y, col = "blue")

    # summary() Function
    DT = timeCalendar(2006)
    SUMMARY = summary(DT)
    checkIdentical(SUMMARY, DT)

    # format() Function
    FORMAT = format(DT)[7]
    print(FORMAT)
    checkIdentical(FORMAT, "2006-07-01")

    # Return Value:
    return()
}


################################################################################

