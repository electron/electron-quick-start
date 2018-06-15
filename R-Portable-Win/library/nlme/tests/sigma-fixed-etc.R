#### Testing Examples --- related to the new  "sigma = fixed" feature
#### ================================================================

## library(nlme,lib.loc=lib.loc)
library(nlme)

## possibly move to ../R/ or ../inst/ if used in more places
doExtras <- function ()
{
    interactive() || nzchar(Sys.getenv("R_nlme_check_extra")) ||
        identical("true", unname(Sys.getenv("R_PKG_CHECKING_doExtras")))
}
doExtras()
isSun <- Sys.info()[["sysname"]] == "SunOS"

##===   example 1 general linear model page 251  gls ML  and LME ================
##
ex <- "ex1_gls_page251"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
sigma <- 2
cat("\nFixed sigma= ",sigma,"  estimation method 'ML'\n")
t1.fix.ML.gls <- gls(distance ~ Sex *I(age-11), data = Orthodont,
                     correlation = corSymm(form = ~1 | Subject),
                     weights = varIdent(form = ~1 |age),
                     control = glsControl(sigma = sigma),
                     method = "ML")
(s1M <- summary(t1.fix.ML.gls))
(a1M <-   anova(t1.fix.ML.gls)) # sequential
(a1Mm<-   anova(t1.fix.ML.gls, type = "marginal"))
## t_{n} ^2  ==  F_{1,n}:
stopifnot(all.equal(as.vector(s1M$tTable[,"t-value"] ^ 2),
                    a1Mm[,"F-value"], tolerance = 1e-14),
          identical(2, sigma(t1.fix.ML.gls)))

##
cat("\nFixed sigma= ",sigma,"  estimation method 'REML'\n")
t1.fix.REML.gls <- gls(distance ~ Sex*I(age-11), data = Orthodont,
                       correlation = corSymm(form = ~1 | Subject),
                       weights = varIdent(form = ~1 |age),
                       control = glsControl(sigma = sigma,
                                            maxIter = 1000, msMaxIter = 200),
                       method = "REML")
(s1R <- summary(t1.fix.REML.gls))
(a1R  <-   anova(t1.fix.REML.gls))
(a1Rm <-   anova(t1.fix.REML.gls, type="marginal"))
intervals(t1.fix.REML.gls) # now work (via 'apVar')
## t_{n} ^2  ==  F_{1,n}:
stopifnot(all.equal(as.vector(s1R$tTable[,"t-value"] ^ 2),
                    a1Rm[,"F-value"], tolerance = 1e-14))

cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 2  linear mixed model page 147  lme ML  and REML ================
ex <- "ex2_lme_page147"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
##
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t1.fix.ML.lme <- lme(distance ~ I(age-11), data = Orthodont,
                     control = lmeControl(sigma = sigma),
                     method = method)
 summary (t1.fix.ML.lme)
   anova (t1.fix.ML.lme)
intervals(t1.fix.ML.lme)
stopifnot(sigma(t1.fix.ML.lme) == 1)

method <- "REML"
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t1.fix.REML.lme <- lme(distance ~ I(age-11), data = Orthodont,
                       control = lmeControl(sigma = sigma), method = method)
 summary (t1.fix.REML.lme)
   anova (t1.fix.REML.lme)
intervals(t1.fix.REML.lme)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 3  general non-linear  model page 402/ page 512  gnls ls ========
ex <- "ex3_gnls_page402"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
##
method <- "LS"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t1.fix.gnls <- gnls( rate ~SSasympOff(pressure, Asym, lrc, c0), data = Dialyzer,
                    params = list(Asym + lrc ~ QB, c0 ~ 1),
                    start = c(53.6,8.6,0.51,-0.26, 0.225),
                    control = gnlsControl(sigma = 1))
stopifnot(is.null(t1.fix.gnls$apVar)) ## as is has  *no*  varying ranef-parameters
 summary (t1.fix.gnls)
   anova (t1.fix.gnls)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n"); .pt <- proc.time()
t1.fix.w <- update(t1.fix.gnls, weights = varPower())
 summary (t1.fix.w)
   anova (t1.fix.w)
(it1fw <- intervals(t1.fix.w))
stopifnot(all.equal(it1fw$varStruct["power",],
		    c(lower = 0.33147895,
		      est.  = 0.36474755,
		      upper = 0.39801614), tol = 1e-6))
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 4  mixed non-linear  model  page 363 nlme =======================
ex <- "ex4_nlme_page363"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
method <- "ML"
cat("\nVariable sigma; estimation method ", method,"\n")
t1.ML.nlme <- nlme(conc ~ SSfol(Dose, Time, lKe, lKa, lCl), data = Theoph,
                   fixed = lKe + lKa + lCl ~ 1,
                   method = method, start = c(-2.4,0.45,-3.2))
## default control, no fixed sigma
t1.ML.nlme$numIter # 23 (32-bit)
stopifnot(all.equal(as.vector(t1.ML.nlme$sigma), 0.6818253, tol = 1e-5))

sigma <- 0.7
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
set.seed(44)
system.time(# *not* fast :
t1.fix.ML.nlme <- nlme(conc ~ SSfol(Dose, Time, lKe, lKa, lCl), data = Theoph,
                       fixed = lKe + lKa + lCl ~ 1,
                       method = method, start = c(-2.4,0.45,-3.2),
                       control = nlmeControl(sigma=sigma, maxIter = 200),
                       verbose = interactive())
)
t1.fix.ML.nlme$numIter # 58 or 61 (and now 22)..
(sM4 <- summary(t1.fix.ML.nlme))
(aM4 <- anova  (t1.fix.ML.nlme))
t1.fix.ML.nlme$apVar ## "Non-positive definite approximate variance-covariance"
##(iM4 <- intervals(t1.fix.ML.nlme))
stopifnot(
    all.equal(fixef(t1.fix.ML.nlme),
              c(lKe = -2.432512, lKa = 0.450163, lCl = -3.2144713), tol= 8e-6)
    ,
    all.equal(sM4$tTable[,"Std.Error"],
              c(lKe = 0.0640155, lKa = 0.196058, lCl = 0.0808379), tol = 5e-5)
    ,
    all.equal(aM4[,"F-value"],
              c(65.439, 9.09557, 1581.21), tol = 5e-5)
)

##
##   REML method
if(doExtras()) { ## -- takes 2--3 minutes
method <- "REML"
sigma <- 0.7
cat("\nFixed sigma= ", sigma,"  estimation method ", method,"\n")
##
## only converges when tolerance is not small (and still takes long!) :
t1.fix.REML.nlme <- update(t1.fix.ML.nlme, method = method,
                           control = nlmeControl(tolerance = 0.0005,
                                                 sigma=sigma,
                                                 pnlsMaxIter = 20, # not just 7
                                                 maxIter = 1000),
                           verbose = interactive())
cat(" -> numIter: ", t1.fix.REML.nlme$numIter, "\n") # 380 or so
print(summary(t1.fix.REML.nlme))
print( anova(t1.fix.REML.nlme))
it1.fRn <- try( intervals(t1.fix.REML.nlme) ) ## cannot get .. Non-positive ...
}# only if(doExtras())

cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 5  mixed non-linear  model  page 358 nlme =======================
##
##
ex <- "ex5_nlme_page365"; .pt <- proc.time()
cat("\n example ", ex,"\n")
##
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t5.fix.ML.nlme <- nlme(circumference ~ SSlogis(age,Asym,xmid,scal), data = Orange,
                       fixed = Asym + xmid + scal ~ 1,
                       method = method, start = c(192,727,356),
                       control = nlmeControl(sigma = sigma))
(sM5 <- summary(t5.fix.ML.nlme))
(aM5 <- anova  (t5.fix.ML.nlme))
(t5.fix.ML.nlme$apVar) ## Non-positive definite  [FIXME?]
stopifnot(
    all.equal(fixef(t5.fix.ML.nlme),
              c(Asym= 192.79023, xmid= 726.36351, scal= 355.62941), tol= 1e-7)
    ,
    all.equal(sM5$tTable[,"Std.Error"],
              c(Asym= 14.1688, xmid= 35.3425, scal=16.3637), tol = 5e-5)
    ,
    all.equal(aM5[,"F-value"],
              c(4879.5, 208.534, 472.316), tol = 5e-5)
)

## REML method
method <-"REML"
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t5.fix.REML.nlme <- update(t5.fix.ML.nlme, method = method,
                           control = nlmeControl(sigma=sigma),
                           verbose = interactive())
## converges very quickly (when started from ML!)
(sR5 <- summary(t5.fix.REML.nlme))
(aR5 <- anova  (t5.fix.REML.nlme))
(               t5.fix.REML.nlme$apVar) ## Non-positive definite  [FIXME?]
stopifnot(
    ## ML and REML : fixed effects are very close
    all.equal(fixef(t5.fix.REML.nlme), fixef(t5.fix.ML.nlme), tol = 1e-6)
    ,
    all.equal(sR5$tTable[,"Std.Error"],
              c(Asym= 13.548, xmid= 33.794, scal=15.6467), tol = 5e-5)
    ,
    all.equal(aR5[,"F-value"],
              c(5336.29, 228.076, 516.594), tol = 5e-5)
)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 6  linear mixed model page 177  lme ML  and REML ================
##
ex <- "ex6_lme_page177"; .pt <- proc.time()
cat("\n example ", ex,"\n")
##
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t6.fix.ML.lme <- lme(distance ~ I(age-11), data = Orthodont,
                     weights = varIdent(form = ~1 | Sex),
                     method = method,
                     control = lmeControl(sigma = sigma))
(sM6 <-  summary (t6.fix.ML.lme))
(aM6 <-   anova  (t6.fix.ML.lme))
(iM6 <- intervals(t6.fix.ML.lme))
stopifnot(
    all.equal(fixef(t6.fix.ML.lme),
              c("(Intercept)"= 24.009565, "I(age - 11)"= 0.64760432), tol= 1e-7)
    ,
    all.equal(sM6$tTable[,"Std.Error"],
              c("(Intercept)"= 0.426561, "I(age - 11)"= 0.066832), tol = 5e-5)
    ,
    all.equal(aM6[,"F-value"], c(3162.47, 93.8969), tol = 5e-5)
    ,
    all.equal(iM6$varStruct["Female",],   ## Win 32
	      c(lower = 0.51230063,       ## 0.51226722
		est.  = 0.65065925,       ## 0.65065925
		upper = 0.82638482),      ## 0.82643872
	      tol = if(isSun) 4e-4 else 6e-5)#= 4.39e-5
    ## seen 5.35e-5 (Sparc Sol., no long double);  later, 6e-5 was not ok
    ## Windows 64bit w/ openblas 0.2.18 gave 5.721e-05 (Avi A)
)

##-------------
method <- "REML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")

t6.fix.REML.lme <- lme(distance ~I(age-11), data = Orthodont,
                       weights = varIdent(form = ~1 | Sex),
                       method = method,
                       control = lmeControl(sigma = sigma))
(sR6 <-  summary (t6.fix.REML.lme))
(aR6 <-   anova  (t6.fix.REML.lme))
(iR6 <- intervals(t6.fix.REML.lme))
stopifnot(
    all.equal(fixef(t6.fix.REML.lme),
              c("(Intercept)"= 24.010662, "I(age - 11)"= 0.64879966), tol= 1e-7)
    ,
    all.equal(sR6$tTable[,"Std.Error"],
              c("(Intercept)"= 0.436365, "I(age - 11)"= 0.0687549), tol = 5e-5)
    ,
    all.equal(aR6[,"F-value"], c(3019.86, 89.046), tol = 5e-5)
    ,
    all.equal(iR6$varStruct["Female",],  ## Win 32
	      c(lower = 0.51774671,      ## 0.51778038
		est.  = 0.66087796,      ## 0.66087807
		upper = 0.8435779),      ## 0.84352331
              tol = if(isSun) 4e-4 else 5e-5)# 4.37e-5
)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 7  linear mixed model page 172  lme ML  and REML ================
ex <- "ex7_lme_page172"; .pt <- proc.time()

cat("\n example ", ex,"\n")
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
set.seed(107)
t7.fix.ML.lme <- lme( current ~ voltage + I(voltage^2), data = Wafer,
                     random = list(Wafer = pdDiag(~voltage + I(voltage^2)),
                                   Site  = pdDiag(~voltage + I(voltage^2)) ),
                     method = method,
                     control = lmeControl(sigma = 1,
                                          ## nlminb: false convergence on 32-bit
                                          msVerbose = TRUE, opt = "optim"))
(ss7 <- summary(t7.fix.ML.lme))
(aa7 <- anova(t7.fix.ML.lme))
stopifnot(
    all.equal(fixef(t7.fix.ML.lme),
              c("(Intercept)" = -4.4611657, "voltage" = 5.9033709,
                "I(voltage^2)" = 1.1704027), tol = 1e-7)
    ,
    all.equal(ss7$tTable[,"Std.Error"],
              c("(Intercept)" = 0.446086, "voltage" = 0.608571,
                "I(voltage^2)"= 0.187459), tol = 5e-5)
    ,
    all.equal(aa7[,"F-value"],
              c(2634.2137, 8851.0513, 38.981463), tol = 5e-5)
          )
##------------------------------------------------------ REML ---
method <- "REML"
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t7.fix.REML.lme <- lme( current ~voltage + I(voltage^2), data = Wafer,
                       random = list(Wafer = pdDiag(~voltage + I(voltage^2)),
                                     Site  = pdDiag(~voltage + I(voltage^2)) ),
                       control = lmeControl(sigma = 1),
                       method = method)
(sR7 <- summary(t7.fix.REML.lme))
(aR7 <-   anova(t7.fix.REML.lme))
stopifnot(
    all.equal(fixef(t7.fix.REML.lme), fixef(t7.fix.ML.lme),
              ## should not change much from ML to REML !
              tol = 1e-6)
    ,
    all.equal(sR7$tTable[,"Std.Error"],
              c("(Intercept)" = 0.44441, "voltage" = 0.606321,
                "I(voltage^2)"= 0.186754), tol = 5e-5)
    ,
    all.equal(aR7[,"F-value"],
              c(2575.3253, 8880.9144, 39.276122), tol = 1e-6)
          )
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 8  mixed non-linear  model  page 364 nlme =======================
##
ex <- "ex8_nlme_page364"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
set.seed(8^2)
t8.fix.ML.nlme <- nlme(conc ~ SSfol(Dose, Time, lKe, lKa, lCl), data = Theoph,
                       fixed = lKe + lKa + lCl ~ 1,
                       random = pdDiag(lKe + lKa + lCl ~ 1),
                       method = method, start = c(-2.4,0.5,-3.3),
                       control = nlmeControl(sigma = 1))
(sM8 <- summary(t8.fix.ML.nlme))
(aM8 <- anova  (t8.fix.ML.nlme))
stopifnot(
    all.equal(fixef(t8.fix.ML.nlme),
              c(lKe = -2.4554999, lKa = 0.44870292, lCl = -3.2296957),
              tol = 1e-7)
    ,
    all.equal(sM8$tTable[,"Std.Error"],
              c(lKe = 0.0739269, lKa = 0.197524, lCl = 0.0683049),
              tol = 5e-5)
    ,
    all.equal(aM8[,"F-value"],
              c(10.9426, 17.4101, 2235.73), tol = 5e-5)
          )
##   REML method
method <- "REML"
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t8.fix.REML.nlme <- update(t8.fix.ML.nlme, method = method)
(sR8 <- summary(t8.fix.REML.nlme))
(aR8 <- anova  (t8.fix.REML.nlme))
stopifnot(
    all.equal(fixef(t8.fix.REML.nlme), fixef(t8.fix.ML.nlme),
              ## should not change much from ML to REML !
              tol = 1e-6)
    ,
    all.equal(sR8$tTable[,"Std.Error"],
              c(lKe = 0.073082, lKa = 0.195266, lCl = 0.0675243),
              tol = 5e-5)
    ,
    all.equal(aR8[,"F-value"],
              c(11.1971, 17.815, 2287.72), tol = 5e-5)
)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")

##===   example 9  mixed non-linear  model  page 365 nlme =======================
##
ex <- "ex9_nlme_page365"; .pt <- proc.time()
##
cat("\n example ", ex,"\n")
method <- "ML"
sigma <- 1
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
set.seed(909)
t9.fix.ML.nlme <- nlme(conc ~ SSfol(Dose, Time, lKe, lKa, lCl), data = Theoph,
                       fixed = lKe + lKa + lCl ~ 1,
                       random = pdDiag( lKa + lCl ~ 1),
                       method = method, start = c(-2.4,0.5,-3.3),
                       control = nlmeControl(sigma = 1))
(sM9 <- summary(t9.fix.ML.nlme))
(aM9 <- anova  (t9.fix.ML.nlme))
stopifnot(
    all.equal(fixef(t9.fix.ML.nlme),
              c(lKe = -2.4555745, lKa = 0.44894103, lCl = -3.2297273),
              tol = 1e-7)
    ,
    all.equal(sM9$tTable[,"Std.Error"],
              c(lKe = 0.0739266, lKa = 0.197459, lCl = 0.0683082),
              tol = 5e-5)
    ,
    all.equal(aM9[,"F-value"],
              c(10.9669, 17.4108, 2235.56), tol = 5e-5)
          )
##   REML method
method <- "REML"
cat("\nFixed sigma= ",sigma,"  estimation method ", method,"\n")
t9.fix.REML.nlme <- update(t9.fix.ML.nlme, method = method)
(sR9 <- summary(t9.fix.REML.nlme))
(aR9 <- anova  (t9.fix.REML.nlme))
stopifnot(
    all.equal(fixef(t9.fix.REML.nlme), fixef(t9.fix.ML.nlme),
              ## should not change much from ML to REML !
              tol = 1e-6)
    ,
    all.equal(sR9$tTable[,"Std.Error"],
              c(lKe = 0.0730817, lKa = 0.195202, lCl = 0.0675275),
              tol = 5e-5)
    ,
    all.equal(aR9[,"F-value"],
              c(11.2219, 17.8157, 2287.55), tol = 5e-5)
)
cat("Time elapsed: ", (proc.time() - .pt)[1:3], "\n")
