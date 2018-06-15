## ----setup, include=FALSE------------------------------------------------
library(knitr)
library(treemap)
set.seed(20151014)

## ------------------------------------------------------------------------
dat <- data.frame(letters=letters[1:26], x=1, y=runif(26)*16-4)

## ------------------------------------------------------------------------
treemap(dat, index="letters", vSize="x", vColor="y", type="value", palette="RdYlBu")

## ------------------------------------------------------------------------
treemap(dat, index="letters", vSize="x", vColor="y", type="value", palette="RdYlBu", range=c(-12,12), n = 9)

## ------------------------------------------------------------------------
treemap(dat, index="letters", vSize="x", vColor="y", type="manual", palette="RdYlBu")

## ------------------------------------------------------------------------
treemap(dat, index="letters", vSize="x", vColor="y", type="value", palette="RdYlBu", 
        mapping=c(-10, 10, 30))

## ------------------------------------------------------------------------
treemap(dat, index="letters", vSize="x", vColor="y", type="value", palette="RdYlBu", 
        mapping=c(-10, 10, 30), range=c(-10, 30))

