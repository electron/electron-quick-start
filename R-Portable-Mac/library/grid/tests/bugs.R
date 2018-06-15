library(grid)

# Physical units in viewport of height 0
pushViewport(viewport(h=0))
stopifnot(is.finite(convertHeight(unit(72, "bigpts"), "inches")))
popViewport()

# The gpar font settings for a grob should affect the grob itself
stopifnot(round(convertHeight(grobHeight(rectGrob(height=unit(1, "lines"), 
                                                  gp=gpar(lineheight=2))),
                              "inches", valueOnly=TRUE) -
                convertHeight(grobHeight(rectGrob(height=unit(1, "lines"),
                                                  vp=viewport(
                                                    gp=gpar(lineheight=2)))),
                              "inches", valueOnly=TRUE),
                digits=5) == 0)

# Calculation of size of packed grob with gp which is non-empty
gf1 <- frameGrob(gp=gpar(fontsize=20))
gf1 <- packGrob(gf1, textGrob("howdy"))
gf1 <- packGrob(gf1, rectGrob(), col=1, row=1)
gf2 <- frameGrob()
gf2 <- packGrob(gf2, gf1)
gf2 <- packGrob(gf2, rectGrob(gp=gpar(col="red")), col=1, row=1)
stopifnot(round(convertWidth(grobWidth(gf1),
                             "inches", valueOnly=TRUE) -
                convertWidth(grobWidth(gf2),
                             "inches", valueOnly=TRUE),
                digits=5) == 0)

