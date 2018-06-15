## tests of the simulate.lm method, added Feb 2009

options(digits = 5)

## cases should be named
load("hills.rda") # copied from package MASS
fit1 <- lm(time ~ dist, data = hills)
set.seed(1)
simulate(fit1, nsim = 3)

## and weights should be taken into account
fit2 <- lm(time ~ -1 + dist + climb, hills[-18, ], weight = 1/dist^2)
coef(summary(fit2))
set.seed(1)
( ys <- simulate(fit2, nsim = 3) )
for(i in seq_len(3))
    print(coef(summary(update(fit2, ys[, i] ~ .))))

## Poisson fit
load("anorexia.rda") # copied from package MASS
fit3 <- glm(Postwt ~ Prewt + Treat + offset(Prewt),
            family = gaussian, data = anorexia)
coef(summary(fit3))
set.seed(1)
simulate(fit3, nsim = 8)

## two-column binomial fit
ldose <- rep(0:5, 2)
numdead <- c(1, 4, 9, 13, 18, 20, 0, 2, 6, 10, 12, 16)
sex <- factor(rep(c("M", "F"), c(6, 6)))
SF <- cbind(numdead, numalive = 20 - numdead)
fit4 <- glm(SF ~ sex + ldose - 1, family = binomial)
coef(summary(fit4))
set.seed(1)
( ys <- simulate(fit4, nsim = 3) )
for(i in seq_len(3))
    print(coef(summary(update(fit4, ys[, i] ~ .))))

## same via proportions
fit5 <- glm(numdead/20 ~ sex + ldose - 1, family = binomial,
            weights = rep(20, 12))
set.seed(1)
( ys <- simulate(fit5, nsim = 3) )
for(i in seq_len(3))
    print(coef(summary(update(fit5, ys[, i] ~ .))))


## factor binomial fit
load("birthwt.rda") # copied from package MASS
bwt <- with(birthwt, {
    race <- factor(race, labels = c("white", "black", "other"))
    table(ptl)
    ptd <- factor(ptl > 0)
    table(ftv)
    ftv <- factor(ftv)
    levels(ftv)[-(1:2)] <- "2+"
    data.frame(low = factor(low), age, lwt, race,
               smoke = (smoke > 0), ptd, ht = (ht > 0), ui = (ui > 0), ftv)
})
fit6 <- glm(low ~ ., family = binomial, data = bwt)
coef(summary(fit6))
set.seed(1)
ys <- simulate(fit6, nsim = 3)
ys[1:10, ]
for(i in seq_len(3))
    print(coef(summary(update(fit6, ys[, i] ~ .))))

## This requires MASS::gamma.shape
if(!require("MASS")) q()

## gamma fit, from example(glm)
clotting <- data.frame(u = c(5,10,15,20,30,40,60,80,100),
                       lot1 = c(118,58,42,35,27,25,21,19,18))
fit7 <- glm(lot1 ~ log(u), data = clotting, family = Gamma)
coef(summary(fit7))
set.seed(1)
( ys <- simulate(fit7, nsim = 3) )
for(i in seq_len(3))
    print(coef(summary(update(fit7, ys[, i] ~ .))))

