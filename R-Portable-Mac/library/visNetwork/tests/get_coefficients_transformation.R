# transformation in vis.js
x <- numberOfNodes <- 1:1000
y <- 12.662 / (numberOfNodes + 7.4147) + 0.0964822
# var factor = Math.min(this.canvas.frame.canvas.clientWidth / 600, this.canvas.frame.canvas.clientHeight / 600);
# zoomLevel *= factor;
plot(x, y)

require(nleqslv)

x = c(2,  42, 100)
y= c(0.02, 0.77, 1.3)

f <- function(par) {
  
  fval <- numeric(length(par))
  v1 <- par[1]
  v2 <- par[2]
  v3 <- par[3]
  
  fval[1] = (v1 / (x[1] + v2) + v3) - y[1]
  fval[2] = (v1 / (x[2] + v2) + v3) - y[2]
  fval[3] = (v1 / (x[3] + v2) + v3) - y[3]
  
  fval
}
nleqslv(c(-100,25, 5), f, control = list(maxit = 5000))

numberOfNodes <- 1:10000
y <- -232.622349 / (numberOfNodes + 91.165919)  +2.516861
plot(numberOfNodes, y)
