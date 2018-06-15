
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

test.isWeekend <- function() {

    # check if there is any problem with timezone and days
    old <- setRmetricsOptions(myFinCenter = "Zurich")
    on.exit(setRmetricsOptions(old))

    td <- timeCalendar(y = 2011, m = 1, d = 1:7)
    check <- c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
    names(check) <- format(td)
    checkIdentical(isWeekend(td), check)

    # change tzone
    setRmetricsOptions(myFinCenter = "GMT")

    td <- timeCalendar(y = 2011, m = 1, d = 1:7)
    check <- c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
    names(check) <- format(td)
    checkIdentical(isWeekend(td), check)
}

