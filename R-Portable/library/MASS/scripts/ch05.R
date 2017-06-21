#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 5   Univariate Statistics

# for later use, from section 5.6
perm.t.test <- function(d) {
# ttest is function(x) mean(x)/sqrt(var(x)/length(x))
    binary.v <- function(x, digits) {
       if(missing(digits)) {
           mx <- max(x)
           digits <- if(mx > 0) 1 + floor(log(mx, base = 2)) else 1
       }
       ans <- 0:(digits - 1)
       lx <- length(x)
       x <- rep(x, rep(digits, lx))
       x <- (x %/% 2^ans) %% 2
       dim(x) <- c(digits, lx)
       x
    }
    digits <- length(d)
    n <- 2^digits
    x <- d * 2 * (binary.v(1:n, digits) - 0.5)
    mx <- matrix(1/digits, 1, digits) %*% x
    s <- matrix(1/(digits - 1), 1, digits)
    vx <- s %*% (x - matrix(mx, digits, n, byrow=TRUE))^2
    as.vector(mx/sqrt(vx/digits))
}

library(MASS)
options(width=65, digits=5, height=9999)
library(lattice)
pdf(file="ch05.pdf", width=8, height=6, pointsize=9)

rm(A, B) # precautionary clear-out
attach(shoes)
tperm <- perm.t.test(B - A) # see section 5.6
detach()

# from ch04
if(!exists("fgl.df")) {
fgl0 <- fgl[ ,-10] # omit type.
fgl.df <- data.frame(type = rep(fgl$type, 9),
  y = as.vector(as.matrix(fgl0)),
  meas = factor(rep(1:9, each = 214), labels = names(fgl0)))
  invisible()
}


# 5.1  Probability distributions


x <- rt(250, df = 9)
par(pty = "s")
qqnorm(x)
qqline(x)
par(pty = "m")

x <- rgamma(100, shape = 5, rate = 0.1)
fitdistr(x, "gamma")
x2 <- rt(250, df = 9)
fitdistr(x2, "t", df = 9)
fitdistr(x2, "t")


# 5.2  Generating random data

contam <- rnorm( 100, 0, (1 + 2*rbinom(100, 1, 0.05)) )


# 5.3  Data summaries

par(mfrow=c(2,3))
hist(geyser$duration, "scott", xlab="duration")
hist(chem, "scott")
hist(tperm, "scott")
hist(geyser$duration, "FD", xlab="duration")
hist(chem, "FD")
hist(tperm, "FD")
par(mfrow=c(1,1))

swiss.fertility <- swiss[, 1]
stem(swiss.fertility)
stem(chem)
stem(abbey)
stem(abbey, scale = 0.4) ## use scale = 0.4 in R


par(mfrow = c(1,2))
boxplot(chem, sub = "chem", range = 0.5)
boxplot(abbey, sub = "abbey")
par(mfrow = c(1,1))

bwplot(type ~ y | meas, data = fgl.df, scales = list(x="free"),
  strip = function(...) strip.default(..., style=1), xlab = "")


# 5.4  Classical univariate statistics

attach(shoes)
t.test(A, mu = 10)
t.test(A)$conf.int

wilcox.test(A, mu = 10)

var.test(A, B)

t.test(A, B, var.equal = TRUE)

t.test(A, B, var.equal = FALSE)

wilcox.test(A, B)

t.test(A, B, paired = TRUE)

wilcox.test(A, B, paired = TRUE)
detach()

par(mfrow = c(1, 2))
truehist(tperm, xlab = "diff")
x <- seq(-4,4, 0.1)
lines(x, dt(x,9))
#cdf.compare(tperm, distribution = "t", df = 9)
sres <- c(sort(tperm), 4)
yres <- (0:1024)/1024
plot(sres, yres, type="S", xlab="diff", ylab="")
lines(x, pt(x,9), lty=3)

legend(-5, 1.05, c("Permutation dsn","t_9 cdf"), lty = c(1,3))
par(mfrow = c(1, 1))


# 5.5  Robust summaries

# Figure 5.7 was obtained by
x <- seq(-10, 10, len=500)
y <- dt(x, 25, log = TRUE)
z <- -diff(y)/diff(x)
plot(x[-1], z, type = "l", xlab = "", ylab = "psi")
y2 <-  dt(x, 5, log = TRUE)
z2 <- -diff(y2)/diff(x)
lines(x[-1], z2, lty = 2)


sort(chem)
mean(chem)
median(chem)
#location.m(chem)
#location.m(chem, psi.fun="huber")
mad(chem)
#scale.tau(chem)
#scale.tau(chem, center=3.68)
unlist(huber(chem))
unlist(hubers(chem))
fitdistr(chem, "t", list(m = 3, s = 0.5), df = 5)

sort(abbey)
mean(abbey)
median(abbey)
#location.m(abbey)
#location.m(abbey, psi.fun="huber")
unlist(hubers(abbey))
unlist(hubers(abbey, k = 2))
unlist(hubers(abbey, k = 1))
fitdistr(abbey, "t", list(m = 12, s = 5), df = 10)


# 5.6  Density estimation

# Figure 5.8
attach(geyser)
par(mfrow=c(2,3))
truehist(duration, h=0.5, x0=0.0, xlim=c(0, 6), ymax=0.7)
truehist(duration, h=0.5, x0=0.1, xlim=c(0, 6), ymax=0.7)
truehist(duration, h=0.5, x0=0.2, xlim=c(0, 6), ymax=0.7)
truehist(duration, h=0.5, x0=0.3, xlim=c(0, 6), ymax=0.7)
truehist(duration, h=0.5, x0=0.4, xlim=c(0, 6), ymax=0.7)

breaks <- seq(0, 5.9, 0.1)
counts <- numeric(length(breaks))
for(i in (0:4)) counts[i+(1:55)] <- counts[i+(1:55)] +
    rep(hist(duration, breaks=0.1*i + seq(0, 5.5, 0.5),
    prob=TRUE, plot=FALSE)$density, rep(5,11))
plot(breaks+0.05, counts/5, type="l", xlab="duration",
    ylab="averaged", bty="n", xlim=c(0, 6), ylim=c(0, 0.7))
detach()


attach(geyser)
truehist(duration, nbins = 15, xlim = c(0.5, 6), ymax = 1.2)
lines(density(duration, width = "nrd"))

truehist(duration, nbins = 15, xlim = c(0.5, 6), ymax = 1.2)
lines(density(duration, width = "SJ", n = 256), lty = 3)
lines(density(duration, n = 256, width = "SJ-dpi"), lty = 1)
detach()

gal <- galaxies/1000
plot(x = c(0, 40), y = c(0, 0.3), type = "n", bty = "l",
    xlab = "velocity of galaxy (1000km/s)", ylab = "density")
rug(gal)
lines(density(gal, width = "SJ-dpi", n = 256), lty = 1)
lines(density(gal, width = "SJ", n = 256), lty = 3)
library(polspline)
x <- seq(5, 40, length = 500)
lines(x, doldlogspline(x, oldlogspline(gal)), lty = 2)


geyser2 <- data.frame(as.data.frame(geyser)[-1, ],
                      pduration = geyser$duration[-299])
attach(geyser2)
par(mfrow = c(2, 2))
plot(pduration, waiting, xlim = c(0.5, 6), ylim = c(40, 110),
   xlab = "previous duration", ylab = "waiting")
f1 <- kde2d(pduration, waiting, n = 50, lims=c(0.5, 6, 40, 110))
image(f1, zlim = c(0, 0.075),
     xlab = "previous duration", ylab = "waiting")
f2 <- kde2d(pduration, waiting, n = 50, lims=c(0.5, 6, 40, 110),
  h = c(width.SJ(duration), width.SJ(waiting)) )
image(f2, zlim = c(0, 0.075),
      xlab = "previous duration", ylab = "waiting")
persp(f2,  phi = 30, theta = 20, d = 5,
      xlab = "previous duration", ylab = "waiting", zlab = "")
detach()

density(gal, n = 1, from = 20.833, to = 20.834, width = "SJ")$y
1/(2 * sqrt(length(gal)) * 0.13)

set.seed(101)
m <- 1000
res <- numeric(m)
for (i in 1:m) res[i] <- median(sample(gal, replace = TRUE))
mean(res - median(gal))
sqrt(var(res))

truehist(res, h = 0.1)
lines(density(res, width = "SJ-dpi", n = 256))
quantile(res, p = c(0.025, 0.975))
x <- seq(19.5, 22.5, length = 500)
lines(x, doldlogspline(x, oldlogspline(res)), lty = 3)

library(boot)
set.seed(101)
gal.boot <- boot(gal, function(x, i) median(x[i]), R = 1000)
gal.boot

boot.ci(gal.boot, conf = c(0.90, 0.95),
         type = c("norm","basic","perc","bca"))
plot(gal.boot)

if(FALSE) { # bootstrap() is an S-PLUS function
gal.bt <- bootstrap(gal, median, seed = 101, B = 1000)
summary(gal.bt)
plot(gal.bt)
qqnorm(gal.bt)

limits.emp(gal.bt)
limits.bca(gal.bt)
}

sim.gen  <- function(data, mle) {
 n <- length(data)
 data[sample(n, replace = TRUE)]  + mle*rnorm(n)
}
gal.boot2 <- boot(gal, median, R = 1000,
 sim = "parametric", ran.gen = sim.gen, mle = 0.5)
boot.ci(gal.boot2, conf = c(0.90, 0.95),
         type = c("norm","basic","perc"))

attach(shoes)
t.test(B - A)
shoes.boot <- boot(B - A, function(x,i) mean(x[i]), R = 1000)
boot.ci(shoes.boot, type = c("norm", "basic", "perc", "bca"))
mean.fun <- function(d, i) {
 n <- length(i)
 c(mean(d[i]), (n-1)*var(d[i])/n^2)
}
shoes.boot2 <- boot(B - A, mean.fun, R = 1000)
boot.ci(shoes.boot2, type = "stud")
detach()

# End of ch05
