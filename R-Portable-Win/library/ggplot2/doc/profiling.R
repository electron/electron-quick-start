## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(ggplot2)
library(profvis)

p <- ggplot(mtcars, aes(x = mpg, y = disp)) + 
  geom_point() + 
  facet_grid(gear ~ cyl)

profile <- profvis(for (i in seq_len(100)) ggplotGrob(p))

profile

## ---- eval=FALSE, include=FALSE------------------------------------------
#  saveRDS(profile, file.path('profilings', paste0(packageVersion('ggplot2'), '.rds')))

