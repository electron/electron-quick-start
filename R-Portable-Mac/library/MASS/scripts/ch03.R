#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 3   S Language

library(MASS)
options(width=65, digits=5, height=9999)

# from Chapter 2

powers.of.pi <- pi^(-2:2)
names(powers.of.pi) <- -2:2
mymat <- matrix(1:30, 3, 10)
myarr <- mymat
dim(myarr) <- c(3, 5, 2)
dimnames(myarr) <- list(letters[1:3], NULL, c("(i)", "(ii)"))


# 3.1  Language layout

1 - pi + exp(1.7)

a <- 6

b <- a <- 6

(z <- 1 - pi + exp(1.7))

search()

objects()

objects(2)

find("objects")

get("[<-.data.frame", pos = 2)

# hills <- hills  # only needed in S-PLUS
hills$ispeed <- hills$time/hills$dist


# 3.2  More on S objects

length(letters)

Empl <- list(employee = "Anna", spouse = "Fred", children = 3,
            child.ages = c(4, 7, 9))

Empl$employee
Empl$child.ages[2]

x <- "spouse"; Empl[[x]]

unlist(Empl)
unlist(Empl, use.names = F)

attributes(myarr)
attr(myarr, "dim")

Empl <- c(Empl, service = 8)

c(list(x = 1:3, a = 3:6), list(y = 8:23, b = c(3, 8, 39)))

as(powers.of.pi, "vector")
as(powers.of.pi, "numeric")
is(powers.of.pi, "numeric")
as(powers.of.pi, "character")
is(powers.of.pi, "vector")
as(powers.of.pi, "integer")
is(mymat, "array")


# 3.3  Arithmetical expressions

x <- c(10.4, 5.6, 3.1, 6.4, 21.7)
y <- c(x, x)
v <- 2 * x + y + 1


s3 <- seq(-5, 5, by = 0.2)
s4 <- seq(length = 51, from = -5, by = 0.2)

s5 <- rep(x, times = 5) # repeat whole vector
s5 <- rep(x, each = 5)  # repeat element-by-element

x <- 1:4          # puts c(1,2,3,4)             into x
i <- rep(2, 4)    # puts c(2,2,2,2)             into i
y <- rep(x, 2)    # puts c(1,2,3,4,1,2,3,4)     into y
z <- rep(x, i)    # puts c(1,1,2,2,3,3,4,4)     into z
w <- rep(x, x)    # puts c(1,2,2,3,3,3,4,4,4,4) into w

( colc <- rep(1:3, each = 8) )
( rowc <- rep(rep(1:4, each = 2), 3) )

1 + (ceiling(1:24/8) - 1) %% 3 -> colc; colc
1 + (ceiling(1:24/2) - 1) %% 4 -> rowc; rowc
# or
gl(3, 8)
gl(4, 2, 24)


# 3.4  Character vector operations

paste(c("X", "Y"), 1:4)
paste(c("X", "Y"), 1:4, sep = "")

paste(c("X", "Y"), 1:4, sep = "", collapse = " + ")


substring(state.name[44:50], 1, 4)

as.vector(abbreviate(state.name[44:50]))
as.vector(abbreviate(state.name[44:50], use.classes = FALSE))

grep("na$", state.name)
regexpr("na$", state.name)
state.name[regexpr("na$", state.name)> 0]


# 3.5  Formatting and printing

d <- date()
cat("Today's date is:", substring(d, 1, 10),
                         substring(d, 25, 28), "\n")

cat(1, 2, 3, 4, 5, 6, fill = 8, labels = letters)

cat(powers.of.pi, "\n")
format(powers.of.pi)
cat(format(powers.of.pi), "\n", sep="  ")


# 3.6  Calling conventions for functions

args(hist.default)


# 3.8  Control stuctures

yp <- rpois(50, lambda = 1) # full Poisson sample of size 50
table(yp)
y <- yp[yp > 0]             # truncate the zeros; n = 29

ybar <- mean(y); ybar
lam <- ybar
it <- 0                     # iteration count
del <- 1                    # iterative adjustment
while (abs(del) > 0.0001 && (it <- it + 1) < 10) {
   del <- (lam - ybar*(1 - exp(-lam)))/(1 - ybar*exp(-lam))
   lam <- lam - del
   cat(it, lam, "\n")}


# 3.9  Array and matrix operations

p <- dbinom(0:4, size = 4, prob = 1/3)  # an example
CC <- -(p %o% p)
diag(CC) <- p + diag(CC)
structure(3^8 * CC, dimnames = list(0:4, 0:4))  # convenience

apply(iris3, c(2, 3), mean)
apply(iris3, c(2, 3), mean, trim = 0.1)
apply(iris3, 2, mean)

ir.var <- apply(iris3, 3, var)

ir.var <- array(ir.var, dim = dim(iris3)[c(2, 2, 3)],
                dimnames = dimnames(iris3)[c(2, 2, 3)])

matrix(rep(1/50, 50) %*% matrix(iris3, nrow = 50), nrow = 4,
        dimnames = dimnames(iris3)[-1])

ir.means <- colMeans(iris3)
sweep(iris3, c(2, 3), ir.means)
log(sweep(iris3, c(2, 3), ir.means, "/"))


# 3.10  Introduction to classes and methods

methods(summary)

# End of ch03

