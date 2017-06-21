#-*- R -*-

library( nlme )
options( width = 65, digits = 5 )
options( contrasts = c(unordered = "contr.helmert",
         ordered = "contr.poly") )
pdf( file = 'ch02.pdf' )

# Chapter 2    Theory and Computational Methods for Linear Mixed-Effects Models

# 2.2   Likelihood Estimation for LME Models

Xmat <- matrix( c(1, 1, 1, 1, 8, 10, 12, 14), ncol = 2 )
Xmat
Xqr <- qr( Xmat )               # creates a QR structure
qr.R( Xqr )                     # returns R
qr.Q( Xqr )                     # returns Q-truncated
qr.Q( Xqr, complete = TRUE )    # returns the full Q

fm1Rail.lme <- lme( travel ~ 1, data = Rail, random = ~ 1 | Rail,
       control = list( msVerbose = TRUE ) )
fm1Rail.lme <- lme( travel ~ 1, data = Rail, random = ~ 1 | Rail,
   control = list( msVerbose = TRUE, niterEM = 0 ))

fm1Machine <-
  lme( score ~ Machine, data = Machines, random = ~ 1 | Worker )
fm2Machine <- update( fm1Machine, random = ~ 1 | Worker/Machine )
anova( fm1Machine, fm2Machine )

OrthoFem <- Orthodont[ Orthodont$Sex == "Female", ]
fm1OrthF <- lme( distance ~ age, data = OrthoFem,
    random = ~ 1 | Subject )
fm2OrthF <- update( fm1OrthF, random = ~ age | Subject )
orthLRTsim <- simulate.lme( fm1OrthF, m2 = fm2OrthF, nsim = 1000 )
plot( orthLRTsim, df = c(1, 2) )    # produces Figure 2.3

machineLRTsim <- simulate.lme(fm1Machine, m2 = fm2Machine, nsim= 1000)
plot( machineLRTsim, df = c(0, 1),      # produces Figure 2.4
 layout = c(4,1), between = list(x = c(0, 0.5, 0)) )

stoolLRTsim <-
  simulate.lme( list(fixed = effort ~ 1, data = ergoStool,
                     random = ~ 1 | Subject),
                m2 = list(fixed = effort ~ Type),
                method = "ML", nsim = 1000 )
plot( stoolLRTsim, df = c(3, 4) )    # Figure 2.5
data( PBIB, package = 'SASmixed' )
pbibLRTsim <-
    simulate.lme(list( fixed = response ~ 1, data = PBIB,
                       random = ~ 1 | Block ),
                 m2 = list(fixed = response ~ Treatment, data = PBIB,
                           random = ~ 1 | Block),
                 method = "ML", nsim = 1000 )
plot( pbibLRTsim, df = c(14,16,18), weights = FALSE )    # Figure 2.6

summary( fm2Machine )

fm1PBIB <- lme(response ~ Treatment, data = PBIB, random = ~ 1 | Block)
anova( fm1PBIB )
fm2PBIB <- update( fm1PBIB, method = "ML" )
fm3PBIB <- update( fm2PBIB, response ~ 1 )
anova( fm2PBIB, fm3PBIB )
anova( fm2Machine )

# cleanup

proc.time()

