#-*- R -*-

library(nlme)
pdf(file = 'ch01.pdf')
options( width = 65, digits = 5 )
options( contrasts = c(unordered = "contr.helmert", ordered = "contr.poly") )

# Chapter 1    Linear Mixed-Effects Models: Basic Concepts and Examples

# 1.1 A Simple Example of Random Effects

Rail
fm1Rail.lm <- lm( travel ~ 1, data = Rail )
fm1Rail.lm
fm2Rail.lm <- lm( travel ~ Rail - 1, data = Rail )
fm2Rail.lm
fm1Rail.lme <- lme(travel ~ 1, data = Rail, random = ~ 1 | Rail)
summary( fm1Rail.lme )
fm1Rail.lmeML <- update( fm1Rail.lme, method = "ML" )
summary( fm1Rail.lmeML )
plot( fm1Rail.lme )   # produces Figure 1.4
intervals( fm1Rail.lme )
anova( fm1Rail.lme )

# 1.2 A Randomized Block Design

plot.design( ergoStool )   # produces Figure 1.6
contrasts( ergoStool$Type )
ergoStool1 <- ergoStool[ ergoStool$Subject == "1", ]
model.matrix( effort ~ Type, ergoStool1 )   # X matrix for Subject 1
fm1Stool <-
  lme(effort ~ Type, data = ergoStool, random = ~ 1 | Subject)
summary( fm1Stool )
anova( fm1Stool )
options( contrasts = c( factor = "contr.treatment",
                        ordered = "contr.poly" ) )
contrasts( ergoStool$Type )
fm2Stool <-
  lme(effort ~ Type, data = ergoStool, random = ~ 1 | Subject)
summary( fm2Stool )
anova( fm2Stool )
model.matrix( effort ~ Type - 1, ergoStool1 )
fm3Stool <-
 lme(effort ~ Type - 1, data = ergoStool, random = ~ 1 | Subject)
summary( fm3Stool )
anova( fm3Stool )
intervals( fm1Stool )
plot( fm1Stool,   # produces Figure 1.8
      form = resid(., type = "p") ~ fitted(.) | Subject,
      abline = 0 )

# 1.3  Mixed-effects Models for Replicated, Blocked Designs

with(Machines, interaction.plot( Machine, Worker, score, las = 1))   # Figure 1.10
fm1Machine <-
  lme( score ~ Machine, data = Machines, random = ~ 1 | Worker )
fm1Machine
fm2Machine <- update( fm1Machine, random = ~ 1 | Worker/Machine )
fm2Machine
anova( fm1Machine, fm2Machine )
  ## delete selected rows from the Machines data
MachinesUnbal <- Machines[ -c(2,3,6,8,9,12,19,20,27,33), ]
  ## check that the result is indeed unbalanced
table(MachinesUnbal$Machine, MachinesUnbal$Worker)
fm1MachinesU <- lme( score ~ Machine, data = MachinesUnbal,
  random = ~ 1 | Worker/Machine )
fm1MachinesU
intervals( fm1MachinesU )
fm4Stool <- lme( effort ~ Type, ergoStool, ~ 1 | Subject/Type )
if (interactive()) intervals( fm4Stool )
(fm1Stool$sigma)^2
(fm4Stool$sigma)^2 + 0.79621^2
Machine1 <- Machines[ Machines$Worker == "1", ]
model.matrix( score ~ Machine, Machine1 )   # fixed-effects X_i
model.matrix( ~ Machine - 1, Machine1 )   # random-effects Z_i
fm3Machine <- update( fm1Machine, random = ~Machine - 1 |Worker)
summary( fm3Machine )
anova( fm1Machine, fm2Machine, fm3Machine )

# 1.4 An Analysis of Covariance Model

names( Orthodont )
levels( Orthodont$Sex )
OrthoFem <- Orthodont[ Orthodont$Sex == "Female", ]
fm1OrthF.lis <- lmList( distance ~ age, data = OrthoFem )
coef( fm1OrthF.lis )
intervals( fm1OrthF.lis )
plot( intervals ( fm1OrthF.lis ) )   # produces Figure 1.12
fm2OrthF.lis <- update( fm1OrthF.lis, distance ~ I( age - 11 ) )
plot( intervals( fm2OrthF.lis ) )    # produces Figure 1.13
fm1OrthF <-
  lme( distance ~ age, data = OrthoFem, random = ~ 1 | Subject )
summary( fm1OrthF )
fm1OrthFM <- update( fm1OrthF, method = "ML" )
summary( fm1OrthFM )
fm2OrthF <- update( fm1OrthF, random = ~ age | Subject )
anova( fm1OrthF, fm2OrthF )
random.effects( fm1OrthF )
ranef( fm1OrthFM )
coef( fm1OrthF )
plot( compareFits(coef(fm1OrthF), coef(fm1OrthFM)))   # Figure 1.15
plot( augPred(fm1OrthF), aspect = "xy", grid = TRUE )   # Figure 1.16

# 1.5  Models for Nested Classification Factors

fm1Pixel <- lme( pixel ~ day + I(day^2), data = Pixel,
  random = list( Dog = ~ day, Side = ~ 1 ) )
intervals( fm1Pixel )
plot( augPred( fm1Pixel ) )   # produces Figure 1.18
VarCorr( fm1Pixel )
summary( fm1Pixel )
fm2Pixel <- update( fm1Pixel, random = ~ day | Dog)
anova( fm1Pixel, fm2Pixel )
fm3Pixel <- update( fm1Pixel, random = ~ 1 | Dog/Side )
anova( fm1Pixel, fm3Pixel )
fm4Pixel <- update( fm1Pixel, pixel ~ day + I(day^2) + Side )
summary( fm4Pixel )

# 1.6  A Split-Plot Experiment

fm1Oats <- lme( yield ~ ordered(nitro) * Variety, data = Oats,
  random = ~ 1 | Block/Variety )
anova( fm1Oats )
fm2Oats <- update( fm1Oats, yield ~ ordered(nitro) + Variety )
anova( fm2Oats )
summary( fm2Oats )
fm3Oats <- update( fm1Oats, yield ~ ordered( nitro ) )
summary( fm3Oats )
fm4Oats <-
  lme( yield ~ nitro, data = Oats, random = ~ 1 | Block/Variety )
summary( fm4Oats )
VarCorr( fm4Oats )
intervals( fm4Oats )
plot(augPred(fm4Oats), aspect = 2.5, layout = c(6, 3),
     between = list(x = c(0, 0, 0.5, 0, 0))) # produces Figure 1.21

# cleanup

proc.time()


