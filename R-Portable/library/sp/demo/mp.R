set.seed(1331)
cl1 = cbind(rnorm(3, 10), rnorm(3, 10))
cl2 = cbind(rnorm(5, 10), rnorm(5,  0))
cl3 = cbind(rnorm(7,  0), rnorm(7, 10))

library(sp)
mp = SpatialMultiPoints(list(cl1, cl2, cl3))
plot(mp, col = 2, cex = 1, pch = 1:3)
mp
mp[1:2]
as(mp, "SpatialPoints")
mp[0,]

print(mp, asWKT=TRUE, digits=3)

mpdf = SpatialMultiPointsDataFrame(list(cl1, cl2, cl3), data.frame(a = 1:3))
mpdf
print(mpdf, asWKT=TRUE, digits=3)
mpdf[0,]

plot(mpdf, col = mpdf$a, cex = 1:3)
as(mpdf, "data.frame")
mpdf[1:2,]
as(mpdf, "SpatialPointsDataFrame")

# aggregate SpatialPointsDataFrame to SpatialMultiPointsDataFrame:
demo(meuse, ask = FALSE, echo = FALSE)
a = aggregate(meuse[c("zinc", "lead")], list(meuse$ffreq))
spplot(a[c("zinc", "lead")])
