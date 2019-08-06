library(grid)

## Tests for grobCoords()

check <- function(coords, model) {
    stopifnot(isTRUE(all.equal(as.numeric(coords$x), model$x)) &&
              isTRUE(all.equal(as.numeric(coords$y), model$y)))
}

## Simple primitive 
coords <- grobCoords(rectGrob(0, 0, 1, 1,
                              just=c("left", "bottom"),
                              default.units="in"),
                     closed=TRUE)
check(coords[[1]], list(x=c(0, 0, 1, 1), y=c(0, 1, 1, 0)))

## Primitives that generate more points than grob description
coords <- grobCoords(circleGrob(0, 0, r=unit(1, "in")), n=4,
                     closed=TRUE)
check(coords[[1]], list(x=c(1, 0, -1, 0), y=c(0, 1, 0, -1)))

coords <- grobCoords(xsplineGrob(c(0, 1, 2), c(0, 1, 0),
                                 default.units="in"),
                     closed=FALSE)
check(coords[[1]], list(x=c(0, 1, 2), y=c(0, 1, 0)))

## grob with 'id'
coords <- grobCoords(polylineGrob(1:4, 1:4,
                                  id=rep(1:2, each=2),
                                  default.units="in"),
                     closed=FALSE)
check(coords[[1]], list(x=1:2, y=1:2))
check(coords[[2]], list(x=3:4, y=3:4))

## grob with 'pathId'
coords <- grobCoords(pathGrob(c(0, 0, 3, 3, 1, 1, 2, 2, 4, 4, 7, 7, 5, 5, 6, 6),
                              c(0, 3, 3, 0, 1, 2, 2, 1, 4, 7, 7, 4, 5, 6, 6, 5),
                              id=rep(rep(1:2, each=4), 2),
                              pathId=rep(1:2, each=8),
                              default.units="in"),
                     closed=TRUE)
check(coords[[1]], list(x=c(0, 0, 3, 3), y=c(0, 3, 3, 0)))
check(coords[[2]], list(x=c(1, 1, 2, 2), y=c(1, 2, 2, 1)))
check(coords[[3]], list(x=c(4, 4, 7, 7), y=c(4, 7, 7, 4)))
check(coords[[4]], list(x=c(5, 5, 6, 6), y=c(5, 6, 6, 5)))

## Mostly testing makeContent()
coords <- grobCoords(bezierGrob(c(0, 1, 2, 3), c(0, 1, 2, 3),
                                default.units="in"),
                     closed=FALSE)
coords <- lapply(coords[[1]], function(x) { x[c(1, length(x))] })
check(coords, list(x=c(0, 3), y=c(0, 3)))

## All emptyCoords
coords <- grobCoords(textGrob("test"))
check(coords, emptyCoords)

coords <- grobCoords(moveToGrob())
check(coords, emptyCoords)

coords <- grobCoords(lineToGrob())
check(coords, emptyCoords)

coords <- grobCoords(nullGrob())
check(coords, emptyCoords)

coords <- grobCoords(clipGrob())
check(coords, emptyCoords)

coords <- grobCoords(rasterGrob(matrix(1)))
check(coords, emptyCoords)

