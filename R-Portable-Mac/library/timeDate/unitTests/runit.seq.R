
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

test.seq.Zurich <- function()
{

    iso1 <- ISOdate(2000,3,25, tz = "Europe/Zurich")
    iso2 <- ISOdate(2000,3,26,  tz = "Europe/Zurich")
    td1 <- timeDate(iso1, zone = "Zurich", FinCenter = "Zurich")
    td2 <- timeDate(iso2, zone = "Zurich", FinCenter = "Zurich")

    checkIdentical(
                   format(seq(iso1, iso2 , length.out = 12)),
                   format(seq(td1, td2 , length.out = 12))
                   )

    checkIdentical(
                   format(seq(iso1, by = "min", length.out = 24*60)),
                   format(seq(td1, by = "min", length.out = 24*60))
                   )

    checkIdentical(
                   format(seq(iso1, by = "hour", length.out = 24)),
                   format(seq(td1, by = "hour", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "days", length.out = 24)),
                   format(seq(td1, by = "days", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "DSTdays", length.out = 24)),
                   format(seq(td1, by = "DSTdays", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "month", length.out = 24)),
                   format(seq(td1, by = "month", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "year", length.out = 24)),
                   format(seq(td1, by = "year", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = 0.5*(iso2 - iso1), length.out = 4)),
                   format(seq(td1, by = 0.5*(td2 - td1), length.out = 4))
                   )

}

# ------------------------------------------------------------------------------

test.seq.GMT <- function()
{

    iso1 <- ISOdate(2000,3,25, tz = "GMT")
    iso2 <- ISOdate(2000,3,26,  tz = "GMT")
    td1 <- timeDate(iso1, zone = "GMT", FinCenter = "GMT")
    td2 <- timeDate(iso2, zone = "GMT", FinCenter = "GMT")

    checkIdentical(
                   format(seq(iso1, iso2 , length.out = 12)),
                   format(seq(td1, td2 , length.out = 12))
                   )

    checkIdentical(
                   format(seq(iso1, by = "min", length.out = 24*60)),
                   format(seq(td1, by = "min", length.out = 24*60))
                   )

    checkIdentical(
                   format(seq(iso1, by = "hour", length.out = 24)),
                   format(seq(td1, by = "hour", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "days", length.out = 24)),
                   format(seq(td1, by = "days", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "DSTdays", length.out = 24)),
                   format(seq(td1, by = "DSTdays", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "month", length.out = 24)),
                   format(seq(td1, by = "month", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = "year", length.out = 24)),
                   format(seq(td1, by = "year", length.out = 24))
                   )

    checkIdentical(
                   format(seq(iso1, by = 0.5*(iso2 - iso1), length.out = 4)),
                   format(seq(td1, by = 0.5*(td2 - td1), length.out = 4))
                   )

}

################################################################################
