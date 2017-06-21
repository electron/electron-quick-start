## tests from David Firth 2004-Oct-13

library(MASS)
y <- structure(as.integer(c(1, 2, 3, 1, 2, 3)), .Label = c("1", "2", "3"),
               class = c("ordered", "factor"))
Freq <- c(10, 0, 10, 10, 0, 10)
group <- structure(as.integer(c(1, 1, 1, 2, 2, 2)), .Label = c("1", "2"),
                   class = "factor")

temp <- polr(y ~ group, weights = Freq)
temp$convergence
temp

stopifnot(all(abs(coef(temp)) < 1e-4))

Freq <- c(1000000, 1, 1000000, 1000000, 1, 1000000)
temp2 <- polr(y ~ group, weights = Freq)
temp2

stopifnot(all(abs(coef(temp2)) < 1e-4))

## tests of rank-deficient model matrix

group <- factor(c(1, 1, 1, 2, 2, 2), levels=1:3)
polr(y ~ group, weights = Freq)
group <- factor(c(1, 1, 1, 3, 3, 3), levels=1:3)
polr(y ~ group, weights = Freq)

## profile on a single-coef model
## data from McCullagh JRSSB 1980
tonsils <- data.frame(carrier = factor(rep(c('yes', 'no'), each=3)),
                      size = ordered(rep(c(1,2,3),2)),
                      count = c(19,29,24,497,560,269))
m <- polr(size ~ carrier, data = tonsils, weights = count)
confint(m)


## refitting needs transformed starting values (Achim Zeileis Mar 2010)
load("BankWages.rda") # from AER
bw <- polr(job ~ education, data = BankWages)
summary(bw)
## failed due to incorrect restarting values

## missing drop = FALSE in profiling (Joris Meys, Sep 2012)
house.plr <- polr(Sat ~ Cont, weights = Freq, data = housing)
pr <- profile(house.plr)
plot(pr)

