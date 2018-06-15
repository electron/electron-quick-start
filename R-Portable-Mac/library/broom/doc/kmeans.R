## ---- echo=FALSE---------------------------------------------------------
library(knitr)
opts_chunk$set(message=FALSE, warning=FALSE)

## ------------------------------------------------------------------------
library(dplyr)

set.seed(2014)
centers <- data.frame(cluster=factor(1:3), size=c(100, 150, 50), x1=c(5, 0, -3), x2=c(-1, 1, -2))
points <- centers %>% group_by(cluster) %>%
    do(data.frame(x1=rnorm(.$size[1], .$x1[1]),
                  x2=rnorm(.$size[1], .$x2[1])))

library(ggplot2)
ggplot(points, aes(x1, x2, color=cluster)) + geom_point()

## ------------------------------------------------------------------------
points.matrix <- cbind(x1 = points$x1, x2 = points$x2)
kclust <- kmeans(points.matrix, 3)
kclust
summary(kclust)

## ------------------------------------------------------------------------
library(broom)
head(augment(kclust, points.matrix))

## ------------------------------------------------------------------------
tidy(kclust)

## ------------------------------------------------------------------------
glance(kclust)

## ------------------------------------------------------------------------
kclusts <- data.frame(k=1:9) %>% group_by(k) %>% do(kclust=kmeans(points.matrix, .$k))

## ------------------------------------------------------------------------
clusters <- kclusts %>%
    group_by(k) %>%
    do(tidy(.$kclust[[1]]))

assignments <- kclusts %>%
    group_by(k) %>%
    do(augment(.$kclust[[1]], points.matrix))

clusterings <- kclusts %>%
    group_by(k) %>%
    do(glance(.$kclust[[1]]))

## ------------------------------------------------------------------------
p1 <- ggplot(assignments, aes(x1, x2)) +
    geom_point(aes(color=.cluster)) +
    facet_wrap(~ k)

p1

## ------------------------------------------------------------------------
p2 <- p1 +
    geom_point(data = clusters, size = 10, shape = "x")

p2

## ------------------------------------------------------------------------
ggplot(clusterings, aes(k, tot.withinss)) + geom_line()

