## PR#14384

sXY <- structure(list(x = c(0, 24, 27, 48, 51, 72, 75, 96, 99),
                      y = c(4.98227, 6.38021, 6.90309, 7.77815, 7.64345, 7.23045, 7.27875, 7.11394, 6.95424)),
                 .Names = c("x", "y"), row.names = c(NA, 9L),
                 class = c("sortedXyData", "data.frame"))
a <- NLSstLfAsymptote(sXY)
d <- NLSstRtAsymptote(sXY)
z <- NLSstClosestX(sXY, (a+d)/2)
stopifnot(!is.na(z))
## early versions gave NaN

