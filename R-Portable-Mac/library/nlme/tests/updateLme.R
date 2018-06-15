library(nlme)

## Example 1  --- was  ./update.R  ---
data(petrol, package = 'MASS')
Petrol <- petrol
Petrol[, 2:5] <- scale(Petrol[, 2:5], scale = FALSE)
pet3.lme <- lme(Y ~ SG + VP + V10 + EP,
                random = ~ 1 | No, data = Petrol, method="ML")
upet3 <- update(pet3.lme, Y ~ SG + VP + V10)
upet3
vc3 <- VarCorr(upet3)
upet2 <- lme(Y ~ SG + VP + V10, random = ~ 1 | No, data = Petrol, method = "ML")
stopifnot(
    all.equal(upet3, upet2, tol = 1e-15)
    ,
    all.equal(fixef(upet3),
	      c("(Intercept)" = 19.659375, SG = 0.125045632,
		VP = 2.27818601, V10 = 0.0672413592), tol = 1e-8)# 1e-9
    ,
    all.equal(as.numeric(vc3[,"StdDev"]),
	      c(0.00029397, 9.69657845), tol=1e-6)
)

## Example 2  ---
data(Assay)
as1 <- lme(logDens~sample*dilut, data=Assay,
           random=pdBlocked(list(
                     pdIdent(~1),
                     pdIdent(~sample-1),
                     pdIdent(~dilut-1))))

as1s <- update(as1, random=pdCompSymm(~sample-1))
(an.1s <- anova(as1, as1s)) # non significant
stopifnot(
    all.equal(drop(data.matrix(an.1s[2,-1])),
              c(Model = 2, df = 33, AIC = -10.958851, BIC = 35.280663,
                logLik = 38.479425, Test = 2,
                L.Ratio = 0.11370211, `p-value` = 0.73596807), tol=8e-8))

as1S <- update(as1, . ~ sample+dilut) # dropping FE interaction
tools::assertWarning(anova(as1, as1S))# REML not ok for different FE.
as1M  <- update(as1,  method = "ML")
as1SM <- update(as1S, method = "ML")
(anM <- anova(as1M, as1SM)) # anova() OK: comparing MLE fits
## ==> significant: P ~= 0.0054
stopifnot(
    all.equal(drop(data.matrix(anM[2,])[,-(1:2)]),
	      c(df = 14, AIC = -169.588248, BIC = -140.267424, logLik = 98.7941241,
		Test = 2, L.Ratio = 39.7345188, `p-value` = 0.0053958561),
	      tol = 8e-8)
)

