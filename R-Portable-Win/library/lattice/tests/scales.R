
postscript("scales.ps")
## Testing weird scales options

library(lattice)



## relation = "free" for factors

dat <- data.frame(a=letters[1:5], b=c("A","A","A","B","B"), y=1:5) 
dotplot(y ~ a | b, data=dat, scales = "same") 
dotplot(y ~ a | b, data=dat, scales = "free") 
dotplot(y ~ a | b, data=dat, scales = "sliced") 



dat <-
    data.frame(a = letters[1:10],
               b = c("A","A","A","B","B","A","B","B", "A", "A"))

dat <- dat[sample(1:10, 200, rep = TRUE), ]
dat$y <- rnorm(200, mean = unclass(as.factor(dat$a)))

bwplot(a ~ y | b, data=dat, scales = "same") 
bwplot(a ~ y | b, data=dat, scales = "free") 
bwplot(a ~ y | b, data=dat, scales = "sliced") 






## text axis colors

xyplot(1:10 ~ 1:10,
       scales =
       list(y = list(font = 2,
            cex = 1,
            col = "green", col.line = "cyan", tck = 5)),
       xlab = list("one to ten",  fontfamily = "HersheySerif"),
       par.settings =
       list(axis.text = list(col = "red", font = 4, cex = 3),
            axis.line = list(col = "yellow")))




x <- rnorm(100)
y <- 2 + 3 * runif(100)
a <- gl(3, 1, 100)

xyplot(y ~ x | a)

xyplot(y ~ x | a, scales = list(axs = "i"))

xyplot(y ~ x | a, xlim = c(-5, 5), scales = list(limits = c(-6, 6)))

xyplot(y ~ x | a, xlim = c(-5, 5), ylim = letters[1:5])


## Should produce an error
cat(try(print(xyplot(y ~ x | a, scales = list(x = list( relation = "same", axs = "i", limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ) )))), silent = TRUE))
xyplot(y ~ x | a, scales = list(x = list( relation = "free", axs = "i", limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ) )))
xyplot(y ~ x | a, scales = list(x = list( relation = "sliced", axs = "i", limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ) )))

## Should produce an error
cat(try(print(xyplot(y ~ x | a, xlim = list( c(-5, 5), c(-4, 4), c(-3, 3)  ), scales = list(x = list( relation = "same", axs = "i")))), silent = TRUE))
xyplot(y ~ x | a, xlim = list( c(-5, 5), c(-4, 4), c(-3, 3)  ), scales = list(x = list( relation = "free", axs = "i")))
xyplot(y ~ x | a, xlim = list( c(-5, 5), c(-4, 4), c(-3, 3)  ), scales = list(x = list( relation = "sliced", axs = "i")))




xyplot(y ~ x | a, scales = list(x = list( relation = "free"  )))

xyplot(y ~ x | a, scales = list(x = list( relation = "free", limits = c(-5, 5))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free", axs = "i", limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ) )))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = c(-3, 3, 0))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), FALSE ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], FALSE  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], FALSE  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "free", rot = 45,
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], month.name[1:5]  ))))









xyplot(y ~ x | a, scales = list(x = list( relation = "sliced"  )))
xyplot(y ~ x | a, scales = list(x = list( relation = "sliced" , axs = "i" )))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced", limits = c(-5, 5))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced", axs = "i", limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ) )))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = c(-3, 3, 0))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), c(-3, 3)  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), c(-3, 3, 0)  ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], c(-3, 3, 0)  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), FALSE ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], FALSE  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced",
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], FALSE  ))))

xyplot(y ~ x | a, scales = list(x = list( relation = "sliced", rot = 45,
                                limits = list( c(-5, 5), c(-4, 4), letters[1:5]  ),
                                at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ),
                                labels = list( as.character(c(0, 5, -5)) , letters[5:7], month.name[1:5]  ))))




xyplot(y ~ x | a, scales = list(x = list( relation = "free", at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ))))
xyplot(y ~ x | a, scales = list(x = list( relation = "sliced", at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ))))

## should produce an error
cat(try(print(xyplot(y ~ x | a, scales = list(y = list( relation = "same", at = list( c(0, 5, -5) , c(-4, 0, 4), 1:5 ))))), silent = TRUE))


## problem
stripplot(rep(1:20, 5) ~ x | a, scales = list(relation = "free", col = "transparent"))
dev.off()
