## reported by simon bond <shug0131@yahoo.co.uk> to R-help 2007-03-16

library(nlme)
x <- rnorm(10, 0.1, 1)
try(gls(x ~ 0))  # segfaulted in 3.1-79


## PR#10364
# copied verbatim from Pinheiro & Bates 8.3.3
fm1Dial.gnls <-
  gnls(rate ~ SSasympOff(pressure, Asym, lrc, c0),
       data = Dialyzer, params = list(Asym + lrc ~ QB, c0 ~ 1),
       start = c(53.6, 8.6, 0.51, -0.26, 0.225))
(p1 <- predict(fm1Dial.gnls))
(p2 <- predict(fm1Dial.gnls, newdata = Dialyzer))
# failed, factor levels complaint
# also, missed row names as names
stopifnot(all.equal(as.vector(p1), as.vector(p2)), # 'label' differs
          identical(names(p1), names(p2)))

## PR#13418
fm1 <- gls(weight ~ Time * Diet, BodyWeight)
(V10 <- Variogram(fm1, form = ~ Time | Rat)[1:10,])
## failed in 3.1-89
stopifnot(all.equal(V10$variog,
                    c(0.0072395216, 0.014584634, 0.014207936, 0.018442267,
                      0.011128505, 0.019910082, 0.027072311, 0.034140379,
                      0.028320657, 0.037525507)),
          V10$dist == c(1, 6, 7, 8, 13, 14, 15, 20, 21, 22),
          V10$n.pairs == 16*c(1, 1, 9, 1, 1, 8, 1, 1, 7, 1))

intervals(fm1)
