
# Rmetrics is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# It is distributed in the hope that it will be useful,
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


test.zurich =
function()
{
    # DST Rules for Zurich:
    head(Zurich())
    tail(Zurich())

    # Return Value:
    return()
}


if ((any(Sys.info()["user"] %in% c("yankee", "chalabi")) && !try(system("zdump")))) {
    test.DST <- function()
    {
        # works only if OS is well configured !!!

        finCenter <- listFinCenter()

        for (k in seq_along(finCenter)) {

            zdump <-
                try(system(paste("zdump ", finCenter[k], sep=" "), intern=TRUE))
            zdump <- strsplit(zdump, " +" )
            zdump <- unlist(zdump)


            dts <- paste(zdump[c(3, 4, 6)], collapse = " ")
            tms <- zdump[5]
            timeSys <- timeDate(paste(dts, tms), format =  "%b %d %Y %H:%M:%S",
                                zone = finCenter[k], FinCenter = finCenter[k])


            timeTest <- Sys.timeDate(finCenter[k])

            # round and compare
            cat("\nSimple DST test for", finCenter[k], "\n")
            cat("System\t\t", as.character(timeSys), "\n")
            cat("timeDate\t", as.character(timeTest), "\n")
            checkTrue(abs(as.numeric(timeSys - timeTest)) < 5)
        }
    }

}


# ------------------------------------------------------------------------------

test.dst1.print <-
    function()
{

    from <- '2008-03-30'
    to <- '2008-03-31'

    # make sure that DST is the same as with POSIXct
    tseq1 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "GMT", FinCenter = "GMT")
    tseq1

    tseq1Test <- c(
                   "2008-03-30 00:00:00", "2008-03-30 01:00:00",
                   "2008-03-30 02:00:00", "2008-03-30 03:00:00",
                   "2008-03-30 04:00:00", "2008-03-30 05:00:00",
                   "2008-03-30 06:00:00", "2008-03-30 07:00:00",
                   "2008-03-30 08:00:00", "2008-03-30 09:00:00",
                   "2008-03-30 10:00:00", "2008-03-30 11:00:00",
                   "2008-03-30 12:00:00", "2008-03-30 13:00:00",
                   "2008-03-30 14:00:00", "2008-03-30 15:00:00",
                   "2008-03-30 16:00:00", "2008-03-30 17:00:00",
                   "2008-03-30 18:00:00", "2008-03-30 19:00:00",
                   "2008-03-30 20:00:00", "2008-03-30 21:00:00",
                   "2008-03-30 22:00:00", "2008-03-30 23:00:00",
                   "2008-03-31 00:00:00")

    checkIdentical(tseq1Test, format(tseq1))

    # make sure that tseq1@Data is a continuous time
    checkIdentical(tseq1Test, format(tseq1@Data))

    # make sure that DST is the same as with POSIXct
    tseq2 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "GMT", FinCenter = "Zurich")
    tseq2

    # make sure that tseq1@Data is a continuous time
    checkIdentical(tseq1Test, format(tseq2@Data))

    # test taken from format(tseq2@Data, tz = "Europe/Zurich")
    tseq2Test <- c(
                   "2008-03-30 01:00:00", "2008-03-30 03:00:00",
                   "2008-03-30 04:00:00", "2008-03-30 05:00:00",
                   "2008-03-30 06:00:00", "2008-03-30 07:00:00",
                   "2008-03-30 08:00:00", "2008-03-30 09:00:00",
                   "2008-03-30 10:00:00", "2008-03-30 11:00:00",
                   "2008-03-30 12:00:00", "2008-03-30 13:00:00",
                   "2008-03-30 14:00:00", "2008-03-30 15:00:00",
                   "2008-03-30 16:00:00", "2008-03-30 17:00:00",
                   "2008-03-30 18:00:00", "2008-03-30 19:00:00",
                   "2008-03-30 20:00:00", "2008-03-30 21:00:00",
                   "2008-03-30 22:00:00", "2008-03-30 23:00:00",
                   "2008-03-31 00:00:00", "2008-03-31 01:00:00",
                   "2008-03-31 02:00:00")

    checkIdentical(tseq2Test, format(tseq2))

    # @Data slot should be the same for both object
    checkIdentical(tseq1@Data, tseq2@Data)

    # should be of length length(tseq2) - 1
    tseq3 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "Zurich", FinCenter = "Zurich")
    tseq3

    # test taken from format(tseq3@Data, tz = "Europe/Zurich")
    tseq3Test <- c(
                   "2008-03-30 00:00:00", "2008-03-30 01:00:00",
                   "2008-03-30 03:00:00", "2008-03-30 04:00:00",
                   "2008-03-30 05:00:00", "2008-03-30 06:00:00",
                   "2008-03-30 07:00:00", "2008-03-30 08:00:00",
                   "2008-03-30 09:00:00", "2008-03-30 10:00:00",
                   "2008-03-30 11:00:00", "2008-03-30 12:00:00",
                   "2008-03-30 13:00:00", "2008-03-30 14:00:00",
                   "2008-03-30 15:00:00", "2008-03-30 16:00:00",
                   "2008-03-30 17:00:00", "2008-03-30 18:00:00",
                   "2008-03-30 19:00:00", "2008-03-30 20:00:00",
                   "2008-03-30 21:00:00", "2008-03-30 22:00:00",
                   "2008-03-30 23:00:00", "2008-03-31 00:00:00")

    checkIdentical(tseq3Test, format(tseq3))

}

# ------------------------------------------------------------------------------

test.dst2.print <-
    function()
{

    from = '2008-10-26'
    to = '2008-10-27'

    # make sure that DST is the same as with POSIXct
    tseq1 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "GMT", FinCenter = "GMT")
    tseq1

    tseq1Test <- c(
                   "2008-10-26 00:00:00", "2008-10-26 01:00:00",
                   "2008-10-26 02:00:00", "2008-10-26 03:00:00",
                   "2008-10-26 04:00:00", "2008-10-26 05:00:00",
                   "2008-10-26 06:00:00", "2008-10-26 07:00:00",
                   "2008-10-26 08:00:00", "2008-10-26 09:00:00",
                   "2008-10-26 10:00:00", "2008-10-26 11:00:00",
                   "2008-10-26 12:00:00", "2008-10-26 13:00:00",
                   "2008-10-26 14:00:00", "2008-10-26 15:00:00",
                   "2008-10-26 16:00:00", "2008-10-26 17:00:00",
                   "2008-10-26 18:00:00", "2008-10-26 19:00:00",
                   "2008-10-26 20:00:00", "2008-10-26 21:00:00",
                   "2008-10-26 22:00:00", "2008-10-26 23:00:00",
                   "2008-10-27 00:00:00")

    checkIdentical(tseq1Test, format(tseq1))

    # make sure that tseq1@Data is a continuous time
    checkIdentical(tseq1Test, format(tseq1@Data))

    # make sure that DST is the same as with POSIXct
    tseq2 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "GMT", FinCenter = "Zurich")
    tseq2

    # make sure that tseq2@Data is a also continuous time
    checkIdentical(tseq1Test, format(tseq2@Data))

    # test taken from format(tseq2@Data, tz = "Europe/Zurich")
    tseq2Test <- c(
                   "2008-10-26 02:00:00", "2008-10-26 02:00:00",
                   "2008-10-26 03:00:00", "2008-10-26 04:00:00",
                   "2008-10-26 05:00:00", "2008-10-26 06:00:00",
                   "2008-10-26 07:00:00", "2008-10-26 08:00:00",
                   "2008-10-26 09:00:00", "2008-10-26 10:00:00",
                   "2008-10-26 11:00:00", "2008-10-26 12:00:00",
                   "2008-10-26 13:00:00", "2008-10-26 14:00:00",
                   "2008-10-26 15:00:00", "2008-10-26 16:00:00",
                   "2008-10-26 17:00:00", "2008-10-26 18:00:00",
                   "2008-10-26 19:00:00", "2008-10-26 20:00:00",
                   "2008-10-26 21:00:00", "2008-10-26 22:00:00",
                   "2008-10-26 23:00:00", "2008-10-27 00:00:00",
                   "2008-10-27 01:00:00")

    # make sure that DST is the same as with POSIXct
    checkIdentical(tseq2Test, format(tseq2))

    # @Data slot should be the same for both object
    checkIdentical(tseq1@Data, tseq2@Data)

    # # should be of length length(tseq2) - 1
    tseq3 <- timeSequence( from = from, to = to,
                          by = "hour", zone = "Zurich", FinCenter = "Zurich")
    tseq3

    # test taken from format(tseq3@Data, tz = "Europe/Zurich")
    tseq3Test <- c(
                   "2008-10-26 00:00:00", "2008-10-26 01:00:00",
                   "2008-10-26 02:00:00", "2008-10-26 02:00:00",
                   "2008-10-26 03:00:00", "2008-10-26 04:00:00",
                   "2008-10-26 05:00:00", "2008-10-26 06:00:00",
                   "2008-10-26 07:00:00", "2008-10-26 08:00:00",
                   "2008-10-26 09:00:00", "2008-10-26 10:00:00",
                   "2008-10-26 11:00:00", "2008-10-26 12:00:00",
                   "2008-10-26 13:00:00", "2008-10-26 14:00:00",
                   "2008-10-26 15:00:00", "2008-10-26 16:00:00",
                   "2008-10-26 17:00:00", "2008-10-26 18:00:00",
                   "2008-10-26 19:00:00", "2008-10-26 20:00:00",
                   "2008-10-26 21:00:00", "2008-10-26 22:00:00",
                   "2008-10-26 23:00:00", "2008-10-27 00:00:00")

    checkIdentical(tseq3Test, format(tseq3))

}


################################################################################
