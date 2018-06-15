
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


test.as <-
    function()
{
    #  as.character.timeDate  Returns a 'timeDate' object as 'character' string
    #  as.double.timeDate     Returns a 'timeDate' object as 'numeric' object
    #  as.data.frame.timeDate Returns a 'timeDate' object as 'data.frame' object
    #  as.POSIXct.timeDate    Returns a 'timeDate' object as 'POSIXct' object
    #  as.POSIXlt.timeDate    Returns a 'timeDate' object as 'POSIXlt' object
    #  as.Date.timeDate       Returns a 'timeDate' object as 'Date' object


    # Monthly calendarical sequence for the current year:
    setRmetricsOptions(myFinCenter = "GMT")
    TC = timeCalendar(2006)
    TC
    checkIdentical(TC@format, "%Y-%m-%d")
    checkIdentical(TC@FinCenter, "GMT")

    # Transform into a vector of character strings:
    month = c(paste("0", 1:9, sep = ""), 10:12)
    month
    charvec = paste("2006-", month, "-01", sep = "")
    charvec
    CHAR = as.character(TC)
    attr(CHAR, "control")<-NULL
    CHAR
    checkIdentical(CHAR, charvec)

    # Transform into a numeric vector:
    DAYS = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30)
    NUM = as.double(TC)
    NUM
    checkIdentical(diff(NUM), DAYS)
    NUM = as.numeric(TC)
    NUM
    checkIdentical(diff(NUM), DAYS)

    # Transform into a data frame:
    DF = as.data.frame(TC)
    DF
    attr(DF, "control")
    DIFF = diff(as.numeric(DF[,1])/3600/24)
    checkIdentical(DIFF, DAYS)

    # Transform into a POSIX object:
    CT = as.POSIXct(TC)
    CT
    # LT = as.POSIXlt(TC)
    # LT
    # checkIdentical(format(CT), format(LT))

    # Transform into a POSIX object:
    as.Date(TC)
    TC2 = TC + 16*3600
    TC2
    as.Date(TC2)
    as.Date(TC2, "round")
    as.Date(TC2, "next")
    target = as.numeric(as.Date(TC))
    current = as.numeric(as.Date(TC2, "round")-1)
    checkIdentical(target, current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.asTimeDate =
    function()
{
    #  as.timeDate            Use Method
    #  as.timeDate.POSIXt     Returns a 'POSIX' object as 'timeDate' object
    #  as.timeDate.Date       Returns a 'POSIX' object as 'timeDate' object

    # Current Time:
    as.timeDate(Sys.time())

    # Coerce:
    setRmetricsOptions(myFinCenter = "GMT")
    Sys.Date()
    as.timeDate(Sys.Date())
    myFinCenter <- getRmetricsOptions("myFinCenter")
    as.timeDate(Sys.Date(), zone = myFinCenter, FinCenter = myFinCenter)
    as.timeDate(Sys.Date(), zone = "Zurich", FinCenter = "Zurich")

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.julian <-
    function()
{
    # julian.timeDate = function(x, FinCenter = myFinCenter, ...)
    setRmetricsOptions(myFinCenter = "GMT")
    GD = timeDate("1970-01-01 00:00:00", zone = "GMT", FinCenter = "GMT")
    GD
    J = julian(GD, FinCenter = "GMT")
    J
    class(J)
    checkIdentical(as.numeric(J), 0)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.atoms <-
    function()
{
    # atoms.timeDate = function(x, ...)
    TC = timeCalendar()
    AT = atoms(TC)
    AT

    # months.timeDate = function(x, abbreviate = NULL)
    MO = months(TC)
    MO

    # Compare:
    checkIdentical(as.vector(AT[, 2]), as.vector(MO))


    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.months <-
    function()
{
    # atoms.timeDate = function(x, ...)
    TC = timeCalendar()
    AT = atoms(TC)
    AT

    # months.timeDate = function(x, abbreviate = NULL)
    MO = months(TC)
    MO

    # Compare:
    checkIdentical(as.vector(AT[, 2]), as.vector(MO))


    # Return Value:
    return()
}


################################################################################

