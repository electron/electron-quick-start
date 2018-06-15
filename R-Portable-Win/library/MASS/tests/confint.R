library(MASS)

PropCI <- function(x, n, conf = 0.95)
{
    DF <- data.frame(y = x / n, weights = n)
    mod <- glm(y ~ 1, weights = weights, family = binomial(), data = DF)
    plogis(confint(mod, level = conf))
}

PropCI(14, 35)
## had scope error prior to 7.2-31

## single variable cases:
n.tot <- c(60,17,8,2,187,85,51,23)
n.hyp <- c(5,2,1,0,35,13,15,8)
hyp.tbl <- cbind(n.hyp, n.tot-n.hyp)
glm.hyp <- glm(hyp.tbl ~ 1, binomial)
plot(profile(glm.hyp))
x <- cbind(2,20)
plot(profile(glm(x~1,binomial)))
# failed in 7.2-39

dat <- data.frame(event = c(2,4,5), nonev = c(4,2,7))
m <- glm(cbind(event, nonev) ~ 1, data=dat, family=binomial)
confint(m)
# failed in 7.2-40
