# http://stackoverflow.com/questions/16032858
library(tidyr)
library(dplyr)

results <- data.frame(
  Ind = paste0("Ind", 1:10),
  Treatment = rep(c("Treat", "Cont"), each = 10),
  value = 1:20
)

results %>% spread(Treatment, value)
