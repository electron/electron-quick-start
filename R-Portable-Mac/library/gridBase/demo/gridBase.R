
# A base plot with grid viewports synchronised then
# further grid viewports pushed to contain pie charts

x <- runif(4)
y <- runif(4)
z <- matrix(runif(4*2), ncol=2)

maxpiesize <- unit(1, "inches")
totals <- apply(z, 1, sum)
sizemult <- totals/max(totals)

oldomi <- par("omi")
plot(x, y, xlim=c(-0.2, 1.2), ylim=c(-0.2, 1.2), type="n")
vps <- baseViewports()
# First grid action will trigger a new page unless we do this
# Should be able to avoid this yuckiness in the future
par(new=TRUE)
pushViewport(vps$inner, vps$figure, vps$plot)
grid.grill(h=y, v=x, default.units="native")
for (i in 1:4) {
  pushViewport(viewport(x=unit(x[i], "native"),
                         y=unit(y[i], "native"),
                         width=sizemult[i]*maxpiesize,
                         height=sizemult[i]*maxpiesize))
  grid.rect(gp=gpar(col="grey", fill="white", lty="dashed"))
  par(mar=rep(0, 4), omi=gridOMI(), new=TRUE)
  pie(z[i,], radius=1, labels=rep("", 2))
  popViewport()
}
popViewport(3)
par(omi=rep(0, 4), mar=c(5.1, 5.1, 4.1, 2.1))
