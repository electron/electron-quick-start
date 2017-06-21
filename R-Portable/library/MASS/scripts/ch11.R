#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 11   Exploratory Multivariate Analysis

library(MASS)
pdf(file="ch11.pdf", width=8, height=6, pointsize=9)
options(width=65, digits=5)


# 11.1  Visualization methods

# ir <- rbind(iris[,,1], iris[,,2], iris[,,3])
ir <- rbind(iris3[,,1], iris3[,,2], iris3[,,3])
ir.species <- factor(c(rep("s", 50), rep("c", 50), rep("v", 50)))
(ir.pca <- princomp(log(ir), cor = TRUE))
summary(ir.pca)
plot(ir.pca)
ir.pc <- predict(ir.pca)
eqscplot(ir.pc[, 1:2], type = "n",
    xlab = "first principal component",
    ylab = "second principal component")
text(ir.pc[, 1:2], labels = as.character(ir.species),
     col = 3 + unclass(ir.species))

lcrabs <- log(crabs[, 4:8])
crabs.grp <- factor(c("B", "b", "O", "o")[rep(1:4, each = 50)])
(lcrabs.pca <- princomp(lcrabs))
loadings(lcrabs.pca)
lcrabs.pc <- predict(lcrabs.pca)
dimnames(lcrabs.pc) <- list(NULL, paste("PC", 1:5, sep = ""))

if(FALSE) { # needs interaction with XGobi, or, better, rggobi
library(xgobi)
xgobi(lcrabs, colors = c("SkyBlue", "SlateBlue", "Orange",
     "Red")[rep(1:4, each = 50)])
xgobi(lcrabs, glyphs = 12 + 5*rep(0:3, each = 50, 4))

library(rggobi)
g <- ggobi(lcrabs)
d <- displays(g)[[1]]
pmode(d) <- "2D Tour"
crabs.grp <- factor(c("B", "b", "O", "o")[rep(1:4, each = 50)])
glyph_colour(g$lcrabs) <- crabs.grp
colorscheme(g) <- "Paired 4"
}

ir.scal <- cmdscale(dist(ir), k = 2, eig = TRUE)
ir.scal$points[, 2] <- -ir.scal$points[, 2]
eqscplot(ir.scal$points, type = "n")
text(ir.scal$points, labels = as.character(ir.species),
     col = 3 + unclass(ir.species), cex = 0.8)

distp <- dist(ir)
dist2 <- dist(ir.scal$points)
sum((distp - dist2)^2)/sum(distp^2)

ir.sam <- sammon(dist(ir[-143,]))
eqscplot(ir.sam$points, type = "n")
text(ir.sam$points, labels = as.character(ir.species[-143]),
     col = 3 + unclass(ir.species), cex = 0.8)

ir.iso <- isoMDS(dist(ir[-143,]))
eqscplot(ir.iso$points, type = "n")
text(ir.iso$points, labels = as.character(ir.species[-143]),
     col = 3 + unclass(ir.species), cex = 0.8)

cr.scale <- 0.5 * log(crabs$CL * crabs$CW)
slcrabs <- lcrabs - cr.scale
cr.means <- matrix(0, 2, 5)
cr.means[1,] <- colMeans(slcrabs[crabs$sex == "F", ])
cr.means[2,] <- colMeans(slcrabs[crabs$sex == "M", ])
dslcrabs <- slcrabs - cr.means[as.numeric(crabs$sex), ]
lcrabs.sam <- sammon(dist(dslcrabs))
eqscplot(lcrabs.sam$points, type = "n", xlab = "", ylab = "")
text(lcrabs.sam$points, labels = as.character(crabs.grp))

fgl.iso <- isoMDS(dist(as.matrix(fgl[-40, -10])))
eqscplot(fgl.iso$points, type = "n", xlab = "", ylab = "", axes = FALSE)
# either
# for(i in seq(along = levels(fgl$type))) {
#   set <- fgl$type[-40] == levels(fgl$type)[i]
#   points(fgl.iso$points[set,], pch = 18, cex = 0.6, col = 2 + i)}
# key(text = list(levels(fgl$type), col = 3:8))
# or
text(fgl.iso$points,
     labels = c("F", "N", "V", "C", "T", "H")[fgl$type[-40]],
     cex = 0.6)
fgl.iso3 <- isoMDS(dist(as.matrix(fgl[-40, -10])), k = 3)
# S: brush(fgl.iso3$points)
fgl.col <- c("SkyBlue", "SlateBlue", "Orange", "Orchid",
             "Green", "HotPink")[fgl$type]
# xgobi(fgl.iso3$points, colors = fgl.col)

library(class)
gr <- somgrid(topo = "hexagonal")
crabs.som <- batchSOM(lcrabs, gr, c(4, 4, 2, 2, 1, 1, 1, 0, 0))
plot(crabs.som)

bins <- as.numeric(knn1(crabs.som$code, lcrabs, 0:47))
plot(crabs.som$grid, type = "n")
symbols(crabs.som$grid$pts[, 1], crabs.som$grid$pts[, 2],
        circles = rep(0.4, 48), inches = FALSE, add = TRUE)
text(crabs.som$grid$pts[bins, ] + rnorm(400, 0, 0.1),
     as.character(crabs.grp))

crabs.som2 <- SOM(lcrabs, gr); plot(crabs.som2)

state <- state.x77[, 2:7]; row.names(state) <- state.abb
biplot(princomp(state, cor = TRUE), pc.biplot = TRUE, cex = 0.7,
       expand = 0.8)

library(fastICA)
nICA <- 4
crabs.ica <- fastICA(crabs[, 4:8], nICA)
Z <- crabs.ica$S
par(mfrow = c(2, nICA))
for(i in 1:nICA) boxplot(Z[, i] ~ crabs.grp)
par(mfrow = c(1, 1))


# S: stars(state.x77[, c(7, 4, 6, 2, 5, 3)], byrow = TRUE)
stars(state.x77[, c(7, 4, 6, 2, 5, 3)])

parcoord(state.x77[, c(7, 4, 6, 2, 5, 3)])
parcoord(log(ir)[, c(3, 4, 2, 1)], col = 1 + (0:149)%/%50)


# 11.2   Cluster analysis

swiss.x <- as.matrix(swiss[,-1])
library(cluster)
# S: h <- hclust(dist(swiss.x), method = "connected")
h <- hclust(dist(swiss.x), method = "single")
plot(h)
cutree(h, 3)
# S: plclust( clorder(h, cutree(h, 3) ))

pltree(diana(swiss.x))
par(mfrow = c(1, 1))

h <- hclust(dist(swiss.x), method = "average")
initial <- tapply(swiss.x, list(rep(cutree(h, 3),
  ncol(swiss.x)), col(swiss.x)), mean)
dimnames(initial) <- list(NULL, dimnames(swiss.x)[[2]])
km <- kmeans(swiss.x, initial)
(swiss.pca <- princomp(swiss.x))
swiss.px <- predict(swiss.pca)
dimnames(km$centers)[[2]] <- dimnames(swiss.x)[[2]]
swiss.centers <- predict(swiss.pca, km$centers)
eqscplot(swiss.px[, 1:2], type = "n",
         xlab = "first principal component",
         ylab = "second principal component")
text(swiss.px[, 1:2], labels = km$cluster)
points(swiss.centers[,1:2], pch = 3, cex = 3)
if(interactive()) identify(swiss.px[, 1:2], cex = 0.5)

swiss.pam <- pam(swiss.px, 3)
summary(swiss.pam)
eqscplot(swiss.px[, 1:2], type = "n",
         xlab = "first principal component",
         ylab = "second principal component")
text(swiss.px[,1:2], labels = swiss.pam$clustering)
points(swiss.pam$medoid[,1:2], pch = 3, cex = 3)

fanny(swiss.px, 3)

## From the on-line Errata:
##
##   `The authors of mclust have chosen to re-use the name for a
##   completely incompatible package.  We can no longer recommend its
##   use, and the code given in the first printing does not work in R's
##   mclust-2.x.'
##

## And later mclust was given a restrictive licence, so this example
## has been removed.  Finally in 2012 it was given an OpenSource licence.


# 11.3 Factor analysis

ability.FA <- factanal(covmat = ability.cov, factors = 1)
ability.FA
(ability.FA <- update(ability.FA, factors = 2))
#summary(ability.FA)
round(loadings(ability.FA) %*% t(loadings(ability.FA)) +
           diag(ability.FA$uniq), 3)

if(require("GPArotation")) {
# loadings(rotate(ability.FA, rotation = "oblimin"))
    L <- loadings(ability.FA)
    print(oblirot <- oblimin(L))
    par(pty = "s")
    eqscplot(L, xlim = c(0,1), ylim = c(0,1))
    if(interactive()) identify(L, dimnames(L)[[1]])
    naxes <- oblirot$Th
    arrows(rep(0, 2), rep(0, 2), naxes[,1], naxes[,2])
}


# 11.4 Discrete multivariate analysis

caith <- as.matrix(caith)
names(dimnames(caith)) <- c("eyes", "hair")
mosaicplot(caith, color = TRUE)
House <- xtabs(Freq ~ Type + Infl + Cont + Sat, housing)
mosaicplot(House, color = TRUE)

corresp(caith)

caith2 <- caith
dimnames(caith2)[[2]] <- c("F", "R", "M", "D", "B")
par(mfcol = c(1, 3))
plot(corresp(caith2, nf = 2)); title("symmetric")
plot(corresp(caith2, nf = 2), type = "rows"); title("rows")
plot(corresp(caith2, nf = 2), type = "col"); title("columns")
par(mfrow = c(1, 1))

farms.mca <- mca(farms, abbrev = TRUE)  # Use levels as names
plot(farms.mca, cex = rep(0.7, 2))

# End of ch11
