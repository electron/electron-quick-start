## stepAIC on an lme object: an example from Robert Cuffe
library(nlme)
library(MASS)
set.seed(321) # to be sure
a <- data.frame( resp=rnorm(250), cov1=rnorm(250),
                 cov2=rnorm(250), group=rep(letters[1:10],25) )
mod1 <- lme(resp~cov1, a, ~cov1|group, method="ML")
mod2 <- stepAIC(mod1, scope=list(upper=~(cov1+cov2)^2, lower=~1) )

beav <- beav2
set.seed(123)
beav$dummy <- rnorm(nrow(beav))
beav.gls <- gls(temp ~ activ + dummy, data = beav,
                 corr = corAR1(0.8), method = "ML")
stepAIC(beav.gls)

