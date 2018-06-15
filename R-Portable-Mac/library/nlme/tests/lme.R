library(nlme)

options(digits = 6)# <==> less platform dependency in print() output
if(!dev.interactive(orNone=TRUE)) pdf("test_lme.pdf")

fm1 <- lmList(Oxboys)
fm1
fm2 <- lme(fm1)
fm2
vc2 <- VarCorr(fm2)
stopifnot(
    all.equal(fixef(fm2), c("(Intercept)" = 149.371753,
                            age = 6.52546866), tol=1e-8),
    all.equal(as.numeric(vc2[,"StdDev"]),
              c(8.081077, 1.680717, 0.659889), tol=4e-7))

# bug report from Arne.Mueller@sanofi-aventis.com
mod <- distance ~ age + Sex
fm3 <- lme(mod, Orthodont, random = ~ 1)
pm3 <- predict(fm3, Orthodont)
stopifnot(all.equal(mean(pm3), 24.023148148),
	  all.equal(  sd(pm3), 2.4802195115),
	  all.equal(quantile(pm3), c("0%"  = 17.0817792, "25%" = 22.3481813,
				     "50%" = 23.9271016, "75%" = 25.5740014,
				     "100%"= 30.8662241)))


## bug report and fix from Dimitris Rizopoulos and Spencer Graves:
## when 'returnObject = TRUE', do not stop() but give warning() on non-convergence:
tools::assertWarning(
fm1 <- lme(distance ~ age, data = Orthodont,
	   control = lmeControl(msMaxIter = 1, returnObject = TRUE))
)

## based on bug report on R-help
(p3.1 <- predict(fm3, Orthodont[1,]))
# failed in 3.1-88
stopifnot(all.equal(pm3[1], p3.1,
		    check.attributes=FALSE, tolerance = 1e-14))

## Intervals failed in a patch proposal (Nov.2015):
(fm4 <- lme(distance ~ age, Orthodont, random = ~ age | Subject))
i4 <- intervals(fm4)
## from  dput(signif(i4$reStruct$Subject, 8))
## R-devel 2016-01-11; 64-bit :
reSS <- data.frame(lower = c(0.9485605, 0.10250901, -0.93825047),
                   est.  = c(2.3270341, 0.22642779, -0.60933286),
                   upper = c(5.7087424, 0.50014674,  0.29816857))
## R-devel 2016-01-11; 32-bit :
## reSS <- data.frame(lower = c(0.94962127,0.10262181, -0.93804767),
##                    est.  = c(2.3270339, 0.22642779, -0.60933284),
##                    upper = c(5.7023648, 0.49959695,  0.29662651))
rownames(reSS) <- rownames(i4$reStruct$Subject)
sm4 <- summary(fm4)
stopifnot(
    all.equal(fixef(fm4),
              c("(Intercept)" = 16.761111, age = 0.66018519)),
    identical(fixef(fm4), sm4$tTable[,"Value"]),
    all.equal(sm4$tTable[,"Std.Error"],
              c("(Intercept)" = 0.77524603, age = 0.071253264), tol=6e-8),
    all.equal(i4$reStruct$Subject[,"est."], reSS[,"est."], tol= 1e-7)
    ## (lower, upper) cannot be very accurate for these : ==> tol = *e-4
   ,## "interestingly" 32-bit values changed from 3.2.3 to R-devel(3.3.0):
    all.equal(i4$reStruct$Subject[,c(1,3)], reSS[,c(1,3)], tol = .005)
   ,
    all.equal(as.vector(i4$sigma),
              ##  lower     est.        upper
              c(1.0849772, 1.3100397, 1.5817881), tol=8e-4)
   ,
    all.equal(as.vector(i4$fixed),
              as.vector(rbind(c(15.218322, 16.761111, 18.3039),
                              c(0.51838667, 0.66018519, 0.8019837))),
              tol = 1e-6)
)


## wrong results from getData:
ss2 <- readRDS("ss2.rds")
m1 <- lme(PV1MATH ~  ESCS + Age +time ,
          random = ~   time|SCHOOLID,
          data = ss2,
          weights = varIdent(form=~1|time),
          corr = corCompSymm(form=~1|SCHOOLID/StIDStd),
          na.action = na.omit)
plot(m1, resid(.) ~ WEALTH)

m2 <- lme(PV1MATH ~  ESCS + Age +time ,
          random = ~   time|SCHOOLID,
          data = ss2,
          weights = varIdent(form=~1|time),
          corr = corCompSymm(form=~1|SCHOOLID/StIDStd),
          na.action = na.omit)
plot(m2, resid(.) ~ WEALTH)


## Variogram() failing in the case of  1-observation groups (PR#17192):
BW <- subset(BodyWeight, ! (Rat=="1" & Time > 1))
if(interactive())
    print( xtabs(~ Rat + Time, data = BW) )# Rat '1' only at Time == 1
fm2 <- lme(fixed = weight ~ Time * Diet, random = ~ 1 | Rat, data = BW)
Vfm2 <- Variogram(fm2, form = ~ Time | Rat)
stopifnot(is.data.frame(Vfm2),
	  identical(dim(Vfm2), c(19L, 3L)),
	  all.equal(unlist(Vfm2[10,]), c(variog = 1.08575384191148,
					 dist = 22, n.pairs = 15))
	  )
## failed in nlme from 3.1-122 till 3.1-128
