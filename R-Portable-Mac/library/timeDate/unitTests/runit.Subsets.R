
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
# S3 METHODS:            TEST AND REPRESENTATION OF OBJECTS:
#  isWeekday              Tests if a date is a weekday or not
#  isWeekend              Tests if a date falls on a weekend or not
#  isBizday               Tests if a date is a business day or not
#  isHoliday              Tests if a date is a non-business day or not
#  dayOfWeek              Returns the day of the week to a 'timeDate' object
#  dayOfYear              Returns the day of the year to a 'timeDate' object
# S3 MEHOD:              SUBSETTING TIMEDATE OBJECTS:
#  [.timeDate             Extracts or replaces subsets from 'timeDate' objects
#  cut.timeDate           Extracts a piece from a 'timeDate' object
#  start.timeDate         Extracts the first entry of a 'timeDate' object
#  end.timeDate           Extracts the last entry of a 'timeDate' object
#  blockStart             Creates start dates for equally sized blocks
#  blockEnd               Creates end dates for equally sized blocks
################################################################################


test.Easter <-
    function()
{
    # Easter() Function:
    setRmetricsOptions(myFinCenter = "Zurich")
    target = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    print(target)
    charvec = c(
        "2006-04-09", "2006-04-10", "2006-04-11", "2006-04-12", "2006-04-13",
        "2006-04-14", "2006-04-15", "2006-04-16")
    current = timeDate(charvec)
    print(current)
    checkIdentical(target, current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.isWeekday <-
    function()
{
    # Weekdays:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    WD = isWeekday(tS)
    current = c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)
    checkIdentical(as.logical(WD), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.isWeekend <-
    function()
{
    # Weekends:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    WE = isWeekend(tS)
    current = !c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)
    checkIdentical(as.logical(WE), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.dayOfWeek <-
    function()
{
    # Day of Week:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    DOW = dayOfWeek(tS)
    current = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
    checkIdentical(as.character(DOW), current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.holidayNYSE <-
    function()
{
    # NYSE Business Days - Dates:
    setRmetricsOptions(myFinCenter = "GMT")
    NYSE = holidayNYSE(2006)
    charvec = c(
        "2006-01-02", "2006-01-16", "2006-02-20", "2006-04-14", "2006-05-29",
        "2006-07-04", "2006-09-04", "2006-11-23", "2006-12-25")
    checkIdentical(format(NYSE), charvec)

    # NYSE Business Days - Day-of-Week:
    DOW = dayOfWeek(NYSE)
    current = c("Mon", "Mon", "Mon", "Fri", "Mon", "Tue", "Mon", "Thu", "Mon")
    checkIdentical(as.character(DOW), current)

    # Holidays:
    TD = Easter(2006)
    checkIdentical(format(TD), "2006-04-16")

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.isBizday <-
    function()
{
    # Bizdays:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    target = isBizday(tS, holidayNYSE(2006))
    current = c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
    names(current) = names(target)
    checkIdentical(target, current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.isHoliday<-
    function()
{
    # Holidays:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)
    target = isHoliday(tS, holidayNYSE(2006))
    current = !c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
    names(current) = names(target)
    checkIdentical(target, current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.subset <-
    function()
{
    # Holidays:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)

    # [ - Subsetting:
    tS[c(1, 6:8)]
    tS[isBizday(tS)]
    tS[isHoliday(tS)]

    tS["2006"]
    tS["2006::"]
    tS["2006-04"]
    tS["2006-04::"]
    tS["2006-04-10::"]

    sub <- tS[c("2006", "2006::", "2006-04", "2006-04::", "2006-04-10::")]
    checkTrue(length(sub) == 39)

    # Return Value:
    return()
}

# ------------------------------------------------------------------------------


test.cut <-
    function()
{
    # Holidays:
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeSequence(from = Easter(2006)-7*24*3600, length.out = 8)

    # cut -
    GF = GoodFriday(2006)
    print(GF)
    EM = EasterMonday(2006)
    print(EM)
    target = cut(tS, from = GF, to = EM)
    print(target)
    charvec = paste("2006-04-1", 4:6, sep = "")
    current = timeDate(charvec)
    print(current)
    checkIdentical(
        target,
        current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.start <-
    function()
{
    # start -
    setRmetricsOptions(myFinCenter = "GMT")
    tS = timeCalendar(getRmetricsOptions("currentYear"))
    target = start(tS)
    print(target)
    currentDate = paste(getRmetricsOptions("currentYear"), "-01-01", sep ="")
    checkIdentical(
        format(target),
        current = format(timeDate(currentDate)))

    # end -
    tS = timeCalendar(getRmetricsOptions("currentYear"))
    target = end(tS)
    print(target)
    currentDate = paste(getRmetricsOptions("currentYear"), "-12-01", sep ="")
    checkIdentical(
        format(target),
        current = format(timeDate(currentDate)))

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.blockStart <-
    function()
{
    # blockStart -
    NA

    # Return Value:
    return()
}


################################################################################

