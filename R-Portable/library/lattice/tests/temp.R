
postscript("temp.ps")
library(lattice)


## dotplot labels problem

xx <- 1:10
names(xx) <- rep(letters[1:5], 2)
dotplot(xx)






## missing levels of factors
## drop unused levels

x <- 1:100
y <- rnorm(100)
g <- gl(4, 25, 100)

xyplot(y ~ x | g)
xyplot(y ~ x | g, subset = g != "2")
xyplot(y ~ x | g, subset = g != "2",
       panel = function(x, y, subscripts) {
           print(subscripts)
           ltext(x, y, lab = subscripts)
       })



## subset & subscript interaction

x <- rnorm(50)
y <- rnorm(50)
subset <- 20:40

xyplot(y ~ x,
       panel = function(x, y, subscripts) {
           print(subscripts)
           ltext(x, y, lab = subscripts)
       })

## gives subscripts = 20:40
xyplot(y ~ x, subset = subset,
       panel = function(x, y, subscripts) {
           print(subscripts)
           ltext(x, y, lab = subscripts)
       })

g <- gl(2,1,50)

xyplot(y ~ x, groups = g, panel = panel.superpose)
xyplot(y ~ x, groups = g, panel = panel.superpose, subset = subset)








## reordering tests

data(iris)
iris$foo <- equal.count(iris$Sepal.Length)

foo <- xyplot(Petal.Length ~ Petal.Width | Species + foo, iris)

foo

foo$subset.cond <- list(1:3, 1:6)
foo$perm.cond <- 1:2
foo

foo$perm.cond <- 2:1
foo$subset.cond <- list(c(1,2,3,1), 2:4)
foo



bar <- xyplot(Petal.Length ~ Petal.Width | Species + foo, iris, skip = c(F, T))
bar

bar <- xyplot(Petal.Length ~ Petal.Width | Species + foo, iris, skip = c(F, T), scales = "free")
bar





## other stuff

x <- numeric(0)
y <- numeric(0)

bwplot(y ~ x)  # fails? FIXME


x <- c(rnorm(10), rep(NA, 10))
y <- gl(1, 20)
a <- gl(2, 10)

bwplot(x ~ y | a)


## warning: why ?
bwplot(x ~ y | a * a)




## example from Wolfram Fischer


my.barley <- subset( barley, ! ( site == "Grand Rapids" & year == "1932" ) )

dotplot(variety ~ yield | year * site, my.barley,
        layout=c(6,2), between=list(x=c(0,6)))



dotplot(variety ~ yield | year * site, data = my.barley,
        layout=c(6,2),
        scales =
        list(rot = 0,
             y =
             list(relation='sliced', 
                  at = rep( list( FALSE, NULL ), 6 ))),
        par.settings =
        list(layout.widths = list(axis.panel = rep(c(1, 0), 3))))




dev.off()



