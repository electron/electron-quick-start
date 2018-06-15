library(nlme)
## ==> ~/R/Pkgs/MASS_CRAN/tests/lme.R : tests  stepAIC() for *both* lme and gls
library(MASS)

## deviance.lme() and extractAIC.lme() :
set.seed(321) # to be sure
a <- data.frame( resp=rnorm(250), cov1=rnorm(250),
                cov2=rnorm(250), group=rep(letters[1:10],25) )
mod1 <- lme(resp~cov1, a, ~cov1|group, method="ML")
mod2 <- stepAIC(mod1, scope = list(upper=~(cov1+cov2)^2, lower=~1) )
stopifnot(all.equal(logLik(mod1), logLik(mod2)),
	  all.equal(  coef(mod1),   coef(mod2)),
	  all.equal(logLik(mod2),
		    structure(-344.190316608, class = "logLik",
			      nall = 250L, nobs = 250, df = 6)))


## deviance.gls() and extractAIC.gls() :
data(beav2, package = "MASS")
set.seed(123)
beav <- beav2; beav$dummy <- rnorm(nrow(beav))
beav.gls <- gls(temp ~ activ + dummy, data = beav,
                corr = corAR1(0.8), method = "ML")
stopifnot(all.equal(sigma(beav.gls), 0.2516395, tol = 1e-6),
	  all.equal(coef(beav.gls),
		    c("(Intercept)" = 37.191057,
		      activ = 0.61602059, dummy =0.006842112)))
st.beav <- stepAIC(beav.gls)
stopifnot(all.equal(coef(st.beav),
		    c("(Intercept)" = 37.1919453124,
		      "activ" = 0.614177660082)),
	  all.equal(sigma(st.beav), 0.2527856, tol = 1e-6))

