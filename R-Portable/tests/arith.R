options(digits=7)

## powers
outer(a <- -4:12,     -2:7, "^")

for (n1 in 1:7)
    print(zapsmall(polyroot(1:n1), digits = 10))

## lowess() {incl. sort, etc}:
options(digits = 5)

lowess(c(3,2,6,3,8,4))$y # this used to differ on Linux

y1 <- c(3,1:2,5:2,4,1:3,3)
lowess(y1)$y
lowess(y1, f = .4)$y

lowess(c(y1,100), f = .4)$y

## this is the test sample from Cleveland's original lowess.doc:
x <- c(1:5, rep(6,10),8,10,12,14,50)
y <- c(18,2,15,6,10,4,16,11,7,3,14,17,20,12,9,13,1,8,5,19)
lowess(x,y, f = .25, iter = 0, delta = 0)$y
lowess(x,y, f = .25, iter = 0, delta = 3)$y
lowess(x,y, f = .25, iter = 2, delta = 0)$y

