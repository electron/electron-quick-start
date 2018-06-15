library(grid)

# Unit conversions
stopifnot(round(convertX(unit(1, "inches"), "inches", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(2.54, "cm"), "inches", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(25.4, "mm"), "inches", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(72.27, "points"), "inches", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(1/12*72.27, "picas"), "inches",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(72, "bigpts"), "inches", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(1157/1238*72.27, "dida"), "inches",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/12*1157/1238*72.27, "cicero"), "inches",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(65536*72.27, "scaledpts"), "inches",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/2.54, "inches"), "cm", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(1/25.4, "inches"), "mm", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(1/72.27, "inches"), "points",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/(1/12*72.27), "inches"), "picas",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/72, "inches"), "bigpts", valueOnly=TRUE) - 1,
                digits=5) == 0)
stopifnot(round(convertX(unit(1/(1157/1238*72.27), "inches"), "dida",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/(1/12*1157/1238*72.27), "inches"), "cicero",
                         valueOnly=TRUE) - 1, digits=5) == 0)
stopifnot(round(convertX(unit(1/(65536*72.27), "inches"), "scaledpts",
                         valueOnly=TRUE) - 1, digits=5) == 0)

pushViewport(viewport(width=unit(1, "inches"),
                       height=unit(2, "inches"),
                       xscale=c(0, 1),
                       yscale=c(1, 3)))
  ## Location versus dimension
stopifnot(round(convertY(unit(2, "native"), "inches", valueOnly=TRUE) -
                1, digits=5) == 0)
stopifnot(round(convertHeight(unit(2, "native"), "inches", valueOnly=TRUE) -
                2, digits=5) == 0)
  ## From "x" to "y" (the conversion is via "inches")
stopifnot(round(convertUnit(unit(1, "native"), "native",
                            axisFrom="x", axisTo="y", valueOnly=TRUE) -
                2, digits=5) == 0)
  ## Convert several values at once
stopifnot(all(round(convertX(unit(c(0.5, 2.54), c("npc", "cm")),
                             c("inches", "native"), valueOnly=TRUE) -
                    c(0.5, 1), digits=5) == 0))
popViewport()

# packing a frame inside a frame
fg <- frameGrob()
fg <- packGrob(fg, textGrob("Hi there"))

fg2 <- frameGrob()
fg2 <- packGrob(fg2, fg)
fg2 <- packGrob(fg2, rectGrob(), side="bottom")
fg2 <- packGrob(fg2, rectGrob(height=unit(1, "inches")), side="top")

stopifnot(convertHeight(fg2$framevp$layout$heights, "inches",
                        valueOnly=TRUE)[2] < 1)

# Regression tests for:

# A: grob[X|Y|Width|Height]

# B: grid.[circle|lines|segments|rect|polygon|text|xspline|points]

# C: at angles seq(0, 360, 45)[-1]

# D: single AND multiple output 

# In each casem, set up a situation where the answer is (easily) known,
# then compare the numeric answer

test <- function(x, y) {
    on.exit(cat(paste("x =", x, " ; y =", y, "\n")))
    stopifnot(isTRUE(all.equal(x, y)))
}

testX <- function(x1, x2) {
    test(convertX(x1, "inches", valueOnly=TRUE),
         convertX(x2, "inches", valueOnly=TRUE))
}

testY <- function(y1, y2) {
    test(convertY(y1, "inches", valueOnly=TRUE),
         convertY(y2, "inches", valueOnly=TRUE))
}

testWidth <- function(w1, w2) {
    test(convertWidth(w1, "inches", valueOnly=TRUE),
         convertWidth(w2, "inches", valueOnly=TRUE))
}

testHeight <- function(h1, h2) {
    test(convertHeight(h1, "inches", valueOnly=TRUE),
         convertHeight(h2, "inches", valueOnly=TRUE))
}

########
# CIRCLE
########
# A = X;  B = circle; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testX(grobX(circleGrob(r=unit(.5, "inches")), theta),
          unit(.5, "npc") + cos(theta/180*pi)*unit(.5, "inches"))
    # Bounding box is 1" by 1"
    testX(grobX(circleGrob(x=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                           y=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                           r=unit(.25, "inches")),
                theta),
          switch(as.character(theta),
                 "360"=, "315"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "180"=, "225"=,
                 "135"=unit(.5, "npc") - unit(.5, "inches"),
                 "90"=,
                 "270"=unit(.5, "npc")))
}

# A = Y;  B = circle; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testY(grobY(circleGrob(r=unit(.5, "inches")), theta),
          unit(.5, "npc") + sin(theta/180*pi)*unit(.5, "inches"))
    # Bounding box is 1" by 1"
    testY(grobY(circleGrob(x=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                           y=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                           r=unit(.25, "inches")),
                theta),
          switch(as.character(theta),
                 "90"=, "135"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "270"=, "315"=,
                 "225"=unit(.5, "npc") - unit(.5, "inches"),
                 "180"=,
                 "360"=unit(.5, "npc")))
}

# A = Width;  B = circle; C = ALL; D = BOTH
testWidth(grobWidth(circleGrob(r=unit(.5, "inches"))),
          unit(1, "inches"))
testWidth(grobWidth(circleGrob(x=unit(.5, "npc") +
                               unit(c(-.25, .25), "inches"),
                               y=unit(.5, "npc") +
                               unit(c(-.25, .25), "inches"),
                               r=unit(.25, "inches"))),
          unit(1, "inches"))          
                    
# A = Height;  B = circle; C = ALL; D = BOTH
testHeight(grobHeight(circleGrob(r=unit(.5, "inches"))),
          unit(1, "inches"))
testHeight(grobHeight(circleGrob(x=unit(.5, "npc") +
                                 unit(c(-.25, .25), "inches"),
                                 y=unit(.5, "npc") +
                                 unit(c(-.25, .25), "inches"),
                                 r=unit(.25, "inches"))),
           unit(1, "inches"))          
                    
########
# RECT
########
# A = X;  B = rect; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testX(grobX(rectGrob(width=unit(1, "inches"),
                         height=unit(1, "inches")), theta),
          switch(as.character(theta),
                 "360"=, "315"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "180"=, "225"=,
                 "135"=unit(.5, "npc") - unit(.5, "inches"),
                 "90"=,
                 "270"=unit(.5, "npc")))
    # Bounding box is 1" by 1"
    testX(grobX(rectGrob(x=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                         y=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                         width=unit(.5, "inches"),
                         height=unit(.5, "inches")),
                theta),
          switch(as.character(theta),
                 "360"=, "315"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "180"=, "225"=,
                 "135"=unit(.5, "npc") - unit(.5, "inches"),
                 "90"=,
                 "270"=unit(.5, "npc")))
}

# A = Y;  B = rect; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testY(grobY(rectGrob(width=unit(1, "inches"),
                         height=unit(1, "inches")), theta),
          switch(as.character(theta),
                 "90"=, "135"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "270"=, "315"=,
                 "225"=unit(.5, "npc") - unit(.5, "inches"),
                 "180"=,
                 "360"=unit(.5, "npc")))
    # Bounding box is 1" by 1"
    testY(grobY(rectGrob(x=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                         y=unit(.5, "npc") + unit(c(-.25, .25), "inches"),
                         width=unit(.5, "inches"),
                         height=unit(.5, "inches")),
                theta),
          switch(as.character(theta),
                 "90"=, "135"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "270"=, "315"=,
                 "225"=unit(.5, "npc") - unit(.5, "inches"),
                 "180"=,
                 "360"=unit(.5, "npc")))
}

# A = Width;  B = rect; C = ALL; D = BOTH
testWidth(grobWidth(rectGrob(width=unit(1, "inches"),
                             height=unit(1, "inches"))),
          unit(1, "inches"))
testWidth(grobWidth(rectGrob(x=unit(.5, "npc") +
                             unit(c(-.25, .25), "inches"),
                             y=unit(.5, "npc") +
                             unit(c(-.25, .25), "inches"),
                             width=unit(.5, "inches"),
                             height=unit(.5, "inches"))),
          unit(1, "inches"))          
                    
# A = Height;  B = rect; C = ALL; D = BOTH
testHeight(grobHeight(rectGrob(width=unit(1, "inches"),
                               height=unit(1, "inches"))),
           unit(1, "inches"))
testHeight(grobHeight(rectGrob(x=unit(.5, "npc") +
                               unit(c(-.25, .25), "inches"),
                               y=unit(.5, "npc") +
                               unit(c(-.25, .25), "inches"),
                               width=unit(.5, "inches"),
                               height=unit(.5, "inches"))),
           unit(1, "inches"))          
                    
########
# polygon
# Four locations in a diamond
########
# A = X;  B = polygon; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testX(grobX(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, 0, .5, 0), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(0, -.5, 0, .5), "inches")),
                theta),
          switch(as.character(theta),
                 "45"=,
                 "315"=unit(.5, "npc") + unit(.25, "inches"),
                 "90"=,
                 "270"=unit(.5, "npc"),
                 "135"=,
                 "225"=unit(.5, "npc") - unit(.25, "inches"),
                 "180"=unit(.5, "npc") - unit(.5, "inches"),
                 "360"=unit(.5, "npc") + unit(.5, "inches")))
    # NOTE:  for polygons, even if there are multiple polygons,
    # we still produce edge of hull for ALL points
    testX(grobX(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, -.25, 0, -.25,
                                   0, .25, .5, .25), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(-.25, -.5, -.25, 0,
                                   .25, 0, .25, .5), "inches"),
                            id=rep(1:2, each=4)),
                theta),
          switch(as.character(theta),
                 "45"=unit(.5, "npc") + unit(.375, "inches"),
                 "90"=unit(.5, "npc"),
                 "135"=unit(.5, "npc") - unit(.125, "inches"),
                 "180"=unit(.5, "npc") - unit(.25, "inches"),
                 "225"=unit(.5, "npc") - unit(.375, "inches"),
                 "270"=unit(.5, "npc"),
                 "315"=unit(.5, "npc") + unit(.125, "inches"),
                 "360"=unit(.5, "npc") + unit(.25, "inches")))
}

# A = Y;  B = polygon; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testY(grobY(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, 0, .5, 0), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(0, -.5, 0, .5), "inches")),
                theta),
          switch(as.character(theta),
                 "45"=,
                 "135"=unit(.5, "npc") + unit(.25, "inches"),
                 "90"=unit(.5, "npc") + unit(.5, "inches"),
                 "180"=,
                 "360"=unit(.5, "npc"),
                 "225"=,
                 "315"=unit(.5, "npc") - unit(.25, "inches"),
                 "270"=unit(.5, "npc") - unit(.5, "inches")))
    # NOTE:  for polygons, even if there are multiple polygons,
    # we still produce edge of hull for ALL points
    testY(grobY(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, -.25, 0, -.25,
                                   0, .25, .5, .25), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(-.25, -.5, -.25, 0,
                                   .25, 0, .25, .5), "inches"),
                            id=rep(1:2, each=4)),
                theta),
          switch(as.character(theta),
                 "45"=unit(.5, "npc") + unit(.375, "inches"),
                 "90"=unit(.5, "npc") + unit(.25, "inches"),
                 "135"=unit(.5, "npc") + unit(.125, "inches"),
                 "180"=unit(.5, "npc"),
                 "225"=unit(.5, "npc") - unit(.375, "inches"),
                 "270"=unit(.5, "npc") - unit(.25, "inches"),
                 "315"=unit(.5, "npc") - unit(.125, "inches"),
                 "360"=unit(.5, "npc")))
}

# A = Width;  B = polygon; C = ALL; D = BOTH
testWidth(grobWidth(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, 0, .5, 0), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(0, -.5, 0, .5), "inches"))),
          unit(1, "inches"))
testWidth(grobWidth(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, -.25, 0, -.25,
                                   0, .25, .5, .25), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(-.25, -.5, -.25, 0,
                                   .25, 0, .25, .5), "inches"),
                            id=rep(1:2, each=4))),
          unit(1, "inches"))          
                    
# A = Height;  B = polygon; C = ALL; D = BOTH
testHeight(grobHeight(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, 0, .5, 0), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(0, -.5, 0, .5), "inches"))),
          unit(1, "inches"))
testHeight(grobHeight(polygonGrob(x=unit(.5, "npc") +
                            unit(c(-.5, -.25, 0, -.25,
                                   0, .25, .5, .25), "inches"),
                            y=unit(.5, "npc") +
                            unit(c(-.25, -.5, -.25, 0,
                                   .25, 0, .25, .5), "inches"),
                            id=rep(1:2, each=4))),
           unit(1, "inches"))          
                    
########
# TEXT
########
# A = X;  B = text; C = ALL; D = BOTH
str <- "testcase"
strw <- stringWidth(str)
strh <- stringHeight(str)
for (theta in seq(0, 360, 45)[-1]) {
    testX(grobX(textGrob(str), theta),
          switch(as.character(theta),
                 "360"=unit(.5, "npc") + 0.5*strw,
                 "135"=,
                 "45"=unit(.5, "npc") + 1/tan(theta/180*pi)*0.5*strh,
                 "315"=,
                 "225"=unit(.5, "npc") - 1/tan(theta/180*pi)*0.5*strh,
                 "180"=unit(.5, "npc") - 0.5*strw,
                 "90"=,
                 "270"=unit(.5, "npc")))
    # Bounding box is 1" by 1"
    testX(grobX(textGrob(str,
                         x=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                         y=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                         hjust=c(0, 1), vjust=c(0, 1)),
                theta),
          switch(as.character(theta),
                 "360"=, "315"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "180"=, "225"=,
                 "135"=unit(.5, "npc") - unit(.5, "inches"),
                 "90"=,
                 "270"=unit(.5, "npc")))
}

# A = Y;  B = text; C = ALL; D = BOTH
for (theta in seq(0, 360, 45)[-1]) {
    testY(grobY(textGrob(str), theta),
          switch(as.character(theta),
                 "90"=, "135"=,
                 "45"=unit(.5, "npc") + 0.5*strh,
                 "270"=, "315"=,
                 "225"=unit(.5, "npc") - 0.5*strh,
                 "180"=,
                 "360"=unit(.5, "npc")))
    # Bounding box is 1" by 1"
    testY(grobY(textGrob(str,
                         x=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                         y=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                         hjust=c(0, 1), vjust=c(0, 1)),
                theta),
          switch(as.character(theta),
                 "90"=, "135"=,
                 "45"=unit(.5, "npc") + unit(.5, "inches"),
                 "270"=, "315"=,
                 "225"=unit(.5, "npc") - unit(.5, "inches"),
                 "180"=,
                 "360"=unit(.5, "npc")))
}

# A = Width;  B = text; C = ALL; D = BOTH
testWidth(grobWidth(textGrob(str)),
          strw)
testWidth(grobWidth(textGrob(str,
                             x=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                             y=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                             hjust=c(0, 1), vjust=c(0, 1))),
          unit(1, "inches"))          
                    
# A = Height;  B = text; C = ALL; D = BOTH
testHeight(grobHeight(textGrob(str)),
          strh)
testHeight(grobHeight(textGrob(str,
                               x=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                               y=unit(.5, "npc") + unit(c(-.5, .5), "inches"),
                               hjust=c(0, 1), vjust=c(0, 1))),
           unit(1, "inches"))

# Determining unit lengths
stopifnot(length(unit.c(unit(1, "npc") + unit(1, "cm"), unit(2, "cm"))) == 2)
stopifnot(length(unit.c(unit(1, "npc") + unit(1, "cm"), unit(2:4, "cm"))) == 4)
stopifnot(length(unit.c(unit(1:3, "npc") + unit(1, "cm"), unit(2:4, "cm"))) == 6)
