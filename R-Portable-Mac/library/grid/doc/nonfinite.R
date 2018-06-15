### R code from vignette source 'nonfinite.Rnw'

###################################################
### code chunk number 1: nonfinite.Rnw:21-25
###################################################
library(grDevices)
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: prim1
###################################################
pushViewport(viewport(layout = grid.layout(1, 2,
                      widths = unit(c(1, 1), c("inches", "null")))))
grid.rect(gp = gpar(col = "grey"))
pushViewport(viewport(layout.pos.col = 1))
grid.text(c("segments", "text", "lines", "rectangles", "circles", "points"),
          x = 1, just = "right", y = c(0.75, 6:2/10), gp = gpar(col = "grey"))
popViewport()
pushViewport(viewport(layout.pos.col = 2))
x <- 1:7/8
x[4] <- NA
grid.lines(x, 0.5)
grid.text(letters[1:5], x, 0.6)
grid.segments(x, 0.7, x, 0.8)
grid.points(x, rep(0.2, 7))
grid.rect(x, 0.4, 0.02, 0.02)
grid.circle(x, 0.3, 0.02)
grid.text("NA", 0.5, 2:8/10, gp = gpar(col = "grey"))
popViewport(2)


###################################################
### code chunk number 3: prim2
###################################################
n <- 7
primtest2 <- function(nas, na) {
    t <- seq(0, 2*pi, length = n+1)[-(n+1)]
    y <- 0.5 + 0.4*sin(t)
    x <- 0.5 + 0.4*cos(t)
    if (any(nas))
        grid.text(paste("NA", (1:n)[nas], sep = ""),
                  x[nas], y[nas], gp = gpar(col = "grey"))
    x[nas] <- na
    y[nas] <- na
    grid.move.to(x[1], y[1])
    for (i in 2:n)
        grid.line.to(x[i], y[i], gp = gpar(lty = "dashed", lwd = 5))
    grid.polygon(x, y, gp = gpar(fill = "grey", col = NULL))
    grid.lines(x, y, arrow = arrow())
}
celltest <- function(r, c, nas, na) {
    pushViewport(viewport(layout.pos.col = c, layout.pos.row = r))
    primtest2(nas, na)
    grid.rect(gp = gpar(col = "grey"))
    popViewport()
}
cellnas <- function(i) {
    temp <- rep(FALSE, n)
    temp[i] <- TRUE
    temp[n - 3 + i] <- TRUE
    temp
}
pushViewport(viewport(layout = grid.layout(2, 2)))
celltest(1, 1, rep(FALSE, n), NA)
celltest(1, 2, cellnas(1), NA)
celltest(2, 1, cellnas(2), NA)
celltest(2, 2, cellnas(3), NA)
popViewport()


