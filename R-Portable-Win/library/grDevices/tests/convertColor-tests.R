
cols <- t(col2rgb(palette()))

## One full space1-XYZ-space2 conversion

convertColor(cols, 'sRGB', 'Lab', scale.in=255)

## to XYZ, then to every defined space

XYZ <- convertColor(cols, 'sRGB', 'XYZ', scale.in=255)
fromXYZ <- vapply(
  names(colorspaces), convertColor, FUN.VALUE=XYZ,
  from='XYZ', color=XYZ, clip=NA
)
round(fromXYZ, 4)

## Back to XYZ, delta to original XYZ should be close to zero

tol <- 1e-5
toXYZ <- vapply(
  dimnames(fromXYZ)[[3]],
  function(x) all(abs(convertColor(fromXYZ[,,x], from=x, to='XYZ') - XYZ)<tol),
  logical(1)
)
toXYZ
stopifnot(all(toXYZ | is.na(toXYZ)))

## Test Apple and CIE RGB on smaller gamuts since they clip

XYZ2 <- XYZ * .7 + .15
fromXYZ2 <- vapply(
  c('Apple RGB', 'CIE RGB'), convertColor, FUN.VALUE=XYZ2,
  from='XYZ', color=XYZ2, clip=NA
)
round(fromXYZ2, 4)
toXYZ2 <- vapply(
  dimnames(fromXYZ2)[[3]],
  function(x)
    all(abs(convertColor(fromXYZ2[,,x], from=x, to='XYZ') - XYZ2)<tol),
  logical(1)
)
stopifnot(all(toXYZ2))

