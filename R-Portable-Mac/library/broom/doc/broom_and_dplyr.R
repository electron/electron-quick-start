## ----opts_chunk, echo=FALSE----------------------------------------------
library(knitr)
opts_chunk$set(message=FALSE, warning=FALSE)

## ----setup---------------------------------------------------------------
library(broom)
library(dplyr)
data(Orange)

dim(Orange)
head(Orange)

## ------------------------------------------------------------------------
cor(Orange$age, Orange$circumference)

library(ggplot2)
ggplot(Orange, aes(age, circumference, color = Tree)) + geom_line()

## ------------------------------------------------------------------------
Orange %>% group_by(Tree) %>% summarize(correlation = cor(age, circumference))

## ------------------------------------------------------------------------
cor.test(Orange$age, Orange$circumference)

## ------------------------------------------------------------------------
Orange %>% group_by(Tree) %>% do(tidy(cor.test(.$age, .$circumference)))

## ------------------------------------------------------------------------
Orange %>% group_by(Tree) %>% do(tidy(lm(age ~ circumference, data=.)))

## ------------------------------------------------------------------------
data(mtcars)
head(mtcars)
mtcars %>% group_by(am) %>% do(tidy(lm(wt ~ mpg + qsec + gear, .)))

## ------------------------------------------------------------------------
regressions <- mtcars %>% group_by(cyl) %>%
    do(fit = lm(wt ~ mpg + qsec + gear, .))
regressions

## ------------------------------------------------------------------------
regressions %>% tidy(fit)
regressions %>% augment(fit)
regressions %>% glance(fit)

