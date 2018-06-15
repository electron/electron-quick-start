
# code from proto vignette

library(proto)

addProto <- proto( x = rnorm(5), add = function(.) sum(.$x) )
addProto$add()
addProto2 <- addProto$proto( x = 1:5 )
addProto2$add()

addProto2$y <- seq(2,10,2)
addProto2$x <- 1:10
addProto2$add3 <- function(., z) sum(.$x) + sum(.$y) + sum(z)
addProto2$add()
addProto2$add3(c(2,3,5))
addProto2$y

# addProto2$add <- function(.) .super$add(.) + sum(.$y)
addProto2$add <- function(.) parent.env(addProto2)$add(.) + sum(.$y)

addProto2a <- addProto$proto(x = 1:5)
addProto2a$add()

Add <- proto(
      add = function(.) sum(.$x),
      new = function(., x) .$proto(x=x)
)
add1 <- Add$new(x = 1:5)
add1$add()
add2 <- Add$new(x = 1:10)
add2$add()

Logadd <- Add$proto( logadd = function(.) log( .$add() ) )
logadd1 <- Logadd$new(1:5)
logadd1$logadd()

addProto$ls()

addProto$str()
addProto$print()
addProto$as.list()
addProto2a$parent.env()

addProto$eapply(length) # show length of each component

addProto$identical(addProto2)

oo <- proto(expr = {
           x <- rnorm(251, 0, 0.15)
           x <- filter(x, c(1.2, -0.05, -0.18), method = "recursive")
           x <- unclass(x[-seq(100)]) * 2 + 20
           tt <- seq(12200, length = length(x))
           ..x.smooth <- NA
           xlab <- "Time (days)"
           ylab <- "Temp (deg C)"
           pch  <- "."
           col  <- rep("black",2)
           smooth <- function(., ...) {
                      .$..x.smooth <- supsmu(.$tt, .$x, ...)$y
                    }
           plot <- function(.) with(., {
                       graphics::plot(tt, x, pch  = pch, xlab = xlab,
                                    ylab = ylab, col  = col[1])
                       if (!is.na(..x.smooth[1]))
                                    lines(tt, ..x.smooth, col=col[2])
                   })
           residuals <- function(.) with(., {
                           data.frame(t = tt, y = x - ..x.smooth)
                         })
         })

## inspect the object
oo
oo$ls(all.names = TRUE)
oo$pch

par(mfrow=c(1,2))
# oo$plot()
## set a slot
oo$pch <- 20
## smooth curve and plot
oo$smooth()
oo$plot()
## plot and analyse residuals, stored in the object
plot(oo$residuals(), type="l")
# hist(oo$residuals()$y)
# acf(oo$residuals()$y)
oo.res <- oo$proto( pch = "-", x = oo$residuals()$y,
               ylab = "Residuals deg K" )

par(mfrow=c(1,1))
oo.res$smooth()
oo.res$plot()

## change date format of the parent
oo$tt <- oo$tt + as.Date("1970-01-01")
oo$xlab <- format(oo.res$tt[1], "%Y")
## change colors
oo$col <- c("blue", "red")

oo$splot <- function(., ...) {
  .$smooth(...)
  .$plot()
}

## the new function is now available to all children of oo
par(mfrow=c(1,2))
oo$splot(bass=2)
oo.res$splot()


## and at last we change the data and repeat the analysis
oos <- oo$proto( expr = {
	tt <- seq(0,4*pi, length=1000)
	x <- sin(tt) + rnorm(tt, 0, .2)
})
oos$splot()
#plot(oos$residuals())

oos.res <- as.proto( oo.res$as.list(), parent = oos )
oos.res$x <- oos$residuals()$y
oos.res$splot()

par(mfrow=c(1,2))
oos$splot()
oos.res$splot()


longley.ci <- proto( expr = {
	data(longley)
	x <- longley[,c("GNP", "Unemployed")]
	n <- nrow(x)
	pp <- c(.025, .975)

	corx <- cor(x)[1,2]
	ci <- function(.)
		(.$CI <- tanh( atanh(.$corx) + qnorm(.$pp)/sqrt(.$n-3) ))
})


longley.ci.boot <- longley.ci$proto({
   N <- 1000
   ci <- function(.) {
      corx <- function(idx) cor(.$x[idx,])[1,2]
      samp <- replicate(.$N, corx(sample(.$n, replace = TRUE)))
      (.$CI <- quantile(samp, .$pp))
   }
})

longley.ci$ci()
longley.ci.boot$ci()
longley.ci.boot$proto(N=4000)$ci()

# do not need left <- right <- NULL anymore in leaf
# also eliminated right <- NULL in parent
tree <- proto(expr = {
	incr <- function(., val) .$value <- .$value + val
	..Name <- "root"
	value <- 3
	..left <- proto( expr = { ..Name = "leaf" })
})

cat("root:", tree$value, "leaf:", tree$..left$value, "\n")

# incrementing root increments leaf too
tree$incr(1)
cat("root:", tree$value, "leaf:", tree$..left$value, "\n")


# incrementing leaf gives it its own value field
# so now incrementing root does not increment leaf
tree$..left$incr(10)
cat("root:", tree$value, "leaf:", tree$..left$value, "\n")
tree$incr(5)
cat("root:", tree$value, "leaf:", tree$..left$value, "\n")

lineq <- proto(eq = "6*x + 12 - 10*x/4 = 2*x",
   solve = function(.) {
      e <- eval(parse(text=paste(sub("=", "-(", .$eq), ")")), list(x = 1i))
      -Re(e)/Im(e)
   },
   print = function(.) cat("Equation:", .$eq, "Solution:", .$solve(), "\n")
)
lineq$print()

lineq2 <- lineq$proto(eq = "2*x = 7*x-12+x")
lineq2$print()

Lineq <- lineq
rm(eq, envir = Lineq)
Lineq$new <- function(., eq) proto(., eq = eq)

lineq3 <- Lineq$new("3*x=6")
lineq3$print()


