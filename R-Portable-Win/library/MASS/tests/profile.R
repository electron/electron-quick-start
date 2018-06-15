### Example from Merete Kjær Hansen 2011-07-06
library(MASS)
dat <- data.frame(y = c(35, 21, 9, 6, 1),
                  dose = c(0.0028, 0.0056, 0.0112, 0.0225, 0.045),
                  n = c(40, 40, 40, 40, 40), w = 1:5)
### fit model with two-column response and weights
fm <- glm(cbind(y, n-y) ~ dose, weights=w, family=binomial, data=dat)
### Investigating the profile likelihoods of the parameters with profile.glm
profile(fm)
## failed in MASS 7.3-13
