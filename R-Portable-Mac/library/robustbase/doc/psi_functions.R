### R code from vignette source 'psi_functions.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: init
###################################################
# set margins for plots
options(SweaveHooks=list(fig=function() par(mar=c(3,3,1.4,0.7),
                         mgp=c(1.5, 0.5, 0))))
## x axis for plots:
x. <- seq(-5, 10, length=1501)
require(robustbase)


###################################################
### code chunk number 2: source-p-psiFun
###################################################
source(system.file("xtraR/plot-psiFun.R", package = "robustbase", mustWork=TRUE))


###################################################
### code chunk number 3: Huber
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(huberPsi, x., ylim=c(-1.4, 5), leg.loc="topright", main=FALSE)


###################################################
### code chunk number 4: lmrob-psi
###################################################
names(.Mpsi.tuning.defaults)


###################################################
### code chunk number 5: tuning-defaults
###################################################
print(c(k.M = .Mpsi.tuning.default("bisquare"),
        k.S = .Mchi.tuning.default("bisquare")), digits = 10)


###################################################
### code chunk number 6: note-p-psiFun (eval = FALSE)
###################################################
getOption("SweaveHooks")[["fig"]]()
## source(system.file("xtraR/plot-psiFun.R", package = "robustbase", mustWork=TRUE))


###################################################
### code chunk number 7: bisquare
###################################################
getOption("SweaveHooks")[["fig"]]()
p.psiFun(x., "biweight", par = 4.685)


###################################################
### code chunk number 8: Hampel
###################################################
getOption("SweaveHooks")[["fig"]]()
## see also hampelPsi
p.psiFun(x., "Hampel", par = ## Default, but rounded:
                             round(c(1.5, 3.5, 8) * 0.9016085, 1))


###################################################
### code chunk number 9: GGW-const
###################################################
cT <- rbind(cc1 = .psi.ggw.findc(ms = -0.5, b = 1.5, eff = 0.95        ),
            cc2 = .psi.ggw.findc(ms = -0.5, b = 1.5,          bp = 0.50)); cT


###################################################
### code chunk number 10: rhoInf-ggw
###################################################
ipsi.ggw <- .psi2ipsi("GGW") # = 5
ccc <- c(0, cT[1, 2:4], 1)
integrate(.Mpsi, 0, Inf, ccc=ccc, ipsi=ipsi.ggw)$value # = rho(Inf)


###################################################
### code chunk number 11: GGW
###################################################
getOption("SweaveHooks")[["fig"]]()
p.psiFun(x., "GGW", par = c(-.5, 1, .95, NA))


###################################################
### code chunk number 12: lqq-const
###################################################
cT <- rbind(cc1 = .psi.lqq.findc(ms= -0.5, b.c = 1.5, eff=0.95, bp=NA ),
            cc2 = .psi.lqq.findc(ms= -0.5, b.c = 1.5, eff=NA , bp=0.50))
colnames(cT) <- c("b", "c", "s"); cT


###################################################
### code chunk number 13: LQQ
###################################################
getOption("SweaveHooks")[["fig"]]()
p.psiFun(x., "LQQ", par = c(-.5,1.5,.95,NA))


###################################################
### code chunk number 14: optimal
###################################################
getOption("SweaveHooks")[["fig"]]()
p.psiFun(x., "optimal", par = 1.06, leg.loc="bottomright")


###################################################
### code chunk number 15: Welsh-GGW
###################################################
ccc <- c(0, a = 2.11^2, b = 2, c = 0, 1)
(ccc[5] <- integrate(.Mpsi, 0, Inf, ccc=ccc, ipsi = 5)$value) # = rho(Inf)
stopifnot(all.equal(Mpsi(x., ccc,  "GGW"),   ## psi[ GGW ](x; a=k^2, b=2, c=0) ==
                    Mpsi(x., 2.11, "Welsh")))## psi[Welsh](x; k)


###################################################
### code chunk number 16: Welsh
###################################################
getOption("SweaveHooks")[["fig"]]()
p.psiFun(x., "Welsh", par = 2.11)


