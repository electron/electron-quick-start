### R code from vignette source 'usercode.Rnw'

###################################################
### code chunk number 1: usercode.Rnw:26-28
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(5.1, 4.1, .3, 1.1))))


###################################################
### code chunk number 2: usercode.Rnw:85-99
###################################################
itemp <- function(y, offset, parms, wt) {
    if (is.matrix(y) && ncol(y) > 1)
       stop("Matrix response not allowed")
    if (!missing(parms) && length(parms) > 0)
        warning("parameter argument ignored")
    if (length(offset)) y <- y - offset
    sfun <- function(yval, dev, wt, ylevel, digits ) {
		  paste("  mean=", format(signif(yval, digits)),
			", MSE=" , format(signif(dev/wt, digits)),
			sep = '')
    }
    environment(sfun) <- .GlobalEnv
    list(y = c(y), parms = NULL, numresp = 1, numy = 1, summary = sfun)
}


###################################################
### code chunk number 3: usercode.Rnw:155-163
###################################################
temp <- 4
fun1 <- function(x) {
    q <- 15
    z <- 10
    fun2 <- function(y) y + z + temp
    fun2(x^2)
}
fun1(5)


###################################################
### code chunk number 4: usercode.Rnw:194-199
###################################################
etemp <- function(y, wt, parms) {
    wmean <- sum(y*wt)/sum(wt)
    rss <- sum(wt*(y-wmean)^2)
    list(label = wmean, deviance = rss)
}


###################################################
### code chunk number 5: usercode.Rnw:249-284
###################################################
stemp <- function(y, wt, x, parms, continuous)
{
    # Center y
    n <- length(y)
    y <- y- sum(y*wt)/sum(wt)

    if (continuous) {
        # continuous x variable
        temp <- cumsum(y*wt)[-n]
        left.wt  <- cumsum(wt)[-n]
        right.wt <- sum(wt) - left.wt
        lmean <- temp/left.wt
        rmean <- -temp/right.wt
        goodness <- (left.wt*lmean^2 + right.wt*rmean^2)/sum(wt*y^2)
        list(goodness = goodness, direction = sign(lmean))
    } else {
        # Categorical X variable
        ux <- sort(unique(x))
        wtsum <- tapply(wt, x, sum)
        ysum  <- tapply(y*wt, x, sum)
        means <- ysum/wtsum

        # For anova splits, we can order the categories by their means
        #  then use the same code as for a non-categorical
        ord <- order(means)
        n <- length(ord)
        temp <- cumsum(ysum[ord])[-n]
        left.wt  <- cumsum(wtsum[ord])[-n]
        right.wt <- sum(wt) - left.wt
        lmean <- temp/left.wt
        rmean <- -temp/right.wt
        list(goodness= (left.wt*lmean^2 + right.wt*rmean^2)/sum(wt*y^2),
             direction = ux[ord])
    }
}


###################################################
### code chunk number 6: usercode.Rnw:327-342
###################################################
library(rpart)
mystate <- data.frame(state.x77, region=state.region)
names(mystate) <- casefold(names(mystate)) #remove mixed case
ulist <- list(eval = etemp, split = stemp, init = itemp)
fit1 <- rpart(murder ~ population + illiteracy + income + life.exp +
              hs.grad + frost + region, data = mystate,
              method = ulist, minsplit = 10)
fit2 <- rpart(murder ~ population + illiteracy + income + life.exp +
              hs.grad + frost + region, data = mystate,
              method = 'anova', minsplit = 10, xval = 0)
all.equal(fit1$frame, fit2$frame)
all.equal(fit1$splits, fit2$splits)
all.equal(fit1$csplit, fit2$csplit)
all.equal(fit1$where, fit2$where)
all.equal(fit1$cptable, fit2$cptable)


###################################################
### code chunk number 7: usercode.Rnw:358-369
###################################################
xgroup <- rep(1:10, length = nrow(mystate))
xfit <- xpred.rpart(fit1, xgroup)
xerror <- colMeans((xfit - mystate$murder)^2)

fit2b <-  rpart(murder ~ population + illiteracy + income + life.exp +
                hs.grad + frost + region, data = mystate,
                method = 'anova', minsplit = 10, xval = xgroup)
topnode.error <- (fit2b$frame$dev/fit2b$frame$wt)[1]

xerror.relative <- xerror/topnode.error
all.equal(xerror.relative, fit2b$cptable[, 4], check.attributes = FALSE)


###################################################
### code chunk number 8: fig1
###################################################
getOption("SweaveHooks")[["fig"]]()
tdata <- mystate[order(mystate$illiteracy), ]
n <- nrow(tdata)
temp <- stemp(tdata$income, wt = rep(1, n), tdata$illiteracy,
              parms = NULL, continuous = TRUE)
xx <- (tdata$illiteracy[-1] + tdata$illiteracy[-n])/2
plot(xx, temp$goodness, xlab = "Illiteracy cutpoint",
     ylab = "Goodness of split")
lines(smooth.spline(xx, temp$goodness, df = 4), lwd = 2, lty = 2)


###################################################
### code chunk number 9: usercode.Rnw:438-458
###################################################
loginit <- function(y, offset, parms, wt)
{
    if (is.null(offset)) offset <- 0
    if (any(y != 0 & y != 1)) stop ('response must be 0/1')

    sfun <- function(yval, dev, wt, ylevel, digits ) {
		  paste("events=",  round(yval[,1]),
			", coef= ", format(signif(yval[,2], digits)),
			", deviance=" , format(signif(dev, digits)),
			sep = '')}
    environment(sfun) <- .GlobalEnv
    list(y = cbind(y, offset), parms = 0, numresp = 2, numy = 2,
         summary = sfun)
    }

logeval <- function(y, wt, parms)
{
    tfit <- glm(y[,1] ~ offset(y[,2]), binomial, weight = wt)
    list(label= c(sum(y[,1]), tfit$coef), deviance = tfit$deviance)
}


###################################################
### code chunk number 10: usercode.Rnw:466-502
###################################################
logsplit <- function(y, wt, x, parms, continuous)
{
    if (continuous) {
	# continuous x variable: do all the logistic regressions
	n <- nrow(y)
	goodness <- double(n-1)
	direction <- goodness
	temp <- rep(0, n)
	for (i in 1:(n-1)) {
	    temp[i] <- 1
            if (x[i] != x[i+1]) {
                tfit <- glm(y[,1] ~ temp + offset(y[,2]), binomial, weight = wt)
                goodness[i] <- tfit$null.deviance - tfit$deviance
                direction[i] <- sign(tfit$coef[2])
            }
        }
    } else {
	# Categorical X variable
	# First, find out what order to put the categories in, which
	#  will be the order of the coefficients in this model
	tfit <- glm(y[,1] ~ factor(x) + offset(y[,2]) - 1, binomial, weight = wt)
	ngrp <- length(tfit$coef)
	direction <- rank(rank(tfit$coef) + runif(ngrp, 0, 0.1)) #break ties
        # breaking ties -- if 2 groups have exactly the same p-hat, it
        #  does not matter which order I consider them in.  And the calling
        #  routine wants an ordering vector.
        #
	xx <- direction[match(x, sort(unique(x)))] #relabel from small to large
	goodness <- double(length(direction) - 1)
	for (i in 1:length(goodness)) {
	    tfit <- glm(y[,1] ~ I(xx > i) + offset(y[,2]), binomial, weight = wt)
	    goodness[i] <- tfit$null.deviance - tfit$deviance
        }
    }
    list(goodness=goodness, direction=direction)
}


