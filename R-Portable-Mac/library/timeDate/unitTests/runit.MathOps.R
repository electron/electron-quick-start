
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
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
# S3 MEHOD:              MATHEMATICAL OPERATIONS:
#  Ops.timeDate           Group 'Ops' generic functions for 'timeDate' objects
#  +.timeDate             Performs arithmetic + operation on 'timeDate' objects
#  -.timeDate             Performs arithmetic - operation on 'timeDate' objects
#  diff.timeDate          Returns suitably lagged and iterated differences
#  difftimeDate           Returns a difference of two 'timeDate' objects
#  round.timeDate         Rounds objects of class 'timeDate'
#  trunc.timeDate         Truncates objects of class 'timeDate'
# S3 MEHOD:              CONCATENATION, ORDERING AND SORTING:
#  c.timeDate             Concatenates 'timeDate' objects
#  rep.timeDate           Replicates a 'timeDate' object
#  sort.timeDate          Sorts a 'timeDate' object
#  sample.timeDate        Resamples a 'timeDate' object
#  unique.timeDate        NMakes a 'timeDate' object unique
#  rev.timeDate           Reverts  a 'timeDate' object
################################################################################


test.timeDateMathOps =
function()
{
    #  Ops.timeDate           Group 'Ops' generic functions for 'timeDate' objects
    #  +.timeDate             Performs arithmetic + operation on 'timeDate' objects
    #  -.timeDate             Performs arithmetic - operation on 'timeDate' objects
    #  diff.timeDate          Returns suitably lagged and iterated differences
    #  difftimeDate           Returns a difference of two 'timeDate' objects
    #  round.timeDate         Rounds objects of class 'timeDate'
    #  trunc.timeDate         Truncates objects of class 'timeDate'

    # New York:
    setRmetricsOptions(myFinCenter = "NewYork")
    NY = timeCalendar(h = 10)

    # Back to Zurich:
    setRmetricsOptions(myFinCenter = "Zurich")
    ZH = timeCalendar(h = 16)

    # Group Ops:
    TEST = (NY > ZH)
    checkTrue(!TEST[1])
    # expr = TEST[4]
    # checkTrue(expr)

    # + Operation:

    # - Operation:
    NewYork()[176:177, ]
    Zurich()[59:60, ]
    DIFF.APRIL = as.integer((NY - ZH)[4])
    # checkEqualsNumeric(
    #     target = as.numeric(DIFF.APRIL), current = 3600)
    DIFF.RESTOFYEAR = sum(as.integer((NY - ZH)[-4]))
    # checkEqualsNumeric(
    #    target = as.numeric(DIFF.RESTOFYEAR), current = 0)

    # diff.timeDate() Function:

    # difftimeDate() Function:

    # round() Function:
    set.seed(4711)
    setRmetricsOptions(myFinCenter = "GMT")
    tC = timeCalendar(
        m = 1:12,
        d = rep(1, 12),
        h = round(runif(12, 0, 23)),
        min = round(runif(12, 0, 59)),
        s = round(runif(12, 0, 59)))
    # rTC = round(tC)
    # rTC

    # trunc() Function:
    # tTC = trunc(tC)
    # tTC

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.timeDateOrdering =
function()
{
    #  c.timeDate             Concatenates 'timeDate' objects
    #  rep.timeDate           Replicates a 'timeDate' object
    #  sort.timeDate          Sorts a 'timeDate' object
    #  sample.timeDate        Resamples a 'timeDate' object
    #  unique.timeDate        NMakes a 'timeDate' object unique
    #  rev.timeDate           Reverts  a 'timeDate' object

    ## NOTA BENE: You CAN NOT work with a function-local variable  'myFincenter',
    ##            Since  R's evaluation rules will use the global one, here!
    ## NB (2)   : currently need to specify 'zone'

    # NewYork:
    cyr <- 2007
    NY = timeCalendar(cyr, h = 10, FinCenter = "NewYork", zone = "NewYork")
    str(NY)
    checkIdentical(format(NY),
                   sprintf("%4d-%02d-01 %02d:00:00", cyr, 1:12, 10))

    # Back to Zurich:
    ZH = timeCalendar(cyr, h = 16, FinCenter = "Zurich", zone = "Zurich")
    str(ZH)
    checkIdentical(format(ZH),
                   sprintf("%4d-%02d-01 %02d:00:00", cyr, 1:12, 16))
    # NY-ZH Concatenate:
    NYC = c(NY, ZH)[13]
    checkIdentical(NYC@FinCenter, "NewYork")
    checkIdentical(format(NYC), paste(cyr, "01-01 10:00:00", sep="-"))

    # ZH-NY Concatenate:
    ZRH = c(ZH, NY)[13]
    checkIdentical(ZRH@FinCenter, "Zurich")
    checkIdentical(format(ZRH), paste(cyr, "01-01 16:00:00", sep="-"))

    # Replicate and "-":
    DIFF = rep(NY[1:3], times = 3) - rep(NY[1:3], each = 3)
    checkIdentical(as.numeric(DIFF[c(1, 5, 9)]), c(0, 0, 0))

    # Sort | Sample:
    TC = timeCalendar()
    SAMPLE = sample(TC)
    print(SAMPLE)
    checkIdentical(TC, sort(SAMPLE))

    # Revert:
    TS = timeSequence("2001-09-11")
    REV = rev(TS)
    print(head(REV))
    checkIdentical(TS, rev(REV))

    # Return Value:
    return()
}


################################################################################


