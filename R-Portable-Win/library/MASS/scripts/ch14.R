#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 14   Time Series

library(MASS)
pdf(file="ch14.pdf", width=8, height=6, pointsize=9)
options(width=65, digits=5)

lh
deaths
#tspar(deaths)
tsp(deaths)
start(deaths)
end(deaths)
frequency(deaths)
cycle(deaths)
ts.plot(lh)
ts.plot(deaths, mdeaths, fdeaths,
        lty = c(1, 3, 4), xlab = "year", ylab = "deaths")

aggregate(deaths, 4, sum)
aggregate(deaths, 1, mean)


# 14.1  Second-order summaries

acf(lh)
acf(lh, type = "covariance")
acf(deaths)
acf(ts.union(mdeaths, fdeaths))

par(mfrow = c(2, 2))
spectrum(lh)
spectrum(deaths)

par(mfrow = c(2, 2))
spectrum(lh)
spectrum(lh, spans = 3)
spectrum(lh, spans = c(3, 3))
spectrum(lh, spans = c(3, 5))

spectrum(deaths)
spectrum(deaths, spans = c(3, 3))
spectrum(deaths, spans = c(3, 5))
spectrum(deaths, spans = c(5, 7))

par(mfrow = c(1, 2))
cpgram(lh)
cpgram(deaths)
par(mfrow = c(1, 1))


# 14.2  ARIMA models


# ts.sim <- arima.sim(list(order = c(1,1,0), ar = 0.7), n = 200)

acf(lh, type = "partial")
acf(deaths, type = "partial")

lh.ar1 <- ar(lh, FALSE, 1)
cpgram(lh.ar1$resid, main = "AR(1) fit to lh")
lh.ar <- ar(lh, order.max = 9)
lh.ar$order
lh.ar$aic
cpgram(lh.ar$resid, main = "AR(3) fit to lh")

(lh.arima1 <- arima(lh, order = c(1,0,0)))
tsdiag(lh.arima1)
(lh.arima3 <- arima(lh, order = c(3,0,0)))
tsdiag(lh.arima3)
(lh.arima11 <- arima(lh, order = c(1,0,1)))

lh.fore <- predict(lh.arima3, 12)
ts.plot(lh, lh.fore$pred, lh.fore$pred + 2*lh.fore$se,
        lh.fore$pred - 2*lh.fore$se, lty = c(1,2,3,3))


# 14.3  Seasonality

deaths.stl <- stl(deaths, "periodic")
dsd <-  deaths.stl$time.series[, "trend"] +
    deaths.stl$time.series[, "remainder"]
#ts.plot(deaths, deaths.stl$sea, deaths.stl$rem)
ts.plot(deaths, deaths.stl$time.series[, "seasonal"], dsd,
        gpars = list(lty = c(1, 3, 2)))

par(mfrow = c(2, 3))
#dsd <- deaths.stl$rem
ts.plot(dsd)

acf(dsd)
acf(dsd, type = "partial")
spectrum(dsd, span = c(3, 3))
cpgram(dsd)
dsd.ar <- ar(dsd)
dsd.ar$order
dsd.ar$aic
dsd.ar$ar
cpgram(dsd.ar$resid, main = "AR(1) residuals")
par(mfrow = c(1, 1))

deaths.diff <- diff(deaths, 12)
acf(deaths.diff, 30)
acf(deaths.diff, 30, type = "partial")
ar(deaths.diff)
# this suggests the seasonal effect is still present.
(deaths.arima1 <- arima(deaths, order = c(2,0,0),
     seasonal = list(order = c(0,1,0), period = 12)) )
tsdiag(deaths.arima1, gof.lag = 30)
# suggests need a seasonal AR term
(deaths.arima2 <- arima(deaths, order = c(2,0,0),
     list(order = c(1,0,0), period = 12)) )
tsdiag(deaths.arima2, gof.lag = 30)
cpgram(deaths.arima2$resid)
(deaths.arima3 <- arima(deaths, order = c(2,0,0),
    list(order = c(1,1,0), period = 12)) )
tsdiag(deaths.arima3, gof.lag = 30)

par(mfrow = c(3, 1))
nott <- window(nottem, end = c(1936, 12))
ts.plot(nott)
nott.stl <- stl(nott, "period")
ts.plot(nott.stl$time.series[, c("remainder", "seasonal")],
        gpars = list(ylim  =  c(-15, 15), lty = c(1, 3)))
nott.stl <- stl(nott, 5)
ts.plot(nott.stl$time.series[, c("remainder", "seasonal")],
        ylim  =  c(-15, 15), lty = c(1, 3))

par(mfrow = c(1, 1))
boxplot(split(nott, cycle(nott)), names = month.abb)

nott[110] <- 35
nott.stl <- stl(nott, "period")
nott1 <- nott.stl$time.series[, "trend"] + nott.stl$time.series[, "remainder"]
acf(nott1)
acf(nott1, type = "partial")
cpgram(nott1)
ar(nott1)$aic
plot(0:23, ar(nott1)$aic, xlab = "order", ylab = "AIC",
     main = "AIC for AR(p)")
(nott1.ar1 <- arima(nott1, order = c(1,0,0)))
nott1.fore <- predict(nott1.ar1, 36)
nott1.fore$pred <- nott1.fore$pred +
    as.vector(nott.stl$time.series[1:36, "seasonal"])
ts.plot(window(nottem, 1937), nott1.fore$pred,
        nott1.fore$pred+2*nott1.fore$se,
        nott1.fore$pred-2*nott1.fore$se, lty = c(3, 1, 2, 2))
title("via Seasonal Decomposition")

acf(diff(nott,12), 30)
acf(diff(nott,12), 30, type = "partial")
cpgram(diff(nott, 12))
(nott.arima1 <- arima(nott, order = c(1,0,0),
     list(order = c(2,1,0), period = 12)) )
tsdiag(nott.arima1, gof.lag = 30)
(nott.arima2 <- arima(nott, order = c(0,0,2),
      list(order = c(0,1,2), period = 12)) )
tsdiag(nott.arima2, gof.lag = 30)
(nott.arima3 <- arima(nott, order = c(1,0,0),
      list(order = c(0,1,2), period = 12)) )
tsdiag(nott.arima3, gof.lag = 30)

nott.fore <- predict(nott.arima3, 36)
ts.plot(window(nottem, 1937), nott.fore$pred,
        nott.fore$pred+2*nott.fore$se,
        nott.fore$pred-2*nott.fore$se, lty = c(3, 1, 2, 2))
title("via Seasonal ARIMA model")


# 14.6  Regression with autocorrelated errors

attach(beav1)
beav1$hours <- 24*(day-346) + trunc(time/100) + (time%%100)/60
detach()
attach(beav2)
beav2$hours <- 24*(day-307) + trunc(time/100) + (time%%100)/60
detach()
par(mfrow = c(2, 2))
plot(beav1$hours, beav1$temp, type = "l", xlab = "time",
     ylab = "temperature", main = "Beaver 1")
usr <- par("usr"); usr[3:4] <- c(-0.2, 8); par(usr = usr)
lines(beav1$hours, beav1$activ, type = "s", lty = 2)
plot(beav2$hours, beav2$temp, type = "l", xlab = "time",
     ylab = "temperature", main = "Beaver 2")
usr <- par("usr"); usr[3:4] <- c(-0.2, 8); par(usr = usr)
lines(beav2$hours, beav2$activ, type = "s", lty = 2)

attach(beav2)
temp2 <- ts(temp, start = 8+2/3, frequency = 6)
activ2 <- ts(activ, start = 8+2/3, frequency = 6)
acf(temp2[activ2 == 0])
acf(temp2[activ2 == 1]) # also look at PACFs
acf(temp2[activ2 == 0], type = "partial")
acf(temp2[activ2 == 1], type = "partial")
ar(temp2[activ2 == 0])
ar(temp2[activ2 == 1])
par(mfrow = c(1, 1))
detach()
rm(temp2, activ2)

library(nlme)
beav2.gls <- gls(temp ~ activ, data = beav2,
                 corr = corAR1(0.8), method = "ML")
summary(beav2.gls)
summary(update(beav2.gls, subset = 6:100))

arima(beav2$temp, c(1,0,0), xreg = beav2$activ)

attach(beav1)
temp1 <- ts(c(temp[1:82], NA, temp[83:114]), start = 9.5, frequency = 6)
activ1 <- ts(c(activ[1:82], NA, activ[83:114]), start = 9.5, frequency = 6)
acf(temp1[1:53])
acf(temp1[1:53], type = "partial")
ar(temp1[1:53])

act <- c(rep(0, 10), activ1)
beav1b <- data.frame(Time = time(temp1), temp = as.vector(temp1),
           act = act[11:125], act1 = act[10:124],
           act2 = act[9:123], act3 = act[8:122])
detach()
rm(temp1, activ1)

summary(gls(temp ~ act + act1 + act2 + act3,
            data = beav1b, na.action = na.omit,
            corr = corCAR1(0.82^6, ~Time), method = "ML"))

arima(beav1b$temp, c(1, 0, 0), xreg = beav1b[, 3:6])


# 14.6  Models for financial time series

plot(SP500, type = "l", xlab = "", ylab = "returns (%)", xaxt = "n", las = 1)
axis(1, at = c(0, 254, 507, 761, 1014, 1266, 1518, 1772, 2025, 2277,
        2529, 2781), lab = 1990:2001)

plot(density(SP500, width = "sj", n = 256), type = "l", xlab = "", ylab = "")

par(pty = "s")
qqnorm(SP500)
qqline(SP500)
if(FALSE) {
    module(garch)
    summary(garch(SP500 ~ 1, ~garch(1,1)))

    fit <- garch(SP500 ~ 1, ~garch(1,1), cond.dist = "t")
    summary(fit)
    plot(fit)

    summary(garch(SP500 ~ 1, ~egarch(1,1), cond.dist = "t", leverage = TRUE))
}

if(require(tseries))
    print(summary(garch(x = SP500 - median(SP500), order = c(1, 1))))

# End of ch14
