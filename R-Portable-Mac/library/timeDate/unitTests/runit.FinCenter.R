
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
# FUNCTION:              FINANCIAL CENTERS:
#  myFinCenter            Sets my financial center
#  rulesFinCenter         Returns DST rules for a financial center
#  listFinCenter          Lists all supported financial centers
################################################################################


test.myFinCenter <-
    function()
{
    # Default Financial Center:
    # "GMT"

###     # Financial Center:
###     myFinCenter = "Zurich"
###     print(myFinCenter)
###     current = "Zurich"
###     print(current)
###     checkIdentical(myFinCenter, current)

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.rulesFinCenter <-
    function()
{
    # Default Financial Center:
    # "GMT"

    # DST Rules for a given Financial Center:
    rulesFinCenter("Zurich")[59:60, ]

    # Return Value:
    return()
}


# ------------------------------------------------------------------------------


test.listFinCenter <-
    function()
{
    # Default Financial Center:
    # "GMT"

    # List of all Financial Centers:
    listFinCenter()
    listFinCenter("Europe")

    # Return Value:
    return()
}


################################################################################

