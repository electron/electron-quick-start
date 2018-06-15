
## Demo of expressions

x <- rnorm(400)
y <- rnorm(400)
a <- gl(4, 100)

xyplot(y ~ x | a, aspect = "fill",
       strip = function(factor.levels, strip.names, var.name, ...) {
           strip.default(factor.levels = expression(alpha, beta, gamma, delta),
                         strip.names = TRUE,
                         var.name = expression(frac(epsilon, 2)),
                         ...) },
       par.strip.text = list(lines = 2),
       xlab=list(expression(sigma[i]), cex = 2),
       ylab=expression(gamma^2),
       main=expression(pi*sum(x, i=0, n)),
       scales=
       list(relation = "free", 
            x=list(at=c(-2, 0, 2), labels=expression(frac(-pi, 2), 0, frac(pi, 2))),
            y=list(at=c(-2, 0, 2), labels=expression(alpha, beta, gamma))),
       key = list(space="right", transparent = TRUE,
       title = expression(e[i[1]]^{alpha + 2 ^ beta}),
       cex.title = 2,
       points=list(pch=1:2),
       text = list(c('small', 'BIG'), cex = c(.8, 3)),
       lines = list(lty = 1:2),
       text=list(expression(theta, zeta))),
       sub=expression(frac(demonstrating, expressions)))


## grob's as xlab, ylab 

qq(gl(2, 100) ~ c(runif(100, min = -2, max = 2), rnorm(100)),
   xlab =
   textGrob(rep("Uniform", 2), 
            x = unit(.5, "npc") + unit(c(.5, 0), "mm"),
            y = unit(.5, "npc") + unit(c(0, .5), "mm"),
            gp = gpar(col = c("black", "red"), cex = 3)),
   ylab =
   textGrob(rep("Normal", 2), rot = 90,
            x = unit(.5, "npc") + unit(c(.5, 0), "mm"),
            y = unit(.5, "npc") + unit(c(0, .5), "mm"),
            gp = gpar(col = c("black", "red"), cex = 3)),
   main = "Q-Q plot")

